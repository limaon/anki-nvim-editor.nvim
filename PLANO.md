# Plano de Desenvolvimento: Anki Editor para Neovim

## Visão Geral

Plugin para Neovim que permite editar templates de cartas do Anki diretamente no editor, similar à extensão VSCode `anki-editor`, mas adaptado para o ecossistema Neovim/Lua.

### Objetivo Principal
Permitir que usuários editem templates do Anki (Front, Back e CSS) através de comandos do Neovim, com sincronização automática via Anki-Connect.

---

## Funcionalidades Principais

### MVP (Minimum Viable Product)
1. **Comando para listar e selecionar templates**
   - `:AnkiEdit` - Abre interface para selecionar tipo de nota e card
   - Lista todos os tipos de nota disponíveis
   - Permite selecionar card específico

2. **Abertura de buffers para edição**
   - Abre 3 buffers separados: Front, Back e Style
   - Buffers nomeados de forma clara (ex: `[Anki] Basic - Front`)
   - Filetype apropriado para cada buffer

3. **Sincronização com Anki**
   - Ao salvar (`:w`), envia alterações para Anki via Anki-Connect
   - Feedback visual de sucesso/erro
   - Validação básica antes de enviar

4. **Configuração básica**
   - Configuração de URL do Anki-Connect (padrão: `http://127.0.0.1:8765`)
   - Configuração de API key (opcional)

### Funcionalidades Futuras (Pós-MVP)
1. **Syntax Highlighting**
   - Highlighting para templates Anki
   - Destaque de campos, filtros e condicionais

2. **Autocomplete**
   - Autocomplete de campos do tipo de nota
   - Autocomplete de filtros built-in do Anki
   - Autocomplete de campos especiais

3. **Diagnósticos**
   - Validação de campos inválidos
   - Validação de sintaxe de templates
   - Avisos de problemas comuns

4. **Comandos adicionais**
   - `:AnkiList` - Lista todos os tipos de nota
   - `:AnkiRefresh` - Atualiza lista de tipos de nota
   - `:AnkiPreview` - Preview do template (se possível)

---

## Arquitetura

### Componentes Principais

```
anki-nvim-editor/
├── lua/
│   ├── anki-nvim-editor/
│   │   ├── init.lua              # Ponto de entrada
│   │   ├── config.lua             # Configurações
│   │   ├── anki_connect.lua       # Cliente Anki-Connect
│   │   ├── commands.lua            # Comandos do Neovim
│   │   ├── buffers.lua             # Gerenciamento de buffers
│   │   ├── ui.lua                  # Interface de seleção (telescope/fzf)
│   │   ├── parser.lua              # Parser básico de templates
│   │   └── utils.lua                # Utilitários
│   └── anki-nvim-editor/
│       └── highlights.lua          # Syntax highlighting (futuro)
├── plugin/
│   └── anki-nvim-editor.vim       # Comandos Vimscript (se necessário)
├── README.md
├── LICENSE
└── .luarc.json                     # Configuração LSP (opcional)
```

### Fluxo de Dados

```
Usuário executa :AnkiEdit
    ↓
UI mostra lista de tipos de nota
    ↓
Usuário seleciona tipo de nota
    ↓
UI mostra lista de cards
    ↓
Usuário seleciona card
    ↓
Anki-Connect busca templates (Front, Back, Style)
    ↓
Neovim cria 3 buffers com conteúdo
    ↓
Usuário edita e salva (:w)
    ↓
Plugin detecta save e envia para Anki-Connect
    ↓
Feedback de sucesso/erro
```

---

## Estrutura Detalhada de Arquivos

### `lua/anki-nvim-editor/init.lua`
- Setup do plugin
- Carregamento de módulos
- Registro de comandos
- Setup de autocomandos

### `lua/anki-nvim-editor/config.lua`
```lua
-- Configurações padrão
local default_config = {
  anki_connect_url = "http://127.0.0.1:8765",
  api_key = nil,
  auto_save = true,  -- Salvar automaticamente ao :w
  buffer_prefix = "[Anki]",  -- Prefixo para buffers
}
```

### `lua/anki-nvim-editor/anki_connect.lua`
- Classe/funções para comunicação HTTP com Anki-Connect
- Funções principais:
  - `get_model_names()` - Lista tipos de nota
  - `get_model_templates(model_name)` - Busca templates
  - `get_model_styling(model_name, card_name)` - Busca CSS
  - `update_model_templates(model_name, card_name, side, html)` - Atualiza template
  - `update_model_styling(model_name, css)` - Atualiza CSS
- Tratamento de erros HTTP
- Cache básico (opcional)

### `lua/anki-nvim-editor/commands.lua`
- `:AnkiEdit` - Comando principal
- `:AnkiList` - Lista tipos de nota
- `:AnkiRefresh` - Atualiza cache
- Setup de autocomandos para detectar saves

### `lua/anki-nvim-editor/buffers.lua`
- Criação de buffers nomeados
- Gerenciamento de estado (qual buffer pertence a qual template)
- Detecção de saves
- Mapeamento de buffers para dados do Anki

### `lua/anki-nvim-editor/ui.lua`
- Interface de seleção usando:
  - `vim.ui.select` (nativo do Neovim 0.6+)
  - Ou integração com Telescope (se disponível)
  - Ou fzf-lua (alternativa)
- Seleção em cascata: Tipo de Nota → Card

### `lua/anki-nvim-editor/parser.lua`
- Parser básico de templates Anki (para validação futura)
- Identificação de campos, filtros, condicionais

### `lua/anki-nvim-editor/utils.lua`
- Funções auxiliares
- Formatação de URLs
- Tratamento de erros
- Logging/debug

---

## Dependências

### Obrigatórias
- **Neovim 0.6+** (para `vim.ui.select` e Lua moderno)
- **Anki** com **Anki-Connect** instalado e rodando

### Opcionais (para melhor UX)
- **telescope.nvim** - Para interface de seleção melhorada
- **plenary.nvim** - Para funções utilitárias (HTTP, etc)
- **nvim-notify** - Para notificações bonitas

### Bibliotecas HTTP
- Usar `vim.system()` (Neovim 0.10+) para requisições HTTP
- Ou `plenary.nvim` com `curl`
- Ou `http.nvim` (plugin dedicado

---

## Especificação Técnica

### API Anki-Connect

O plugin precisará fazer requisições POST para o Anki-Connect:

```lua
-- Exemplo de requisição
local response = vim.system({
  "curl",
  "-X", "POST",
  "-H", "Content-Type: application/json",
  "-d", json.encode({
    action = "modelNames",
    version = 6
  }),
  "http://127.0.0.1:8765"
})
```

**Ações principais:**
1. `modelNames` - Lista tipos de nota
2. `modelFieldNames` - Lista campos de um tipo
3. `modelTemplates` - Busca templates de um tipo
4. `modelStyling` - Busca CSS de um card
5. `updateModelTemplates` - Atualiza template
6. `updateModelStyling` - Atualiza CSS

### Estrutura de Dados

```lua
-- Estado do plugin
local state = {
  active_templates = {
    [buffer_id] = {
      model_name = "Basic",
      card_name = "Card 1",
      side = "Front",  -- ou "Back" ou "Styling"
      original_content = "...",
      modified = false
    }
  }
}
```

### Autocomandos

```lua
-- Detectar save em buffers do Anki
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "[Anki]*",
  callback = function()
    -- Enviar para Anki-Connect
  end
})
```

---

## Roadmap de Desenvolvimento

### Fase 1: Setup e Estrutura Base (Semana 1)
- [ ] Criar estrutura de diretórios
- [ ] Setup básico do plugin (`init.lua`)
- [ ] Sistema de configuração (`config.lua`)
- [ ] README básico
- [ ] Testes manuais de estrutura

### Fase 2: Cliente Anki-Connect (Semana 1-2)
- [ ] Implementar `anki_connect.lua`
- [ ] Função para listar tipos de nota
- [ ] Função para buscar templates
- [ ] Função para atualizar templates
- [ ] Tratamento de erros HTTP
- [ ] Testes com Anki rodando

### Fase 3: Interface de Seleção (Semana 2)
- [ ] Implementar `ui.lua`
- [ ] Seleção de tipo de nota
- [ ] Seleção de card
- [ ] Integração opcional com Telescope
- [ ] Feedback visual

### Fase 4: Gerenciamento de Buffers (Semana 2-3)
- [ ] Implementar `buffers.lua`
- [ ] Criação de buffers nomeados
- [ ] Carregamento de conteúdo
- [ ] Mapeamento buffer → dados Anki
- [ ] Detecção de modificações

### Fase 5: Comandos e Autocomandos (Semana 3)
- [ ] Implementar `commands.lua`
- [ ] Comando `:AnkiEdit`
- [ ] Autocomando para detectar saves
- [ ] Envio automático ao salvar
- [ ] Feedback de sucesso/erro

### Fase 6: Polimento e Testes (Semana 3-4)
- [ ] Tratamento de edge cases
- [ ] Mensagens de erro amigáveis
- [ ] Documentação completa
- [ ] Testes em diferentes cenários
- [ ] Preparação para release

### Fase 7: Release (Semana 4)
- [ ] Criar repositório GitHub
- [ ] Adicionar LICENSE
- [ ] README completo com screenshots/exemplos
- [ ] Tag de versão inicial (v0.1.0)
- [ ] Publicar no GitHub

### Fase 8: Melhorias Pós-Release (Futuro)
- [ ] Syntax highlighting
- [ ] Autocomplete
- [ ] Diagnósticos
- [ ] Comandos adicionais
- [ ] Integração com LSP (se aplicável)

---

## Design de Interface

### Comando Principal
```
:AnkiEdit
```

**Fluxo:**
1. Mostra lista de tipos de nota (ex: "Basic", "Cloze", "Image Occlusion")
2. Usuário seleciona tipo
3. Mostra lista de cards daquele tipo (ex: "Card 1", "Card 2")
4. Usuário seleciona card
5. Abre 3 buffers:
   - `[Anki] Basic - Card 1 - Front`
   - `[Anki] Basic - Card 1 - Back`
   - `[Anki] Basic - Card 1 - Style`

### Nomeação de Buffers
```
[Anki] {ModelName} - {CardName} - {Side}
```

### Feedback Visual
- Notificação ao salvar com sucesso: `Template atualizado no Anki`
- Notificação de erro: `Erro ao atualizar: {mensagem}`
- Indicador visual de buffer modificado (padrão do Neovim)

---

## Considerações Técnicas

### Gerenciamento de Estado
- Usar `vim.b` (buffer-local) para armazenar metadados
- Ou tabela global com mapeamento buffer_id → dados

### Cache
- Cache simples em memória para tipos de nota
- Invalidar cache ao detectar mudanças

### Tratamento de Erros
- Verificar se Anki está rodando
- Verificar se Anki-Connect está acessível
- Validar resposta do Anki-Connect
- Mensagens de erro claras

### Performance
- Requisições assíncronas (usar `vim.system` ou similar)
- Não bloquear UI durante requisições
- Timeout para requisições HTTP

### Compatibilidade
- Funcionar sem dependências opcionais
- Graceful degradation se Telescope não estiver disponível
- Suportar Neovim 0.6+ (mínimo)

---

## Documentação Necessária

### README.md
- Instalação
- Requisitos
- Configuração
- Uso básico
- Exemplos
- Troubleshooting
- Contribuindo

### Comentários no Código
- Documentar funções principais
- Exemplos de uso
- Notas sobre decisões de design

---

## Estratégia de Testes

### Testes Manuais
1. Anki rodando, Anki-Connect ativo
2. Executar `:AnkiEdit` e selecionar template
3. Editar e salvar
4. Verificar no Anki se mudanças foram aplicadas

### Cenários de Teste
- Anki não rodando
- Anki-Connect não acessível
- Template inválido
- Múltiplos buffers abertos
- Salvar sem modificar
- Modificar e não salvar

---

## Preparação para Release

### Checklist de Release
- [ ] Código limpo e comentado
- [ ] README completo
- [ ] LICENSE adicionado (MIT recomendado)
- [ ] CHANGELOG.md (opcional para primeira versão)
- [ ] Tag de versão (semantic versioning)
- [ ] Releases no GitHub
- [ ] Screenshots/GIFs (se possível)

### Estrutura de Release
```
v0.1.0
├── README.md
├── LICENSE
├── lua/
│   └── anki-nvim-editor/
└── plugin/
    └── anki-nvim-editor.vim (se necessário)
```

---

## Funcionalidades Futuras (Pós-MVP)

### Syntax Highlighting
- Usar `nvim-treesitter` para parsing
- Ou criar syntax file Vimscript
- Highlight de campos, filtros, condicionais

### Autocomplete
- Usar `nvim-cmp` para completions
- Source customizado para campos do Anki
- Source para filtros built-in

### LSP Integration
- Criar LSP server customizado (mais complexo)
- Ou usar `nvim-lspconfig` com servidor existente

### Preview
- Preview HTML do template renderizado
- Usar buffer flutuante ou split

---

## Notas de Implementação

### Requisições HTTP no Neovim
```lua
-- Opção 1: vim.system (Neovim 0.10+)
local result = vim.system({"curl", ...}, {text = true})

-- Opção 2: plenary.nvim
local Job = require('plenary.job')
Job:new({
  command = 'curl',
  args = {...},
  on_exit = function(job, code)
    -- process result
  end
}):start()

-- Opção 3: http.nvim
local http = require('http')
http.post(url, {body = json_data})
```

### Seleção de UI
```lua
-- Opção 1: vim.ui.select (nativo)
vim.ui.select(items, {
  prompt = "Selecione tipo de nota:",
  format_item = function(item)
    return item.name
  end
}, function(choice)
  -- handle choice
end)

-- Opção 2: Telescope (se disponível)
local pickers = require('telescope.pickers')
-- ...
```

### Gerenciamento de Buffers
```lua
-- Criar buffer
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_name(buf, "[Anki] Basic - Card 1 - Front")
vim.api.nvim_buf_set_option(buf, "filetype", "html")
vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

-- Abrir em janela
vim.api.nvim_open_win(buf, true, {
  relative = "editor",
  width = 80,
  height = 24,
  col = 0,
  row = 0
})
```

---

## Métricas de Sucesso

### MVP Bem-Sucedido
- Usuário consegue listar tipos de nota
- Usuário consegue abrir templates para edição
- Alterações são salvas no Anki ao salvar buffer
- Feedback claro de sucesso/erro
- Funciona sem dependências opcionais

### Próximos Passos Após MVP
- Adicionar syntax highlighting
- Adicionar autocomplete
- Melhorar UX com Telescope
- Adicionar diagnósticos
- Expandir documentação

---

## Recursos e Referências

### Documentação
- [Anki-Connect API](https://github.com/FooSoft/anki-connect)
- [Neovim Lua API](https://neovim.io/doc/user/lua.html)
- [Neovim Plugin Development](https://github.com/nanotee/nvim-lua-guide)

### Plugins Similares para Referência
- [anki-editor (VSCode)](https://github.com/Pedro-Bronsveld/anki-editor)
- Outros plugins Neovim que fazem HTTP requests
- Plugins que gerenciam múltiplos buffers

---

## Conclusão

Este plano fornece uma base sólida para desenvolver o plugin Anki Editor para Neovim. O foco inicial está em criar um MVP funcional que permita editar templates do Anki, com espaço para crescimento e melhorias futuras.

**Próximo passo:** Começar pela Fase 1 - Setup e Estrutura Base.

