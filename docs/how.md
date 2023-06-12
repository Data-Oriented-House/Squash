# How To Serialize?

Every character in a string can represent 256 possible values, since there are 256 characters in extended ASCII or UTF-8. This is equivalent to 8 bits, or 1 byte. Therefore, we can represent 256^2 = 65536 possible values with 2 characters, 256^3 = 16777216 possible values with 3 characters, and so on. There are many ways to interpret these bytes depending on context. Knowing how to interpret these bytes is the key to serialization.

# Booleans

In Luau, the `boolean` type is 1 byte large, but only 1 bit is actually necessary to store the contents of a boolean. This means we can actually serialize not just 1, but 8 booleans in a single byte. This is a common strategy called [*bit masking*](https://en.wikipedia.org/wiki/Mask_(computing)).

| Happy | Confused | Irritated | Concerned | Angry | Humber | Dazed | Nage |
| - | - | - | - | - | - | - | - |
| 1 | 1 | 0 | 1 | 0 | 1 | 1 | 0 |

All of this information fits inside a single character! We can use this to serialize 8 booleans in a single byte. This is called a *byte mask*.

# Numbers

In Luau, the `number` type is 8 bytes large, but only 52 of the bits are dedicated to storing the contents of the number. This means there is no need to serialize more than 8 bytes for any kind of number.

## Unsigned Integers

Unsigned Integers are Whole Numbers that can be serialized with 1 through 8 bytes:

***N = { 0, 1, 2, 3, 4, ... }***

With 1 byte, the possible values that can be represented are:

***N1 = { 0, 1, 2, 3, ..., 253, 254, 255 }***

Where the minimum and maximum values are:

***0 <= N1 <= 2^8 - 1***

With 2 bytes, the possible values that can be represented are:

***N2 = { 0, 1, 2, 3, ..., 65,533, 65,534, 65,535 }***

Where the minimum and maximum values are:

***0 <= N2 <= 2^16 - 1***

With *n* bytes, the possible values that can be represented are:

***c = 2^8n***

***Nn = { 0, 1, 2, ..., c - 2, c - 1 }***

Where the minimum and maximum values are:

***0 <= Nn <= c - 1***

## Signed Integers

Signed Integers are Integers that can be serialized with 1 through 8 bytes:

***Z = { ..., -2, -1, 0, 1, 2, 3, ... }***

With 1 byte, the possible values that can be represented are:

***Z1 = { -128, -127, -126, ..., 125, 126, 127 }***

Where the minimum and maximum values are:

***-2^7 <= Z1 <= 2^7 - 1***

With 2 bytes, the possible values that can be represented are:

***Z2 = { -32,768, -32,767, -32,766, ..., 32,765, 32,766, 32,767 }***

Where the minimum and maximum values are:

***-2^15 <= Z2 <= 2^15 - 1***

With *n* bytes, the possible values that can be represented are:

***c = 2^(8n-1)***

***Zn = { -c, -c + 1, -c + 2, ..., c - 3, c - 2, c - 1 }***

Where the minimum and maximum values are:

***-c <= Zn <= c - 1***

## Floating Point

Floating Point Numbers are Real Numbers that can be serialized with either 4 or 8 bytes:

***R = { ..., -2.0, ..., -1.0, ..., 0.0, ..., 1.0, ..., 2.0, ... }***

With 4 bytes (called a `float`), the possible values that can be represented are a bit more complicated. The first bit is used to represent the sign of the number, the next 8 bits are used to represent the exponent, and the last 23 bits are used to represent the mantissa.

![Floating Point](/floatingpoint.png)

The formula for calculating the value of a `float` from its sign, exponent, and mantissa can be found at [this wikipedia article](https://en.wikipedia.org/wiki/Single-precision_floating-point_format).

With 8 bytes (called a `double`). The first bit is used to represent the sign of the number, the next 11 bits are used to represent the exponent, and the last 52 bits are used to represent the mantissa.

![Double Precision Floating Point](/floatingpointdouble.png)

The formula for calculating the value of a `double` from its sign, exponent, and mantissa can be found at [this wikipedia article](https://en.wikipedia.org/wiki/Double-precision_floating-point_format).

# Strings

Strings are a bit more complicated than numbers. There are many ways to compress serialized strings, a lossless approach is to treat the string itself as a number and convert the number into a higher base, or radix. This is called [base conversion](https://en.wikipedia.org/wiki/Radix). Strings come in many different *flavors* though, so we need to know how to serialize each *flavor*. Each string is composed of a sequence of certain characters. The set of those certain characters is called that string's smallest **Alphabet**. For example the string ***"Hello, World!"*** has the alphabet ***" !,HWdelorw"***. We can assign a number to each character in the alphabet like its position in the string. With our example:
```lua
{
	[' '] = 1, ['!'] = 2, [','] = 3, ['H'] = 4, ['W'] = 5,
	['d'] = 6, ['e'] = 7, ['l'] = 8, ['o'] = 9, ['r'] = 10,
	['w'] = 11,
}
```
This allows us to now calculate a numerical value for each string using [Positional Notation](https://en.wikipedia.org/wiki/Positional_notation). The alphabet above has a radix of 11, so we can convert the string into a number with base 11. We can then use the base conversion formula, modified to work with strings, to convert the number with a radix 11 alphabet into a number with a radix 255 alphabet such as extended ASCII or UTF-8 minus the \0 character. Long story short, you can fit ***log11(255) = 2.31*** characters from the original string into a single character in the new string. This proccess is invertible and lossless, so we can convert the serialized string back into the original string when we are ready. To play with this concept for arbitrary alphabets, you can visit [zamicol's base converter](https://convert.zamicol.com/) which supports these exact operations and comes with many pre-defined alphabets.