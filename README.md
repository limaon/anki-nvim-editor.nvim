# anki-editor.nvim

Neovim plugin to edit Anki card templates directly in the editor, with automatic synchronization via Anki-Connect.

This project adapts the VSCode extension [anki-editor](https://github.com/Pedro-Bronsveld/anki-editor) to Neovim, implemented in Lua instead of TypeScript.

## Status

MVP in development — base structure created, main features being implemented.

See [PLANO.md](./PLANO.md) for the detailed roadmap and architecture notes.

## Requirements

### Required
- Neovim 0.6+ (0.10+ recommended for better `vim.system`)
- Anki desktop installed and running
- [Anki-Connect](https://github.com/FooSoft/anki-connect) add-on

### Optional (better UX)
- [Anki Preview Reloader](https://ankiweb.net/shared/info/1020073684) — refreshes previews in Anki when templates change
- [nvim-notify](https://github.com/rcarriga/nvim-notify) — nicer notifications
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) — improved selection UI (future)

## Features

### MVP (implemented / planned)
- HTTP client for Anki-Connect with error handling
- Buffer management for Front, Back, and CSS
- Configuration system
- `:AnkiEdit` command for template selection and editing
- Auto-sync on save (`:w`)
- Success/error notifications
- Connectivity check with `:AnkiPing`

### Future
- Syntax highlighting for fields, filters, and conditionals
- Autocomplete for Anki fields and filters
+- Diagnostics for template issues
- Rename for conditional tags ({{#if}} → {{/if}})
- LSP integration
- Rendered HTML preview

## Installation

### lazy.nvim (recommended)

```lua
-- In your lazy.nvim spec:
{
  'limaon/anki-editor.nvim',
  event = 'VeryLazy',
  config = function()
    require('anki-editor').setup({
      anki_connect_url = "http://127.0.0.1:8765",
    })
  end,
  keys = {
    { '<leader>ne', ':AnkiEdit<CR>', desc = 'Edit Anki template' },
  },
}
```

### vim-plug

```vim
Plug 'limaon/anki-editor.nvim'
```

```vim
" In your init.vim or init.lua:
lua require('anki-editor').setup()
```

### Manual

1. Clone the repository:
```bash
git clone https://github.com/limaon/anki-editor.nvim.git \
  ~/.local/share/nvim/site/pack/manual/start/anki-editor.nvim
```

2. Add setup to your `init.lua`:
```lua
require('anki-editor').setup()
```

## Configuration

```lua
require('anki-editor').setup({
  -- Anki-Connect URL and port
  anki_connect_url = "http://127.0.0.1:8765",

  -- Optional API key (if configured in Anki-Connect)
  api_key = nil,

  -- Automatically sync on :w
  auto_save = true,

  -- Buffer name prefix
  buffer_prefix = "[Anki]",

  -- HTTP timeout (ms)
  timeout_ms = 5000,

  -- Debounce time for rapid saves (ms)
  debounce_ms = 200,

  -- Validate template before saving
  check_on_write = true,

  -- Notification provider: "vim.notify" or "nvim-notify"
  notify_provider = "vim.notify",
})
```

See `examples/` for additional configurations (lazy.nvim, vim-plug).

## Usage

### Commands

```vim
:AnkiEdit       " Interactive selection and editing of templates
:AnkiList       " List available note types
:AnkiRefresh    " Clear model cache
:AnkiPing       " Check Anki-Connect connectivity
```

### Basic Flow

1. Run `:AnkiEdit`
2. Select the note type (model)
3. Select the card (e.g., "Card 1")
4. Select the side (Front, Back, or Styling)
5. Edit the opened buffer
6. Save with `:w` to sync with Anki

### Example Keybindings

```lua
-- In your init.lua
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>ne', ':AnkiEdit<CR>', opts)
vim.keymap.set('n', '<leader>nl', ':AnkiList<CR>', opts)
vim.keymap.set('n', '<leader>np', ':AnkiPing<CR>', opts)
```

## Troubleshooting

### Anki-Connect does not connect

1. Ensure Anki is running: `pgrep anki`
2. Verify Anki-Connect is installed and enabled in Anki
3. Test the URL: `curl http://127.0.0.1:8765`
4. Run `:AnkiPing` in Neovim

### Plugin does not load

```vim
:checkhealth
:messages
```

Check if the plugin is in the `runtimepath`:
```vim
:set runtimepath?
```

### Buffers do not save

- Verify the Anki-Connect API is responding
- Check for errors in `:messages`
- Use `:AnkiList` to validate connectivity

## Development

See [development.md](./development.md) for:
- Local development setup
- Code style (StyLua, Luacheck)
- How to test locally
- How to contribute

### Contributing Checklist

- [ ] Fork the repository
- [ ] Your branch: `git checkout -b feature/your-feature`
- [ ] Clear commit messages
- [ ] Run `stylua lua/ plugin/` for formatting
- [ ] Run `luacheck lua/ --globals vim` for linting
- [ ] Push: `git push origin feature/your-feature`
- [ ] Pull Request with description

## License

[MIT License](./LICENSE)

## Credits

- Inspired by [anki-editor](https://github.com/Pedro-Bronsveld/anki-editor) by Pedro Bronsveld for VSCode
- [Anki-Connect](https://github.com/FooSoft/anki-connect) by FooSoft
- [Anki Documentation](https://docs.ankiweb.net/)

## Resources

- [Neovim Lua API](https://neovim.io/doc/user/lua.html)
- [Anki-Connect API Reference](https://github.com/FooSoft/anki-connect)
- [Neovim plugin development guide](https://github.com/nanotee/nvim-lua-guide)
- [PLANO.md](./PLANO.md) — Roadmap and architecture

