-- Example configuration for lazy.nvim package manager

return {
  {
    'your-github-username/anki-nvim-editor',
    -- Or use local path for development:
    -- dir = '/path/to/anki-nvim-editor',
    event = 'VeryLazy', -- Load plugin lazily
    config = function()
      require('anki-nvim-editor').setup({
        anki_connect_url = "http://127.0.0.1:8765",
        timeout_ms = 5000,
      })
    end,
    keys = {
      { '<leader>ne', ':AnkiEdit<CR>', desc = 'Edit Anki template' },
      { '<leader>nl', ':AnkiList<CR>', desc = 'List Anki models' },
      { '<leader>np', ':AnkiPing<CR>', desc = 'Ping Anki-Connect' },
    },
  },
}

