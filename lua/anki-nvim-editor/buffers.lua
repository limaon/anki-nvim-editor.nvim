-- Buffer management for anki-nvim-editor

local M = {}
local utils = require("anki-nvim-editor.utils")
local anki_connect = require("anki-nvim-editor.anki_connect")

---Setup autocommands for buffer saves
---@param state table Plugin state
function M.setup_autocmds(state)
  local group = vim.api.nvim_create_augroup("AnkiEditorGroup", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*",
    callback = function(args)
      local bufnr = args.buf
      if state.active_templates[bufnr] then
        M.handle_buffer_save(state, bufnr)
      end
    end,
  })
end

---Handle save event for an Anki template buffer
---@param state table Plugin state
---@param bufnr number Buffer number
function M.handle_buffer_save(state, bufnr)
  local template = state.active_templates[bufnr]
  if not template then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Check for modifications
  if content == template.original_content then
    require("anki-nvim-editor").notify("No changes detected", "info")
    return
  end

  -- Validate before sending (basic check)
  if state.config.check_on_write then
    local valid, msg = M.validate_template(content, template.side)
    if not valid then
      require("anki-nvim-editor").notify("Validation failed: " .. msg, "warn")
      return
    end
  end

  -- Determine what to update
  if template.side == "Styling" then
    -- Update styling
    anki_connect.update_model_styling(state, template.model_name, content, function(result, error)
      if error then
        require("anki-nvim-editor").notify("Error updating styling: " .. error, "error")
      else
        template.original_content = content
        require("anki-nvim-editor").notify("Styling updated in Anki", "info")
      end
    end)
  else
    -- Update template (Front or Back)
    anki_connect.get_model_templates(state, template.model_name, function(templates, error)
      if error then
        require("anki-nvim-editor").notify("Error fetching templates: " .. error, "error")
        return
      end

      if not templates[template.card_name] then
        require("anki-nvim-editor").notify("Card not found: " .. template.card_name, "error")
        return
      end

      local updated_templates = {}
      for card_name, card_templates in pairs(templates) do
        updated_templates[card_name] = {}
        updated_templates[card_name].Front = card_templates.Front
        updated_templates[card_name].Back = card_templates.Back

        if card_name == template.card_name then
          updated_templates[card_name][template.side] = content
        end
      end

      anki_connect.update_model_templates(state, template.model_name, updated_templates, function(result, err2)
        if err2 then
          require("anki-nvim-editor").notify("Error updating template: " .. err2, "error")
        else
          template.original_content = content
          require("anki-nvim-editor").notify(
            "Template updated in Anki (" .. template.side .. ")",
            "info"
          )
        end
      end)
    end)
  end
end

---Validate template content
---@param content string Template content
---@param side string "Front", "Back", or "Styling"
---@return boolean, string valid, error message
function M.validate_template(content, side)
  if side == "Styling" then
    -- Basic CSS validation
    local open_braces = string.len(content) - string.len(string.gsub(content, "{", ""))
    local close_braces = string.len(content) - string.len(string.gsub(content, "}", ""))
    if open_braces ~= close_braces then
      return false, "Unbalanced braces in CSS"
    end
  else
    -- Basic template validation
    local open_brackets = string.len(content) - string.len(string.gsub(content, "{{", ""))
    local close_brackets = string.len(content) - string.len(string.gsub(content, "}}", ""))
    if open_brackets ~= close_brackets then
      return false, "Unbalanced template brackets"
    end
  end
  return true, nil
end

---Create buffers for editing templates
---@param state table Plugin state
---@param model_name string Model name
---@param card_name string Card name
---@param templates table Template data { Front = "...", Back = "..." }
---@param css string CSS content
function M.create_template_buffers(state, model_name, card_name, templates, css)
  -- Defer buffer/window operations to main loop to avoid fast event context errors
  vim.schedule(function()
    local sides = {
      { name = "Front", content = templates.Front or "", ft = "html" },
      { name = "Back", content = templates.Back or "", ft = "html" },
      { name = "Styling", content = css or "", ft = "css" },
    }

    local buf_numbers = {}

    for _, side_data in ipairs(sides) do
      local buf = vim.api.nvim_create_buf(false, true)
      local buf_name = utils.format_buffer_name(model_name, card_name, side_data.name, state.config.buffer_prefix)

      -- Set buffer name
      vim.api.nvim_buf_set_name(buf, buf_name)

      -- Set filetype
      vim.api.nvim_set_option_value("filetype", side_data.ft, { buf = buf })

      -- Set content
      local lines = vim.split(side_data.content, "\n")
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      -- Mark as not modified initially
      vim.api.nvim_buf_set_option(buf, "modified", false)

      -- Store template metadata
      state.active_templates[buf] = {
        model_name = model_name,
        card_name = card_name,
        side = side_data.name,
        original_content = side_data.content,
        version = 6,
      }

      table.insert(buf_numbers, buf)
    end

    -- Open buffers in splits
    if #buf_numbers > 0 then
      vim.api.nvim_set_current_buf(buf_numbers[1])
      vim.cmd("vsplit")
      vim.api.nvim_set_current_buf(buf_numbers[2])
      vim.cmd("split")
      vim.api.nvim_set_current_buf(buf_numbers[3])
    end

    require("anki-nvim-editor").notify(
      "Opened 3 buffers for editing: Front, Back, Styling",
      "info"
    )
  end)
end

return M

