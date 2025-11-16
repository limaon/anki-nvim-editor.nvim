-- Buffer management for anki-editor

local M = {}
local utils = require("anki-editor.utils")
local anki_connect = require("anki-editor.anki_connect")

---Setup autocommands for buffer saves
---@param state table Plugin state
function M.setup_autocmds(state)
  local group = vim.api.nvim_create_augroup("AnkiEditorGroup", { clear = true })

  -- Intercept writes for Anki buffers so we don't try to write files to disk
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = group,
    pattern = "*",
    callback = function(args)
      local bufnr = args.buf
      if state.active_templates[bufnr] then
        M.handle_buffer_save(state, bufnr)
        -- Mark as saved and stop the default write
        vim.api.nvim_buf_set_option(bufnr, "modified", false)
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
    require("anki-editor").notify("No changes detected", "info")
    return
  end

  -- Validate before sending (basic check). Warn only; let Anki-Connect be the final validator.
  if state.config.check_on_write then
    local valid, msg = M.validate_template(content, template.side)
    if not valid then
      require("anki-editor").notify("Validation warning: " .. (msg or "potential template issue"), "warn")
      -- continue anyway
    end
  end

  -- Determine what to update
  if template.side == "Styling" then
    -- Update styling
    anki_connect.update_model_styling(state, template.model_name, content, function(result, error)
      if error then
        require("anki-editor").notify("Error updating styling: " .. error, "error")
      else
        template.original_content = content
        require("anki-editor").notify("Styling updated in Anki", "info")
      end
    end)
  else
    -- Update template (Front or Back)
    anki_connect.get_model_templates(state, template.model_name, function(templates, error)
      if error then
        require("anki-editor").notify("Error fetching templates: " .. error, "error")
        return
      end

      if not templates[template.card_name] then
        require("anki-editor").notify("Card not found: " .. template.card_name, "error")
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
          require("anki-editor").notify("Error updating template: " .. err2, "error")
        else
          template.original_content = content
          require("anki-editor").notify(
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
    -- Basic CSS validation: count literal '{' and '}' (escape patterns)
    local opens = select(2, string.gsub(content or "", "%%{", ""))
    local closes = select(2, string.gsub(content or "", "%%}", ""))
    if opens ~= closes then
      return false, "Unbalanced braces in CSS"
    end
  else
    -- Basic template validation: count double-curly pairs literally
    local opens = select(2, string.gsub(content or "", "%%{%{", ""))
    local closes = select(2, string.gsub(content or "", "%%}%}", ""))
    if opens ~= closes then
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
    -- Normalize inputs (Anki-Connect returns { css = "..." } for styling)
    local css_str = css
    if type(css_str) == "table" and css_str.css then
      css_str = css_str.css
    end
    if css_str == nil then css_str = "" end

    local front_str = templates and templates.Front or ""
    local back_str = templates and templates.Back or ""
    if type(front_str) ~= "string" then front_str = tostring(front_str or "") end
    if type(back_str) ~= "string" then back_str = tostring(back_str or "") end
    if type(css_str) ~= "string" then css_str = tostring(css_str or "") end

    local sides = {
      { name = "Front", content = front_str, ft = "html" },
      { name = "Back", content = back_str, ft = "html" },
      { name = "Styling", content = css_str, ft = "css" },
    }

    local buf_numbers = {}

    for _, side_data in ipairs(sides) do
      local buf_name = utils.format_buffer_name(model_name, card_name, side_data.name, state.config.buffer_prefix)
      local existing = vim.fn.bufnr(buf_name)
      local buf
      if existing ~= -1 then
        buf = existing
      else
        -- Create a normal, listed buffer (not scratch)
        buf = vim.api.nvim_create_buf(true, false)
        -- Set buffer name (only for new buffers)
        vim.api.nvim_buf_set_name(buf, buf_name)
      end

      -- Ensure buffer behaves like a virtual editable document (not written to disk)
      vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
      vim.api.nvim_set_option_value("buflisted", true, { buf = buf })
      vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

      -- Set filetype
      vim.api.nvim_set_option_value("filetype", side_data.ft, { buf = buf })

      -- Set content
      local content = side_data.content or ""
      if type(content) ~= "string" then
        content = tostring(content)
      end
      local lines = vim.split(content, "\n", { plain = true })
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

    require("anki-editor").notify(
      "Opened 3 buffers for editing: Front, Back, Styling",
      "info"
    )
  end)
end

return M


