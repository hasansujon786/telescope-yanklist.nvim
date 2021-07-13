local entry_display = require('telescope.pickers.entry_display')
local utils = require('telescope.utils')
local themes = require('telescope.themes')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
-- local actions = require('telescope/actions')
local action_state = require('telescope.actions.state')
-- local sorters = require('telescope/sorters')
local conf = require('telescope.config').values


local yanklist_get = vim.fn['yanklist#read']
local put_on_buf = vim.fn['yanklist#putreg_from_telescope']

local local_actions = {
  put = function (prompt_bufnr)
    local entry = action_state.get_selected_entry()
    require('telescope.actions').close(prompt_bufnr)
    put_on_buf(entry.value,'p',0)
  end
}
local make_entry_form_yank = function(line)
  local displayer = entry_display.create {
    separator = ' ',
    items = {
      { width = 4 },
      { remaining = true },
    },
  }
  local make_display = function()
    local prefix = line[2] == 'v' and 'char' or 'line'
    return displayer {
      { prefix, 'TelescopeResultsComment' },
      line[1][1]
    }
  end
  return { display = make_display, ordinal = line[1][1], value = line}
end

local M = {}

M.yanklist = function()
  local opts = {}
  -- opts = themes.get_dropdown{}

  pickers.new(opts, {
    finder = finders.new_table{
      -- results = results,
      results = yanklist_get(),
      entry_maker = opts.entry_maker or make_entry_form_yank
    },
    prompt_title = 'YankList',
    -- initial_mode = 'normal',
    sorter = conf.generic_sorter(opts),
    -- previewer = conf.file_previewer(opts),
    -- default_selection_index = 2,
    selection_strategy = 'reset', -- follow, reset, row
    color_devicons = true,
    attach_mappings = function(_, map)
      map('i', '<cr>', local_actions.put)
      map('n', '<cr>', local_actions.put)

      return true
    end,
  }):find()
end

return M
