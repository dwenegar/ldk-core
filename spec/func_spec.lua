local func = require 'ldk.func'

describe("#func", function()
  describe("compose", function()
    it("should return the proper result", function()
      local function f(x) return x + 1 end
      local function g(x) return x * 10 end
      local fg = func.compose(f, g)
      assert.equal(11, fg(1))
      assert.equal(101, fg(10))
    end)
    it("should handle function returning multiple values", function()
      local function f(x, y) return x + y end
      local function g(x) return x * 10, x end
      local fg = func.compose(f, g)
      assert.equal(11, fg(1))
    end)
  end)
  describe("partial", function()
    it("should return the proper result", function()
      local f = function(x, y) return x + y end
      local f1 = func.partial(1, f)
      assert.equal(2, f1(1))
      assert.equals(10, f1(9))
    end)
  end)
  describe("curry", function()
    it("should return the proper result", function()
      local f = function(x, y) return x + y end
      local curryf = func.curry(f)
      assert.equal(2, curryf(1)(1))
      assert.equals(10, curryf(9)(1))
    end)
  end)
  local function testmemoize(n, memoize, f, ...)
    for _ = 1, n do
      local calln = 0
      local mf = memoize(function(...)
        calln = calln + 1
        return f(...)
      end)
      assert.equal(0, calln)
      local fa, fb = f(...)
      local mfa, mfb = mf(...)
      assert.equal(fa, mfa)
      assert.equal(fb, mfb)
      assert.equal(1, calln)
      mf(...)
      assert.equal(1, calln)
    end
  end
  describe("memoize0", function()
    it("should cache the function result", function()
      testmemoize(5, func.memoize0, function()
        return true
      end)
      testmemoize(5, func.memoize0, function()
        return true, 'true'
      end)
      testmemoize(5, func.memoize0, function()
        return nil, true
      end)
    end)
  end)
  describe("memoize1", function()
    it("should cache the function execution", function()
      testmemoize(5, func.memoize1, function(x)
        return x == nil
      end)
      testmemoize(5, func.memoize1, function(x)
        return x
      end, 1)
      testmemoize(5, func.memoize1, function(x)
        return x, x + 1
      end, 1)
      testmemoize(5, func.memoize1, function(x)
        return nil, x * x
      end, 1)
    end)
  end)
  describe("memoize2", function()
    it("should cache the function execution", function()
      testmemoize(5, func.memoize2, function(x1, x2)
        return x1 == nil and x2 == nil
      end)
      testmemoize(5, func.memoize2, function(x1, x2)
        return x1 + x2
      end, 7, 13)
      testmemoize(5, func.memoize2, function(x1, x2)
        return x1, x2
      end, 7, 15)
      testmemoize(5, func.memoize2, function(x1, x2)
        return nil, x1 * x2
      end, 7, 13)
    end)
  end)
  describe("memoize3", function()
    it("should cache the function execution", function()
      testmemoize(5, func.memoize3, function(x1, x2, x3)
        return x1 == nil and x2 == nil and x3 == nil
      end)
      testmemoize(5, func.memoize3, function(x1, x2, x3)
        return x1 + x2, x3
      end, 17, 13, 29)
      testmemoize(5, func.memoize3, function(x1, x2, x3)
        return x1, x2 + x3
      end, 7, 15, 29)
      testmemoize(5, func.memoize3, function(x1, x2, x3)
        return nil, x1 * x2 * x3
      end, 7, 17, 31)
    end)
  end)
  describe("memoize4", function()
    it("should cache the function execution", function()
      testmemoize(5, func.memoize4, function(x1, x2, x3, x4)
        return x1 == nil and x2 == nil and x3 == nil and x4 == nil
      end)
      testmemoize(5, func.memoize4, function(x1, x2, x3, x4)
        return x1 + x2, x3 + x4
      end, 17, 13, 29, 37)
      testmemoize(5, func.memoize4, function(x1, x2, x3, x4)
        return x1, x2 + x3 + x4
      end, 7, 15, 29, 31)
      testmemoize(5, func.memoize4, function(x1, x2, x3, x4)
        return nil, x1 * x2 * x3 / x4
      end, 7, 17, 31, 29)
    end)
  end)
  describe("always", function()
    it("should always return the same value", function()
      local one = func.always(1)
      assert.equal(1, one())
      assert.equal(1, one())
    end)
  end)
  describe("identity", function()
    it("should return the input value", function()
      for i = 1, 100 do
        assert.equal(i, func.identity(i))
      end
    end)
  end)
  describe("lambda", function()
    it("should compile a string into a simple function", function()
      local one = func.lambda('1')
      assert.equal(1, one())
    end)
    it("should compile a string into a simple function", function()
      local sum2 = func.lambda('_1 + _2')
      assert.equal(1, sum2(1, 0))
      assert.equal(5, sum2(2, 3))
    end)
    it("should compile a string into a simple function", function()
      local pack = func.lambda('{_2 , _1}')
      assert.same({0, 1}, pack(1, 0))
      assert.same({3, 2}, pack(2, 3))
    end)
  end)
end)
