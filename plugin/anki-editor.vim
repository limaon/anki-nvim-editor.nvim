" anki-editor - Neovim plugin for editing Anki templates (module alias)
" This entrypoint supports the new module name 'anki-editor'.

if exists('g:anki_editor_loaded')
  finish
endif
let g:anki_editor_loaded = 1

if !has('nvim-0.6')
  echohl ErrorMsg
  echom 'anki-editor requires Neovim 0.6 or newer'
  echohl None
  finish
endif

let g:anki_editor_config = get(g:, 'anki_editor_config', {})

lua require('anki-editor').setup(vim.g.anki_editor_config)


