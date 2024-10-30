local entry_display = require('telescope.pickers.entry_display')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values
local utils = require('yanklist.utils')
local yanklist_get = vim.fn['yanklist#read']

local local_actions = {
  put = function(prompt_bufnr, put_after, is_visual)
    ---@type SelectedEntry
    local entry = action_state.get_selected_entry()
    require('telescope.actions').close(prompt_bufnr)

    local value = entry.value
    local reg_type = value[2]
    local content = value[1]

    if is_visual then
      vim.schedule(function()
        vim.cmd('normal! gv"_d')
        vim.api.nvim_put(content, reg_type, false, true)
      end)
      return
    end

    vim.schedule(function()
      vim.api.nvim_put(content, reg_type, put_after, true)
    end)
  end,
  yank = function(prompt_bufnr)
    ---@type SelectedEntry
    local entry = action_state.get_selected_entry()
    require('telescope.actions').close(prompt_bufnr)
    vim.fn.setreg('"', entry.value[1], entry.value[2])
  end,
}
local make_entry_form_yank = function(entry)
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = 4 },
      { remaining = true },
    },
  })
  local combiled_lines = table.concat(entry[1], ' ')
  local make_display = function()
    local prefix = entry[2] == 'v' and 'char' or 'line'
    return displayer({
      { prefix, 'TelescopeResultsComment' },
      combiled_lines,
    })
  end
  return { display = make_display, ordinal = combiled_lines, value = entry }
end

local M = {}

M.yanklist = function(opts)
  opts = utils.get_default(opts, {})
  local is_visual = utils.get_default(opts.is_visual, false)

  pickers
    .new(opts, {
      finder = finders.new_table({
        results = yanklist_get(),
        entry_maker = opts.entry_maker or make_entry_form_yank,
      }),
      prompt_title = opts.prompt_title or 'YankList',
      sorter = opts.sorter or conf.generic_sorter(opts),
      -- initial_mode = 'normal',
      -- previewer = conf.file_previewer(opts),
      attach_mappings = function(prompt_bufnr, map)
        map({ 'n', 'i' }, '<cr>', function()
          local_actions.put(prompt_bufnr, true, is_visual)
        end)
        map({ 'n', 'i' }, '<c-t>', function()
          local_actions.put(prompt_bufnr, false, is_visual)
        end)
        map({ 'n', 'i' }, '<c-y>', local_actions.yank)

        map({ 'n', 'i' }, '<tab>', require('telescope.actions').move_selection_previous)
        map({ 'n', 'i' }, '<s-tab>', require('telescope.actions').move_selection_next)

        map({ 'n', 'i' }, '<C-v>', nil)
        map({ 'n', 'i' }, '<C-s>', nil)
        return true
      end,
    })
    :find()
end

M.yanklist_visual = function(opts)
  opts = utils.get_default(opts, {})
  opts.is_visual = true
  M.yanklist(opts)
end

return M

---@class Value
---@field [1] string[] -- content
---@field [2] string -- reg_type
---@field [3] string -- I forgot

---@class SelectedEntry
---@field display fun() -- Display string
---@field index number -- Index number
---@field ordinal string -- Ordinal string
---@field value Value -- Value field of type Value
