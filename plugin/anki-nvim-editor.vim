" anki-nvim-editor - Neovim plugin for editing Anki templates
" This file is loaded to setup the plugin

if exists('g:anki_nvim_editor_loaded')
  finish
endif
let g:anki_nvim_editor_loaded = 1

" Make sure we have Neovim 0.6+
if !has('nvim-0.6')
  echohl ErrorMsg
  echom 'anki-nvim-editor requires Neovim 0.6 or newer'
  echohl None
  finish
endif

" Default configuration (can be overridden by user)
let g:anki_nvim_editor_config = get(g:, 'anki_nvim_editor_config', {})

" Initialize plugin via Lua
lua require('anki-nvim-editor').setup(vim.g.anki_nvim_editor_config)

