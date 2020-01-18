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

-- Test Array Type
local test_array = contract.contract(
	-- Return type
	contract.ArrayTyped(contract.IntRange(0, 10)),
	-- Argument types
	{contract.ArrayTyped(contract.IntRange(0, 10))},
	function(v)
	  return v
	end)

assert(test_array({a = 2}) == bad)
assert(test_array({1, 2, 3}) ~= bad)

-- Test Union
assert(contract.Union(contract.IntRange(0, 10), contract.FloatRange(0, 10))(1.8) ~= bad)