-- Copyright 2019 James Milne
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
-- 1. Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- 2. Redistributions in binary form must reproduce the above copyright notice,
-- this list of conditions and the following disclaimer in the documentation
-- and/or other materials provided with the distribution.
--
-- 3. Neither the name of the copyright holder nor the names of its contributors
-- may be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- ***THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.***

local r = {}

-- Allow overriding our error response
r['collapse'] = function(boolean, message)
	assert(boolean, message)
end

-- The main constructor
r['contract'] = function(returnType, argumentTypes, f)
	return function(...)
	  local args = {...}

	  local check = nil

	  -- Check we have the right number of arguments
	  check = r['collapse'](#argumentTypes == #args, string.format("ContractViolation: Wrong number of arguments supplied. Expected %s, received %s.", #argumentTypes, #args))
	  if check ~= nil then return check end

	  for idx, arg in ipairs(args) do
	  	check = argumentTypes[idx](arg, "argument")
	  	-- Return here, in case collapse is overridden to return
	  	if check ~= nil then return check end
	  end

	  local v = f(...)

	  check = returnType(v, "return")
	  -- Return here, in case collapse is overridden to return
	  if check ~= nil then return check end

	  return v
	end
end

-- Constructs the integer range assertion function
r['IntRange'] = function(start, finish)
	return function(x, kind)
	  -- Return ret from collapse, in case collapse is overridden to return
	  local ret = nil

	  ret = r['collapse'](type(start) == 'number', string.format("IntRange<ContractViolation>: Specified start value is not a number."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](math.floor(start) == start, string.format("IntRange<ContractViolation>: Specified start value is not an integer."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](type(finish) == 'number', string.format("IntRange<ContractViolation>: Specified finish value is not a number."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](math.floor(finish) == finish, string.format("IntRange<ContractViolation>: Specified finish value is not an integer."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](type(x) == 'number', string.format("IntRange<TypeViolation>: %s is not an integer on %s", type(x), kind))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](math.floor(x) == x, string.format("IntRange<TypeViolation>: Float is not an integer on %s", kind))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](x > start, string.format("IntRange<RangeViolation>: Value(%s) too small on %s. Expected a value of at least %s.", x, kind, start))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](x < finish, string.format("IntRange<RangeViolation>: Value(%s) too large on %s. Expected a value less than %s.", x, kind, finish))
	  if ret ~= nil then return ret end
	end
end

-- Constructs the float range assertion function
r['FloatRange'] = function(start, finish)
	return function(x, kind)
	  -- Return ret from collapse, in case collapse is overridden to return
	  local ret = nil

	  ret = r['collapse'](type(start) == 'number', string.format("FloatRange<ContractViolation>: Specified start value is not a number."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](type(finish) == 'number', string.format("FloatRange<ContractViolation>: Specified finish value is not a number."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](type(x) == 'number', string.format("FloatRange<TypeViolation>: %s is not an integer on %s", type(x), kind))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](x > start, string.format("FloatRange<RangeViolation>: Value(%s) too small on %s. Expected a value of at least %s.", x, kind, start))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](x < finish, string.format("FloatRange<RangeViolation>: Value(%s) too large on %s. Expected a value less than %s.", x, kind, finish))
	  if ret ~= nil then return ret end
	end
end

-- A string type with an exact length
r['StringFixed'] = function(length)
	return function(x, kind)
	  -- Return ret from collapse, in case collapse is overridden to return
	  local ret = nil

	  ret = r['collapse'](type(length) == 'number', string.format("StringFixed<ContractViolation>: Specified length value is not a number."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](math.floor(length) == length, string.format("StringFixed<ContractViolation>: Specified length value is not an integer."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](type(x) == 'string', string.format("StringFixed<TypeViolation>: %s is not a string on %s.", x, kind))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](#x == length, string.format("StringFixed<RangeViolation>: Expected a length of %s, recieved a length of %s, on %s.", length, #x, kind))
	  if ret ~= nil then return ret end
	end
end

-- A string type with a safe range
r['StringRange'] = function(start, finish)
	return function(x, kind)
	  -- Return ret from collapse, in case collapse is overridden to return
	  local ret = nil

	  ret = r['collapse'](type(start) == 'number', string.format("StringRange<ContractViolation>: Specified start value is not a number."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](math.floor(start) == start, string.format("StringRange<ContractViolation>: Specified start value is not an integer."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](type(finish) == 'number', string.format("StringRange<ContractViolation>: Specified finish value is not a number."))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](math.floor(finish) == finish, string.format("StringRange<ContractViolation>: Specified start value is not an integer."))
	  if ret ~= nil then return ret end

	  r['collapse'](type(x) == 'string', string.format("StringRange<TypeViolation>: %s is not a string on %s.", x, kind))
	  if ret ~= nil then return ret end

	  r['collapse'](#x > start, string.format("StringRange<RangeViolation>: Length(%s) too small on %s. Expected a length of at least %s.", #x, kind, length))
	  if ret ~= nil then return ret end

	  r['collapse'](#x < finish, string.format("StringRange<RangeViolation>: Length(%s) too large on %s. Expected a length of less than %s.", #x, kind, length))
	  if ret ~= nil then return ret end
	end
end

return r