local entry_display = require('telescope.pickers.entry_display')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values
-- local actions = require('telescope/actions')
-- local sorters = require('telescope/sorters')
local utils = require('yanklist.utils')

local is_visual = false
local yanklist_get = vim.fn['yanklist#read']

local put_on_buf = function(data, after, visual)
  local reg_type = data[2]
  local follow_cursor = not reg_type == 'l'

  if visual then
    vim.cmd('normal! gvd')
    local old_reg_type = vim.fn.getregtype('"')
    if after and old_reg_type == 'V' then
      after = false
    end
  end

  vim.schedule(function()
    vim.api.nvim_put(data[1], reg_type, after, follow_cursor)
  end)
end

local local_actions = {
  put = function(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    require('telescope.actions').close(prompt_bufnr)
    put_on_buf(entry.value, true, is_visual)
  end,
  put_before = function(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    require('telescope.actions').close(prompt_bufnr)
    put_on_buf(entry.value, false, is_visual)
  end,
  yank = function(prompt_bufnr)
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
  is_visual = utils.get_default(opts.is_visual, false)

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
      -- default_selection_index = 2,
      attach_mappings = function(_, map)
        map({ 'n', 'i' }, '<cr>', local_actions.put)
        map({ 'n', 'i' }, '<c-t>', local_actions.put_before)
        map({ 'n', 'i' }, '<c-y>', local_actions.yank)
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
