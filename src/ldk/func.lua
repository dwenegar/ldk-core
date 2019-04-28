--- Functional programming support module.
-- @module ldk.func
local M = {}

local load = load
local tonumber = tonumber
local pack = table.pack
local concat = table.concat
local unpack = table.unpack

local _ENV = M

--- Composes the specified functions.
-- @tparam function f the first function to be composed.
-- @tparam function g the second function to be composed.
-- @treturn function a new function calculating `f(g(...))`.
function compose(f, g)
  return function(...)
    return f(g(...))
  end
end

--- Create a partial application of the given function.
-- @param a the argument to fix.
-- @tparam function f the function.
-- @treturn function a new partial application of `f` using `a`.
function partial(a, f)
  return function(...)
    return f(a, ...)
  end
end

--- Curries the given function.
-- @tparam function f the function to be curried.
-- @treturn function the curried function.
function curry(f)
  return function(a)
    return partial(a, f)
  end
end

--- Creates a function that alwayes returns the specified value.
-- @param v the value to be returned.
-- @treturn function a function returning always the specified value.
function always(v)
  return function()
    return v
  end
end

--- The identity function.
-- @param v the value to be returned.
-- @return the input value unmodified.
function identity(v)
  return v
end

--- Memoizes a function with no argument.
-- @tparam function f the function to be memoized.
-- @treturn function the memoized function.
function memoize0(f)
  local value
  return function()
    if not value then
      value = pack(f())
    end
    return unpack(value)
  end
end

local function getcache(cache, k1, k2, k3)
  if not cache[k1] then
    cache[k1] = {}
  end
  cache = cache[k1]
  if k2 == nil then
    return cache
  end
  if not cache[k2] then
    cache[k2] = {}
  end
  cache = cache[k2]
  if k3 == nil then
    return cache
  end
  if not cache[k3] then
    cache[k3] = {}
  end
  return cache[k3]
end

local NIL = {}
local function masknil(v)
  if v == nil then
    return NIL
  end
  return v
end

--- Memoizes a function with one argument.
-- @tparam function f the function to be memoized.
-- @treturn function the memoized function.
function memoize1(f)
  local cache = {}
  return function(arg1)
    local k1 = masknil(arg1)
    if not cache[k1] then
      cache[k1] = pack(f(arg1))
    end
    return unpack(cache[k1])
  end
end

--- Memoizes a function with two arguments.
-- @tparam function f the function to be memoized.
-- @treturn function the memoized function.
function memoize2(f)
  local cache = {}
  return function(arg1, arg2)
    local k1, k2 = masknil(arg1), masknil(arg2)
    local cache2 = getcache(cache, k1)
    if not cache2[k2] then
      cache2[k2] = pack(f(arg1, arg2))
    end
    return unpack(cache2[k2])
  end
end

--- Memoizes a function with threw arguments.
-- @tparam function f the function to be memoized.
-- @treturn function the memoized function.
function memoize3(f)
  local cache = {}
  return function(arg1, arg2, arg3)
    local k1, k2, k3 = masknil(arg1), masknil(arg2), masknil(arg3)
    local cache3 = getcache(cache, k1, k2)
    if not cache3[k3] then
      cache3[k3] = pack(f(arg1, arg2, arg3))
    end
    return unpack(cache3[k3])
  end
end

--- Memoizes a function with four arguments.
-- @tparam function f the function to be memoized.
-- @treturn function the memoized function.
function memoize4(f)
  local cache = {}
  return function(arg1, arg2, arg3, arg4)
    local k1, k2, k3, k4 = masknil(arg1), masknil(arg2), masknil(arg3), masknil(arg4)
    local cache4 = getcache(cache, k1, k2, k3)
    if not cache4[k4] then
      cache4[k4] = pack(f(arg1, arg2, arg3, arg4))
    end
    return unpack(cache4[k4])
  end
end

--- Compiles a string into a Lua function.
--
-- A valid lambda string takes one of two forms:
--
--   1. `'expression'`: equivalent to `function() return expression end`
--   2. `'(params) expression'`: equivalent to `function(params) return expression end`
--
-- @tparam string s a valid lambda string.
-- @treturn function the compiled lambda string, or `nil` if the compilation fails.
-- @treturn string an error message if the compilation fails, `nil` otherwise.
function lambda(s)
  local params, body = s:match('^%s*%(%s*([^%(]*)%s*%)%s*(.+)%s*$')
  if not params then
    local maxargn = 0
    for argn in s:gmatch('_(%d+)') do
      argn = tonumber(argn)
      if argn > maxargn then
        maxargn = argn
      end
    end
    if maxargn > 0 then
      local b = {}
      for i = 1, maxargn do
        b[#b + 1] = ('_%d'):format(i)
      end
      params = concat(b, ', ')
    end
    body = s
  end
  local chunk
  if params then
    chunk = ('%s = ...; return %s'):format(params, body)
  else
    chunk = ('return %s'):format(body)
  end
  local f, err = load(chunk)
  if err then
    return nil, ('invalid lambda string: %q (%s)'):format(s, err)
  end
  return f
end

return M
