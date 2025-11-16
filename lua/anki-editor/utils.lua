-- Utility functions for anki-editor

local M = {}

---Debounce a function
---@param func function Function to debounce
---@param delay number Delay in milliseconds
---@return function Debounced function
function M.debounce(func, delay)
  local timer = nil
  return function(...)
    local args = { ... }
    if timer then
      vim.fn.timer_stop(timer)
    end
    timer = vim.fn.timer_start(delay, function()
      func(unpack(args))
      timer = nil
    end)
  end
end

---Check if a string starts with a prefix
---@param str string String to check
---@param prefix string Prefix to look for
---@return boolean
function M.starts_with(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

---Check if a string ends with a suffix
---@param str string String to check
---@param suffix string Suffix to look for
---@return boolean
function M.ends_with(str, suffix)
  return string.sub(str, -string.len(suffix)) == suffix
end

---Trim whitespace from string
---@param str string String to trim
---@return string
function M.trim(str)
  return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

---Split string by delimiter
---@param str string String to split
---@param delimiter string Delimiter (default: whitespace)
---@return table Array of parts
function M.split(str, delimiter)
  delimiter = delimiter or "%s+"
  local parts = {}
  for part in string.gmatch(str, "[^" .. delimiter .. "]+") do
    table.insert(parts, part)
  end
  return parts
end

---Check if table contains value
---@param tbl table Table to search
---@param value any Value to find
---@return boolean
function M.table_contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

---Get keys from table
---@param tbl table Table
---@return table Array of keys
function M.table_keys(tbl)
  local keys = {}
  for k in pairs(tbl) do
    table.insert(keys, k)
  end
  return keys
end

---Deep copy a table
---@param tbl table Table to copy
---@return table
function M.table_deep_copy(tbl)
  local copy = {}
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      copy[k] = M.table_deep_copy(v)
    else
      copy[k] = v
    end
  end
  return copy
end

---Format buffer name for Anki template
---@param model_name string Model name
---@param card_name string Card name
---@param side string "Front", "Back", or "Styling"
---@param prefix string Prefix (default: "[Anki]")
---@return string Formatted buffer name
function M.format_buffer_name(model_name, card_name, side, prefix)
  prefix = prefix or "[Anki]"
  return string.format("%s %s - %s - %s", prefix, model_name, card_name, side)
end

return M


