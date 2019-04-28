--- Extensions to Lua's `debug` library.
--- @module ldk.debugx
local M = {}

do local _ = require 'ldk._base'
  _.merge(M, debug)
end

local debug_getupvalue = debug.getupvalue
local debug_upvaluejoin = debug.upvaluejoin
local debug_setupvalue = debug.setupvalue

local _ENV = M

--- Sets the environment to be used by a given function.
-- @tparam function f the function to set the environment of.
-- @tparam table env the environment to set.
-- @treturn boolean `true` if the environment has been successfully set; `false` otherwise.
function setfenv(f, env)
  local up = 0
  local name
  repeat
    up = up + 1
    name = debug_getupvalue(f, up)
  until name == '_ENV' or name == nil
  if name then
    debug_upvaluejoin(f, up, function ()
      return name
    end, 1)
    debug_setupvalue(f, up, env)
    return true
  end
  return false
end

--- Sets the environment to be used by a given function.
-- @tparam function f the function to get the environment of.
-- @treturn table the environment of the give function.
function getfenv(f)
  local up = 0
  local name, env
  repeat
    up = up + 1
    name, env = debug_getupvalue(f, up)
  until name == '_ENV' or name == nil
  return env
end

return M

