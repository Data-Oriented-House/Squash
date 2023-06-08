--!strict

--[=[
	@class Squash
]=]
local Squash = {}

--[=[
	@within Squash
	@type Alphabet string

	A string of unique characters that represent the basis of other strings.
]=]
export type Alphabet = string

--[=[
	@within Squash
	@prop Delimiter string

	The delimiter used to separate strings or other types in variable sized arrays.
]=]
Squash.Delimiter = '\0'

--[=[
	@within Squash
	@prop Digits Alphabet

	All digits in base 10.
]=]
Squash.Digits = '0123456789' :: Alphabet

--[=[
	@within Squash
	@prop Lower Alphabet

	All lowercase letters in the English language.
]=]
Squash.Lower = 'abcdefghijklmnopqrstuvwxyz' :: Alphabet

--[=[
	@within Squash
	@prop Upper Alphabet

	All uppercase letters in the English language.
]=]
Squash.Upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' :: Alphabet

--[=[
	@within Squash
	@prop Letters Alphabet

	All letters in the English language.
]=]
Squash.Letters = Squash.Lower .. Squash.Upper :: Alphabet

--[=[
	@within Squash
	@prop Punctuation Alphabet

	All punctuation symbols in the English language.
]=]
Squash.Punctuation = ' .,?!:;\'"-' :: Alphabet

--[=[
	@within Squash
	@prop English Alphabet

	All symbols in the English language.
]=]
Squash.English = Squash.Letters .. Squash.Punctuation :: Alphabet

--[=[
	@within Squash
	@prop UTF8 Alphabet

	The UTF-8 character set, excluding the delimiter.
]=]
local utf8Characters = table.create(255)
for i = 1, 255 do
	utf8Characters[i] = string.char(i)
end
Squash.UTF8 = table.concat(utf8Characters) :: Alphabet

-- Duplication Reducers --

--[=[
	@within Squash
	@type NumberSer (x: number, bytes: number?) -> string

	A function that serializes a number into a string. Usually this is Squash's UInt, Int, or Float Ser methods.
]=]
type NumberSer = (x: number, bytes: number?) -> string

--[=[
	@within Squash
	@type NumberDes (y: string, bytes: number?) -> number

	A function that deserializes a number from a string. Usually this is Squash's UInt, Int, or Float Des methods.
]=]
type NumberDes = (y: string, bytes: number?) -> number

--[=[
	@within Squash
	@interface NumberSerDes
	.Ser NumberSer
	.Des NumberDes
]=]
type NumberSerDes = {
	Ser: NumberSer,
	Des: NumberDes,
}

type VectorSer<T> = (T, NumberSerDes?, number?) -> string
type VectorDes<T> = (string, NumberSerDes?, number?) -> T
type VectorSerDes<T, U> = {
	Ser: VectorSer<T>,
	Des: VectorDes<U>,
}

type VectorNoCodingSer<T> = (T, number?) -> string
type VectorNoCodingDes<T> = (string, number?) -> T
type VectorNoCodingSerDes<T> = {
	Ser: VectorNoCodingSer<T>,
	Des: VectorNoCodingDes<T>,
}

type FixedSer<T> = (T) -> string
type FixedDes<T> = (string) -> T
type FixedSerDes<T> = {
	Ser: FixedSer<T>,
	Des: FixedDes<T>,
}

type VariableSer<T, U...> = (T, U...) -> string
type VariableDes<T, U...> = (string, U...) -> T
type VariableSerDes<T, U...> = {
	Ser: VariableSer<T, U...>,
	Des: VariableDes<T, U...>,
}

local bytesAssert = function(bytes: number)
	if bytes ~= math.floor(bytes) or bytes < 1 or bytes > 8 then
		error 'bytes must one of 1, 2, 3, 4, 5, 6, 7, 8'
	end
end

local floatAssert = function(bytes: number)
	if bytes ~= 4 and bytes ~= 8 then
		error(`Expected 4 or 8 bytes. Invalid number of bytes for floating point: {bytes}`)
	end
end

local serArrayNumber = function<T>(ser: (x: T, bytes: number?) -> string)
	return function(x: { T }, bytes: number?): string
		local bytes = bytes or 4
		bytesAssert(bytes)

		local y = {}
		for i, v in x do
			y[i] = ser(v, bytes)
		end
		return table.concat(y)
	end
end

local desArrayNumber = function<T>(des: (y: string, bytes: number?) -> T)
	return function(y: string, bytes: number?): { T }
		local bytes = bytes or 4
		bytesAssert(bytes)

		local x = {}
		for i = 1, #y / bytes do
			local a = bytes * (i - 1) + 1
			local b = bytes * i
			x[i] = des(string.sub(y, a, b), bytes)
		end
		return x
	end
end

local serArrayFixed = function<T>(serdes: FixedSerDes<T>)
	local ser = serdes.Ser
	return function(x: { T }): string
		local y = {}
		for i, v in x do
			y[i] = ser(v)
		end
		return table.concat(y)
	end
end

local desArrayFixed = function<T>(serdes: FixedSerDes<T>, bytes: number)
	local des = serdes.Des
	return function(y: string): { T }
		local x = {}
		for i = 1, #y / bytes do
			local a = bytes * (i - 1) + 1
			local b = bytes * i
			x[i] = des(string.sub(y, a, b))
		end
		return x
	end
end

local serArrayVariable = function<T, U...>(serdes: VariableSerDes<T, U...>)
	local ser = serdes.Ser
	return function(x: { T }, ...: U...): string
		local y = {}
		for i, v in x do
			y[i] = ser(v, ...)
		end
		return table.concat(y, Squash.Delimiter)
	end
end

local desArrayVariable = function<T, U...>(serdes: VariableSerDes<T, U...>)
	local des = serdes.Des
	return function(y: string, ...: U...): { T }
		local x = {}
		for v in string.gmatch(y, '[^' .. Squash.Delimiter .. ']+') do
			table.insert(x, des(v, ...))
		end
		return x
	end
end

local serArrayVector = function<T, U>(serializer: VectorSerDes<T, U>)
	local ser = serializer.Ser
	return function(x: { T }, serdes: NumberSerDes?, bytes: number?): string
		local bytes = bytes or 4
		local encoding = serdes or Squash.Int

		local y = {}
		for i, v in x do
			y[i] = ser(v, encoding, bytes)
		end
		return table.concat(y)
	end
end

local desArrayVector = function<T, U>(deserializer: VectorSerDes<T, U>, elements: number, offsetBytes: number)
	local des = deserializer.Des
	return function(y: string, serdes: NumberSerDes?, bytes: number?): { U }
		local bytes = bytes or 4
		local decoding = serdes or Squash.Int

		local size = offsetBytes + elements * bytes
		local x = {}
		for i = 1, #y / size do
			local a = size * (i - 1) + 1
			local b = size * i
			x[i] = des(string.sub(y, a, b), decoding, bytes)
		end
		return x
	end
end

local serArrayVectorNoCoding = function<T>(serializer: VectorNoCodingSerDes<T>)
	local ser = serializer.Ser
	return function(x: { T }, bytes: number?): string
		local bytes = bytes or 4

		local y = {}
		for i, v in x do
			y[i] = ser(v, bytes)
		end
		return table.concat(y)
	end
end

local desArrayVectorNoCoding = function<T>(deserializer: VectorNoCodingSerDes<T>, elements: number, offsetBytes: number)
	local des = deserializer.Des
	return function(y: string, bytes: number?): { T }
		local bytes = bytes or 4

		local size = offsetBytes + elements * bytes
		local x = {}
		for i = 1, #y / size do
			local a = size * (i - 1) + 1
			local b = size * i
			x[i] = des(string.sub(y, a, b), bytes)
		end
		return x
	end
end

local tau = 2 * math.pi
local angleRatio = 65536 / tau

local serAngle = function(x: number): string
	return Squash.UInt.Ser(x % tau * angleRatio, 2)
	--return Squash.Float.Ser(x)
end

local desAngle = function(y: string): number
	return Squash.UInt.Des(y, 2) / angleRatio
	--return Squash.Float.Des(y)
end

local getBitSize = function(x: number): number
	return math.ceil(math.log(x, 2 ^ 1))
end

local getByteSize = function(x: number): number
	return math.ceil(math.log(x, 2 ^ 8))
end

local getItemData = function<T>(array: { T }): { items: { T }, bits: number, bytes: number }
	return {
		items = array,
		bits = getBitSize(#array),
		bytes = getByteSize(#array),
	}
end

local enumData = getItemData(Enum:GetEnums() :: { Enum })
local enumItemData = {}
for _, enum in enumData.items do
	enumItemData[enum] = getItemData(enum:GetEnumItems() :: { EnumItem })
end

local desEnumItem = function<T>(y: string, offset: number, enum: Enum): (number, EnumItem)
	local enumData = enumItemData[enum]
	local enumItemId = Squash.UInt.Des(string.sub(y, offset, offset + enumData.bytes - 1), enumData.bytes)
	return offset + enumData.bytes, enumData.items[enumItemId]
end

local packBits = function(x: { number }, bits: number): string
	local packed = {}
	local byte = 0
	local count = 0
	for i = 1, #x do
		for b = bits - 1, 0, -1 do
			byte = byte * 2 + math.floor(x[i] / 2 ^ b) % 2
			count = count + 1
			if count == 8 then
				table.insert(packed, string.char(byte))
				byte = 0
				count = 0
			end
		end
	end
	if count > 0 then
		byte = byte * 2 ^ (8 - count)
		table.insert(packed, string.char(byte))
	end
	return table.concat(packed)
end

local unpackBits = function(y: string, bits: number): { number }
	local x = {}
	local value = 0
	local count = 0
	for i = 1, #y do
		local byte = string.byte(y, i)
		for b = 7, 0, -1 do
			value = value * 2 + math.floor(byte / 2 ^ b) % 2
			count = count + 1
			if count == bits then
				table.insert(x, value)
				value = 0
				count = 0
			end
		end
	end
	return x
end

--* Actual API *--

--[=[
	@class Bool
]=]
Squash.Bool = {}

--[=[
	@within Bool
	@function Ser
	@param x1 boolean?
	@param x2 boolean?
	@param x3 boolean?
	@param x4 boolean?
	@param x5 boolean?
	@param x6 boolean?
	@param x7 boolean?
	@param x8 boolean?
	@return string
]=]
Squash.Bool.Ser = function(
	x1: boolean?,
	x2: boolean?,
	x3: boolean?,
	x4: boolean?,
	x5: boolean?,
	x6: boolean?,
	x7: boolean?,
	x8: boolean?
): string
	return string.char(
		(if x1 then 2 ^ 0 else 0)
			+ (if x2 then 2 ^ 1 else 0)
			+ (if x3 then 2 ^ 2 else 0)
			+ (if x4 then 2 ^ 3 else 0)
			+ (if x5 then 2 ^ 4 else 0)
			+ (if x6 then 2 ^ 5 else 0)
			+ (if x7 then 2 ^ 6 else 0)
			+ (if x8 then 2 ^ 7 else 0)
	)
end

--[=[
	@within Bool
	@function Des
	@param y string
	@return boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean
]=]
Squash.Bool.Des = function(y: string): (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean)
	local x = string.byte(y)
	return (x * 2 ^ -0) % 2 >= 1,
		(x * 2 ^ -1) % 2 >= 1,
		(x * 2 ^ -2) % 2 >= 1,
		(x * 2 ^ -3) % 2 >= 1,
		(x * 2 ^ -4) % 2 >= 1,
		(x * 2 ^ -5) % 2 >= 1,
		(x * 2 ^ -6) % 2 >= 1,
		(x * 2 ^ -7) % 2 >= 1
end

--[=[
	@within Bool
	@function SerArr
	@param x { boolean }
	@return string
]=]
Squash.Bool.SerArr = function(x: { boolean }): string
	local y = {}
	for i = 1, math.ceil(#x / 8) do
		y[i] = Squash.Bool.Ser(x[i + 0], x[i + 1], x[i + 2], x[i + 3], x[i + 4], x[i + 5], x[i + 6], x[i + 7])
	end
	return table.concat(y)
end

--[=[
	@within Bool
	@function DesArr
	@param y string
	@return { boolean }
]=]

Squash.Bool.DesArr = function(y: string): { boolean }
	local x = {}
	for i = 1, #y do
		local j = 8 * i
		x[j - 7], x[j - 6], x[j - 5], x[j - 4], x[j - 3], x[j - 2], x[j - 1], x[j] =
			Squash.Bool.Des(string.sub(y, i, i))
	end
	return x
end

--[=[
	@class UInt
]=]
Squash.UInt = {}

--[=[
	@within UInt
	@function Ser
	@param x number
	@param bytes number?
	@return string
]=]
Squash.UInt.Ser = function(x: number, bytes: number?): string
	local bytes = bytes or 4
	bytesAssert(bytes)

	local chars = {}
	for i = 1, bytes do
		chars[i] = math.floor(x * 256 ^ (1 - i)) % 256
	end
	return string.char(table.unpack(chars))
end

--[=[
	@within UInt
	@function Des
	@param y string
	@param bytes number?
	@return number
]=]
Squash.UInt.Des = function(y: string, bytes: number?): number
	local bytes = bytes or 4
	bytesAssert(bytes)

	local sum = 0
	for i = 1, bytes do
		sum += string.byte(y, i) * 256 ^ (i - 1)
	end
	return sum
end

--[=[
	@within UInt
	@function SerArr
	@param x { number }
	@param bytes number?
	@return string
]=]
Squash.UInt.SerArr = serArrayNumber(Squash.UInt.Ser)

--[=[
	@within UInt
	@function DesArr
	@param y string
	@param bytes number?
	@return { number }
]=]
Squash.UInt.DesArr = desArrayNumber(Squash.UInt.Des)

--[=[
	@class Int
]=]
Squash.Int = {}

--[=[
	@within Int
	@function Ser
	@param x number
	@param bytes number?
	@return string
]=]
Squash.Int.Ser = function(x: number, bytes: number?): string
	local bytes = bytes or 4
	bytesAssert(bytes)

	local sx = if x < 0 then x + 256 ^ bytes else x
	return Squash.UInt.Ser(sx, bytes)
end

--[=[
	@within Int
	@function Des
	@param y string
	@param bytes number?
	@return number
]=]
Squash.Int.Des = function(y: string, bytes: number?): number
	local bytes = bytes or 4
	bytesAssert(bytes)

	local x = Squash.UInt.Des(y, bytes)
	return if x > 0.5 * 256 ^ bytes - 1 then x - 256 ^ bytes else x
end

--[=[
	@within Int
	@function SerArr
	@param x { number }
	@param bytes number?
	@return string
]=]
Squash.Int.SerArr = serArrayNumber(Squash.Int.Ser)

--[=[
	@within Int
	@function DesArr
	@param y string
	@param bytes number?
	@return { number }
]=]
Squash.Int.DesArr = desArrayNumber(Squash.Int.Des)

--[=[
	@class Float
]=]
Squash.Float = {}

--[=[
	@within Float
	@function Ser
	@param x number
	@param bytes number?
	@return string
]=]
Squash.Float.Ser = function(x: number, bytes: number?): string
	local bytes = bytes or 4
	floatAssert(bytes)
	return string.pack(if bytes == 4 then 'f' else 'd', x)
end

--[=[
	@within Float
	@function Des
	@param y string
	@param bytes number?
	@return number
]=]
Squash.Float.Des = function(y: string, bytes: number?): number
	local bytes = bytes or 4
	floatAssert(bytes)
	return string.unpack(if bytes == 4 then 'f' else 'd', y)
end

--[=[
	@within Float
	@function SerArr
	@param x { number }
	@param bytes number?
	@return string
]=]
Squash.Float.SerArr = serArrayNumber(Squash.Float.Ser)

--[=[
	@within Float
	@function DesArr
	@param y string
	@param bytes number?
	@return { number }
]=]
Squash.Float.DesArr = desArrayNumber(Squash.Float.Des)

--[=[
	@class String
]=]
Squash.String = {}

--[=[
	@within String
	@function Alphabet
	@param source string
	@return Alphabet

	Maps a string to the smallest alphabet that represents it.
]=]
Squash.String.Alphabet = function(source: string): Alphabet
	local lookup = {}
	local alphabet = table.create(#source)
	for i = 1, #source do
		local char = string.sub(source, i, i)
		if not lookup[char] then
			lookup[char] = true
			table.insert(alphabet, char)
		end
	end
	-- Sort alphabet for consistency. --! This is not necessary
	table.sort(alphabet) --? Remove this? It allows some nice properties, such as the order of characters in strings not changing the output alphabet
	return table.concat(alphabet)
end

--[=[
	@within String
	@function Convert
	@param x string
	@param inAlphabet Alphabet
	@param outAlphabet Alphabet
	@return string

	Converts a string from one alphabet to another.
]=]
Squash.String.Convert = function(x: string, inAlphabet: Alphabet, outAlphabet: Alphabet): string
    inAlphabet = Squash.Delimiter .. inAlphabet
	outAlphabet = Squash.Delimiter .. outAlphabet

    local sourceDigits = {}
    for i = 1, #inAlphabet do
        sourceDigits[string.byte(inAlphabet, i)] = i - 1
    end

	local targetDigits = {}
    for i = 1, #outAlphabet do
        targetDigits[i - 1] = string.byte(outAlphabet, i)
    end

	local inputDigits = {}
    for i = 1, #x do
        table.insert(inputDigits, sourceDigits[string.byte(x, i)])
    end

	local output = {}
	local sourceBase = #inAlphabet
    local targetBase = #outAlphabet
	local carry, value
    while #inputDigits > 0 do
        carry = 0

        for i = 1, #inputDigits do
            value = inputDigits[i] + carry * sourceBase
            inputDigits[i] = math.floor(value / targetBase)
            carry = value % targetBase
        end

        while #inputDigits > 0 and inputDigits[1] == 0 do
            table.remove(inputDigits, 1)
        end

        table.insert(output, 1, string.char(targetDigits[carry]))
    end

    return table.concat(output)
end

--[=[
	@within String
	@function Ser
	@param x string
	@param alphabet Alphabet?
	@return string
]=]
Squash.String.Ser = function(x: string, alphabet: Alphabet?): string
	return Squash.String.Convert(x, alphabet or Squash.English, Squash.UTF8)
end

--[=[
	@within String
	@function Des
	@param y string
	@param alphabet Alphabet?
	@return string
]=]
Squash.String.Des = function(y: string, alphabet: Alphabet?): string
	return Squash.String.Convert(y, Squash.UTF8, alphabet or Squash.English)
end

--[=[
	@within String
	@function SerArr
	@param x { string }
	@param alphabet Alphabet?
	@return string
]=]
Squash.String.SerArr = function(x: { string }, alphabet: Alphabet?)
	local y = {}
	for i, v in x do
		y[i] = Squash.String.Ser(v, alphabet)
	end
	return table.concat(y, Squash.Delimiter)
end

--[=[
	@within String
	@function DesArr
	@param y string
	@param alphabet Alphabet?
	@return { string }
]=]
Squash.String.DesArr = function(y: string, alphabet: Alphabet?): { string }
	local x = {}
	for v in string.gmatch(y, '[^' .. Squash.Delimiter .. ']+') do
		table.insert(x, Squash.String.Des(v, alphabet))
	end
	return x
end

--[=[
	@class Vector2
]=]
Squash.Vector2 = {}

--[=[
	@within Vector2
	@function Ser
	@param x Vector2
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.Vector2.Ser = function(x: Vector2, serdes: NumberSerDes?, bytes: number?): string
	local ser = if serdes then serdes.Ser else Squash.Int.Ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.X, bytes) .. ser(x.Y, bytes)
end

--[=[
	@within Vector2
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return Vector2
]=]
Squash.Vector2.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): Vector2
	local des = if serdes then serdes.Des else Squash.Int.Des :: NumberDes
	local bytes = bytes or 4
	return Vector2.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[=[
	@within Vector2
	@function SerArr
	@param x { Vector2 }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.Vector2.SerArr = serArrayVector(Squash.Vector2)

--[=[
	@within Vector2
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { Vector2 }
]=]
Squash.Vector2.DesArr = desArrayVector(Squash.Vector2, 2, 0)

--[=[
	@class Vector3
]=]
Squash.Vector3 = {}

--[=[
	@within Vector3
	@function Ser
	@param x Vector3
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.Vector3.Ser = function(x: Vector3, serdes: NumberSerDes?, bytes: number?): string
	local ser = if serdes then serdes.Ser else Squash.Int.Ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.X, bytes) .. ser(x.Y, bytes) .. ser(x.Z, bytes)
end

--[=[
	@within Vector3
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return Vector3
]=]
Squash.Vector3.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): Vector3
	local des = if serdes then serdes.Des else Squash.Int.Des :: NumberDes
	local bytes = bytes or 4
	return Vector3.new(
		des(string.sub(y, 1, bytes), bytes),
		des(string.sub(y, bytes + 1, 2 * bytes), bytes),
		des(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes)
	)
end

--[=[
	@within Vector3
	@function SerArr
	@param x { Vector3 }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.Vector3.SerArr = serArrayVector(Squash.Vector3)

--[=[
	@within Vector3
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { Vector3 }
]=]
Squash.Vector3.DesArr = desArrayVector(Squash.Vector3, 3, 0)

--[=[
	@class Vector2int16
]=]
Squash.Vector2int16 = {}

--[=[
	@within Vector2int16
	@function Ser
	@param x Vector2int16
	@return string
]=]
Squash.Vector2int16.Ser = function(x: Vector2int16)
	return Squash.Int.Ser(2, x.X) .. Squash.Int.Ser(2, x.Y)
end

--[=[
	@within Vector2int16
	@function Des
	@param y string
	@return Vector2int16
]=]
Squash.Vector2int16.Des = function(y: string): Vector2int16
	return Vector2int16.new(Squash.Int.Des(string.sub(y, 1, 2), 2), Squash.Int.Des(string.sub(y, 3, 4), 2))
end

--[=[
	@within Vector2int16
	@function SerArr
	@param x { Vector2int16 }
	@return string
]=]
Squash.Vector2int16.SerArr = serArrayFixed(Squash.Vector2int16)

--[=[
	@within Vector2int16
	@function DesArr
	@param y string
	@return { Vector2int16 }
]=]
Squash.Vector2int16.DesArr = desArrayFixed(Squash.Vector2int16, 4)

--[=[
	@class Vector3int16
]=]
Squash.Vector3int16 = {}

--[=[
	@within Vector3int16
	@function Ser
	@param x Vector3int16
	@return string
]=]
Squash.Vector3int16.Ser = function(x: Vector3int16)
	return Squash.Int.Ser(2, x.X) .. Squash.Int.Ser(2, x.Y) .. Squash.Int.Ser(2, x.Z)
end

--[=[
	@within Vector3int16
	@function Des
	@param y string
	@return Vector3int16
]=]
Squash.Vector3int16.Des = function(y: string): Vector3int16
	return Vector3int16.new(
		Squash.Int.Des(string.sub(y, 1, 2), 2),
		Squash.Int.Des(string.sub(y, 3, 4), 2),
		Squash.Int.Des(string.sub(y, 5, 6), 2)
	)
end

--[=[
	@within Vector3int16
	@function SerArr
	@param x { Vector3int16 }
	@return string
]=]
Squash.Vector3int16.SerArr = serArrayFixed(Squash.Vector3int16)

--[=[
	@within Vector3int16
	@function DesArr
	@param y string
	@return { Vector3int16 }
]=]
Squash.Vector3int16.DesArr = desArrayFixed(Squash.Vector3int16, 6)

--[=[
	@class CFrame
]=]
Squash.CFrame = {}

--[=[
	@within CFrame
	@function Ser
	@param x CFrame
	@param serdes NumberSerDes?
	@param posBytes number?
	@return string
]=]
Squash.CFrame.Ser = function(x: CFrame, serdes: NumberSerDes?, posBytes: number?): string
	local ser = if serdes then serdes.Ser else Squash.Int.Ser :: NumberSer
	local posBytes = posBytes or 4

	local rx, ry, rz = x:ToOrientation()
	local px, py, pz = x.Position.X, x.Position.Y, x.Position.Z

	return serAngle(rx) .. serAngle(ry) .. serAngle(rz) .. ser(px, posBytes) .. ser(py, posBytes) .. ser(pz, posBytes)
end

--[=[
	@within CFrame
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param posBytes number?
	@return CFrame
]=]
Squash.CFrame.Des = function(y: string, serdes: NumberSerDes?, posBytes: number?): CFrame
	local des = if serdes then serdes.Des else Squash.Int.Des :: NumberDes
	local posBytes = posBytes or 4

	local rx = desAngle(string.sub(y, 1, 2))
	local ry = desAngle(string.sub(y, 3, 4))
	local rz = desAngle(string.sub(y, 5, 6))

	local px = des(string.sub(y, 7 + 0 * posBytes, 7 + 1 * posBytes - 1), posBytes)
	local py = des(string.sub(y, 7 + 1 * posBytes, 7 + 2 * posBytes - 1), posBytes)
	local pz = des(string.sub(y, 7 + 2 * posBytes, 7 + 3 * posBytes - 1), posBytes)

	--local rx = desAngle(string.sub(y, 1, 4))
	--local ry = desAngle(string.sub(y, 5, 8))
	--local rz = desAngle(string.sub(y, 9, 12))

	--local px = des(string.sub(y, 13 + 0 * posBytes, 13 + 1 * posBytes - 1), posBytes)
	--local py = des(string.sub(y, 13 + 1 * posBytes, 13 + 2 * posBytes - 1), posBytes)
	--local pz = des(string.sub(y, 13 + 2 * posBytes, 13 + 3 * posBytes - 1), posBytes)

	return CFrame.fromOrientation(rx, ry, rz) + Vector3.new(px, py, pz)
end

--[=[
	@within CFrame
	@function SerArr
	@param x { CFrame }
	@param serdes NumberSerDes?
	@param posBytes number?
	@return string
]=]
Squash.CFrame.SerArr = serArrayVector(Squash.CFrame)

--[=[
	@within CFrame
	@function DesArr
	@param y string
	@param posBytes number
	@param serdes NumberSerDes?
	@return { CFrame }
]=]
Squash.CFrame.DesArr = function(y: string, posBytes: number, serdes: NumberSerDes?): { CFrame }
	local decoding = serdes or Squash.Int
	local bytes = 7 + 3 * posBytes

	local x = {}
	for i = 1, #y / bytes do
		local a = bytes * (i - 1) + 1
		local b = bytes * i
		x[i] = Squash.CFrame.Des(string.sub(y, a, b), decoding, posBytes)
	end
	return x
end

--[=[
	@class Enum
]=]
Squash.Enum = {}

--[=[
	@within Enum
	@function Ser
	@param x Enum
	@return string
]=]
Squash.Enum.Ser = function(x: Enum): string
	local enumDataStuff = enumData[x]
	local enumId = table.find(enumDataStuff.items, x) :: number
	return Squash.UInt.Ser(enumId, enumDataStuff.bytes)
end

--[=[
	@within Enum
	@function Des
	@param y string
	@return Enum
]=]
Squash.Enum.Des = function(y: string): Enum
	local enumId = Squash.UInt.Des(y, enumData.bytes)
	return enumData.items[enumId]
end

--[=[
	@class EnumItem
]=]
Squash.EnumItem = {}

--[=[
	@within EnumItem
	@function Ser
	@param x EnumItem
	@return string
]=]
Squash.EnumItem.Ser = function(enumItem: EnumItem): string
	local enumData = enumItemData[enumItem.EnumType]
	local enumItemId = table.find(enumData.items, enumItem) :: number
	return Squash.UInt.Ser(enumItemId, enumData.bytes)
end

--[=[
	@within EnumItem
	@function Des
	@param y string
	@param enum Enum
	@return EnumItem
]=]
Squash.EnumItem.Des = function(y: string, enum: Enum): EnumItem
	local enumData = enumItemData[enum]
	local enumItemId = Squash.UInt.Des(y, enumData.bytes)
	return enumData.items[enumItemId]
end

--[=[
	@class Axes
]=]
Squash.Axes = {}

--[=[
	@within Axes
	@function Ser
	@param x Axes
	@return string
]=]
Squash.Axes.Ser = function(x: Axes)
	return Squash.Bool.Ser(x.X, x.Y, x.Z) .. Squash.Bool.Ser(x.Top, x.Bottom, x.Left, x.Right, x.Back, x.Front)
end

--[=[
	@within Axes
	@function Des
	@param y string
	@return Axes
]=]
Squash.Axes.Des = function(y: string): Axes
	local axes = Axes.new()
	axes.X, axes.Y, axes.Z = Squash.Bool.Des(string.sub(y, 1))
	axes.Top, axes.Bottom, axes.Left, axes.Right, axes.Back, axes.Front = Squash.Bool.Des(string.sub(y, 2))
	return axes
end

--[=[
	@within Axes
	@function SerArr
	@param x { Axes }
	@return string
]=]
Squash.Axes.SerArr = serArrayFixed(Squash.Axes)

--[=[
	@within Axes
	@function DesArr
	@param y string
	@return { Axes }
]=]
Squash.Axes.DesArr = desArrayFixed(Squash.Axes, 8)

--[=[
	@class BrickColor
]=]
Squash.BrickColor = {}

--[=[
	@within BrickColor
	@function Ser
	@param x BrickColor
	@return string
]=]
Squash.BrickColor.Ser = function(x: BrickColor): string
	return Squash.UInt.Ser(x.Number, 2)
end

--[=[
	@within BrickColor
	@function Des
	@param y string
	@return BrickColor
]=]
Squash.BrickColor.Des = function(y: string): BrickColor
	return BrickColor.new(Squash.UInt.Des(y, 2))
end

--[=[
	@within BrickColor
	@function SerArr
	@param x { BrickColor }
	@return string
]=]
Squash.BrickColor.SerArr = serArrayFixed(Squash.BrickColor)

--[=[
	@within BrickColor
	@function DesArr
	@param y string
	@return { BrickColor }
]=]
Squash.BrickColor.DesArr = desArrayFixed(Squash.BrickColor, 2)

--[=[
	@class Color3
]=]
Squash.Color3 = {}

--[=[
	@within Color3
	@function Ser
	@param x Color3
	@return string
]=]
Squash.Color3.Ser = function(x: Color3): string
	return string.char(x.R * 255, x.G * 255, x.B * 255)
end

--[=[
	@within Color3
	@function Des
	@param y string
	@return Color3
]=]
Squash.Color3.Des = function(y: string): Color3
	return Color3.fromRGB(string.byte(y, 1), string.byte(y, 2), string.byte(y, 3))
end

--[=[
	@within Color3
	@function SerArr
	@param x { Color3 }
	@return string
]=]
Squash.Color3.SerArr = serArrayFixed(Squash.Color3)

--[=[
	@within Color3
	@function DesArr
	@param y string
	@return { Color3 }
]=]
Squash.Color3.DesArr = desArrayFixed(Squash.Color3, 3)

--[=[
	@class CatalogSearchParams
]=]
Squash.CatalogSearchParams = {}

--[=[
	@within CatalogSearchParams
	@function Ser
	@param x CatalogSearchParams
	@param alphabet Alphabet?
	@return string
]=]
Squash.CatalogSearchParams.Ser = function(x: CatalogSearchParams, alphabet: Alphabet?): string
	local alphabet = alphabet or Squash.English

	local assetIndices = {}
	for i, v in x.AssetTypes do
		assetIndices[i] = table.find(enumItemData[Enum.AssetType].items, v) :: number
	end

	local bundleIndices = {}
	for i, v in x.BundleTypes do
		bundleIndices[i] = table.find(enumItemData[Enum.BundleType].items, v) :: number
	end

	return Squash.Bool.Ser(x.IncludeOffSale)
		.. Squash.UInt.Ser(x.MinPrice, 4)
		.. Squash.UInt.Ser(x.MaxPrice, 4)
		.. Squash.EnumItem.Ser(x.SalesTypeFilter)
		.. Squash.EnumItem.Ser(x.CategoryFilter)
		.. Squash.EnumItem.Ser(x.SortAggregation)
		.. Squash.EnumItem.Ser(x.SortType)
		.. packBits(assetIndices, enumItemData[Enum.AssetType].bits)
		.. packBits(bundleIndices, enumItemData[Enum.BundleType].bits)
		.. Squash.String.SerArr({ x.SearchKeyword, x.CreatorName }, alphabet)
end

--[=[
	@within CatalogSearchParams
	@function Des
	@param y string
	@param alphabet Alphabet?
	@return CatalogSearchParams
]=]
Squash.CatalogSearchParams.Des = function(y: string, alphabet: Alphabet): CatalogSearchParams
	local alphabet = alphabet or Squash.English

	local x = CatalogSearchParams.new()
	x.IncludeOffSale = Squash.Bool.Des(string.sub(y, 1, 1))
	x.MinPrice = Squash.UInt.Des(string.sub(y, 2, 5), 4)
	x.MaxPrice = Squash.UInt.Des(string.sub(y, 6, 9), 4)

	local offset = 10
	offset, x.SalesTypeFilter = desEnumItem(y, offset, Enum.SalesTypeFilter)
	offset, x.CategoryFilter = desEnumItem(y, offset, Enum.CatalogCategoryFilter)
	offset, x.SortAggregation = desEnumItem(y, offset, Enum.CatalogSortAggregation)
	offset, x.SortType = desEnumItem(y, offset, Enum.CatalogSortType)

	local assetTypeData = enumItemData[Enum.AssetType]
	for i, v in unpackBits(string.sub(y, offset, offset + assetTypeData.bytes - 1), assetTypeData.bits) do
		x.AssetTypes[i] = assetTypeData[v]
	end
	offset += assetTypeData.bytes

	local bundleTypeData = enumItemData[Enum.BundleType]
	for i, v in unpackBits(string.sub(y, offset, offset + bundleTypeData.bytes - 1), bundleTypeData.bits) do
		x.BundleTypes[i] = bundleTypeData[v]
	end
	offset += bundleTypeData.bytes

	local keywordEnd = Squash.String.DesArr(string.sub(y, offset), alphabet)
	x.SearchKeyword = keywordEnd[1]
	x.CreatorName = keywordEnd[2]
	return x
end

--[=[
	@within CatalogSearchParams
	@function SerArr
	@param x { CatalogSearchParams }
	@param alphabet Alphabet?
	@return string
]=]
Squash.CatalogSearchParams.SerArr = serArrayVariable(Squash.CatalogSearchParams)

--[=[
	@within CatalogSearchParams
	@function DesArr
	@param y string
	@param alphabet Alphabet?
	@return { CatalogSearchParams }
]=]
Squash.CatalogSearchParams.DesArr = desArrayVariable(Squash.CatalogSearchParams)

--[=[
	@class DateTime
]=]
Squash.DateTime = {}

local dateTimeOffset = 17_987_443_200

--[=[
	@within DateTime
	@function Ser
	@param x DateTime
	@return string
]=]
Squash.DateTime.Ser = function(x: DateTime): string
	return Squash.UInt.Ser(5, x.UnixTimestamp + dateTimeOffset)
end

--[=[
	@within DateTime
	@function Des
	@param y string
	@return DateTime
]=]
Squash.DateTime.Des = function(y: string): DateTime
	return DateTime.fromUnixTimestamp(Squash.UInt.Des(y, 5) - dateTimeOffset)
end

--[=[
	@within DateTime
	@function SerArr
	@param x { DateTime }
	@return string
]=]
Squash.DateTime.SerArr = serArrayFixed(Squash.DateTime)

--[=[
	@within DateTime
	@function DesArr
	@param y string
	@return { DateTime }
]=]
Squash.DateTime.DesArr = desArrayFixed(Squash.DateTime, 5)

--[=[
	@class DockWidgetPluginGuiInfo
]=]
Squash.DockWidgetPluginGuiInfo = {}

--[=[
	@within DockWidgetPluginGuiInfo
	@function Ser
	@param x DockWidgetPluginGuiInfo
	@return string
]=]
Squash.DockWidgetPluginGuiInfo.Ser = function(x: DockWidgetPluginGuiInfo): string
	return Squash.Bool.Ser(x.InitialEnabled, x.InitialEnabledShouldOverrideRestore)
		.. Squash.Int.Ser(2, x.FloatingXSize)
		.. Squash.Int.Ser(2, x.FloatingYSize)
		.. Squash.Int.Ser(2, x.MinWidth)
		.. Squash.Int.Ser(2, x.MinHeight)
end

--[=[
	@within DockWidgetPluginGuiInfo
	@function Des
	@param y string
	@return DockWidgetPluginGuiInfo
]=]
Squash.DockWidgetPluginGuiInfo.Des = function(y: string): DockWidgetPluginGuiInfo
	local x = DockWidgetPluginGuiInfo.new()
	x.InitialEnabled, x.InitialEnabledShouldOverrideRestore = Squash.Bool.Des(string.sub(y, 1, 1))
	x.FloatingXSize = Squash.Int.Des(string.sub(y, 2, 3), 2)
	x.FloatingYSize = Squash.Int.Des(string.sub(y, 4, 5), 2)
	x.MinWidth = Squash.Int.Des(string.sub(y, 6, 7), 2)
	x.MinHeight = Squash.Int.Des(string.sub(y, 8, 9), 2)
	return x
end

--[=[
	@within DockWidgetPluginGuiInfo
	@function SerArr
	@param x { DockWidgetPluginGuiInfo }
	@return string
]=]
Squash.DockWidgetPluginGuiInfo.SerArr = serArrayFixed(Squash.DockWidgetPluginGuiInfo)

--[=[
	@within DockWidgetPluginGuiInfo
	@function DesArr
	@param y string
	@return { DockWidgetPluginGuiInfo }
]=]
Squash.DockWidgetPluginGuiInfo.DesArr = desArrayFixed(Squash.DockWidgetPluginGuiInfo, 9)

--[=[
	@class ColorSequenceKeypoint
]=]
Squash.ColorSequenceKeypoint = {}

--[=[
	@within ColorSequenceKeypoint
	@function Ser
	@param x ColorSequenceKeypoint
	@return string
]=]
Squash.ColorSequenceKeypoint.Ser = function(x: ColorSequenceKeypoint): string
	return string.char(x.Time * 255) .. Squash.Color3.Ser(x.Value)
end

--[=[
	@within ColorSequenceKeypoint
	@function Des
	@param y string
	@return ColorSequenceKeypoint
]=]
Squash.ColorSequenceKeypoint.Des = function(y: string): ColorSequenceKeypoint
	return ColorSequenceKeypoint.new(string.byte(y, 1) / 255, Squash.Color3.Des(string.sub(y, 2, 4)))
end

--[=[
	@within ColorSequenceKeypoint
	@function SerArr
	@param x { ColorSequenceKeypoint }
	@return string
]=]
Squash.ColorSequenceKeypoint.SerArr = serArrayFixed(Squash.ColorSequenceKeypoint)

--[=[
	@within ColorSequenceKeypoint
	@function DesArr
	@param y string
	@return { ColorSequenceKeypoint }
]=]
Squash.ColorSequenceKeypoint.DesArr = desArrayFixed(Squash.ColorSequenceKeypoint, 4)

--[=[
	@class ColorSequence
]=]
Squash.ColorSequence = {}

--[=[
	@within ColorSequence
	@function Ser
	@param x ColorSequence
	@return string
]=]
Squash.ColorSequence.Ser = function(x: ColorSequence): string
	return Squash.ColorSequenceKeypoint.SerArr(x.Keypoints)
end

--[=[
	@within ColorSequence
	@function Des
	@param y string
	@return ColorSequence
]=]
Squash.ColorSequence.Des = function(y: string): ColorSequence
	return ColorSequence.new(Squash.ColorSequenceKeypoint.DesArr(y))
end

--[=[
	@within ColorSequence
	@function SerArr
	@param x { ColorSequence }
	@return string
]=]
Squash.ColorSequence.SerArr = serArrayVariable(Squash.ColorSequence)

--[=[
	@within ColorSequence
	@function DesArr
	@param y string
	@return { ColorSequence }
]=]
Squash.ColorSequence.DesArr = desArrayVariable(Squash.ColorSequence)

--[=[
	@class Faces
]=]
Squash.Faces = {}

--[=[
	@within Faces
	@function Ser
	@param x Faces
	@return string
]=]
Squash.Faces.Ser = function(x: Faces): string
	return Squash.Bool.Ser(x.Top, x.Bottom, x.Left, x.Right, x.Back, x.Front)
end

--[=[
	@within Faces
	@function Des
	@param y string
	@return Faces
]=]
Squash.Faces.Des = function(y: string): Faces
	local faces = Faces.new()
	faces.Top, faces.Bottom, faces.Left, faces.Right, faces.Back, faces.Front = Squash.Bool.Des(y)
	return faces
end

--[=[
	@within Faces
	@function SerArr
	@param x { Faces }
	@return string
]=]
Squash.Faces.SerArr = serArrayFixed(Squash.Faces)

--[=[
	@within Faces
	@function DesArr
	@param y string
	@return { Faces }
]=]
Squash.Faces.DesArr = desArrayFixed(Squash.Faces, 1)

--[=[
	@class FloatCurveKey
]=]
Squash.FloatCurveKey = {}

--[=[
	@within FloatCurveKey
	@function Ser
	@param x FloatCurveKey
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.FloatCurveKey.Ser = function(x: FloatCurveKey, serdes: NumberSerDes?, bytes: number?): string
	local ser = if serdes then serdes.Ser else Squash.Float.Ser :: NumberSer
	local bytes = bytes or 4

	return Squash.EnumItem.Ser(x.Interpolation)
		.. ser(x.Time, bytes)
		.. ser(x.Value, bytes)
		.. ser(x.LeftTangent, bytes)
		.. ser(x.RightTangent, bytes)
end

--[=[
	@within FloatCurveKey
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return FloatCurveKey
]=]
Squash.FloatCurveKey.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): FloatCurveKey
	local des = if serdes then serdes.Des else Squash.Float.Des :: NumberDes
	local bytes = bytes or 4

	local offset = enumItemData[Enum.KeyInterpolationMode].bytes
	local x = FloatCurveKey.new(
		des(string.sub(y, offset + 1, offset + bytes), bytes),
		des(string.sub(y, offset + bytes + 1, offset + 2 * bytes), bytes),
		Squash.EnumItem.Des(string.sub(y, 1, offset), Enum.KeyInterpolationMode) :: Enum.KeyInterpolationMode
	)
	offset += 2 * bytes
	x.LeftTangent = des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes
	x.RightTangent = des(string.sub(y, offset + 1, offset + bytes), bytes)
	return x
end

--[=[
	@within FloatCurveKey
	@function SerArr
	@param x { FloatCurveKey }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.FloatCurveKey.SerArr = serArrayVariable(Squash.FloatCurveKey)

--[=[
	@within FloatCurveKey
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { FloatCurveKey }
]=]
Squash.FloatCurveKey.DesArr = desArrayVariable(Squash.FloatCurveKey)

--[=[
	@class Font
]=]
Squash.Font = {}

--[=[
	@within Font
	@function Ser
	@param x Font
	@return string
]=]
Squash.Font.Ser = function(x: Font): string
	local family = string.match(x.Family, '(.+)%..+$')
	if not family then
		error 'Font Family must be a Roblox Font'
	end

	return Squash.EnumItem.Ser(x.Style) .. Squash.EnumItem.Ser(x.Weight) .. Squash.String.Ser(family)
end

--[=[
	@within Font
	@function Des
	@param y string
	@return Font
]=]
Squash.Font.Des = function(y: string): Font
	local a, b = 1, enumItemData[Enum.FontStyle].bytes
	local style = Squash.EnumItem.Des(string.sub(y, a, b), Enum.FontStyle) :: Enum.FontStyle
	a += b
	b += enumItemData[Enum.FontWeight].bytes
	local fontWeight = Squash.EnumItem.Des(string.sub(y, a, b), Enum.FontWeight) :: Enum.FontWeight
	local family = Squash.String.Des(string.sub(y, b + 1))
	return Font.new(family, fontWeight, style)
end

--[=[
	@within Font
	@function SerArr
	@param x { Font }
	@return string
]=]
Squash.Font.SerArr = serArrayVariable(Squash.Font)

--[=[
	@within Font
	@function DesArr
	@param y string
	@return { Font }
]=]
Squash.Font.DesArr = desArrayVariable(Squash.Font)

--[=[
	@class NumberRange
]=]
Squash.NumberRange = {}

--[=[
	@within NumberRange
	@function Ser
	@param x NumberRange
	@param serdes NumberSerDes?
	@param bytes number?
]=]
Squash.NumberRange.Ser = function(x: NumberRange, serdes: NumberSerDes?, bytes: number?): string
	local ser = if serdes then serdes.Ser else Squash.Int.Ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.Min, bytes) .. ser(x.Max, bytes)
end

--[=[
	@within NumberRange
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return NumberRange
]=]
Squash.NumberRange.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): NumberRange
	local des = if serdes then serdes.Des else Squash.Int.Des :: NumberDes
	local bytes = bytes or 4
	return NumberRange.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[=[
	@within NumberRange
	@function SerArr
	@param x { NumberRange }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.NumberRange.SerArr = serArrayVector(Squash.NumberRange)

--[=[
	@within NumberRange
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { NumberRange }
]=]
Squash.NumberRange.DesArr = desArrayVector(Squash.NumberRange, 2, 0)

--[=[
	@class NumberSequenceKeypoint
]=]
Squash.NumberSequenceKeypoint = {}

--[=[
	@within NumberSequenceKeypoint
	@function Ser
	@param x NumberSequenceKeypoint
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.NumberSequenceKeypoint.Ser = function(x: NumberSequenceKeypoint, serdes: NumberSerDes?, bytes: number?): string
	local ser = if serdes then serdes.Ser else Squash.Float.Ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.Time, bytes) .. ser(x.Value, bytes) .. ser(x.Envelope, bytes)
end

--[=[
	@within NumberSequenceKeypoint
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return NumberSequenceKeypoint
]=]
Squash.NumberSequenceKeypoint.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): NumberSequenceKeypoint
	local des = if serdes then serdes.Des else Squash.Float.Des :: NumberDes
	local bytes = bytes or 4
	return NumberSequenceKeypoint.new(
		des(string.sub(y, 1, bytes), bytes),
		des(string.sub(y, bytes + 1, 2 * bytes), bytes),
		des(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes)
	)
end

--[=[
	@within NumberSequenceKeypoint
	@function SerArr
	@param x { NumberSequenceKeypoint }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.NumberSequenceKeypoint.SerArr = serArrayVector(Squash.NumberSequenceKeypoint)

--[=[
	@within NumberSequenceKeypoint
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { NumberSequenceKeypoint }
]=]
Squash.NumberSequenceKeypoint.DesArr = desArrayVector(Squash.NumberSequenceKeypoint, 3, 0)

--[=[
	@class NumberSequence
]=]
Squash.NumberSequence = {}

--[=[
	@within NumberSequence
	@function Ser
	@param x NumberSequence
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.NumberSequence.Ser = function(x: NumberSequence, serdes: NumberSerDes?, bytes: number?): string
	return Squash.NumberSequenceKeypoint.SerArr(x.Keypoints, serdes, bytes)
end

--[=[
	@within NumberSequence
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return NumberSequence
]=]
Squash.NumberSequence.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): NumberSequence
	return NumberSequence.new(Squash.NumberSequenceKeypoint.DesArr(y, serdes, bytes))
end

--[=[
	@within NumberSequence
	@function SerArr
	@param x { NumberSequence }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.NumberSequence.SerArr = serArrayVariable(Squash.NumberSequence)

--[=[
	@within NumberSequence
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { NumberSequence }
]=]
Squash.NumberSequence.DesArr = desArrayVariable(Squash.NumberSequence)

--[=[
	@class OverlapParams
]=]
Squash.OverlapParams = {}

--[=[
	@within OverlapParams
	@function Ser
	@param x OverlapParams
	@return string
]=]
Squash.OverlapParams.Ser = function(x: OverlapParams): string
	return string.char(
		(if x.FilterType == Enum.RaycastFilterType.Include then 1 else 0) + (if x.RespectCanCollide then 2 else 0)
	) .. Squash.UInt.Ser(2, x.MaxParts) .. Squash.String.Ser(x.CollisionGroup) -- I wish we could use GetCollisionGroupId and restrict this to 1 or 2 bytes, but that was deprecated.
end

--[=[
	@within OverlapParams
	@function Des
	@param y string
	@return OverlapParams
]=]
Squash.OverlapParams.Des = function(y: string): OverlapParams
	local filterTypeAndRespectCanCollide = string.byte(y, 1)

	local x = OverlapParams.new()
	x.CollisionGroup = Squash.String.Des(string.sub(y, 4))
	x.MaxParts = Squash.UInt.Des(string.sub(y, 2, 3), 2)
	x.RespectCanCollide = filterTypeAndRespectCanCollide >= 2
	x.FilterType = if filterTypeAndRespectCanCollide % 2 == 1
		then Enum.RaycastFilterType.Include
		else Enum.RaycastFilterType.Exclude

	return x
end

--[=[
	@within OverlapParams
	@function SerArr
	@param x { OverlapParams }
	@return string
]=]
Squash.OverlapParams.SerArr = serArrayVariable(Squash.OverlapParams)

--[=[
	@within OverlapParams
	@function DesArr
	@param y string
	@return { OverlapParams }
]=]
Squash.OverlapParams.DesArr = desArrayVariable(Squash.OverlapParams)

--[=[
	@class RaycastParams
]=]
Squash.RaycastParams = {}

--[=[
	@within RaycastParams
	@function Ser
	@param x RaycastParams
	@return string
]=]
Squash.RaycastParams.Ser = function(x: RaycastParams): string
	return Squash.Bool.Ser(x.FilterType == Enum.RaycastFilterType.Include, x.IgnoreWater, x.RespectCanCollide)
		.. Squash.String.Ser(x.CollisionGroup)
end

--[=[
	@within RaycastParams
	@function Des
	@param y string
	@return RaycastParams
]=]
Squash.RaycastParams.Des = function(y: string): RaycastParams
	local isInclude, ignoreWater, respectCanCollide = Squash.Bool.Des(string.sub(y, 1, 1))

	local x = RaycastParams.new()
	x.CollisionGroup = Squash.String.Des(string.sub(y, 2))
	x.RespectCanCollide = respectCanCollide
	x.IgnoreWater = ignoreWater
	x.FilterType = if isInclude then Enum.RaycastFilterType.Include else Enum.RaycastFilterType.Exclude

	return x
end

--[=[
	@within RaycastParams
	@function SerArr
	@param x { RaycastParams }
	@return string
]=]
Squash.RaycastParams.SerArr = serArrayVariable(Squash.RaycastParams)

--[=[
	@within RaycastParams
	@function DesArr
	@param y string
	@return { RaycastParams }
]=]
Squash.RaycastParams.DesArr = desArrayVariable(Squash.RaycastParams)

--[=[
	@class PathWaypoint
]=]
Squash.PathWaypoint = {}

--[=[
	@within PathWaypoint
	@function Ser
	@param x PathWaypoint
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.PathWaypoint.Ser = function(x: PathWaypoint, serdes: NumberSerDes?, bytes: number?): string
	local bytes = bytes or 4
	return Squash.EnumItem.Ser(x.Action) .. Squash.Vector3.Ser(x.Position, serdes, bytes)
end

--[=[
	@within PathWaypoint
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return PathWaypoint
]=]
Squash.PathWaypoint.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): PathWaypoint
	local bytes = bytes or 4
	local offset, action = 1, nil
	offset, action = desEnumItem(y, offset, Enum.PathWaypointAction)
	return PathWaypoint.new(
		Squash.Vector3.Des(string.sub(y, offset + 1), serdes, bytes),
		action :: Enum.PathWaypointAction
	)
end

--[=[
	@within PathWaypoint
	@function SerArr
	@param x { PathWaypoint }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.PathWaypoint.SerArr = serArrayVector(Squash.PathWaypoint)

--[=[
	@within PathWaypoint
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { PathWaypoint }
]=]
Squash.PathWaypoint.DesArr = desArrayVector(Squash.PathWaypoint, 3, enumItemData[Enum.PathWaypointAction].bytes)

--[=[
	@class PhysicalProperties
]=]
Squash.PhysicalProperties = {}

--[=[
	@within PhysicalProperties
	@function Ser
	@param x PhysicalProperties
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.PhysicalProperties.Ser = function(x: PhysicalProperties, serdes: NumberSerDes?, bytes: number?): string
	local ser = if serdes then serdes.Ser else Squash.Int.Ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.Density, bytes)
		.. ser(x.Friction, bytes)
		.. ser(x.Elasticity, bytes)
		.. ser(x.FrictionWeight, bytes)
		.. ser(x.ElasticityWeight, bytes)
end

--[=[
	@within PhysicalProperties
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return PhysicalProperties
]=]
Squash.PhysicalProperties.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): PhysicalProperties
	local des = if serdes then serdes.Des else Squash.Int.Des :: NumberDes
	local bytes = bytes or 4
	return PhysicalProperties.new(
		des(string.sub(y, 1, bytes), bytes),
		des(string.sub(y, bytes + 1, 2 * bytes), bytes),
		des(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes),
		des(string.sub(y, 3 * bytes + 1, 4 * bytes), bytes),
		des(string.sub(y, 4 * bytes + 1, 5 * bytes), bytes)
	)
end

--[=[
	@within PhysicalProperties
	@function SerArr
	@param x { PhysicalProperties }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.PhysicalProperties.SerArr = serArrayVector(Squash.PhysicalProperties)

--[=[
	@within PhysicalProperties
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { PhysicalProperties }
]=]
Squash.PhysicalProperties.DesArr = desArrayVector(Squash.PhysicalProperties, 5, 0)

--[=[
	@class Ray
]=]
Squash.Ray = {}

--[=[
	@within Ray
	@function Ser
	@param x Ray
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.Ray.Ser = function(x: Ray, serdes: NumberSerDes?, bytes: number?): string
	local bytes = bytes or 4
	return Squash.Vector3.Ser(x.Origin, serdes, bytes) .. Squash.Vector3.Ser(x.Direction, serdes, bytes)
end

--[=[
	@within Ray
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return Ray
]=]
Squash.Ray.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): Ray
	local bytes = bytes or 4
	return Ray.new(
		Squash.Vector3.Des(string.sub(y, 1, bytes), serdes, bytes),
		Squash.Vector3.Des(string.sub(y, bytes + 1, 2 * bytes), serdes, bytes)
	)
end

--[=[
	@within Ray
	@function SerArr
	@param x { Ray }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.Ray.SerArr = serArrayVector(Squash.Ray)

--[=[
	@within Ray
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { Ray }
]=]
Squash.Ray.DesArr = desArrayVector(Squash.Ray, 2, 0)

--[=[
	@class RaycastResult
]=]
Squash.RaycastResult = {}

--[=[
	@within RaycastResult
	@function Ser
	@param x RaycastResult
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.RaycastResult.Ser = function(x: RaycastResult, serdes: NumberSerDes?, bytes: number?): string
	local bytes = bytes or 4
	return Squash.EnumItem.Ser(x.Material)
		.. Squash.UInt.Ser(x.Distance, bytes)
		.. Squash.Vector3.Ser(x.Position, serdes, bytes)
		.. Squash.Vector3.Ser(x.Normal, serdes, bytes)
end

--[=[
	@within Squash
	@interface SquashRaycastResult
	.Material Enum.Material
	.Distance number
	.Position Vector3
	.Normal Vector3
]=]
export type SquashRaycastResult = {
	Material: Enum.Material,
	Distance: number,
	Position: Vector3,
	Normal: Vector3,
}

--[=[
	@within RaycastResult
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { Material: Enum.Material, Distance: number, Position: Vector3, Normal: Vector3 }
]=]
Squash.RaycastResult.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): SquashRaycastResult
	local bytes = bytes or 4

	local offset, material = 0, nil
	offset, material = desEnumItem(y, offset, Enum.Material)

	local distance = Squash.UInt.Des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes

	local position = Squash.Vector3.Des(string.sub(y, offset + 1, offset + bytes), serdes, bytes)
	offset += bytes

	local normal = Squash.Vector3.Des(string.sub(y, offset + 1, offset + bytes), serdes, bytes)

	return {
		Material = material :: Enum.Material,
		Distance = distance,
		Position = position,
		Normal = normal,
	}
end

--[=[
	@within RaycastResult
	@function SerArr
	@param x { RaycastResult }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.RaycastResult.SerArr = serArrayVector(Squash.RaycastResult)

--[=[
	@within RaycastResult
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { RaycastResult }
]=]
Squash.RaycastResult.DesArr = desArrayVector(Squash.RaycastResult, 7, enumItemData[Enum.Material].bytes)

--[=[
	@class Rect
]=]
Squash.Rect = {}

--[=[
	@within Rect
	@function Ser
	@param x Rect
	@param bytes number?
	@return string
]=]
Squash.Rect.Ser = function(x: Rect, bytes: number?)
	local bytes = bytes or 4
	return Squash.UInt.Ser(x.Min.X, bytes)
		.. Squash.UInt.Ser(x.Min.Y, bytes)
		.. Squash.UInt.Ser(x.Max.X, bytes)
		.. Squash.UInt.Ser(x.Max.Y, bytes)
end

--[=[
	@within Rect
	@function Des
	@param y string
	@param bytes number?
	@return Rect
]=]
Squash.Rect.Des = function(y: string, bytes: number?): Rect
	local bytes = bytes or 4
	return Rect.new(
		Squash.UInt.Des(string.sub(y, 1, bytes), bytes),
		Squash.UInt.Des(string.sub(y, bytes + 1, 2 * bytes), bytes),
		Squash.UInt.Des(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes),
		Squash.UInt.Des(string.sub(y, 3 * bytes + 1, 4 * bytes), bytes)
	)
end

--[=[
	@within Rect
	@function SerArr
	@param x { Rect }
	@param bytes number?
	@return string
]=]
Squash.Rect.SerArr = serArrayVectorNoCoding(Squash.Rect)

--[=[
	@within Rect
	@function DesArr
	@param y string
	@param bytes number?
	@return { Rect }
]=]
Squash.Rect.DesArr = desArrayVectorNoCoding(Squash.Rect, 4, 0)

--[=[
	@class Region3
]=]
Squash.Region3 = {}

--[=[
	@within Region3
	@function Ser
	@param x Region3
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.Region3.Ser = function(x: Region3, serdes: NumberSerDes?, bytes: number?): string
	local bytes = bytes or 4
	return Squash.Vector3.Ser(x.Size, serdes, bytes) .. Squash.CFrame.Ser(x.CFrame, serdes, bytes)
end

--[=[
	@within Region3
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return Region3
]=]
Squash.Region3.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): Region3
	local bytes = bytes or 4
	local x = Region3.new(Vector3.zero, Vector3.zero)
	x.Size = Squash.Vector3.Des(string.sub(y, 1, 12), serdes, bytes)
	x.CFrame = Squash.CFrame.Des(string.sub(y, 13, 24), serdes, bytes)
	return x
end

--[=[
	@within Region3
	@function SerArr
	@param x { Region3 }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.Region3.SerArr = serArrayVector(Squash.Region3)

--[=[
	@within Region3
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { Region3 }
]=]
Squash.Region3.DesArr = desArrayVector(Squash.Region3, 9, 6)

--[=[
	@class Region3int16
]=]
Squash.Region3int16 = {}

--[=[
	@within Region3int16
	@function Ser
	@param x Region3int16
	@return string
]=]
Squash.Region3int16.Ser = function(x: Region3int16): string
	return Squash.Vector3int16.Ser(x.Min) .. Squash.Vector3int16.Ser(x.Max)
end

--[=[
	@within Region3int16
	@function Des
	@param y string
	@return Region3int16
]=]
Squash.Region3int16.Des = function(y: string): Region3int16
	return Region3int16.new(Squash.Vector3int16.Des(string.sub(y, 1, 6)), Squash.Vector3int16.Des(string.sub(y, 7, 12)))
end

--[=[
	@within Region3int16
	@function SerArr
	@param x { Region3int16 }
	@return string
]=]
Squash.Region3int16.SerArr = serArrayFixed(Squash.Region3int16)

--[=[
	@within Region3int16
	@function DesArr
	@param y string
	@return { Region3int16 }
]=]
Squash.Region3int16.DesArr = desArrayFixed(Squash.Region3int16, 12)

--[=[
	@class TweenInfo
]=]
Squash.TweenInfo = {}

--[=[
	@within TweenInfo
	@function Ser
	@param x TweenInfo
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.TweenInfo.Ser = function(x: TweenInfo, serdes: NumberSerDes?, bytes: number?): string
	local ser = if serdes then serdes.Ser else Squash.Float.Ser :: NumberSer
	local bytes = bytes or 4
	return Squash.Bool.Ser(x.Reverses)
		.. Squash.EnumItem.Ser(x.EasingStyle)
		.. Squash.EnumItem.Ser(x.EasingDirection)
		.. Squash.Int.Ser(x.RepeatCount, bytes)
		.. ser(x.Time, bytes)
		.. ser(x.DelayTime, bytes)
end

--[=[
	@within TweenInfo
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return TweenInfo
]=]
Squash.TweenInfo.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): TweenInfo
	local des = if serdes then serdes.Des else Squash.Float.Des :: NumberDes
	local bytes = bytes or 4

	local offset = 0
	local reverses = Squash.Bool.Des(string.sub(y, offset + 1, offset + 1))
	offset += 1

	local easingStyle
	offset, easingStyle = desEnumItem(y, offset, Enum.EasingStyle)

	local easingDirection
	offset, easingDirection = desEnumItem(y, offset, Enum.EasingDirection)

	local repeatCount = Squash.Int.Des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes

	local tweenTime = des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes

	local delayTime = des(string.sub(y, offset + 1, offset + bytes), bytes)

	return TweenInfo.new(
		tweenTime,
		easingStyle :: Enum.EasingStyle,
		easingDirection :: Enum.EasingDirection,
		repeatCount,
		reverses,
		delayTime
	)
end

--[=[
	@within TweenInfo
	@function SerArr
	@param x { TweenInfo }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.TweenInfo.SerArr = serArrayVector(Squash.TweenInfo)

--[=[
	@within TweenInfo
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { TweenInfo }
]=]
Squash.TweenInfo.DesArr = desArrayVector(
	Squash.TweenInfo,
	3,
	1 + enumItemData[Enum.EasingStyle].bytes + enumItemData[Enum.EasingDirection].bytes
)

--[=[
	@class UDim
]=]
Squash.UDim = {}

--[=[
	@within UDim
	@function Ser
	@param x UDim
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.UDim.Ser = function(x: UDim, serdes: NumberSerDes?, bytes: number?): string
	local ser = if serdes then serdes.Ser else Squash.Int.Ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.Scale, bytes) .. ser(x.Offset, bytes)
end

--[=[
	@within UDim
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return UDim
]=]
Squash.UDim.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): UDim
	local des = if serdes then serdes.Des else Squash.Int.Des :: NumberDes
	local bytes = bytes or 4
	return UDim.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[=[
	@within UDim
	@function SerArr
	@param x { UDim }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.UDim.SerArr = serArrayVector(Squash.UDim)

--[=[
	@within UDim
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { UDim }
]=]
Squash.UDim.DesArr = desArrayVector(Squash.UDim, 2, 0)

--[=[
	@class UDim2
]=]
Squash.UDim2 = {}

--[=[
	@within UDim2
	@function Ser
	@param x UDim2
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.UDim2.Ser = function(x: UDim2, serdes: NumberSerDes?, bytes: number?): string
	local bytes = bytes or 4
	return Squash.UDim.Ser(x.X, serdes, bytes) .. Squash.UDim.Ser(x.Y, serdes, bytes)
end

--[=[
	@within UDim2
	@function Des
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return UDim2
]=]
Squash.UDim2.Des = function(y: string, serdes: NumberSerDes?, bytes: number?): UDim2
	local bytes = bytes or 4
	return UDim2.new(
		Squash.UDim.Des(string.sub(y, 1, 2 * bytes), serdes, bytes),
		Squash.UDim.Des(string.sub(y, 2 * bytes + 1, 4 * bytes), serdes, bytes)
	)
end

--[=[
	@within UDim2
	@function SerArr
	@param x { UDim2 }
	@param serdes NumberSerDes?
	@param bytes number?
	@return string
]=]
Squash.UDim2.SerArr = serArrayVector(Squash.UDim2)

--[=[
	@within UDim2
	@function DesArr
	@param y string
	@param serdes NumberSerDes?
	@param bytes number?
	@return { UDim2 }
]=]
Squash.UDim2.DesArr = desArrayVector(Squash.UDim2, 4, 0)

return Squash
