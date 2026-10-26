--- Insert-mode <CR> that continues markdown lists.
---
--- Key ownership in this config: <CR> is mapped globally by nvim-autopairs
--- (`map_cr = true`) and <Tab> by blink.cmp's `super-tab` preset. This module
--- claims <CR> buffer-locally in markdown only, and hands every non-list line
--- straight back to autopairs so bracket behaviour is unchanged everywhere.
--- Tab/S-Tab are driven from blink's own keymap config (see plugins/blink.lua),
--- because blink re-applies its buffer-local maps on every InsertEnter.
---
--- It is wired as an *expr* mapping: returning keys is the only reliable way to
--- delegate to another plugin's <CR> (feeding them with `nvim_feedkeys` from
--- inside a mapping callback silently drops them). Expr mappings may not modify
--- the buffer, so the list edit is returned as a `<Cmd>` call instead.

local M = {}

local BULLET_PATTERN = "^(%s*)([-*+])(%s+)(.*)$"
local ORDERED_PATTERN = "^(%s*)(%d+)([.)])(%s+)(.*)$"
local CHECKBOX_PATTERN = "^%[[ xX]%]%s*(.*)$"

-- One nesting level. Two spaces is the markdown convention and is what prettier
-- normalises to, so `<leader>F` will not undo the indent this produces.
local INDENT_WIDTH = 2

--- Describe the list item on `line`, or nil when it is not one.
--- @return table|nil `indent`, `next_marker` (the prefix a following item needs,
--- including its trailing space and a reset `[ ]` checkbox) and `content` (the
--- item's text, used to detect an empty item).
local function parse_item(line)
  local indent, bullet, space, content = line:match(BULLET_PATTERN)
  local next_marker

  if indent then
    next_marker = bullet .. space
  else
    local number, delimiter
    indent, number, delimiter, space, content = line:match(ORDERED_PATTERN)
    if not indent then
      return nil
    end
    next_marker = tostring(tonumber(number) + 1) .. delimiter .. space
  end

  local unchecked = content:match(CHECKBOX_PATTERN)
  if unchecked then
    next_marker = next_marker .. "[ ] "
    content = unchecked
  end

  return { indent = indent, next_marker = next_marker, content = content }
end

--- Split the current list item at the cursor, or end the list when it is empty.
--- Called from the `<Cmd>` returned by `M.expr`, where buffer edits are allowed.
function M.continue()
  local line = vim.api.nvim_get_current_line()
  local item = parse_item(line)
  if not item then
    return
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  -- Enter on an item with no text ends the list instead of adding another marker.
  if item.content == "" and col >= #line then
    vim.api.nvim_set_current_line("")
    vim.api.nvim_win_set_cursor(0, { row, 0 })
    return
  end

  -- Carry any text right of the cursor onto the new item.
  local prefix = item.indent .. item.next_marker
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, {
    line:sub(1, col),
    prefix .. line:sub(col + 1),
  })
  vim.api.nvim_win_set_cursor(0, { row + 1, #prefix })
end

--- Move the list item under the cursor one nesting level left or right.
--- @param delta integer columns of indent to add, negative to remove
--- @return boolean handled, false when the caller should fall back to a plain Tab
local function shift(delta)
  local line = vim.api.nvim_get_current_line()
  local item = parse_item(line)
  if not item then
    return false
  end

  local indent = #item.indent
  local new_indent = math.max(0, indent + delta)
  if new_indent == indent then
    return false
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local shifted = string.rep(" ", new_indent) .. line:sub(indent + 1)
  local new_col = math.max(0, col + (new_indent - indent))

  -- blink calls this from an expr mapping, where buffer edits are blocked, so
  -- decide synchronously and apply on the next tick.
  vim.schedule(function()
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { shifted })
    vim.api.nvim_win_set_cursor(0, { row, new_col })
  end)
  return true
end

--- Indent the list item under the cursor. @return boolean handled
function M.indent()
  return shift(INDENT_WIDTH)
end

--- Outdent the list item under the cursor. @return boolean handled
function M.outdent()
  return shift(-INDENT_WIDTH)
end

--- Keys <CR> should produce on the current line.
function M.expr()
  if parse_item(vim.api.nvim_get_current_line()) then
    return "<Cmd>lua require('mrk.markdown_list').continue()<CR>"
  end

  -- Not a list: give <CR> back to whoever owns it outside markdown. autopairs
  -- returns pre-escaped termcodes, which `replace_keycodes` passes through.
  local ok, autopairs = pcall(require, "nvim-autopairs")
  return ok and autopairs.completion_confirm() or "<CR>"
end

return M
