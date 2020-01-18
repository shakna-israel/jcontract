local contract = require "jcontract"

-- Override the collapse so that it returns
-- our own values we can assert for!
local bad = {}
contract.collapse = function(boolean, message)
  if boolean == false then
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
