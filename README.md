# jcontract

A simple contract library for Lua

---

Current master: [![builds.sr.ht status](https://builds.sr.ht/~shakna/jcontract.svg)](https://builds.sr.ht/~shakna/jcontract?)

---

## Example Code

    local contract = require "jcontract"

    local double_it = contract.contract(contract.IntRange(0, 10), {contract.IntRange(0, 5)},
  		function(x)
    		return 2 * x
  		end)

This constructs a function with a runtime contract that it:

* Returns an Integer in the exclusive range of 0, 10.
* Takes an argument of a single Integer in the exclusive range of 0, 5.

When the contract is violated, it'll crash (unless you've overriden this behaviour):

    double_it('a')

> luajit: ./jcontract.lua:5: IntRange<TypeViolation>: string(a) is not an integer on argument

	stack traceback:
		[C]: in function 'assert'
		./jcontract.lua:5: in function 'collapse'
		./jcontract.lua:34: in function <./jcontract.lua:31>
		./jcontract.lua:14: in function 'double_it'
		test.lua:8: in main chunk
		[C]: at 0x557b9b169c00

Or, for something that takes advantage of the range specifics:

    double_it(6)

> luajit: ./jcontract.lua:5: IntRange<RangeViolation>: Value(6) too large on argument. Expected a value less than 5.

	stack traceback:
		[C]: in function 'assert'
		./jcontract.lua:5: in function 'collapse'
		./jcontract.lua:49: in function <./jcontract.lua:37>
		./jcontract.lua:20: in function 'double_it'
		test.lua:19: in main chunk
		[C]: at 0x562e5eb42c00

---

## API

The table name used for the following is 'contract', and is for demonstration only. However you import this may change it.

For now, we're assuming: ```local contract = require "jcontract"```

## contract.version

This is the version of the library in use. It takes the form of a 3-number array.

If the first number of the array is 0, then breaking changes may occur, and the numbers are only guaranteed to increase.

If the first number of the array is not 0, then breaking changes only occur when the first number is incremented.

## contract.contract

    contract.contract(ReturnSpecifier, {ArgumentSpecifier...}, function)

This is the main binding for everything.

It takes a Type Specifier for the expected return type, an array of Type Specifiers for the expected argument types, and the function to apply the contract to.

## contract.collapse

    contract.collapse(boolean, message)

### Overriding

This is the function to override if you wish to change how the contract behaves.

If contract.collapse returns anything other than nil, then the called function will immediately return that value.

The boolean represents success or failure of the contract.

The message is a string designed to be human readable - the exact construction of the string is not guaranteed and can be changed arbitrarily between versions.

The test suite makes use of overriding so that we can test the contract library, it may be a good place to look if you need an example.

### User Type Specifiers

If you want to define your own contract Type Specifier, such as for objects of your own classes, then you'll use this function.

A Type Specifier should look something like:

	local MyTypeSpecifier = function()
	  return function(x, kind)
	    local r = contract.collapse(type(x.name) == "string", "MyType<ContractViolation>: Name should be a string")
	    if r ~= nil then return r end
	  end
	end

And used in the usual way:

	local set_name = contract.contract(MyTypeSpecifier(), {MyTypeSpecifier()}, function(x)
		x.name = "Hello"
		return x
	end)

## contract.Integer

This is a Type Specifier.

    contract.Integer()

It specifies the given object is:

* A number
* A whole number

## contract.Float

This is a Type Specifier.

    contract.Float()

It specifies the given object is:

* A number

## contract.Nil

This is a Type Specifier.

    contract.Nil()

It specifies the given object is:

* ```nil```

## contract.Boolean

This is a Type Specifier.

    contract.Boolean()

It specifies the given object is:

* A boolean
* Either true or false

## contract.True

This is a Type Specifier.

    contract.True()

It specifies the given object is:

* A boolean
* true

## contract.False

This is a Type Specifier.

    contract.False()

It specifies the given object is:

* A boolean
* false

## contract.IntRange

This is a Type Specifier.

    contract.IntRange(start, finish)

It specifies the given object is:

* A number
* A whole number
* Greater than the ```start``` value
* Less than the ```finish``` value

If also specifies:

* ```start``` is a whole number
* ```finish``` is a whole number

## contract.FloatRange

This is a Type Specifier.

    contract.FloatRange(start, finish)

It specifies the given object is:

* A number
* Greater than the ```start``` value
* Less than the ```finish``` value

If also specifies:

* ```start``` is a number
* ```finish``` is a number

## contract.String

This is a Type Specifier.

    contract.String()

It specifies the given object is:

* A string

## contract.StringFixed

This is a Type Specifier.

    contract.StringFixed(N)

It specifies the given object is:

* A string
* Exactly N characters long

If also specifies:

* N is a whole number

## contract.StringRange

This is a Type Specifier.

    contract.StringRange(start, finish)

It specifies the given object is:

* A string
* Has a length greater than the ```start``` value
* Has a length less than the ```finish``` value

If also specifies:

* ```start``` is a whole number
* ```finish``` is a whole number

## contract.Array

This is a Type Specifier.

    contract.Array()

If specifies the given object is:

* A table
* An array-like table

## contract.ArrayTyped

This is a Type Specifier.

    contract.ArrayTyped(TypeSpecifier)

It specifies the given object is:

* A table
* An array-like table

It also specifies:

* Every item of the array matches the given Type Specifier.

## contract.ArrayFixed

This is a Type Specifier.

    contract.ArrayFixed(N, TypeSpecifier)

It specifies the given object is:

* A table
* An array-like table
* Exactly N items long

It also specifies:

* N is a whole number
* Every item of the array matches the given Type Specifier.

## contract.ArrayRange

This is a Type Specifier.

    contract.ArrayRange(start, finish, TypeSpecifier)

It specifies the given object is:

* A table
* An array-like table
* More than ```start``` items long
* Less than ```finish``` items long

It also specifies:

* ```start``` is a whole number
* ```finish``` is a whole number
* Every item of the array matches the given Type Specifier.

## contract.Union

This is a Type Specifier.

    contract.Union(TypeSpecifier_A, TypeSpecifier_B)

It specifies the given object:

* Matches at least one of the two given Type Specifiers

## contract.Struct

This is a Type Specifier.

    contract.Struct(tbl)

This takes a table, where every key is linked to a Type Specifier.

It specifies the given object:

* Has all the keys given
* Has only the keys given
* Each value matches the corresponding given Type Specifier

## contract.Any

This is a Type Specifier.

    contract.Any()

This guarantees nothing at all, and should not generally be used.

---

## License

Copyright 2019 James Milne

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

***THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.***