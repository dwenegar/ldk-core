local M = {}

local error = error
local pairs = pairs
local type = type

local _ENV = M

function merge(t1, t2)
  for k, v in pairs(t2) do
    t1[k] = v
  end
  return t1
end

function argerror(i, name, msg, level)
  if type(msg) == 'number' then
    level, msg = msg, nil
  end
  level = level or 1
  if msg then
    msg = ("bad argument #%d to '%s' (%s)"):format(i, name, msg)
  else
    msg = ("bad argument #%d to '%s'"):format(i, name)
  end
  error(msg, level + 2)
end


return M
