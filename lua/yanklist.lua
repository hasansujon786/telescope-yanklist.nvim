local M = {}

local finder = nil
if vim.g.yanklist_finder == 'fzf-lua' then
  finder = require('yanklist.providers.fzf')
else
  finder = require('yanklist.providers.telescope')
end

M.yanklist = function(opts)
  finder.yanklist(false, opts)
end

M.yanklist_visual = function(opts)
  finder.yanklist(true, opts)
end

return M
