-- Configuration management for anki-editor

local M = {}

---Default configuration values
M.defaults = {
  -- Connection settings
  anki_connect_url = "http://127.0.0.1:8765",
  api_key = nil,

  -- UI settings
  buffer_prefix = "[Anki]",
  auto_save = true,

  -- Performance settings
  timeout_ms = 5000,
  debounce_ms = 200,

  -- Feature flags
  check_on_write = true,
  enable_diagnostics = false, -- Future: real-time diagnostics

  -- Notification provider
  notify_provider = "vim.notify", -- Alternative: "nvim-notify"
}

---Validate configuration
---@param config table Configuration to validate
---@return boolean, string success and error message if validation fails
function M.validate(config)
  if config.anki_connect_url and type(config.anki_connect_url) ~= "string" then
    return false, "anki_connect_url must be a string"
  end

  if config.api_key and type(config.api_key) ~= "string" then
    return false, "api_key must be a string"
  end

  if config.timeout_ms and type(config.timeout_ms) ~= "number" then
    return false, "timeout_ms must be a number"
  end

  if config.timeout_ms and config.timeout_ms < 1000 then
    return false, "timeout_ms should be at least 1000ms"
  end

  return true, nil
end

return M


