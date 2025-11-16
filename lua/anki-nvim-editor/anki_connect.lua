-- Anki-Connect client for communication with Anki via HTTP JSON-RPC

local M = {}

---Make a request to Anki-Connect
---@param state table Plugin state containing config
---@param action string Anki-Connect action name
---@param params table|nil Request parameters
---@param callback function Callback function(result, error)
local function request(state, action, params, callback)
  -- Ensure params is an object for Anki-Connect schema; use vim.empty_dict() when no params.
  local payload = {
    action = action,
    version = 6,
    params = (params == nil or (type(params) == "table" and next(params) == nil)) and vim.empty_dict() or params,
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

      -- Normalize vim.NIL to Lua nil
      local dec_error = decoded and decoded.error
      local dec_result = decoded and decoded.result
      if dec_error == vim.NIL then dec_error = nil end
      if dec_result == vim.NIL then dec_result = nil end

      if dec_error ~= nil then
        callback(nil, tostring(dec_error))
        return
      end

      -- If both result and error are nil, surface a helpful message
      -- Some update actions return null result on success; treat as OK when no error
      local allow_nil_result = {
        updateModelTemplates = true,
        updateModelStyling = true,
      }
      if dec_result == nil and not allow_nil_result[action] then
        callback(nil, "Empty response from Anki-Connect. Is the add-on enabled and listening on " .. (state.config.anki_connect_url or "http://127.0.0.1:8765") .. "?")
        return
      end

      callback(dec_result or true, nil)
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

