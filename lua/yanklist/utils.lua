local M = {}

M.if_nil = function(x, was_nil, was_not_nil)
  if x == nil then
    return was_nil
  else
    return was_not_nil
  end
end

M.get_default = function(x, default)
  return M.if_nil(x, default, x)
end

return M
