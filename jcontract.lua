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

r['version'] = {0, 5, 0}

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

r['Integer'] = function()
  return function(x, kind)
    local ret = nil
    ret = r['collapse'](type(x) == 'number', string.format("Integer<TypeViolation>: Specified value is not a number: %s", x))
  	if ret ~= nil then return ret end

  	ret = r['collapse'](math.floor(x) == x, string.format("Integer<TypeViolation>: Specified value is not an integer: %s", x))
  	if ret ~= nil then return ret end
  end
end

r['Float'] = function()
  return function(x, kind)
  	local ret = nil
    ret = r['collapse'](type(x) == 'number', string.format("Float<TypeViolation>: Specified value is not a number: %s", x))
  	if ret ~= nil then return ret end
  end
end

r['Nil'] = function()
	return function(x, kind)
		local ret = nil
		ret = r['collapse'](type(x) == 'nil', string.format("Nil<TypeViolation>: Expected nil, received a: %s", type(x)))
		if ret ~= nil then return ret end
	end
end

r['Boolean'] = function()
	return function(x, kind)
	  local ret = nil
	  ret = r['collapse'](type(x) == 'boolean', string.format("Boolean<TypeViolation>: Expected boolean, received: %s", type(x)))
	  if ret ~= nil then return ret end
	end
end

r['True'] = function()
	return function(x, kind)
	  local ret = nil
	  ret = r['collapse'](type(x) == 'boolean', string.format("Boolean<TypeViolation>: Expected boolean, received: %s", type(x)))
	  if ret ~= nil then return ret end
	  ret = r['collapse'](x == true, string.format("Boolean<ContractViolation>: Expected true."))
	  if ret ~= nil then return ret end
	end
end

r['False'] = function()
	return function(x, kind)
	  local ret = nil
	  ret = r['collapse'](type(x) == 'boolean', string.format("Boolean<TypeViolation>: Expected boolean, received: %s", type(x)))
	  if ret ~= nil then return ret end
	  ret = r['collapse'](x == false, string.format("Boolean<ContractViolation>: Expected false."))
	  if ret ~= nil then return ret end
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

	  ret = r['collapse'](type(x) == 'number', string.format("IntRange<TypeViolation>: %s(%s) is not an integer on %s", type(x), x, kind))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](math.floor(x) == x, string.format("IntRange<TypeViolation>: Float is not an integer on %s", kind))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](x > start, string.format("IntRange<RangeViolation>: Value(%s) too small on %s. Expected a value greater than %s.", x, kind, start))
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

	  ret = r['collapse'](x > start, string.format("FloatRange<RangeViolation>: Value(%s) too small on %s. Expected a greater than %s.", x, kind, start))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](x < finish, string.format("FloatRange<RangeViolation>: Value(%s) too large on %s. Expected a value less than %s.", x, kind, finish))
	  if ret ~= nil then return ret end
	end
end

r['String'] = function()
	return function(x, kind)
		local ret = nil
		ret = r['collapse'](type(x) == 'string', string.format("String<TypeViolation>: Expected a string, recieved: %s", type(x)))
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

	  ret = r['collapse'](type(x) == 'string', string.format("StringRange<TypeViolation>: %s is not a string on %s.", x, kind))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](#x > start, string.format("StringRange<RangeViolation>: Length(%s) too small on %s. Expected a length of at least %s.", #x, kind, start))
	  if ret ~= nil then return ret end

	  ret = r['collapse'](#x < finish, string.format("StringRange<RangeViolation>: Length(%s) too large on %s. Expected a length of less than %s.", #x, kind, finish))
	  if ret ~= nil then return ret end
	end
end

-- This is expensive, so we memoise it.
local is_array_checks = {}
local is_array = function(t)
	if type(t) ~= 'table' then return false end

	local check = string.format("%s", t)
	if is_array_checks[check] then
		return is_array_checks[check]
	end

	-- Prevent memoiser taking up too much space
	local mem_count = 0
	for k, v in pairs(is_array_checks) do
		mem_count = mem_count + 1
		if mem_count > 50 then
			-- Naively blow up the cache
			is_array_checks = {}
		end
	end

	local max = 0
	local count = 0

	for k, v in pairs(t) do
		if type(k) == 'number' then
			count = count + 1
		else
			is_array_checks[check] = false
			return false
		end
	end

	is_array_checks[check] = #t == count
	return #t == count
end

r['Array'] = function()
  return function(x, kind)
    local ret = nil
    ret = r['collapse'](is_array(x), "Array<TypeViolation>: Expected an array.")
    if ret ~= nil then return ret end
  end
end

r['ArrayTyped'] = function(TypeSpecifier)
	return function(x, kind)

	  local ret = nil

	  ret = r['collapse'](is_array(x), "ArrayTyped<TypeViolation>: Expected an array.")
	  if ret ~= nil then return ret end

	  for idx, cell in ipairs(x) do
	  	ret = TypeSpecifier(cell, string.format("%s(array)", kind))
	  	if ret ~= nil then return ret end
	  end

	end
end

r['ArrayFixed'] = function(length, TypeSpecifier)
  return function(x, kind)
    local ret = nil

    ret = r['collapse'](type(length) == 'number', string.format("ArrayFixed<ContractViolation>: length is a %s not a number.", type(length)))
    if ret ~= nil then return ret end

    ret = r['collapse'](math.floor(length) == length, string.format("ArrayFixed<ContractViolation>: length is not a whole number."))
    if ret ~= nil then return ret end

    ret = r['collapse'](is_array(x), "ArrayFixed<TypedViolation>: Expected an array.")
    if ret ~= nil then return ret end

    ret = r['collapse'](#x == length, string.format("ArrayFixed<RangeViolation>: Expected an array of length %d but got %d", length, #x))
    if ret ~= nil then return ret end

    for idx, cell in ipairs(x) do
    	ret = TypeSpecifier(cell, string.format("%s(array)", kind))
    	if ret ~= nil then return ret end
    end
  end
end

r['ArrayRange'] = function(start, finish, TypeSpecifier)
	return function(x, kind)
		local ret = nil

		-- Check start
		ret = r['collapse'](type(start) == 'number', string.format("ArrayRange<ContractViolation>: start is a %s not a number.", type(start)))
		if ret ~= nil then return ret end
		ret = r['collapse'](math.floor(start) == start, "ArrayRange<ContractViolation>: start is not an integer.")
		if ret ~= nil then return ret end

		-- Check finish
		ret = r['collapse'](type(finish) == 'number', string.format("ArrayRange<ContractViolation>: finish is a %s not a number.", type(start)))
		if ret ~= nil then return ret end
		ret = r['collapse'](math.floor(finish) == finish, "ArrayRange<ContractViolation>: finish is not an integer.")
		if ret ~= nil then return ret end

		-- Check is array
		ret = r['collapse'](is_array(x), "ArrayRange<TypeViolation>: Expected an array.")
		if ret ~= nil then return ret end

		-- Check array minimum length
		ret = r['collapse'](#x > start, string.format("ArrayRange<RangeViolation>: Expected an array of greater than %d length, received %d", #x, start))
		if ret ~= nil then return ret end

		-- Check array maximum length
		ret = r['collapse'](#x < finish, string.format("ArrayRange<RangeViolation>: Expected an array of less than %d length, received %d", #x, start))
		if ret ~= nil then return ret end

		-- Check arguments
		for idx, cell in ipairs(x) do
    		ret = TypeSpecifier(cell, string.format("%s(array)", kind))
    		if ret ~= nil then return ret end
    	end
	end
end

r['Union'] = function(TypeSpecifierA, TypeSpecifierB)
	return function(x, kind)
		local ret = nil

		local collapse_keep = r['collapse']

		local bad = {}
		r['collapse'] = function(boolean, message)
			if boolean == false then return bad end
		end

		local check_a = false
		local check_b = false

		ret = TypeSpecifierA(x, string.format("%s(union)", kind))
		if ret ~= bad then
			check_a = true
		end

		ret = TypeSpecifierB(x, string.format("%s(union)", kind))
		if ret == bad then
			-- Matches TypeSpecifierA
			if check_a then
				r['collapse'] = collapse_keep
				return
			end
		else
			check_b = true
		end

		-- Restore
		r['collapse'] = collapse_keep

		-- Failed to match either 
		if not check_a and not check_b then
			ret = r['collapse'](false, string.format("Union<ContractViolation>: Did not match either given specifiers on %s", kind))
			if ret ~= nil then return ret end
		end

	end
end

r['Struct'] = function(specifiers)
  return function(x, kind)
    local ret = nil

    ret = r['collapse'](type(x) == 'table', string.format("Struct<ContractViolation>: Requires a table, not a %s", type(x)))
    if ret ~= nil then return ret end

    for k, v in pairs(specifiers) do
    	-- Check the key actually exists
    	ret = r['collapse'](x[k] ~= nil, string.format("Struct<KeyViolation>: Key missing: %s", k))
    	if ret ~= nil then return ret end
    end

    for k, v in pairs(x) do
    	-- Check key specified
    	ret = r['collapse'](specifiers[k] ~= nil, string.format("Struct<KeyViolation>: Key not specified: %s", k))
    	if ret ~= nil then return ret end

    	-- Check value specifies
    	ret = specifiers[k](v, string.format("struct(%s)", kind))
    	if ret ~= nil then return ret end
    end

  end
end

r['Any'] = function()
  return function(x, kind)
  end
end

return r