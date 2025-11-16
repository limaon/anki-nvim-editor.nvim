-- Commands for anki-editor

local M = {}
local anki_connect = require("anki-editor.anki_connect")
local ui = require("anki-editor.ui")
local buffers = require("anki-editor.buffers")

---Setup commands and their handlers
---@param state table Plugin state
function M.setup(state)
  -- Commands are registered in init.lua
end

---Edit template command handler
---@param state table Plugin state
function M.edit_template(state)
  require("anki-editor").notify("Fetching model list...", "info")

  anki_connect.get_model_names(state, function(models, error)
    if error then
      require("anki-editor").notify("Error fetching models: " .. error, "error")
      return
    end

    if not models or #models == 0 then
      require("anki-editor").notify("No models found", "warn")
      return
    end

    -- Sort models for consistent display
    table.sort(models)

    -- Show UI for selection
    ui.select_template(state, models, function(model, card, side)
      if not model or not card or not side then
        require("anki-editor").notify("Selection cancelled", "info")
        return
      end

      -- Fetch templates and styling
      anki_connect.get_model_templates(state, model, function(templates, error1)
        if error1 then
          require("anki-editor").notify("Error fetching templates: " .. error1, "error")
          return
        end

        anki_connect.get_model_styling(state, model, function(css, error2)
          if error2 then
            require("anki-editor").notify("Error fetching styling: " .. error2, "error")
            return
          end

          -- Create buffers for all three sides
          buffers.create_template_buffers(state, model, card, templates[card], css)
        end)
      end)
    end)
  end)
end

---List models command handler
---@param state table Plugin state
function M.list_models(state)
  require("anki-editor").notify("Fetching model list...", "info")

  anki_connect.get_model_names(state, function(models, error)
    if error then
      require("anki-editor").notify("Error fetching models: " .. error, "error")
      return
    end

    if not models or #models == 0 then
      require("anki-editor").notify("No models found", "warn")
      return
    end

    -- Display models in a notification or in command output
    table.sort(models)
    local model_list = table.concat(models, "\n")
    vim.cmd("echo '" .. string.gsub(model_list, "'", "\\'") .. "'")
  end)
end

---Ping Anki-Connect command handler
---@param state table Plugin state
function M.ping(state)
  require("anki-editor").notify("Testing Anki-Connect connection...", "info")

  anki_connect.get_version(state, function(version, error)
    if error then
      require("anki-editor").notify(
        "Anki-Connect not accessible: " .. error,
        "error"
      )
    else
      require("anki-editor").notify(
        "Anki-Connect v" .. tostring(version) .. " is running",
        "info"
      )
    end
  end)
end

return M


