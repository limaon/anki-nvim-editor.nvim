-- Example configuration for vim-plug package manager

-- In your init.vim or init.lua, add:

-- init.vim:
-- call plug#begin('~/.local/share/nvim/plugged')
-- Plug 'your-github-username/anki-nvim-editor'
-- call plug#end()
--
-- lua require('anki-nvim-editor').setup()

-- Or in init.lua:
local Plug = vim.fn['plug#']

-- Assuming you're using a plugin manager that supports Lua
require('anki-nvim-editor').setup({
  anki_connect_url = "http://127.0.0.1:8765",
  timeout_ms = 5000,
  auto_save = true,
})

