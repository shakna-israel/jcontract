local contract = require "jcontract"

print(string.format("Testing v%d.%d.%d", contract.version[1], contract.version[2], contract.version[3]))

-- Override the collapse so that it returns
-- our own values we can assert for!
local bad = {}
contract.collapse = function(boolean, message)
  if boolean == false then
  	print(message)
  	return bad
  end
end

-- Integer Failures
assert(contract.Integer()('a') == bad)
assert(contract.Integer()(1.1) == bad)
assert(contract.Integer()({}) == bad)
-- Integer Successes
assert(contract.Integer()(1) ~= bad)
assert(contract.Integer()(100000) ~= bad)

-- Float Failures
assert(contract.Float()('a') == bad)
assert(contract.Float()({}) == bad)
-- Float Successes
assert(contract.Float()(1.1) ~= bad)
assert(contract.Float()(11) ~= bad)

-- IntRange Failures
assert(contract.IntRange(0, 5)(0) == bad)
assert(contract.IntRange(0, 5)(-1) == bad)
assert(contract.IntRange(0, 5)(1.1) == bad)
assert(contract.IntRange(0, 5)('a') == bad)
assert(contract.IntRange(0, 5)({}) == bad)
-- IntRange Successes
assert(contract.IntRange(0, 5)(1) ~= bad)
assert(contract.IntRange(0, 5)(2) ~= bad)
assert(contract.IntRange(0, 5)(3) ~= bad)
assert(contract.IntRange(0, 5)(4) ~= bad)

-- FloatRange Failures
assert(contract.FloatRange(0, 5.0)(0) == bad)
assert(contract.FloatRange(0, 5.0)(-0.0) == bad)
assert(contract.FloatRange(0, 5.0)(-0.1) == bad)
assert(contract.FloatRange(0, 5.0)(5.0) == bad)
assert(contract.FloatRange(0, 5.0)('a') == bad)
assert(contract.FloatRange(0, 5.0)({}) == bad)
-- FloatRange Successes
assert(contract.FloatRange(0, 5.0)(0.1) ~= bad)
assert(contract.FloatRange(0, 5.0)(4.9) ~= bad)

-- String Successes
assert(contract.String()(1) == bad)
assert(contract.String()({}) == bad)
assert(contract.String()(1.1) == bad)
-- String Failures
assert(contract.String()("a") ~= bad)

-- StringFixed Failures
assert(contract.StringFixed(5)("a") == bad)
assert(contract.StringFixed(5)(0) == bad)
assert(contract.StringFixed(5)({}) == bad)
assert(contract.StringFixed(5)("aaaaaaaaa") == bad)
-- StringFixed Successes
assert(contract.StringFixed(5)("hello") ~= bad)

-- StringRange Failures
assert(contract.StringRange(0, 6)("") == bad)
assert(contract.StringRange(0, 6)(1) == bad)
assert(contract.StringRange(0, 6)({}) == bad)
assert(contract.StringRange(0, 6)("aaaaaa") == bad)

-- StringRange Successes
assert(contract.StringRange(0, 6)("hello") ~= bad)
assert(contract.StringRange(0, 6)("a") ~= bad)

-- Array Failures
assert(contract.Array()({'a', 'b', c=12}) == bad)
assert(contract.Array()({c=12}) == bad)
assert(contract.Array()(12) == bad)
assert(contract.Array()("a") == bad)
-- Array Successes
assert(contract.Array()({'a', 'b', 'c'}) ~= bad)
assert(contract.Array()({1, 2, 3}) ~= bad)

-- ArrayTyped Failures
assert(contract.ArrayTyped(contract.IntRange(0, 5))({0}) == bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))({5}) == bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))({'a'}) == bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))({a = 1}) == bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))('a') == bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))(0) == bad)
-- ArrayTyped Successes
assert(contract.ArrayTyped(contract.IntRange(0, 5))({1,2,3,4}) ~= bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))({4,4,4,4,4,4,4,4,4,4}) ~= bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))({1}) ~= bad)

-- ArrayFixed Failures
assert(contract.ArrayFixed(5, contract.IntRange(0, 5))({1,1,1,1}) == bad)
assert(contract.ArrayFixed(5, contract.IntRange(0, 5))({1,1,1,1,60}) == bad)
assert(contract.ArrayFixed(5, contract.IntRange(0, 5))({a=2}) == bad)
assert(contract.ArrayFixed(5, contract.IntRange(0, 5))('a') == bad)
assert(contract.ArrayFixed(5, contract.IntRange(0, 5))(0) == bad)
-- ArrayFixed Successes
assert(contract.ArrayFixed(5, contract.IntRange(0, 5))({1,1,1,1,1}) ~= bad)

-- ArrayRange Failures
assert(contract.ArrayRange(0, 5, contract.IntRange(0, 5))('a') == bad)
assert(contract.ArrayRange(0, 5, contract.IntRange(0, 5))({1,2,3,4,5}) == bad)
assert(contract.ArrayRange(0, 5, contract.IntRange(0, 5))({1,2,60,4}) == bad)
-- ArrayRange Successes
assert(contract.ArrayRange(0, 5, contract.IntRange(0, 5))({1}) ~= bad)
assert(contract.ArrayRange(0, 5, contract.IntRange(0, 5))({1,2}) ~= bad)
assert(contract.ArrayRange(0, 5, contract.IntRange(0, 5))({1,2,3}) ~= bad)
assert(contract.ArrayRange(0, 5, contract.IntRange(0, 5))({1,2,3,4}) ~= bad)

-- Union Failures
assert(contract.Union(contract.IntRange(0, 5), contract.FloatRange(0.0, 5.0))('a') == bad)
assert(contract.Union(contract.IntRange(0, 5), contract.FloatRange(0.0, 5.0))({}) == bad)
assert(contract.Union(contract.IntRange(0, 5), contract.FloatRange(0.0, 5.0))(-0.0) == bad)
assert(contract.Union(contract.IntRange(0, 5), contract.FloatRange(0.0, 5.0))(0) == bad)
-- Union Successes
assert(contract.Union(contract.IntRange(0, 5), contract.FloatRange(0.0, 5.0))(1.2) ~= bad)
assert(contract.Union(contract.IntRange(0, 5), contract.FloatRange(0.0, 5.0))(1) ~= bad)

-- Struct Failures
assert(contract.Struct({a=contract.IntRange(0, 5), b=contract.IntRange(0, 5)})({a=1, b=2, c=3}) == bad)
assert(contract.Struct({a=contract.IntRange(0, 5), b=contract.IntRange(0, 5)})({}) == bad)
assert(contract.Struct({a=contract.IntRange(0, 5), b=contract.IntRange(0, 5)})({a=1, c=3}) == bad)
-- Struct Successes
assert(contract.Struct({a=contract.IntRange(0, 5), b=contract.IntRange(0, 5)})({a=1, b=2}) ~= bad)

-- Any always succeeds
assert(contract.Any()('a') ~= bad)
assert(contract.Any()({}) ~= bad)
assert(contract.Any()(1) ~= bad)
assert(contract.Any()(2.1) ~= bad)

-- Contract
-- Test the example function

local double_it = contract.contract(contract.IntRange(0, 10), {contract.IntRange(0, 5)},
  function(x)
    return 2 * x
  end)

-- Failures
assert(double_it() == bad)
assert(double_it('a') == bad)
assert(double_it(5) == bad)
assert(double_it(0) == bad)
assert(double_it(-10) == bad)

-- Passes
assert(double_it(1) ~= bad)
assert(double_it(2) ~= bad)
assert(double_it(3) ~= bad)
assert(double_it(4) ~= bad)

-- Contract User type specifiers using README example
local MyTypeSpecifier = function()
  return function(x, kind)
    local r = contract.collapse(type(x.name) == "string", "MyType<ContractViolation>: Name should be a string")
    if r ~= nil then return r end
  end
end

local set_name = contract.contract(MyTypeSpecifier(), {MyTypeSpecifier()}, function(x)
	x.name = "Hello"
	return x
end)

local set_name_bad = contract.contract(MyTypeSpecifier(), {MyTypeSpecifier()}, function(x)
	x.name = 21
	return x
end)

-- Failures
assert(set_name({}) == bad)
assert(set_name('a') == bad)
assert(set_name({1,2,3}) == bad)
assert(set_name({x = ""}) == bad)
assert(set_name_bad({name = ""}) == bad)

-- Passes
assert(set_name({name = ""}) ~= bad)
assert(set_name({name = "sdfghj"}) ~= bad)

print("Testing suite passed.")
