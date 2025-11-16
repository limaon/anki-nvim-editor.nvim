-- Example configuration for vim-plug package manager

-- In your init.vim or init.lua, add:

-- init.vim:
-- call plug#begin('~/.local/share/nvim/plugged')
-- Plug 'limaon/anki-editor.nvim'
-- call plug#end()
--
-- lua require('anki-editor').setup()

-- Or in init.lua:
local Plug = vim.fn['plug#']

-- Assuming you're using a plugin manager that supports Lua
require('anki-editor').setup({
  anki_connect_url = "http://127.0.0.1:8765",
  timeout_ms = 5000,
  auto_save = true,
})

-- Suggested keymaps (non-conflicting with avante.nvim)
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>ne', ':AnkiEdit<CR>', opts)
vim.keymap.set('n', '<leader>nl', ':AnkiList<CR>', opts)
vim.keymap.set('n', '<leader>np', ':AnkiPing<CR>', opts)

