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

-- ArrayTyped Failures
assert(contract.ArrayTyped(contract.IntRange(0, 5))({0}) == bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))({5}) == bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))({'a'}) == bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))({a = 1}) == bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))('a') == bad)
assert(contract.ArrayTyped(contract.IntRange(0, 5))(0) == bad)
-- ArrayTyped Successes
assert(contract.ArrayTyped(contract.IntRange(0, 5))({1,2,3,4}) ~= bad)

-- Test: ArrayFixed

-- Test: ArrayRange

-- Test: Union

-- Test: Contract

-- Test: Contract User type specifiers using README example
local MyTypeSpecifier = function()
  return function(x, kind)
    local r = contract.collapse(type(x.name) == "string", "MyType<ContractViolation>: Name should be a string")
    if r ~= nil then return r end
  end
end

assert(false, "Testing suite not fully implemented.")

print("Testing suite passed.")
