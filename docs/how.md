# How To Serialize?

Every character in a string can represent 256 possible values, since there are 256 characters in extended ASCII or UTF-8. This is equivalent to 8 bits, or 1 byte. Therefore, we can represent 256^2 = 65536 possible values with 2 characters, 256^3 = 16777216 possible values with 3 characters, and so on. There are many ways to interpret these bytes depending on context. Knowing how to interpret these bytes is the key to serialization.

## Booleans

In Luau, the `boolean` type is 1 byte large, but only 1 bit is actually necessary to store the contents of a boolean. This means we can actually serialize not just 1, but 8 booleans in a single byte. This is a common strategy called [*bit masking*](https://en.wikipedia.org/wiki/Mask_(computing)).

| Happy | Confused | Irritated | Concerned | Angry | Humber | Dazed | Nage |
| - | - | - | - | - | - | - | - |
| 1 | 1 | 0 | 1 | 0 | 1 | 1 | 0 |

All of this information fits inside a single character! We can use this to serialize 8 booleans in a single byte. This is called a *byte mask*.

```lua
local y1 = Squash.boolean.ser(true)
print(y1) -- ☺

local y2 = Squash.boolean.ser(true, false, true, false, true, true, false, true)
print(y2) -- ╡

print(Squash.boolean.des(y1)) -- true, false, false, false, false, false, false, false
print(Squash.boolean.des(y2)) -- true, false, true, false, true, true, false, true
```

## Numbers

In Luau, the `number` type is 8 bytes large, but only 52 of the bits are dedicated to storing the contents of the number. This means there is no need to serialize more than 8 bytes for any kind of number.

### Unsigned Integers

Unsigned integers are whole numbers that can be serialized using 1 to 8 bytes.

***N = { 0, 1, 2, 3, 4, 5, . . . }***

They may only be positive and can represent all possible permutations of their bits. These are the easiest to wrap our heads around and manipulate. They are often used to implement [Fixed Point](https://en.wikipedia.org/wiki/Fixed-point_arithmetic) numbers by multiplying by some scale factor and shifting by some offset, then doing the reverse when deserializing.

| Bytes | Range | Min | Max |
| - | - | - | - |
| ***1*** | **{ 0, 1, 2, 3, . . . , 253, 254, 255 }** | ***0*** | ***255*** |
| ***2*** | **{ 0, 1, 2, 3, . . . , 65,534, 65,535 }** | ***0*** | ***65,535*** |
| ***3*** | **{ 0, 1, 2, 3, . . . , 16,777,214, 16,777,215 }** | ***0*** | ***16,777,215*** |
| . . . | . . . | . . . | . . . |
| ***n*** | **{ 0, 1, 2, 3, . . . , 2^(8n) - 2, 2^(8n) - 1 }** | ***0*** | ***2^(8n) - 1*** |

```lua
local y1 = Squash.uint.ser(243, 1)
print(y1) -- ≤
print(Squash.uint.des(y1, 1)) -- 243

local y2 = Squash.uint.ser(-13, 1)
print(y2) -- ≤
print(Squash.uint.des(y2, 1)) -- 243

local y3 = Squash.uint.ser(7365, 2)
print(y3) -- ┼∟
print(Squash.uint.des(y3, 2)) -- 7365
```

### Signed Integers

Signed Integers are Integers that can be serialized with 1 through 8 bytes:

***Z = { ..., -2, -1, 0, 1, 2, 3, ... }***

They use [2's Compliment](https://en.wikipedia.org/wiki/Two%27s_complement) to represent negative numbers. The first bit is called the *sign bit* and the rest of the bits are called the *magnitude bits*. The sign bit is 0 for positive numbers and 1 for negative numbers. This implies the range of signed integers is one power of two smaller than the range of unsigned integers with the same number of bits, because the sign bit is not included in the magnitude bits.

| Bytes | Range | Min | Max |
| - | - | - | - |
| ***1*** | **{ -128, -127, . . . , 126, 127 }** | ***-128*** | ***127*** |
| ***2*** | **{ -32,768, -32,767, . . . , 32,766, 32,767 }** | ***-32,768*** | ***32,767*** |
| ***3*** | **{ -8,388,608, -8,388,607, . . . , 8,388,606, 8,388,607 }** | ***-8,388,608*** | ***8,388,607*** |
| . . . | . . . | . . . | . . . |
| ***n*** | **{ -2^(8n - 1), -2^(8n - 1) + 1, . . . , 2^(8n - 1) - 2, 2^(8n - 1) - 1 }** | ***-2^(8n - 1)*** | ***2^(8n - 1) - 1*** |

```lua
local y1 = Squash.int.ser(127, 1)
print(y1) -- cannot display A
print(Squash.int.des(y1, 1)) -- 127

local y2 = Squash.int.ser(-127, 1)
print(y2) -- cannot display B
print(Squash.int.des(y2, 1)) -- -127

local y3 = Squash.int.ser(128, 1)
print(y3) -- cannot display C
print(Squash.int.des(y3, 1)) -- -128

local y4 = Squash.int.ser(-128, 1)
print(y4) -- cannot display C
print(Squash.int.des(y4, 1)) -- -128
```

### Floating Point

Floating Point Numbers are Real Numbers that can be serialized with either 4 or 8 bytes:

***R = { ..., -2.0, ..., -1.0, ..., 0.0, ..., 1.0, ..., 2.0, ... }***

With 4 bytes (called a `float`), the possible values that can be represented are a bit more complicated. The first bit is used to represent the sign of the number, the next 8 bits are used to represent the exponent, and the last 23 bits are used to represent the mantissa.

![Floating Point](/floatingpoint.png)

The formula for calculating the value of a `float` from its sign, exponent, and mantissa can be found at [this wikipedia article](https://en.wikipedia.org/wiki/Single-precision_floating-point_format).

With 8 bytes (called a `double`). The first bit is used to represent the sign of the number, the next 11 bits are used to represent the exponent, and the last 52 bits are used to represent the mantissa.

![Double Precision Floating Point](/floatingpointdouble.png)

The formula for calculating the value of a `double` from its sign, exponent, and mantissa can be found at [this wikipedia article](https://en.wikipedia.org/wiki/Double-precision_floating-point_format).

```lua
local y1 = Squash.float.ser(174302.923957475339573, 4)
print(y1) -- ╗7*H
print(Squash.float.des(y1, 4)) -- 174302.921875

local y2 = Squash.float.ser(-17534840302.923957475339573, 8)
print(y2) -- "▓╗╖íT►┬
print(Squash.float.des(y2, 8)) -- -17534840302.923958
```

## Strings

Strings are a bit more complicated than numbers. There are many ways to compress serialized strings, a lossless approach is to treat the string itself as a number and convert the number into a higher base, or radix. This is called [base conversion](https://en.wikipedia.org/wiki/Radix). Strings come in many different *flavors* though, so we need to know how to serialize each *flavor*. Each string is composed of a sequence of certain characters. The set of those certain characters is called that string's smallest **Alphabet**. For example the string ***"Hello, World!"*** has the alphabet ***" !,HWdelorw"***. We can assign a number to each character in the alphabet like its position in the string. With our example:
```lua
{
	[' '] = 1, ['!'] = 2, [','] = 3, ['H'] = 4, ['W'] = 5,
	['d'] = 6, ['e'] = 7, ['l'] = 8, ['o'] = 9, ['r'] = 10,
	['w'] = 11,
}
```
This allows us to now calculate a numerical value for each string using [Positional Notation](https://en.wikipedia.org/wiki/Positional_notation). The alphabet above has a radix of 11, so we can convert the string into a number with base 11. We can then use the base conversion formula, modified to work with strings, to convert the number with a radix 11 alphabet into a number with a radix 255 alphabet such as extended ASCII or UTF-8 minus the \0 character. Long story short, you can fit ***log11(255) = 2.31*** characters from the original string into a single character in the new string. This proccess is invertible and lossless, so we can convert the serialized string back into the original string when we are ready. To play with this concept for arbitrary alphabets, you can visit [zamicol's base converter](https://convert.zamicol.com/) which supports these exact operations and comes with many pre-defined alphabets.
```lua
local x1 = 'Hello, world!'
local alphabet = Squash.string.alphabet(x1)
print(alphabet) -- ' !,Hdelorw'
local y1 = Squash.string.ser(x1, alphabet)
print(y1) --[[    <-- There is a newline character here
'��C�]]
print(Squash.string.des(y1, alphabet)) -- 'Hello, world!'

local x2 = 'great sword'
print(Squash.lower .. ' ') -- 'abcdefghijklmnopqrstuvwxyz '
local y2 = Squash.string.ser(x2, Squash.lower .. ' ')
print(y2) -- ��L�,
print(Squash.string.des(y2, Squash.lower .. '  ')) -- 'great sword'

local x3 = 'lowercase'
local y3 = Squash.string.convert(x3, Squash.lower, Squash.upper)
print(y3) -- 'LOWERCASE'
print(Squash.string.convert(y3, Squash.upper, Squash.lower)) -- 'lowercase'

local x4 = '1936'
local y4 = Squash.string.convert(x4, Squash.decimal, Squash.binary)
print(y4) -- '11110010000'
print(Squash.string.convert(y4, Squash.binary, Squash.decimal)) -- '1936'
```