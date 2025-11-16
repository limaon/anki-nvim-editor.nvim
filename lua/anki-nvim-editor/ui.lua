-- UI selection interface for anki-nvim-editor

local M = {}

---Select item from list using vim.ui.select
---@param items table List of items
---@param prompt string Prompt text
---@param callback function Callback function(selected_item, index)
local function select_item(items, prompt, callback)
  if #items == 0 then
    callback(nil, nil)
    return
  end

  vim.ui.select(items, {
    prompt = prompt,
    format_item = function(item)
      return item
    end,
  }, function(choice, index)
    callback(choice, index)
  end)
end

---Recursively select model, card, and side
---@param state table Plugin state
---@param models table List of model names
---@param callback function Callback function(model, card, side)
function M.select_template(state, models, callback)
  select_item(models, "Select model: ", function(model, _)
    if not model then
      return
    end

    local anki_connect = require("anki-nvim-editor.anki_connect")

    -- Fetch templates for selected model
    anki_connect.get_model_templates(state, model, function(templates, error)
      if error then
        require("anki-nvim-editor").notify("Error fetching templates: " .. error, "error")
        return
      end

      local card_names = {}
      for card_name in pairs(templates) do
        table.insert(card_names, card_name)
      end
      table.sort(card_names)

      select_item(card_names, "Select card: ", function(card, _)
        if not card then
          return
        end

        local sides = { "Front", "Back", "Styling" }
        select_item(sides, "Select side: ", function(side, _)
          if side then
            callback(model, card, side)
          end
        end)
      end)
    end)
  end)
end

return M

