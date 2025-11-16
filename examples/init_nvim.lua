-- Example Neovim configuration for anki-nvim-editor plugin
-- Copy this to your Neovim config and adjust as needed

-- Make sure plugin is in your runtimepath
-- vim.opt.runtimepath:prepend('/path/to/anki-nvim-editor')

-- Basic setup with defaults
require('anki-nvim-editor').setup()

-- Or with custom configuration
require('anki-nvim-editor').setup({
  -- URL and port where Anki-Connect is listening
  anki_connect_url = "http://127.0.0.1:8765",

  -- Optional API key (if configured in Anki-Connect)
  api_key = nil,

  -- Automatically save templates on :w
  auto_save = true,

  -- Prefix for buffer names
  buffer_prefix = "[Anki]",

  -- Timeout for HTTP requests (milliseconds)
  timeout_ms = 5000,

  -- Debounce time for rapid saves (milliseconds)
  debounce_ms = 200,

  -- Validate template before saving
  check_on_write = true,

  -- Notification provider: "vim.notify" or "nvim-notify"
  notify_provider = "vim.notify",
})

-- Available commands:
-- :AnkiEdit       - Open template editor (main command)
-- :AnkiList       - List available models
-- :AnkiRefresh    - Refresh model cache
-- :AnkiPing       - Test Anki-Connect connection

-- Example key mappings (optional)
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>ne', ':AnkiEdit<CR>', opts)
vim.keymap.set('n', '<leader>nl', ':AnkiList<CR>', opts)
vim.keymap.set('n', '<leader>np', ':AnkiPing<CR>', opts)

