local fzf_lua = require('fzf-lua')
local utils = require('yanklist.utils')

local get_yanklist = vim.fn['yanklist#read']
local function ansi_codes_saturated_yellow(str)
  return '\27[38;5;102m' .. str .. '\27[0m'
end

local M = {}
local function make_entry(state)
  local contents = {}
  for index, content in ipairs(state) do
    local chartype = fzf_lua.utils.ansi_codes.grey(content[2] == 'v' and 'char' or 'line')

    local prefix = '%s %s. '
    prefix = prefix:format(chartype, ansi_codes_saturated_yellow(tostring(index)))
    local space_gap = string.rep(' ', 8)

    table.insert(contents, prefix .. string.gsub(content[1], '\n', '\n' .. space_gap))
  end
  return contents
end

M.actions = {
  paste_content = function(reg_state, selected, is_visual, put_after)
    if not selected or #selected == 0 then
      return
    end

    local num = tonumber(string.match(selected[1], '%d+'))
    local selected_value = reg_state[num]

    local reg_type = selected_value[2]
    local lines = vim.split(selected_value[1], '\n')

    if is_visual then
      vim.schedule(function()
        vim.cmd('normal! gv"_d')
        vim.api.nvim_put(lines, reg_type, false, true)
      end)
      return
    end

    vim.schedule(function()
      vim.api.nvim_put(lines, reg_type, put_after, true)
    end)
  end,
  yank = function(reg_state, selected)
    if not selected or #selected == 0 then
      return
    end

    local num = tonumber(string.match(selected[1], '%d+'))
    local selected_value = reg_state[num]

    vim.fn.setreg('+', selected_value[1], selected_value[2])
  end,
}

function M.yanklist(is_visual, opts)
  is_visual = utils.get_default(is_visual, false)
  opts = utils.get_default(opts, {})

  local reg_state = get_yanklist()

  fzf_lua.fzf_exec(make_entry(reg_state), {
    winopts = { title = ' Yanklist ' },
    fzf_opts = {
      ['--exact'] = true, -- Enable exact matching
    },
    multiline = true,
    preview = function(line)
      local num = tonumber(string.match(line[1], '%d+'))
      return reg_state[num][1]
    end,
    actions = {
      ['default'] = function(selected)
        M.actions.paste_content(reg_state, selected, is_visual, true)
      end,
      ['ctrl-t'] = function(selected)
        M.actions.paste_content(reg_state, selected, is_visual, false)
      end,
      ['ctrl-y'] = function(selected)
        M.actions.yank(reg_state, selected)
      end,
    },
  })
end

return M
