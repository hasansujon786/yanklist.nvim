local M = {}

local finder = nil

if vim.g.yanklist_finder == 'fzf-lua' then
  finder = require('yanklist.providers.fzf')
elseif vim.g.yanklist_finder == 'snacks' then
  finder = require('yanklist.providers.snacks')
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
