--- Provides methods for creating, manipulating, and searching arrays.
-- @module ldk.array
local M = {}

local ipairs = ipairs
local rawequal = rawequal
local type = type

local math_max = math.max
local math_min = math.min
local math_random = math.random

local table_concat = table.concat
local table_move = table.move
local table_remove = table.remove

local _ENV = M

local defaults = {
  eq = function(x, y)
    return x == y
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
  make_pair = function(x, y)
    return {x, y}
  end
}

local function normalize(a, from, to, f)
  if type(from) == 'function' then
    f, from, to = from, 1, #a
  elseif type(to) == 'function' then
    f, to = to, #a
  end
  from = from or 1
  to = to or #a
  if from < 0 then
    from = from + #a + 1
  end
  if to < 0 then
    to = to + #a + 1
  end
  from = math_max(1, from)
  to = math_min(#a, to)
  return from, to, f
end

--- Creates an array using the specified values.
-- @param ... the values to be placed in the array.
-- @treturn array a new array with the given values.
function of(...)
  return {...}
end

--- Creates an array containing a sequence of numbers using the given parameters.
-- @tparam integer len the length of the sequence to generate.
-- @tparam integer from the first value of the sequence.
-- @tparam[opt] number step the difference between two consecutive values of the
-- sequence.
-- @treturn array an array of numbers of the specified length.
function seq(len, from, step)
  from, step = from or 0, step or 1
  local r = {}
  for i = 1, len do
    r[i], from = from, from + step
  end
  return r
end

--- Creates an array of the specified length using the a generator function.
-- @tparam integer len the length of the array to generate.
-- @tparam function f a generator function used to generate the elements of the
-- array; the first argument of the function is the index of the element's index.
-- @treturn array an array of the specified length.
function with(len, f)
  local r = {}
  for i = 1, len do
    r[i] = f(i)
  end
  return r
end

--- Creates an array of the specified length using the given value.
-- @tparam integer len the length of the array to generate.
-- @param v the value to generate the array with.
-- @treturn array an array of the specified length containing the given value.
function rep(len, v)
  local r = {}
  for i = 1, len do
    r[i] = v
  end
  return r
end

--- Concatenates the given arrays.
-- @tparam array ... the arrays to concatenate.
-- @treturn array an array containing the concatenated elements of the input arrays.
function cat(...)
  local r = {}
  for _, x in ipairs({...}) do
    copy(x, r, #r + 1)
  end
  return r
end

--- Creates a set from a range of elements of an array.
-- @tparam array a an array to create a set from.
-- @tparam[opt] integer from the starting index of the range.
-- @tparam[optchain] integer to the ending index of the range.
-- @treturn array a set containing the elements of the input array.
function toset(a, from, to)
  if #a == 0 then
    return {}
  end
  from, to = normalize(a, from, to)
  local r = {}
  for i = from, to do
    r[a[i]] = true
  end
  return r
end

--- Creates a map from a range of elements of an array.
-- @tparam array a an array to create a set from.
-- @tparam[opt] integer from the starting index of the range.
-- @tparam[optchain] integer to the ending index of the range.
-- @tparam[optchain] function f function used to calculate the map values.
-- @treturn table a map whose keys are the value of the input array, and the
-- values are the result of the application of `f`.
function tomap(a, from, to, f)
  from, to, f = normalize(a, from, to, f)
  local r = {}
  f = f or defaults.id
  for i = from, to do
    local x = a[i]
    r[x] = f(x)
  end
  return r
end

--- Creates a bag from a range of elements of an array.
-- @tparam array a an array to create a set from.
-- @tparam[opt] integer from the starting index of the range.
-- @tparam[optchain] integer to the ending index of the range.
-- @treturn table containing the elements of the input array TODO
function tobag(a, from, to)
  if #a == 0 then
    return {}
  end
  from, to = normalize(a, from, to)
  local r = {}
  for i = from, to do
    local x = a[i]
    r[x] = (r[x] or 0) + 1
  end
  return r
end

--- Applies an accumulator function over an array.
-- @tparam array a an array to aggregate over.
-- @param acc the initial value of the accumulator.
-- @tparam function f an accumulator function to be applied to each element;
-- the second argument is the previous accumulator's value.
-- @return the final accumulator value.
function aggregate(a, acc, f)
  for _, x in ipairs(a) do
    acc = f(x, acc)
  end
  return acc
end

--- Calculates the sum of the array of numbers that are obtained by applying a
-- transform function to each element of an array.
-- @tparam array a an array to calculate the average of.
-- @tparam[opt] transform f a transform function to apply to each element.
-- @treturn number the sum of the projected values.
function sum(a, f)
  if #a == 0 then
    return 0
  end
  f = f or defaults.id
  local sum = 0
  for _, x in ipairs(a) do
    sum = sum + f(x)
  end
  return sum
end

--- Calculates the average of the array of numbers that are obtained by applying a
-- transform function to each element of an array.
-- @tparam array a an array to calculate the average of.
-- @tparam[opt] transform f a transform function to apply to each element.
-- @treturn number the average of the projected values; `nil` if the array is empty.
function avg(a, f)
  if #a == 0 then
    return
  end
  return sum(a, f) / #a
end

--- Determines whether all the elements of an array satisfy a condition.
-- @tparam array a an array containing the elements to apply the predicate to.
-- @tparam predicate p a function to test each element for a condition.
-- @treturn boolean `true` if every element of the array satisfies the
-- specified predicate, or if the array is empty; otherwise `false`.
function all(a, p)
  if #a == 0 then
    return true
  end
  for _, x in ipairs(a) do
    if not p(x) then
      return false
    end
  end
  return true
end

--- Determines whether any element of an array satisfy a condition.
-- @tparam array a an array containing the elements to apply the predicate to.
-- @tparam predicate p a function to test each element for a condition.
-- @treturn boolean `true` if any element of the array satisfies the
-- specified predicate, or if the array is empty; otherwise `false`.
function any(a, p)
  if #a == 0 then
    return true
  end
  for _, x in ipairs(a) do
    if p(x) then
      return true
    end
  end
  return false
end

--- Counts how many elements of an array satisfy a condition.
-- @tparam array a an array containing the elements to be tested and counted.
-- @tparam predicate p a function to test each element.
-- @treturn integer the number of elements satisfying the specified predicate.
function count(a, p)
  if #a == 0 then
    return 0
  end
  local n = 0
  for _, x in ipairs(a) do
    if p(x) then
      n = n + 1
    end
  end
  return n
end

--- Returns distinct elements from an array.
-- @tparam array a the array to remove the duplicated elements from.
-- @treturn array a new array containing distinct elements from the input array.
function distinct(a)
  if #a == 0 then
    return {}
  end
  local r, seen = {}, {}
  for _, x in ipairs(a) do
    if not seen[x] then
      r[#r + 1] = x
      seen[x] = true
    end
  end
  return r
end

--- Produces the set difference of two arrays.
-- @tparam array a1 an array whose elements that are not also in `a2` will be returned.
-- @tparam array a2 an array whose elements that also occur in `a1` will cause those
-- elements to be removed from the returned sequence.
-- @treturn array an array containing the set difference of the two input arrays.
function except(a1, a2)
  if #a1 == 0 then
    return {}
  end
  local r, seen = {}, toset(a2)
  for _, x in ipairs(a1) do
    if not seen[x] then
      r[#r + 1] = x
    end
  end
  return r
end

--- Resturns the set intersection of two arrays.
-- @tparam array a1 an array whose distinct elements that also appear in `a2` will be returned.
-- @tparam array a2 an array whose distinct elements that also appear in `a1` will be returned.
-- @treturn array an array that contains the elements that appear in `a1` and `a2`.
function intersect(a1, a2)
  if #a1 == 0 or #a2 == 0 then
    return {}
  end
  local r, seen = {}, tobag(a2)
  for _, x in ipairs(a1) do
    local n = seen[x]
    if n then
      r[#r + 1] = x
      n = n - 1
      seen[x] = n > 0 and n
    end
  end
  return r
end

--- Filters an array based on a predicate.
-- @tparam array a an array to filter.
-- @tparam predicate p a function to test each element.
-- @treturn array an array containing elements from the input array satisfying
-- the specified condition.
function filter(a, p)
  if #a == 0 then
    return {}
  end
  local r = {}
  for i, v in ipairs(a) do
    if p(v, i) then
      r[#r + 1] = v
    end
  end
  return r
end

--- Projects each element of an array into a new value.
-- @tparam array a an array to invoke the transforms function on.
-- @tparam transform f a transform function to apply to each element; the
-- second parameter is the index of the element.
-- @treturn array an array whose elements are the the result of applying
-- the specified transform function on the elements of the input array.
function map(a, f)
  local r = {}
  for i, v in ipairs(a) do
    r[#r + 1] = f(v, i)
  end
  return r
end

--- Applies a trasform function to the elements of an array and flatten the
-- resulting array.
-- @tparam array a the array to invoke the transformation function on.
-- @tparam function f a transform function to apply to each element; the
-- second parameter is the position of the element in the array; if the function
-- returns `nil` the element will be skipped; the function must return an array.
-- @treturn array a new array whose elements are the the result of invoking
-- the specified transform function on the elements of an array.
function mapmany(a, f)
  local r = {}
  for i, v in ipairs(a) do
    local c = f(v, i)
    if c then
      copy(c, r, #r + 1)
    end
  end
  return r
end

--- Groups the elements of an array according to a specified key selector.
-- @tparam array a an array whose elements to group.
-- @tparam keyselector f a function to extract the key for each element.
-- @treturn array a collection of elements where each element represents a
-- a projection over a group and its key.
function groupby(a, f)
  local r = {}
  for i, x in ipairs(a) do
    local gk = f(x, i)
    if gk ~= nil then
      local t = r[gk]
      if not t then
        t = {}
        r[gk] = t
      end
      t[#t + 1] = x
    end
  end
  return r
end

--- Applies a transform function to each element of an array and return the
-- the maximum of the projected values.
-- @tparam array a an array to determine the maximum value of.
-- @tparam[opt] transform f a transform function to apply to each element.
-- @return the maximum projected value in the array, or `nil` if the array is empty.
function max(a, f)
  if #a == 0 then
    return
  end
  f = f or defaults.id
  local fr
  for _, x in ipairs(a) do
    local fx = f(x)
    if fr == nil or fx > fr then
      fr = fx
    end
  end
  return fr
end

--- Applies a transform function to each element of an array and returns the
-- maximum according to the projected values.
-- @tparam array a an array to determine the maximum value of.
-- @tparam transform f a transform function to apply to each element.
-- @return the maximum value in the array according to the transform function,
-- or `nil` if the array is empty.
function maxby(a, f)
  if #a == 0 then
    return
  end
  local r, fr
  for _, x in ipairs(a) do
    local fx = f(x)
    if fr == nil or fx > fr then
      r, fr = x, fx
    end
  end
  return r
end

--- Applies a transform function to each element of an array and return the
-- the minimum of the projected values.
-- @tparam array a an array to determine the minimum value of.
-- @tparam[opt] transform f a transform function to apply to each element.
-- @return the minimum projected value in the array, or `nil` if the array is empty.
function min(a, f)
  if #a == 0 then
    return
  end
  f = f or defaults.id
  local fr
  for _, x in ipairs(a) do
    local fx = f(x)
    if fr == nil or fx < fr then
      fr = fx
    end
  end
  return fr
end

--- Applies a transform function to each element of an array and returns the
-- minimum according to the projected values.
-- @tparam array a an array to determine the minimum value of.
-- @tparam transform f a transform function to apply to each element.
-- @return the minimum value in the array according to the transform function,
-- or `nil` if the array is empty.
function minby(a, f)
  if #a == 0 then
    return
  end
  local r, fr
  for _, x in ipairs(a) do
    local fx = f(x)
    if r == nil or fx < fr then
      r, fr = x, fx
    end
  end
  return r
end

--- Drops a specified number of elements from an array and returns the
-- remaining elements.
-- @tparam array a an array to return elements from.
-- @tparam[opt=1] integer n the number of elements to return.
-- @treturn array an array containing the elements occurring after the specified
-- index in the input array.
function drop(a, n)
  n = n or 1
  if #a == 0 or n == #a then
    return {}
  end
  return table_move(a, n + 1, #a, 1, {})
end

--- Drops a specified number of elements from an array and returns the
--- Skips the elements of an array as long as they satisfy a specified condition
-- and returns the remaining elements.
-- @tparam array a an array to return elements from.
-- @tparam predicate p a function to test each element.
-- @treturn array an array containing the element from the input array occurring
-- after the last element satisfying the specified condition.
function dropwhile(a, p)
  if #a == 0 then
    return {}
  end
  local i, n = 1, #a
  while i <= n and p(a[i]) do
    i = i + 1
  end
  local r = {}
  for j = i, n do
    r[#r + 1] = a[j]
  end
  return r
end

--- Returns a specified number of elements from the start an array.
-- @tparam array a an array to return elements from.
-- @tparam[opt=1] integer n the number of elements to return.
-- @treturn array an array containing the specified number of elements from
-- the start of the input array.
function take(a, n)
  n = n or 1
  if #a == 0 or n == 0 then
    return {}
  end
  return table_move(a, 1, n or 1, 1, {})
end

--- Returns elements from an array as long as a specified condition is true.
-- @tparam array a an array to return elements from.
-- @tparam predicate p a function to test each element.
-- @treturn array an array containing elements from the input array occurring
-- before the first element not satisfying the specified condition.
function takewhile(a, p)
  local t = {}
  for _, v in ipairs(a) do
    if not p(v) then
      break
    end
    t[#t + 1] = v
  end
  return t
end

--- Applies a specified function to the corresponding elements of two arrays,
-- and returns the resulting elements.
-- @tparam array a1 the first array to merge.
-- @tparam array a2 the second array to merge.
-- @tparam function f a function that specifies how to merge the elements
-- from the two arrays.
-- @treturn array an array containing merged elements of the input arrays.
function zip(a1, a2, f)
  f = f or defaults.make_pair
  local r = {}
  for i = 1, math_min(#a1, #a2) do
    local x, y = a1[i], a2[i]
    r[i] = f(x, y)
  end
  return r
end

--- Searches a range of elements in a sorted array for a value using the
-- specified comparer.
-- @tparam array a the sorted array to be searched.
-- @param v the value to search.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam[opt] comparer cmp the comparer to use when comparing elements.
-- @treturn integer the index of the specified value in the array; or `nil` if
-- the element is not found.
function binsearch(a, v, from, to, cmp)
  from, to, cmp = normalize(a, from, to, cmp)
  cmp = cmp or defaults.cmp
  while from <= to do
    local mid = (from + to) // 2
    local test = cmp(a[mid], v)
    if test == 0 then
      return mid
    elseif test > 0 then
      to = mid - 1
    else
      from = mid + 1
    end
  end
end

--- Removes all the elements from an array.
-- @tparam array a an array to clear.
function clear(a)
  for i = #a, 1, -1 do
    a[i] = nil
  end
end

--- Copies a range of elements of an array to another array starting at the
-- specified index.
-- @tparam array a1 the array to copy from.
-- @tparam[opt] integer from1 the starting index of the range to copy.
-- @tparam[optchain] integer to1 the ending index of the range to copy.
-- @tparam array a2 the array to copy to.
-- @tparam[opt] integer from2 the index at which copying begins.
-- @treturn array the destination array.
function copy(a1, from1, to1, a2, from2)
  if type(from1) == 'table' then
    a2, from2, from1, to1 = from1, to1, 1, #a1
  elseif type(to1) == 'table' then
    a2, from2, to1 = to1, a2, #a1
  end
  a2 = a2 or {}
  from1, to1 = normalize(a1, from1, to1)
  if from1 > to1 then
    return a2
  end
  return table_move(a1, from1, to1, from2 or 1, a2)
end

--- Compares two arrays using a specified comparer.
-- @tparam array a1 the first array to be compared.
-- @tparam array a2 the second array to be compared.
-- @tparam comparer cmp the comparator used to compare the arrays' elements.
-- @treturn int a positive number if the first array is greater than the second;
-- a negative number if the second array is greater than the first; zero otherwise.
function cmp(a1, a2, cmp)
  if a1 and rawequal(a1, a2) then
    return 0
  end
  if a1 == nil then
    return a2 == nil and 0 or -1
  elseif a2 == nil then
    return 1
  end
  if #a1 < #a2 then
    return -1
  elseif #a1 > #a2 then
    return 1
  end
  cmp = cmp or defaults.cmp
  for i = 1, #a1 do
    local t = cmp(a1[i], a2[i])
    if t ~= 0 then
      return t
    end
  end
  return 0
end

--- Compares two arrays for equality using the specified equality comparer.
-- @tparam array a1 the first array to be compared.
-- @tparam array a2 the second array to be compared.
-- @tparam[opt] eq_comparer eq a function to test the elements of each array for
-- equality.
-- @treturn boolean `true` if the arrays are equals, otherwise `false`.
function eq(a1, a2, eq)
  if a1 and rawequal(a1, a2) then
    return true
  end
  local n1, n2 = #a1, #a2
  if n1 ~= n2 then
    return false
  end
  eq = eq or defaults.eq
  for i = 1, n1 do
    if not eq(a1[i], a2[i]) then
      return false
    end
  end
  return true
end

-- Searches a range of elements of an array for the first element satisfying a
-- specified condition.
-- @tparam array a an array to be searched.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam predicate p a function to test each element.
-- @return the first element satisfying the specified condition; `nil` otherwise.
-- @treturn integer the index of the first element satisfying the specified condition; `nil` otherwise.
function find(a, from, to, p)
  if #a == 0 then
    return
  end
  from, to, p = normalize(a, from, to, p)
  for i = from, to do
    if p(a[i]) then
      return a[i], i
    end
  end
end

-- Searches a range of elements of an array for the last element satisfying a
-- specified condition.
-- @tparam array a an array to be searched.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam predicate p a function to test each element.
-- @return the last element satisfying the specified condition; `nil` otherwise.
-- @treturn integer the index of the last element satisfying the specified condition; `nil` otherwise.
function findlast(a, from, to, p)
  if #a == 0 then
    return
  end
  from, to, p = normalize(a, from, to, p)
  for i = to, from, -1 do
    if p(a[i]) then
      return a[i], i
    end
  end
end

--- Searches a range of elements of an array for all the elements satisfying a
-- specified condition.
-- @tparam array a an array to be searched.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam predicate p a function to test each element.
-- @treturn array the elements satisfying the specified condition; `nil` otherwise.
function findall(a, from, to, p)
  if #a == 0 then
    return {}
  end
  from, to, p = normalize(a, from, to, p)
  local r = {}
  for i = from, to do
    if p(a[i]) then
      r[#r + 1] = a[i]
    end
  end
  return r
end

--- Determines whether the specified range of an array contains a specified value
-- using the specified equality comparer.
-- @tparam array a an array in which to locate the value.
-- @param v the value to locate in the array.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam[optchain] eq_comparer eq the function to compare values for equality.
-- @treturn boolean `true` if the array contains the specified value; `false` otherwise.
function contains(a, v, from, to, eq)
  return indexof(a, v, from, to, eq) ~= nil
end

--- Determines whether an array is empty or not.
-- @tparam array a an array containing the elements to be tested.
-- @treturn boolean `true` if the array is empty, otherwise `false`.
function isempty(a)
  return #a == 0
end

--- Searches an array for the specified value using a specified equality
-- comparer, and returns the index of the first occurrence within the specified
-- range.
-- @tparam array a an array to be searched.
-- @param v the value to look for.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam[optchain] eq_comparer eq the function to compare values.
-- @treturn integer the index of the first occurrences of the specified value,
-- if found; `nil` otherwise.
function indexof(a, v, from, to, eq)
  if #a == 0 then
    return
  end
  from, to, eq = normalize(a, from, to, eq)
  eq = eq or defaults.eq
  for i = from, to do
    if eq(a[i], v) then
      return i
    end
  end
end

--- Searches an array for the specified value using a specified equality
-- comparer, and returns the index of the last occurrence within the specified
-- range.
-- @tparam array a an array to be searched.
-- @param v the value to look for.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam[optchain] eq_comparer eq the function to compare values.
-- @treturn integer the index of the last occurrences of the specified value,
-- if found; `nil` otherwise.
function lastindexof(a, v, from, to, eq)
  if #a == 0 then
    return
  end
  from, to, eq = normalize(a, from, to, eq)
  eq = eq or defaults.eq
  for i = to, from, -1 do
    if eq(a[i], v) then
      return i
    end
  end
end

--- Extracts a range of elements of an array.
-- @tparam array a an array to extract the elements from.
-- @tparam integer from the starting index of the range to extract.
-- @tparam[optchain] integer to the ending index of the range to extract.
-- @treturn an array with the elements of the input array in the specified range.
function range(a, from, to)
  if #a == 0 then
    return {}
  end
  from, to = normalize(a, from, to)
  return table_move(a, from, to, 1, {})
end

-- Reverses in-place a range of elements of an array.
-- @tparam array a an array to reverse.
-- @tparam[opt] integer from the starting index of the range to reverse.
-- @tparam[optchain] integer to the ending index of the range to reverse.
function reverse(a, from, to)
  if #a == 0 then
    return a
  end
  from, to = normalize(a, from, to)
  while from < to do
    a[from], a[to] = a[to], a[from]
    from, to = from + 1, to - 1
  end
  return a
end

--- Shuffles in-place a range of elements of an array..
-- @tparam array a an array to shuffle.
-- @tparam[opt] integer from the starting index of the range to shuffle.
-- @tparam[optchain] integer to the ending index of the range to shuffle.
function shuffle(a, from, to)
  from, to = normalize(a, from, to)
  for i = to, from, -1 do
    local j = math_random(from, i)
    a[i], a[j] = a[j], a[i]
  end
end

--- Fills a range of an array with a specified value.
-- @tparam array a an array to fill.
-- @param v the value to use to fill the array.
-- @tparam[opt] integer from the starting index of the range to fill.
-- @tparam[optchain] integer to the ending index of the range to fill.
-- @treturn array the input array.
function fill(a, v, from, to)
  from, to = normalize(a, from, to)
  for i = from, to do
    a[i] = v
  end
  return a
end

--- Grows an array to the specified length using the specified value.
-- @tparam array a the array to be grown.
-- @tparam integer len the new length of the array.
-- @param[opt] v the value to be used to fill the array; if not specified the last
-- value of `a` will be used if the array is not empty, otherwise `true` will be used.
function grow(a, len, v)
  if v == nil then
    v = a[#a] or true
  end
  for i = #a + 1, len do
    a[i] = v
  end
  return a
end

--- Shrinks an array to a specified length.
-- @tparam array a an array to be shrunk.
-- @tparam integer len the new length of the array.
function shrink(a, len)
  for i = len + 1, #a do
    a[i] = nil
  end
  return a
end

-- Removes the element of an array at the specified index.
-- @tparam array a an array to remove the element from.
-- @tparam integer i the index of the element to remove.
-- @return the element removed; `nil` otherwise.
function removeat(a, i)
  local v = a[i]
  table_remove(a, i)
  return v
end

--- Removes all the elements of an array within a specified range.
-- @tparam array a an array to remove the elements from.
-- @tparam[opt] integer from the starting index of the range to remove.
-- @tparam[optchain] integer to the ending index of the range to remove.
function removerange(a, from, to)
  if #a == 0 then
    return a
  end
  from, to = normalize(a, from, to)
  if from > to then
    clear(a)
    return a
  end
  if to + 1 <= #a then
    table_move(a, to + 1, #a, from, a)
  end
  shrink(a, #a - to + from - 1)
  return a
end

-- Searches a range of elements of an array for the first occurrence of a
-- specified value using the specified equality comparer, and remove it.
-- @tparam array a an array to remove the value from.
-- @param v the element to be removed.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam[optchain] eq_comparer eq the function to compare values.
-- @treturn boolean `true` if any element is removed; otherwise `false`.
function remove(a, v, from, to, eq)
  if #a == 0 then
    return false
  end
  from, to, eq = normalize(a, from, to, eq)
  eq = eq or defaults.eq
  for i = from, to do
    if eq(a[i], v) then
      table_remove(a, i)
      return true
    end
  end
  return false
end

--- Searches a range of elements of an array for all the occurrences of the
-- specified value using a specified equality comparer, and remove them.
-- @tparam array a the array to remove the values from.
-- @param v the value to be removed.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam[opt] eq_comparer eq the function to compare values.
-- @treturn integer the number of elements removed.
function removeall(a, v, from, to, eq)
  if #a == 0 then
    return 0
  end
  from, to, eq = normalize(a, from, to, eq)
  eq = eq or defaults.eq
  local n = 0
  for i = to, from, -1 do
    if eq(a[i], v) then
      table_remove(a, i)
      n = n + 1
    end
  end
  return n
end

-- Searches a range of elements of an array for the first element satisfying a
-- specified condition, and remove it.
-- @tparam array a an array to be searched.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam predicate p a function to test each element.
-- @treturn boolean `true` if any element is removed; otherwise `false`.
function removeif(a, from, to, p)
  from, to, p = normalize(a, from, to, p)
  for i = from, to do
    if p(a[i]) then
      table_remove(a, i)
      return true
    end
  end
  return false
end

--- Searches a range of elements of an array for all the elements satisfying a
-- specified condition, and remove them.
-- @tparam array a an array to be searched.
-- @tparam[opt] integer from the starting index of the range to search.
-- @tparam[optchain] integer to the ending index of the range to search.
-- @tparam predicate p a function to test each element.
-- @treturn integer the number of elements removed.
function removeallif(a, from, to, p)
  if #a == 0 then
    return 0
  end
  from, to, p = normalize(a, from, to, p)
  local n = 0
  for i = to, from, -1 do
    if p(a[i]) then
      table_remove(a, i)
      n = n + 1
    end
  end
  return n
end

--- Returns the string representation of a range of elements of an array.
-- @tparam array a an array.
-- @tparam[opt] integer from the starting index of the range.
-- @tparam[optchain] integer to the ending index of the range.
-- @treturn string the string representing the specified range of elements.
function tostring(a, from, to)
  if #a == 0 then
    return '{}'
  end
  from, to = normalize(a, from, to)
  if from > to then
    return '{..}'
  end
  local b = {}
  b[#b + 1] = '{'
  if from > 1 then
    b[#b + 1] = '.., '
  end
  b[#b + 1] = table_concat(a, ', ', from, to)
  if to < #a then
    b[#b + 1] = ', ..'
  end
  b[#b + 1] = '}'
  return table_concat(b)
end

--- Invokes a function on each element of a range of elements of an array.
-- @tparam array a an array to invoke the function on.
-- @tparam[opt] integer from the starting index of the range.
-- @tparam[optchain] integer to the ending index of the range.
-- @tparam function f a function to invoke on each element; the second
-- parameter is the index of the element in the array.
function each(a, from, to, f)
  from, to, f = normalize(a, from, to, f)
  for i = from, to do
    f(a[i], i)
  end
end

--- Returns an iterator over a specified range of elements of an array.
-- @tparam array a an array to return the iterator of.
-- @tparam[opt] integer from the starting index of the range.
-- @tparam[optchain] integer to the ending index of the range.
-- @treturn function an iterator.
function values(a, from, to)
  from, to = normalize(a, from, to)
  from = from - 1
  return function()
    if from < to then
      from = from + 1
      return a[from]
    end
  end
end

return M

--- Tests an array element for a condition.
-- @ftype predicate
-- @param x the array element to be tested.
-- @tparam integer i the index of the array element.
-- @treturn boolean `true` if the element satisfies the condition, `false` otherwise.

--- Signature of a key selector function.
-- @ftype keyselector
-- @param x the array element.
-- @tparam integer i the element's index.
-- @return any value that can be used as a table key.

--- Compares two element for equality.
-- @ftype eq_comparer
-- @param x the first element to compare.
-- @param y the second element to compare.
-- @treturn boolean `true` if the specified objects are equal; `false` otherwise.

--- Compares two elements and returns a value indicating whether one is less than,
-- equal to, or greater than the other.
-- @ftype comparer
-- @param x the first element to compare.
-- @param y the second element to compare.
-- @treturn int a signed integer that indicates the relative values of x and y,
-- as shown in the following table
