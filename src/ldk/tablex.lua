--- Extensions to the `table` module.
-- @module ldk.tablex

local M = {}

local _ = require 'ldk._base'
_.merge(M, table)
_ = nil

local next = next
local pairs = pairs
local ipairs = ipairs
local luatostring = tostring
local type = type
local rawequal = rawequal

local table_concat = table.concat
local table_sort = table.sort

local _ENV = M

local defaults = {
  eq = function(x, y)
    return x == y
  end,
  lt = function(x, y)
   return x < y
  end,
  le = function(x, y)
    return x <= y
  end,
  cmp = function(lhs, rhs)
    if lhs < rhs then
      return -1
    elseif lhs > rhs then
      return 1
    end
    return 0
  end,
  id = function(x)
    return x
  end,
  selectv = function(_, v)
    return v
  end,
  enpair = function(x, y)
    return { x, y }
  end,
}

--- Applies an accumulator function over a table.
-- @tparam table t the table to aggregate over.
-- @param[opt] acc the initial value of the accumulator.
-- @tparam accumulator f the accumulator function to be applied to each
-- key-value pair.
-- @return the final accumulator value.
function aggregate(t, acc, f)
  for k, v in pairs(t) do
    acc = f(k, v, acc)
  end
  return acc
end

--- Determines whether all the key-value pairs of a table satisfy a condition.
-- @tparam table t a table containing the key-value pairs to apply the predicate to.
-- @tparam predicate p a function to test each key-value pair for a condition.
-- @treturn boolean `true` if every key-value pair of the table satisfies the
-- specified predicate, or if the table is empty; otherwise `false`.
function all(t, p)
  for k, v in pairs(t) do
    if not p(k, v) then
      return false
    end
  end
  return true
end

--- Determines whether any key-value pair of a table satisfy a condition.
-- @tparam table t a table containing the key-value pairs to apply the predicate to.
-- @tparam predicate p a function to test each key-value pair for a condition.
-- @treturn boolean `true` if any key-value pair of the table satisfies the
-- specified predicate, or if the table is empty; otherwise `false`.
function any(t, p)
  for k, v in pairs(t) do
    if p(k, v) then
      return true
    end
  end
  return false
end

--- Calculates the sum of the array of numbers that are obtained by applying a
-- transform function to each key-value pair of a table.
-- @tparam array t a table to calculate the average of.
-- @tparam[opt] transform f a transform function to apply to each key-value pair.
-- @treturn number the sum of the projected key-value pairs.
function sum(t, f)
  f = f or defaults.selectv
  local sum, n = 0, 0
  for k, v in pairs(t) do
    sum = sum + f(k, v)
    n = n + 1
  end
  return sum, n
end

--- Calculates the average of the values obtained by applying a
-- transform function to each key-value pair of a table.
-- @tparam table t a table to calculate the average of.
-- @tparam[opt] transform f a transform function to apply to each element.
-- @treturn number the average of the projected values; `nil` if the table is empty.
function avg(t, f)
  local s, n = sum(t, f)
  if n > 0 then
    return s / n
  end
end

--- Fills a table with the specified value.
-- @tparam table t a table to fill.
-- @param v the value to use to fill the table.
-- @treturn table the input table.
function fill(t, v)
  for k in pairs(t) do
    t[k] = v
  end
  return t
end

--- Projects each key-value pair of a table into a new value.
-- @tparam table t a table to invoke the transforma function on.
-- @tparam transform f a transform function to apply to each key-value pair; the
-- second parameter is the index of the key-value pair.
-- @treturn table a table whose key-value pairs are the the result of applying
-- the specified transform function on the key-value pairs of the input table.
function map(t, f)
  local r = {}
  for k, v in pairs(t) do
    local nk, nv = f(k, v)
    if nk ~= nil then
      r[nk] = nv
    end
  end
  return r
end

--- Groups the key-value pairs of a table according to a specified key selector.
-- @tparam table t a table whose key-value pairs to group.
-- @tparam keyselector f a function to extract the key for each key-value pair.
-- @treturn table a collection of key-value pairs where each key-value pair represents a
-- a projection over a group and its key.
function groupby(t, f)
  local r = {}
  for k, v in pairs(t) do
    local gk = f(k, v)
    if gk ~= nil then
      local rt = r[gk]
      if not rt then
        rt = {}
        r[gk] = rt
      end
      rt[k] = v
    end
  end
  return r
end

--- Applies a transform function to each value of a table and return the
-- the maximum of the projected values.
-- @tparam table t an table to determine the maximum value of.
-- @tparam transform f a transform function to apply to each value.
-- @return the key of maximum projected value in the table, or `nil` if the table is empty.
-- @return the maximum projected value in the table, or `nil` if the table is empty.
function max(t, f)
  f = f or defaults.id
  local rk, rv
  for k, v in pairs(t) do
    local fv = f(v)
    if rv == nil or fv > rv then
      rk, rv = k, fv
    end
  end
  return rk, rv
end

--- Applies a transform function to each value of a table and returns the
-- maximum according to the projected values.
-- @tparam table t a table to determine the maximum value of.
-- @tparam transform f a transform function to apply to each value.
-- @return the key of maximum value in the table according to the transform function
-- or `nil` if the table is empty.
-- @return the maximum value in the table according to the transform function,
-- or `nil` if the table is empty.
function maxby(t, f)
  local rk, rv, fr
  for k, v in pairs(t) do
    local fv = f(v)
    if fr == nil or fv > fr then
      rk, rv, fr = k, v, fv
    end
  end
  return rk, rv
end

--- Applies a transform function to each value of a table and return the
-- the minimum of the projected values.
-- @tparam table t a table to determine the minimum value of.
-- @tparam[opt] transform f a transform function to apply to each value.
-- @return the minimum projected value in the table, or `nil` if the table is empty.
function min(t, f)
  f = f or defaults.id
  local rk, rv
  for k, v in pairs(t) do
    local fv = f(v)
    if rv == nil or fv < rv then
      rk, rv = k, fv
    end
  end
  return rk, rv
end

--- Applies a transform function to each value of a table and returns the
-- minimum according to the projected values.
-- @tparam table t a table to determine the minimum value of.
-- @tparam transform f a transform function to apply to each value.
-- @return the minimum value in the table according to the transform function,
-- or `nil` if the table is empty.
function minby(t, f)
  local rk, rv, fr
  for k, v in pairs(t) do
    local fv = f(v)
    if fr == nil or fv < fr then
      rk, rv, fr = k, v, fv
    end
  end
  return rk, rv
end

--- Creates a table with the keys of a table.
-- @tparam table t the table tho return the keys of.
-- @tparam[opt] boolean sorted if `true` the keys will be sorted.
-- @tparam[opt] comparator cmp a function used to compare each key.
-- @treturn table a table with the keys of the input table.
function keys(t, sorted, cmp)
  local r = {}
  for k in pairs(t) do
    r[#r + 1] = k
  end
  if sorted then
    table_sort(r, cmp)
  end
  return r
end

--- Creates an iterator over the values of a table.
-- @tparam table t the table tho return an iterator of.
-- @treturn function an iterator over the values of the input table.
function values(t)
  local k, v
  return function()
    k, v = next(t, k)
    return v
  end
end



--- Determines whether a table contains a specified value by using the given
-- equality comparer.
-- @tparam table t the table in which to locate the value.
-- @param v the value to locate in the table.
-- @tparam[opt] function eq the function to be used to test the value for equality.
-- @treturn boolean `true` if the table contains the specified value;
-- `false` otherwise.
function containsv(t, v, eq)
  eq = eq or defaults.eq
  for _, x in pairs(t) do
    if eq(x, v) then
      return true
    end
  end
  return false
end

--- Determines whether a table contains a specified key by using the given
-- equality comparer.
-- @tparam table t the table in which to locate the value.
-- @param k the key to locate in the table.
-- @tparam[opt] function eq the function to be used to test the key for equality.
-- @treturn boolean `true` if the table contains the specified key;
-- `false` otherwise.
function containsk(t, k, eq)
  if not eq then
    return t[k] ~= nil
  end
  for x in pairs(t) do
    if eq(x, k) then
      return true
    end
  end
  return false
end

--- Counts how many key-value pairs of a table satisfy a condition.
-- @tparam table t a table containing the key-value pairs to be tested and counted.
-- @tparam predicate p a function to test each key-value pair.
-- @treturn integer the number of key-value pairs satisfying the specified predicate.
function count(t, p)
  local n = 0
  for k, v in pairs(t) do
    if p(k, v) then
      n = n + 1
    end
  end
  return n
end

local function _eq(t1, t2, eq)

  local function _eqv(x, y)
    local tx = type(x)
    local ty = type(y)
    if y == nil or ty ~= tx then
      return false
    elseif tx == 'table' then
      if not _eq(x, y, eq) then
        return false
      end
    elseif not eq(x, y) then
      return false
    end
    return true
  end

  if rawequal(t1, t2)
    then return true
  end
  local k1, v1, k2, v2
  eq = eq or defaults.eq
  while true do
    k1, v1 = next(t1, k1)
    k2, v2 = next(t2, k2)
    if k1 == nil then
      return k2 == nil
    elseif k2 == nil then
      return false
    end
    if k1 == k2 then
      local v21 = t2[k1]
      if not _eqv(v1, v21) then
        return false
      end
    else
      local v12, v21 = t1[k2], t2[k1]
      if v12 == nil or v21 == nil or not _eqv(v1, t1, v21) or not _eqv(v2, v12) then
        return false
      end
    end
  end
end

--- Compares two tables for equality.
-- @tparam table t1 the first table to compare.
-- @tparam table t2 the second table to compare.
-- @tparam function[opt] eq the function used to test the table's values for equality.
-- @treturn bool `true` if the tables are equals, `false` otherwise.
function eq(t1, t2, eq)
  return _eq(t1, t2, eq)
end

--- Filters a table based on a predicate.
-- @tparam table t the table containing the key-value pairs to be tested.
-- @tparam predicate p the function used to test each key-value pair.
-- @treturn table a table containing key-value pairs satisfying the condition.
function filter(t, p)
  local r = {}
  for k, v in pairs(t) do
    if p(k, v) then
      r[k] = v
    end
  end
  return r
end

--- Removes all key-value pairs from a table.
-- @tparam table t the table to wipe.
-- @treturn table the empty input table.
function clear(t)
  for k in pairs(t) do
    t[k] = nil
  end
  return t
end

--- Copies the key-value pairs from a table to another table.
-- @tparam table t1 the table to copy from.
-- @tparam table t2 the table to copy to.
-- @treturn table the destination table.
function copy(t1, t2)
  for k, v in pairs(t1) do
    t2[k] = v
  end
  return t2
end

-- Searches a table for the first key-value pair satisfying a specified
-- condition.
-- @tparam table t an table to be searched.
-- @tparam predicate p a function to test each key-value pair.
-- @return the first key-value pair satisfying the specified condition; `nil` otherwise.
function find(t, p)
  for k, v in pairs(t) do
    if p(k, v) then
      return k, v
    end
  end
end

--- Determines whether a table is empty or not.
-- @tparam table t a table containing the key-value pairs to be tested.
-- @treturn boolean `true` if the table is empty, otherwise `false`.
function isempty(t)
  return next(t) == nil
end

-- Searches a table for the first key-value pair satisfying a specified
-- condition, and remove it.
-- @tparam table t a table to be searched.
-- @tparam predicate p a function to test each key-value pair.
-- @treturn boolean `true` if any key-value pair is removed; otherwise `false`.
function removeif(t, p)
  for k, v in pairs(t) do
    if p(k, v) then
      t[k] = nil
      return true
    end
  end
  return false
end

--- Searches a table for all the key-value pairs satisfying a specified
-- condition, and remove them.
-- @tparam table t a table to be searched.
-- @tparam predicate p a function to test each key-value pair.
-- @treturn integer the number of key-value pairs removed.
function removeallif(t, p)
  local n = 0
  for k, v in pairs(t) do
    if p(k, v) then
      t[k] = nil
      n = n + 1
    end
  end
  return n
end

--- Returns the string representation of a table.
-- @tparam table t the table to return the string representation of.
-- @tparam[opt] boolean sortkeys if `true` the keys of the table will be sorted.
-- @treturn string a string representing the given table.
function tostring(t, sortkeys)
  local buf, refs, ref, tabs = {}, {}, 0, 0
  local function build(x)
    if type(x) == 'string' then
      buf[#buf + 1] = ('%q'):format(x)
    elseif type(x) ~= 'table' then
      buf[#buf + 1] = luatostring(x)
    elseif refs[x] then
      buf[#buf + 1] = '@'
      buf[#buf + 1] = refs[x]
    else
      refs[x], ref = ref, ref + 1
      if isempty(x) then
        buf[#buf + 1] = '{} -- '
        buf[#buf + 1] = refs[x]
      else
        buf[#buf + 1] = '{ -- '
        buf[#buf + 1] = refs[x]
        buf[#buf + 1] = '\n'
        tabs = tabs + 1
        for _, k in ipairs(keys(x, sortkeys)) do
          buf[#buf + 1] = ('  '):rep(tabs)
          if type(k) == 'string' then
            buf[#buf + 1] = ('[%q] = '):format(k)
          elseif type(k) == 'number' then
            buf[#buf + 1] = ('[%d] = '):format(k)
          else
            buf[#buf + 1] = ('[%s] = '):format(k)
          end
          build(x[k])
          buf[#buf + 1] = ',\n'
        end
        tabs = tabs - 1
        buf[#buf + 1] = ('  '):rep(tabs)
        buf[#buf + 1] = '}'
      end
    end
  end
  build(t)
  return table_concat(buf)
end

--- Merge the given tables.
-- @tparam[opt] boolean deep if `true` tables will be merged recursively.
-- @tparam table ... the tables to merge.
-- @treturn table a new table containing the key-value pairs of the input tables.
function merge(deep, ...)
  if type(deep) == 'table' then
    return merge(false, deep, ...)
  end
  local r = {}
  for i = 1, select('#', ...) do
    local t = select(i, ...)
    for k, v in pairs(t) do
      if deep and type(r[k]) == 'table' and type(v) == 'table' then
        r[k] = merge(deep, r[k], v)
      else
        r[k] = v
      end
    end
  end
  return r
end

--- Updates a table with values of another specified table.
-- @tparam table t1 atable to update.
-- @tparam table t2 the table containing the updated values.
-- @tparam[opt] boolean deep if `true` performs a deep update.
function update(t1, t2, deep)
  for k, v in pairs(t2) do
    if t1[k] ~= nil then
      if deep and type(t1[k]) == 'table' and type(v) == 'table' then
        update(t1[k], v, deep)
      else
        t1[k] = v
      end
    end
  end
end

--- Invokes a function on each key-value pair of a table.
-- @tparam table t the table to invoke the function on.
-- @tparam function f a function to apply to invoke on each key-value pair.
function each(t, f)
  for k, v in pairs(t) do
    f(k, v)
  end
end

return M

--- Signature of a predicate function.
-- @ftype predicate
-- @param k the key-value pair's key.
-- @param v the key-value pair's value.
-- @treturn boolean `true` if the key-value pair matches the condition, `false` otherwise.

--- Signature of a key selector function.
-- @ftype keyselector
-- @param k the key-value pair's key.
-- @param v the key-value pair's value.
-- @return any value that can be used as a table key.

--- Signature of a transform function.
-- @ftype transform
-- @param k the key-value pair's key.
-- @param v the key-value pair's value.
-- @return the transformed key, or `nil` the key-value pair must be skipped.
-- @return the transformed value, or `nil` the key-value pair must be skipped.
