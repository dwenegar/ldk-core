--- Extensions to the `string` module.
-- @module ldk.stringx

local M = {}

local argerror
do local _ = require 'ldk._base'
  argerror = _.argerror
  _.merge(M, string)
  _ = nil
end

local ipairs = ipairs
local tonumber = tonumber
local tostring = tostring
local type = type
local setmetatable = setmetatable

local MAX_INT = math.maxinteger

local table_concat = table.concat

local _ENV = M

local L_SPACE = ('^%s+(.-)$')
local R_SPACE = ('^(.-)%s+$')
local LR_SPACE= ('^%s+(.-)%s+$')

local caches = setmetatable({}, { __mode = 'k'})
local function getp(p, f)
  local cache = caches[f]
  if not cache then
    cache = setmetatable({}, { __mode = 'k'})
    caches[f] = cache
  end
  local r = cache[p]
  if not r then
    r = f(p)
    cache[p] = r
  end
  return r
end

--- Creates an array with the characters of a string.
-- @tparam string s a string to be divided into characters.
-- @tparam[opt] table a a table where to store the characters.
-- @treturn {string} an table with the characters of `s`.
function chars(s, a)
  a = a or {}
  for c in s:gmatch('.') do
    a[#a + 1] = c
  end
  return a
end

--- Searches a string for the last occurrence of the specified pattern.
-- @tparam string s the string to be searched.
-- @tparam string p the pattern to search for.
-- @tparam integer init the index  where to start the search.
-- @tparam[opt=`%s`] boolean plain if `true` the pattern is considered a plain string.
-- @treturn integer the index where the pattern starts.
-- @treturn integer the index where the pattern ends.
function findr(s, p, init, plain)
  local f1, e1 = s:find(p, init, plain)
  if not f1 then
    return nil
  end
  while true do
    local f2, e2 = s:find(p, e1 + 1, plain)
    if not f2 then
      return f1, e1
    end
    f1, e1 = f2, e2
  end
end

--- Removes all the leading occurrences of a specified pattern from a string.
-- @tparam string s the string to be trimmed.
-- @tparam[opt=`%s`] string p the pattern to remove; the pattern must not contain
-- captures.
-- @treturn string the string that remains after all the leading occurrences
-- of the specified pattern are removed from the input string.
function triml(s, p)
  p = p and getp(p, function(x)
    return ('^%s+(.-)$'):format(x)
  end) or L_SPACE
  local t = s:match(p)
  while t do
    s, t = t, t:match(p)
  end
  return s
end

--- Removes all the trailing occurrences of a specified pattern from a string.
-- @tparam string s the string to be trimmed.
-- @tparam[opt=`%s`] string p the pattern to remove; the pattern must not contain
-- captures.
-- @treturn string the string that remains after all the traling occurrences
-- of the specified pattern are removed from the input string.
function trimr(s, p)
  p = p and getp(p, function(x)
    return ('^(.-)%s+$'):format(x)
  end) or R_SPACE
  local t = s:match(p)
  while t do
    s, t = t, t:match(p)
  end
  return s
end

--- Removes all the leading and trailing occurrences of a specified pattern
-- from a string.
-- @tparam string s the string to be trimmed.
-- @tparam[opt=`%s`] string p the pattern to remove; the pattern must not contain
-- captures.
-- @treturn string the string that remains after all the leading and traling
-- occurrences of the specified pattern are removed from the input string.
function trim(s, p)
  p = p and getp(p, function(x)
    return ('^%s+(.-)%s+$'):format(x, x)
  end) or LR_SPACE
  local t = s:match(p)
  while t do
    s, t = t, t:match(p)
  end
  return s
end

--- Splits a string into substring based on a specified separator.
-- @tparam string s the string to be split.
-- @tparam[opt='%s+'] string sep the pattern that delimits the substrings; the pattern must
-- not contain captures.
-- @tparam[optchain] integer maxn the maximum number of substrings to return.
-- @treturn {string} an array containing the substrings in the input string that
-- are delimited by one or more separators.
function split(s, sep, maxn)
  sep = sep or '%s+'
  maxn = maxn or MAX_INT
  local a = {}
  foreach(s, sep, maxn, function(w)
    a[#a +1] = w
  end)
  return a
end

--- Determines whether a string begins with a spcified pattern.
-- @tparam string s the string to be tested.
-- @tparam string p the pattern to search for; the pattern must not contain
-- neither captures nor anchors.
-- @tparam[opt] boolean plain if `true` the pattern is considered a plain string.
-- @treturn boolean `true` if the pattern is found at the beginning of the
-- input string.
function startswith(s, p, plain)
  if plain then
    return s:find(p, 1, true) == 1
  end
  p = getp(p, function(x)
    return ('^%s'):format(x)
  end)
  return s:find(p) ~= nil
end

--- Determines whether a string ends with a spcified pattern.
-- @tparam string s the string to be tested.
-- @tparam string p the pattern to search for; the pattern must not contain
-- neither captures nor anchors.
-- @tparam[opt] boolean plain if `true` the pattern is considered a plain string.
-- @treturn boolean `true` if the pattern is found at the end of the
-- input string.
function endswith(s, p, plain)
  if plain then
    local _, e = s:find(p, #s - #p, true)
    return e == #s
  end
  p = getp(p, function(x)
    return ('%s$'):format(x)
  end)
  return s:find(p) ~= nil
end

--- Searches `sep` in the string `s` from the beginning of the string and returns
-- the part before it, the match, and the part after it. If it is not found,
-- returns two empty strings and `s`.
-- @tparam string s the string to be searched.
-- @tparam string sep the pattern to search
-- @tparam[opt] boolean plain if `true` the pattern is considered a plain string.
-- @treturn string the substring occurring before the specified pattern.
-- @treturn string the substring matching the specified pattern.
-- @treturn string the substring occurring after the specified pattern.
function partition(s, sep, plain)
  local ps, pe = s:find(sep, 1, plain)
  if not ps then
    return s, nil, nil
  end
  return s:sub(1, ps - 1), s:sub(ps, pe), s:sub(pe + 1)
end

--- Searches `sep` in the string `s` from the end of the string and returns
-- the part before it, the match, and the part after it. If it is not found,
-- returns two empty strings and `s`.
-- @tparam string s the string.
-- @tparam string sep the seperator.
-- @tparam[opt] boolean plain if `true` the pattern is considered a plain string.
-- @treturn string the part before the separator.
-- @treturn string the separator
-- @treturn string the part after the separator.
function partitionr(s, sep, plain)
  local ps, pe = findr(s, sep, 1, plain)
  if not ps then
    return nil, nil, s
  end
  return s:sub(1, ps - 1), s:sub(ps, pe), s:sub(pe + 1)
end

--- Returns a new string with characters in `from` replaced with the
-- corresponding characters in `to`.
-- @tparam string s the string.
-- @tparam string from the characters to replace.
-- @tparam string to the replacement characters.
-- @treturn string the new string.
function translate(s, from, to)
  if #from ~= #to then
    argerror(1, 'translate', 'from and to must have the same length')
  end
  local m
  return (s:gsub('(.)', function(c)
    local i = from:find(c)
    if not i then
      return c
    end
    if not m then
      m = chars(to)
    end
    return m[i]
  end))
end

--- Simple string interpolator; it inserts its arguments between corresponding
-- parts of a pattern.
-- @tparam string s a pattern to interpolate.
-- @tparam table values the arguments to be replaced.
-- @treturn string the formatted string.
--
-- @usage
-- print(S("Hello, $name", { name = 'James' })))
function S(s, values)
  return (s:gsub('%$(%S+)', function(w)
    return tostring(values[tonumber(w) or w])
  end))
end

--- The formatted string interpolator; it inserts its arguments between
-- corresponding parts of the pattern.
-- @tparam string s a pattern to interpolate.
-- @tparam table values the arguments to be replaced.
-- @treturn string the formatted string.
--
-- @usage
-- print(F("$height%2.2f", { height = 1.9 }))
function F(s, values)
  return (s:gsub('%$(%S+)(%%%S+)', function(w, fmt)
    return fmt:format(values[tonumber(w) or w])
  end))
end

--- Returns a copy of `s' with all characters in `x` deleted.
-- @tparam string s the string.
-- @tparam string p the pattern representing the characters to delete.
-- @tparam[opt] boolean plain if `true` the pattern is considered a plain string.
-- @treturn string the new string with the characters deleted.
function delete(s, p, plain)
  if plain then
    for _, c in ipairs(chars(p)) do
      s = s:gsub(c, '')
    end
  else
    s = s:gsub(p, '')
  end
  return s
end

--- Returns the string `s` with all the runs of the characters in `x`
-- replaced with a single character.
-- @tparam string s the string.
-- @tparam string p the pattern representing the characters to squeeze.
-- @tparam[opt] boolean plain if `true` the pattern is considered a plain string.
-- @treturn string the new string.
function squeeze(s, p, plain)
  local t, lc = {}, nil
  if plain then
    p = ('[%s]'):format(p)
  end
  for c in s:gmatch('.') do
    if c ~= lc then
      t[#t + 1] = c
      if c:match(p) then
        lc = c
      else
        lc = nil
      end
    end
  end
  return table_concat(t)
end

--- Inserts `x` before the character at the given `position` in `s`.
-- @tparam string s the string.
-- @tparam string x the string to insert
-- @tparam[opt] integer position the position to insert the string at; it must
-- be a valid index.
-- @treturn string the new string; or `s` if the index is not valid.
function insert(s, x, position)
    if #x == 0 or position == 0 then
      return s
    end
    if not position then
      return ('%s%s'):format(x, s)
    elseif position == 1 then
      return ('%s%s'):format(x, s)
    elseif position == -1 then
      return ('%s%s'):format(s, x)
    elseif position > 0 then
      return ('%s%s%s'):format(s:sub(1, position - 1), x, s:sub(position))
    end
    return ('%s%s%s'):format(s:sub(1, position - 1), x, s:sub(position))
end

--- Returns an array containing the string `s` split into lines.
-- @tparam string s the string.
-- @tparam[opt] integer maxn the maximum number of lines to return.
-- @treturn {string} an array whose elements contains the lines of `s`.
function lines(s, maxn)
  local a = {}
  foreachline(s, maxn, function(line)
    a[#a + 1] = line
  end)
  return a
end

--- Splits the string `s` into lines and invoke `f` with each of them.
-- @tparam string s the string.
-- @tparam[opt] integer maxn the maximum number of lines to process.
-- @tparam consumer f the function to invoke.
function foreachline(s, maxn, f)
  foreach(s, '\n\r', maxn or MAX_INT, f)
end

--- Splits the string `s` into substring divided by the given separator `sep`
-- and invoke `f` with each of them.
-- @tparam string s the string.
-- @tparam[opt=' '] string sep the separator.
-- @tparam[optchain] integer maxn the maximum number of strings to process.
-- @tparam consumer f the function to invoke.
function foreach(s, sep, maxn, f)
  if type(sep) == 'function' then
    f, sep, maxn = sep, ' ', MAX_INT
  elseif type(maxn) == 'function' then
    f, maxn = maxn, MAX_INT
  end
  sep = sep or ' '
  maxn = maxn or MAX_INT
  if maxn < 1 then
    return
  end
  local wp = ('([^%s]+)'):format(sep)
  local itr = s:gmatch(wp)
  local w = itr()
  while w and maxn > 0 do
    f(w)
    w, maxn = itr(), maxn - 1
  end
end

--- signature of a @{foreach} or @{foreachline} callback function
-- @ftype consumer
-- @tparam string s a string
-- @see foreach
-- @see foreachline

return M
