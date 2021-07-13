local entry_display = require('telescope.pickers.entry_display')
local utils = require('telescope.utils')
local themes = require('telescope.themes')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
-- local actions = require('telescope/actions')
local action_state = require('telescope.actions.state')
-- local sorters = require('telescope/sorters')
local conf = require('telescope.config').values


local is_visual = false
local yanklist_get = vim.fn['yanklist#read']
local put_on_buf = vim.fn['yanklist#putreg_from_telescope']

local local_actions = {
  put = function (prompt_bufnr)
    local entry = action_state.get_selected_entry()
    require('telescope.actions').close(prompt_bufnr)
    put_on_buf(entry.value,'p', is_visual)
  end
}
local make_entry_form_yank = function(entry)
  local displayer = entry_display.create {
    separator = ' ',
    items = {
      { width = 4 },
      { remaining = true },
    },
  }
  local combiled_lines = table.concat(entry[1], ' ')
  local make_display = function()
    local prefix = entry[2] == 'v' and 'char' or 'line'
    return displayer {
      { prefix, 'TelescopeResultsComment' },
      combiled_lines
    }
  end
  return { display = make_display, ordinal = combiled_lines, value = entry}
end

local M = {}

M.yanklist = function(opts)
  opts = utils.get_default(opts, {})
  is_visual = utils.get_default(opts.is_visual, false)

  pickers.new(opts, {
    finder = finders.new_table{
      results = yanklist_get(),
      entry_maker = opts.entry_maker or make_entry_form_yank
    },
    prompt_title = opts.prompt_title or 'YankList',
    sorter = opts.sorter or conf.generic_sorter(opts),
    -- initial_mode = 'normal',
    -- previewer = conf.file_previewer(opts),
    -- default_selection_index = 2,
    attach_mappings = function(_, map)
      map('i', '<cr>', local_actions.put)
      map('n', '<cr>', local_actions.put)

      return true
    end,
  }):find()
end

return M
