-- anki-editor: Neovim plugin for editing Anki templates
-- Main entry point for the plugin (new namespace)

local M = {}

-- Default configuration
local default_config = {
  anki_connect_url = "http://127.0.0.1:8765",
  api_key = nil,
  auto_save = true,
  buffer_prefix = "[Anki]",
  timeout_ms = 5000,
  check_on_write = true,
  notify_provider = "vim.notify", -- or "nvim-notify" if available
}

-- Global state
local state = {
  config = default_config,
  active_templates = {}, -- Maps bufnr -> { model_name, card_name, side, original_content, version }
  model_cache = {}, -- Cache for model names and templates
  cache_ttl = 300000, -- 5 minutes in ms
  cache_timestamp = 0,
}

---Setup plugin with user configuration
---@param user_config table|nil User configuration to merge with defaults
function M.setup(user_config)
  user_config = user_config or {}

  -- Merge user config with defaults
  state.config = vim.tbl_deep_extend("force", default_config, user_config)

  -- Require submodules
  local commands = require("anki-editor.commands")
  local buffers = require("anki-editor.buffers")

  -- Setup commands
  commands.setup(state)

  -- Setup autocommands for buffer saves
  buffers.setup_autocmds(state)

  -- Create user commands
  vim.api.nvim_create_user_command("AnkiEdit", function()
    commands.edit_template(state)
  end, { desc = "Edit Anki template" })

  vim.api.nvim_create_user_command("AnkiList", function()
    commands.list_models(state)
  end, { desc = "List Anki model types" })

  vim.api.nvim_create_user_command("AnkiRefresh", function()
    state.model_cache = {}
    state.cache_timestamp = 0
    M.notify("Cache cleared", "info")
  end, { desc = "Refresh Anki model cache" })

  vim.api.nvim_create_user_command("AnkiPing", function()
    commands.ping(state)
  end, { desc = "Test Anki-Connect connection" })

  -- M.notify("anki-editor initialized", "info")
end

---Notify user with message
---@param message string Message to display
---@param level string Notification level: "info", "warn", "error"
function M.notify(message, level)
  level = level or "info"
  -- Always schedule notifications to avoid fast event context errors (E5560)
  vim.schedule(function()
    if state.config.notify_provider == "nvim-notify" then
      local ok, notify = pcall(require, "notify")
      if ok then
        notify(message, level)
        return
      end
    end
    -- Fallback to vim.notify with numeric level
    local lvl = vim.log.levels[string.upper(level)] or vim.log.levels.INFO
    vim.notify(message, lvl)
  end)
end

---Get current state (for debugging)
---@return table
function M.get_state()
  return state
end

return M
