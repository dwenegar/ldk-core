--- Extensions to the `string` module.
-- @module ldk.stringx
local M = {}

local native = require 'ldk.stringx.native'

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
local table_pack= table.pack
local table_unpack= table.unpack

local _ENV = M

local L_SPACE = ('^%s+(.-)$')
local R_SPACE = ('^(.-)%s+$')
local LR_SPACE= ('^%s+(.-)%s+$')

local tmpbuf = {}

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
-- @return ... the captures of the pattern, if it contained any.
function findr(s, p, init, plain)
  local r1 = table_pack(s:find(p, init, plain))
  if #r1 == 0 then
    return nil
  end
  while true do
    local r2 = table_pack(s:find(p, r1[2] + 1, plain))
    if #r2 == 0 then
      return table_unpack(r1)
    end
    r1 = r2
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
  return (s:gsub('%$([^%$%s]+)', function(w)
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
  return (s:gsub('%$([^%$%s]+)(%%%S+)', function(w, fmt)
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
  if type(maxn) == 'function' then
    f, maxn = maxn, nil
  end
  foreach(s, '\n\r', maxn, f)
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

--- Centers a string on a specified width.
-- If the specified width is greater than the input string's length, returns a
-- new string padded with the specified character; otherwise it returns the input string
-- unchanged.
-- @tparam string s the string to be centered.
-- @tparam integer width the width of the line to center the line on.
-- @tparam[opt=' '] string pad the character to use for padding.
-- @treturn string the input string centered on a line of the specified width.
function center(s, width, pad)
  pad = pad or ' '
  if #s > width then
    return s
  end
  local margin = (width - #s) // 2
  local r, q = margin % #pad, margin // #pad

  local i = 1
  tmpbuf[i], i = pad:rep(q), i + 1
  if r > 0 then
    tmpbuf[i], i = pad:sub(1, r), i + 1
  end
  tmpbuf[i], i = s, i + 1

  margin = width - #s - margin
  r, q = margin % #pad, margin // #pad
  tmpbuf[i], i = pad:rep(q), i + 1
  if r > 0 then
    tmpbuf[i], i = pad:sub(1, r), i + 1
  end
  tmpbuf[i] = nil
  return table_concat(tmpbuf)
end

--- Expands the tabs in a given string into spaces.
-- @tparam string s the string whose tabs will be expaned.
-- @tparam[opt=8] integer tabsize the size in spaces of each tab.
-- @treturn string the input string with the tabs replaces by the specifed number of spaces.
function expand_tabs(text, tabsize)
  tabsize = tabsize or 8
  return (text:gsub('\t', (' '):rep(tabsize)))
end

--- Returns a left-justified string of the specified length by padding a given
-- string with the specified padding characters.
-- @tparam string s the string to be left-justified.
-- @tparam integer width the width of the line to left-justify the line on.
-- @tparam[opt=' '] string pad the character to use for padding.
-- @treturn string the input string left-justified on a line of the specified width.
function ljust(s, width, pad)
  pad = pad or ' '
  if #s >= width then
    return s
  end
  local margin = width - #s
  local r, q = margin % #pad, margin // #pad

  local i = 1
  tmpbuf[i], i = s, i + 1
  tmpbuf[i], i = pad:rep(q), i + 1
  if r > 0 then
    tmpbuf[i], i = pad:sub(1, r), i + 1
  end
  tmpbuf[i] = nil
  return table_concat(tmpbuf)
end

--- Returns a right-justified string of the specified length by padding a given
-- string with the specified padding characters.
-- @tparam string s the string to be right-justified.
-- @tparam integer width the width of the line to right-justify the line on.
-- @tparam[opt] string pad the character to use for padding.
-- @treturn string the input string right-justified on a line of the specified width.
function rjust(s, width, pad)
  pad = pad or ' '
  if #s >= width then
    return s
  end
  local margin = width - #s
  local r, q = margin % #pad, margin // #pad

  local i = 1
  tmpbuf[i], i = pad:rep(q), i + 1
  if r > 0 then
    tmpbuf[i], i = pad:sub(1, r), i + 1
  end
  tmpbuf[i], i = s, i + 1
  tmpbuf[i] = nil
  return table_concat(tmpbuf)
end

--- Wraps a given string to the specified width.
-- @tparam string s the string to be wrapped.
-- @tparam integer width the width the line is wrapped to.
-- @treturn string the input string wrapped to the specified width.
function wrap(s, width)
  if #s < width then
    return s
  end
  local i, len, spc = 1, 0, nil
  local function append(x, is_space)
    if i > 1 and len > 0 and len + #x > width then
      tmpbuf[i], i = '\n', i + 1
      len = 0
      if is_space then return end
    end
    if is_space then
      spc = x
    else
      if spc and len > 0 then
        tmpbuf[i], i = spc, i + 1
        spc = nil
      end
      tmpbuf[i], i = x, i + 1
    end
    len = len + #x
  end

  local le = 1
  for b, w, e in s:gmatch('()(%S+)()') do
    if b > le then
      append(s:sub(le, b - 1), true)
    end
    append(w)
    le = e
  end
  tmpbuf[i] = nil
  return table_concat(tmpbuf)
end

--- Replaces a format specifiers in a given string with the string representation of a
-- corresponding value; the function behaves like Lua's `string.format` but
-- also support positional specifiers: `%n$...`.
-- @tparam string s a format string.
-- @param ... the values to be formatted.
-- @treturn string a copy of `s` in which the format items have been replaced
-- by the string representation of the corresponding value.
-- @raise if positional and non positional format specifiers are used together.
function format(s, ...)
  local args = table_pack(...)
  local ss, i, p = s, 0, nil
  local b = {}
  repeat
    local h, n, fmt, t = ss:match('^(.-)%%(%d*)%$?([^%%]+)(.*)$')
    if #n > 0 then
      p, i = true, p == false and argerror(1, 'format', "invalid format") or tonumber(n)
    else
      p, i = false, p == true and argerror(1, 'format', "invalid format") or i + 1
    end
    b[#b + 1] = #h > 0 and h or nil
    b[#b + 1] = ('%' .. fmt):format(args[i])
    ss = t
  until #ss == 0
  return table_concat(b)
end

--- signature of a @{foreach} or @{foreachline} callback function
-- @ftype consumer
-- @tparam string s a string
-- @see foreach
-- @see foreachline

return M
