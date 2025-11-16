-- Anki-Connect client for communication with Anki via HTTP JSON-RPC

local M = {}

---Make a request to Anki-Connect
---@param state table Plugin state containing config
---@param action string Anki-Connect action name
---@param params table|nil Request parameters
---@param callback function Callback function(result, error)
local function request(state, action, params, callback)
  local payload = {
    action = action,
    version = 6,
    params = params or {},
  }

  if state.config.api_key then
    payload.key = state.config.api_key
  end

  local json_data = vim.json.encode(payload)

  vim.system(
    {
      "curl",
      "-sS",
      "-X",
      "POST",
      "-H",
      "Content-Type: application/json",
      "-d",
      json_data,
      state.config.anki_connect_url,
    },
    { text = true, timeout = state.config.timeout_ms },
    function(result)
      if result.code ~= 0 then
        callback(nil, "Connection failed: " .. (result.stderr or ("exit code " .. tostring(result.code))))
        return
      end

      local ok, decoded = pcall(vim.json.decode, result.stdout)
      if not ok then
        callback(nil, "Invalid JSON response from Anki-Connect")
        return
      end

      if decoded.error then
        callback(nil, tostring(decoded.error))
        return
      end

      callback(decoded.result, nil)
    end
  )
end

---Get list of model names from Anki
---@param state table Plugin state
---@param callback function Callback function(models, error)
function M.get_model_names(state, callback)
  request(state, "modelNames", nil, callback)
end

---Get field names for a model
---@param state table Plugin state
---@param model_name string Name of the model
---@param callback function Callback function(fields, error)
function M.get_model_field_names(state, model_name, callback)
  request(state, "modelFieldNames", { modelName = model_name }, callback)
end

---Get templates for a model
---@param state table Plugin state
---@param model_name string Name of the model
---@param callback function Callback function(templates, error)
---Returns: { card_name = { Front = "...", Back = "..." }, ... }
function M.get_model_templates(state, model_name, callback)
  request(state, "modelTemplates", { modelName = model_name }, callback)
end

---Get CSS styling for a model
---@param state table Plugin state
---@param model_name string Name of the model
---@param callback function Callback function(css, error)
function M.get_model_styling(state, model_name, callback)
  request(state, "modelStyling", { modelName = model_name }, callback)
end

---Update templates for a model
---@param state table Plugin state
---@param model_name string Name of the model
---@param templates table Structure: { card_name = { Front = "...", Back = "..." }, ... }
---@param callback function Callback function(result, error)
function M.update_model_templates(state, model_name, templates, callback)
  local payload = {
    model = {
      name = model_name,
      templates = templates,
    },
  }
  request(state, "updateModelTemplates", payload, callback)
end

---Update CSS styling for a model
---@param state table Plugin state
---@param model_name string Name of the model
---@param css string CSS content
---@param callback function Callback function(result, error)
function M.update_model_styling(state, model_name, css, callback)
  local payload = {
    model = {
      name = model_name,
      css = css,
    },
  }
  request(state, "updateModelStyling", payload, callback)
end

---Get Anki version (for testing connection)
---@param state table Plugin state
---@param callback function Callback function(version, error)
function M.get_version(state, callback)
  request(state, "version", nil, callback)
end

return M

