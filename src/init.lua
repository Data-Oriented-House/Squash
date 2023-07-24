--!strict
--!optimize 2

--[=[
	@class Squash
]=]
local Squash = {}

--* Types *--

--[=[
	@within Squash
	@type Alphabet string

	A string of unique characters that represent the basis of other strings.
]=]
export type Alphabet = string

--[=[
	@within Squash
	@type Bytes number

	1, 2, 3, 4, 5, 6, 7, 8

	The number of bytes used to represent a number.
]=]
export type Bytes = number

--[=[
	@within Squash
	@type FloatBytes number

	4, 8

	The number of bytes used to represent a floating point number.
]=]
export type FloatBytes = number

--[=[
	@within Squash
	@type NumberSer (x: number, bytes: Bytes?) -> string

	A function that serializes a number into a string. Usually this is Squash's uint, int, or number ser methods.
]=]
export type NumberSer = (x: number, bytes: Bytes?) -> string

--[=[
	@within Squash
	@type NumberDes (y: string, bytes: Bytes?) -> number

	A function that deserializes a number from a string. Usually this is Squash's uint, int, or number des methods.
]=]
export type NumberDes = (y: string, bytes: Bytes?) -> number

--[=[
	@within Squash
	@interface NumberSerDes
	.ser NumberSer
	.des NumberDes
]=]
export type NumberSerDes = {
	ser: NumberSer,
	des: NumberDes,
}

type VectorSer<T> = (T, NumberSerDes?, number?) -> string
type VectorDes<T> = (string, NumberSerDes?, number?) -> T
type VectorSerDes<T, U> = {
	ser: VectorSer<T>,
	des: VectorDes<U>,
}

type VectorNoCodingSer<T> = (T, number?) -> string
type VectorNoCodingDes<T> = (string, number?) -> T
type VectorNoCodingSerDes<T> = {
	ser: VectorNoCodingSer<T>,
	des: VectorNoCodingDes<T>,
}

type FixedSer<T> = (T) -> string
type FixedDes<T> = (string) -> T
type FixedSerDes<T> = {
	ser: FixedSer<T>,
	des: FixedDes<T>,
}

type VariableSer<T, U...> = (T, U...) -> string
type VariableDes<T, U...> = (string, U...) -> T
type VariableSerDes<T, U...> = {
	ser: VariableSer<T, U...>,
	des: VariableDes<T, U...>,
}

--* Properties *--

--[=[
	@within Squash
	@prop delimiter string

	The delimiter used to separate strings or other types in variable sized arrays and act as the 0 element for base conversions.
]=]
Squash.delimiter = string.char(0) -- \0

--[=[
	@within Squash
	@prop binary Alphabet

	All digits in base 2.
]=]
Squash.binary = '01' :: Alphabet

--[=[
	@within Squash
	@prop octal Alphabet

	All digits in base 8.
]=]
Squash.octal = '01234567' :: Alphabet

--[=[
	@within Squash
	@prop decimal Alphabet

	All digits in base 10.
]=]
Squash.decimal = '0123456789' :: Alphabet

--[=[
	@within Squash
	@prop duodecimal Alphabet

	All digits in base 12.
]=]
Squash.duodecimal = '0123456789AB' :: Alphabet

--[=[
	@within Squash
	@prop hexadecimal Alphabet

	All digits in base 16.
]=]
Squash.hexadecimal = '0123456789ABCDEF' :: Alphabet

--[=[
	@within Squash
	@prop utf8 Alphabet

	All digits in base 256. The UTF-8 character set.
]=]
local utf8Characters = table.create(256)
for i = 0, 255 do
	utf8Characters[i + 1] = string.char(i)
end
Squash.utf8 = table.concat(utf8Characters) :: Alphabet

--[=[
	@within Squash
	@prop lower Alphabet

	All lowercase letters in the english language.
]=]
Squash.lower = 'abcdefghijklmnopqrstuvwxyz' :: Alphabet

--[=[
	@within Squash
	@prop upper Alphabet

	All uppercase letters in the english language.
]=]
Squash.upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' :: Alphabet

--[=[
	@within Squash
	@prop letters Alphabet

	All letters in the english language.
]=]
Squash.letters = Squash.lower .. Squash.upper :: Alphabet

--[=[
	@within Squash
	@prop punctuation Alphabet

	All punctuation symbols in the english language.
]=]
Squash.punctuation = ' .,?!:;\'"-_' :: Alphabet

--[=[
	@within Squash
	@prop english Alphabet

	All symbols in the english language.
]=]
Squash.english = Squash.letters .. Squash.punctuation :: Alphabet

--[=[
	@within Squash
	@prop filepath Alphabet

	All characters that may be used in a filepath.
]=]
Squash.filepath = Squash.letters .. ':/' :: Alphabet

--[=[
	@within Squash
	@prop datastore Alphabet

	All characters that will not be expanded when JSONEncoded.
]=]
Squash.datastore = ' !#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~'

--* Duplication Reducers *--

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

local serArrayNumber = function<T>(ser: (x: T, bytes: Bytes?) -> string)
	return function(x: { T }, bytes: Bytes?): string
		local bytes = bytes or 4
		bytesAssert(bytes)

		local y = {}
		for i, v in x do
			y[i] = ser(v, bytes)
		end
		return table.concat(y)
	end
end

local desArrayNumber = function<T>(des: (y: string, bytes: Bytes?) -> T)
	return function(y: string, bytes: Bytes?): { T }
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
	local ser = serdes.ser
	return function(x: { T }): string
		local y = {}
		for i, v in x do
			y[i] = ser(v)
		end
		return table.concat(y)
	end
end

local desArrayFixed = function<T>(serdes: FixedSerDes<T>, bytes: number)
	local des = serdes.des
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
	local ser = serdes.ser
	return function(x: { T }, ...: U...): string
		local y = {}
		for i, v in x do
			y[i] = ser(v, ...)
		end
		return table.concat(y, Squash.delimiter)
	end
end

local desArrayVariable = function<T, U...>(serdes: VariableSerDes<T, U...>)
	local des = serdes.des
	return function(y: string, ...: U...): { T }
		local x = {}
		for v in string.gmatch(y, '[^' .. Squash.delimiter .. ']+') do
			table.insert(x, des(v, ...))
		end
		return x
	end
end

local serArrayVector = function<T, U>(serializer: VectorSerDes<T, U>)
	local ser = serializer.ser
	return function(x: { T }, serdes: NumberSerDes?, bytes: Bytes?): string
		local bytes = bytes or 4
		local encoding = serdes or Squash.number

		local y = {}
		for i, v in x do
			y[i] = ser(v, encoding, bytes)
		end
		return table.concat(y)
	end
end

local desArrayVector = function<T, U>(deserializer: VectorSerDes<T, U>, elements: number, offsetBytes: number)
	local des = deserializer.des
	return function(y: string, serdes: NumberSerDes?, bytes: Bytes?): { U }
		local bytes = bytes or 4
		local decoding = serdes or Squash.number

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
	local ser = serializer.ser
	return function(x: { T }, bytes: Bytes?): string
		local bytes = bytes or 4

		local y = {}
		for i, v in x do
			y[i] = ser(v, bytes)
		end
		return table.concat(y)
	end
end

local desArrayVectorNoCoding = function<T>(deserializer: VectorNoCodingSerDes<T>, elements: number, offsetBytes: number)
	local des = deserializer.des
	return function(y: string, bytes: Bytes?): { T }
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
	return Squash.uint.ser(x % tau * angleRatio, 2)
end

local desAngle = function(y: string): number
	return Squash.uint.des(y, 2) / angleRatio
end

local getBitSize = function(x: number): number
	return math.ceil(math.log(x, 2))
end

local getByteSize = function(x: number): number
	return math.ceil(math.log(x, 256))
end

local getItemData = function<T>(array: { T }): { items: { T }, lookup: { [T]: number }, bits: number, bytes: number }
	local lookup = {}

	for i, v in array do
		lookup[v] = i
	end

	return {
		items = array,
		lookup = lookup,
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
	local enumItemId = Squash.uint.des(string.sub(y, offset, offset + enumData.bytes - 1), enumData.bytes)
	return offset + enumData.bytes, enumData.items[enumItemId]
end

local packBits = function(x: { number }, bits: number): string
	local packed = {}
	local byte = 0
	local count = 0
	for i = 1, #x do
		for b = bits - 1, 0, -1 do
			byte = byte * 2 + math.floor(x[i] * 2 ^ -b) % 2
			count += 1
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
			value = value * 2 + math.floor(byte * 2 ^ -b) % 2
			count += 1
			if count == bits then
				table.insert(x, value)
				value = 0
				count = 0
			end
		end
	end
	return x
end

--? Done this way because roblox luau does not support constant folding. This has been benchmarked.

local n2_2 = 2 ^ 2
local n2_3 = 2 ^ 3
local n2_4 = 2 ^ 4
local n2_5 = 2 ^ 5
local n2_6 = 2 ^ 6
local n2_7 = 2 ^ 7

local n2_1_ = 2 ^ -1
local n2_2_ = 2 ^ -2
local n2_3_ = 2 ^ -3
local n2_4_ = 2 ^ -4
local n2_5_ = 2 ^ -5
local n2_6_ = 2 ^ -6
local n2_7_ = 2 ^ -7

local n256_2 = 256 ^ 2
local n256_3 = 256 ^ 3
local n256_4 = 256 ^ 4
local n256_5 = 256 ^ 5
local n256_6 = 256 ^ 6
local n256_7 = 256 ^ 7

--* Actual API *--

--[=[
	@class boolean
]=]
Squash.boolean = {}

--[=[
	@within boolean
	@function ser
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
Squash.boolean.ser = function(
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
		(if x1 then 1 else 0)
			+ (if x2 then 2 else 0)
			+ (if x3 then n2_2 else 0)
			+ (if x4 then n2_3 else 0)
			+ (if x5 then n2_4 else 0)
			+ (if x6 then n2_5 else 0)
			+ (if x7 then n2_6 else 0)
			+ (if x8 then n2_7 else 0)
	)
end

--[=[
	@within boolean
	@function des
	@param y string
	@return boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean
]=]
Squash.boolean.des = function(y: string): (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean)
	local x = string.byte(y)
	return x % 2 >= 1,
		(x * n2_1_) % 2 >= 1,
		(x * n2_2_) % 2 >= 1,
		(x * n2_3_) % 2 >= 1,
		(x * n2_4_) % 2 >= 1,
		(x * n2_5_) % 2 >= 1,
		(x * n2_6_) % 2 >= 1,
		(x * n2_7_) % 2 >= 1
end

--[=[
	@within boolean
	@function serarr
	@param x { boolean }
	@return string
]=]
Squash.boolean.serarr = function(x: { boolean }): string
	local y = {}
	for i = 1, math.ceil(#x / 8) do
		y[i] = Squash.boolean.ser(x[i + 0], x[i + 1], x[i + 2], x[i + 3], x[i + 4], x[i + 5], x[i + 6], x[i + 7])
	end
	return table.concat(y)
end

--[=[
	@within boolean
	@function desarr
	@param y string
	@return { boolean }
]=]

Squash.boolean.desarr = function(y: string): { boolean }
	local x = {}
	for i = 1, #y do
		local j = 8 * i
		x[j - 7], x[j - 6], x[j - 5], x[j - 4], x[j - 3], x[j - 2], x[j - 1], x[j] =
			Squash.boolean.des(string.sub(y, i, i))
	end
	return x
end

--[=[
	@class uint
]=]
Squash.uint = {}

--[=[
	@within uint
	@function ser
	@param x number
	@param bytes Bytes?
	@return string
]=]
Squash.uint.ser = function(x: number, bytes: Bytes?): string
	local bytes = bytes or 4
	bytesAssert(bytes)

	--? Compared to a simple for loop, this is about 10x faster.
	--? The order of these if statements is attempted to be optimized for performance, with the most common cases first.
	if bytes == 4 then
		return string.char(
			math.floor(x) % 256,
			math.floor(x * 256) % 256,
			math.floor(x * n256_2) % 256,
			math.floor(x * n256_3) % 256
		)
	elseif bytes == 8 then
		return string.char(
			math.floor(x) % 256,
			math.floor(x * 256) % 256,
			math.floor(x * n256_2) % 256,
			math.floor(x * n256_3) % 256,
			math.floor(x * n256_4) % 256,
			math.floor(x * n256_5) % 256,
			math.floor(x * n256_6) % 256,
			math.floor(x * n256_7) % 256
		)
	elseif bytes == 2 then
		return string.char(math.floor(x) % 256, math.floor(x * 256) % 256)
	elseif bytes == 1 then
		return string.char(math.floor(x) % 256)
	elseif bytes == 3 then
		return string.char(math.floor(x) % 256, math.floor(x * 256) % 256, math.floor(x * n256_2) % 256)
	elseif bytes == 5 then
		return string.char(
			math.floor(x) % 256,
			math.floor(x * 256) % 256,
			math.floor(x * n256_2) % 256,
			math.floor(x * n256_3) % 256,
			math.floor(x * n256_4) % 256
		)
	elseif bytes == 6 then
		return string.char(
			math.floor(x) % 256,
			math.floor(x * 256) % 256,
			math.floor(x * n256_2) % 256,
			math.floor(x * n256_3) % 256,
			math.floor(x * n256_4) % 256,
			math.floor(x * n256_5) % 256
		)
	elseif bytes == 7 then
		return string.char(
			math.floor(x) % 256,
			math.floor(x * 256) % 256,
			math.floor(x * n256_2) % 256,
			math.floor(x * n256_3) % 256,
			math.floor(x * n256_4) % 256,
			math.floor(x * n256_5) % 256,
			math.floor(x * n256_6) % 256
		)
	end

	--? Should never get called because of the bytesAssert at the top of the function. This is just to make the typechecker happy.
	error('Invalid bytes: ' .. bytes)
end

--[=[
	@within uint
	@function des
	@param y string
	@param bytes Bytes?
	@return number
]=]
Squash.uint.des = function(y: string, bytes: Bytes?): number
	local bytes = bytes or 4
	bytesAssert(bytes)

	--? The order of these if statements is attempted to be optimized for performance, with the most common cases first.
	if bytes == 4 then
		return math.floor(string.byte(y, 1))
			+ math.floor(string.byte(y, 2) * 256)
			+ math.floor(string.byte(y, 3) * n256_2)
			+ math.floor(string.byte(y, 4) * n256_3)
	elseif bytes == 8 then
		return math.floor(string.byte(y, 1))
			+ math.floor(string.byte(y, 2) * 256)
			+ math.floor(string.byte(y, 3) * n256_2)
			+ math.floor(string.byte(y, 4) * n256_3)
			+ math.floor(string.byte(y, 5) * n256_4)
			+ math.floor(string.byte(y, 6) * n256_5)
			+ math.floor(string.byte(y, 7) * n256_6)
			+ math.floor(string.byte(y, 8) * n256_7)
	elseif bytes == 2 then
		return math.floor(string.byte(y, 1)) + math.floor(string.byte(y, 2) * 256)
	elseif bytes == 1 then
		return math.floor(string.byte(y, 1))
	elseif bytes == 3 then
		return math.floor(string.byte(y, 1))
			+ math.floor(string.byte(y, 2) * 256)
			+ math.floor(string.byte(y, 3) * n256_2)
	elseif bytes == 5 then
		return math.floor(string.byte(y, 1))
			+ math.floor(string.byte(y, 2) * 256)
			+ math.floor(string.byte(y, 3) * n256_2)
			+ math.floor(string.byte(y, 4) * n256_3)
			+ math.floor(string.byte(y, 5) * n256_4)
	elseif bytes == 6 then
		return math.floor(string.byte(y, 1))
			+ math.floor(string.byte(y, 2) * 256)
			+ math.floor(string.byte(y, 3) * n256_2)
			+ math.floor(string.byte(y, 4) * n256_3)
			+ math.floor(string.byte(y, 5) * n256_4)
			+ math.floor(string.byte(y, 6) * n256_5)
	elseif bytes == 7 then
		return math.floor(string.byte(y, 1))
			+ math.floor(string.byte(y, 2) * 256)
			+ math.floor(string.byte(y, 3) * n256_2)
			+ math.floor(string.byte(y, 4) * n256_3)
			+ math.floor(string.byte(y, 5) * n256_4)
			+ math.floor(string.byte(y, 6) * n256_5)
			+ math.floor(string.byte(y, 7) * n256_6)
	end

	--? Should never get called because of the bytesAssert at the top of the function. This is just to make the typechecker happy.
	error('Invalid bytes: ' .. bytes)
end

--[=[
	@within uint
	@function serarr
	@param x { number }
	@param bytes Bytes?
	@return string
]=]
Squash.uint.serarr = serArrayNumber(Squash.uint.ser)

--[=[
	@within uint
	@function desarr
	@param y string
	@param bytes Bytes?
	@return { number }
]=]
Squash.uint.desarr = desArrayNumber(Squash.uint.des)

--[=[
	@class int
]=]
Squash.int = {}

--[=[
	@within int
	@function ser
	@param x number
	@param bytes Bytes?
	@return string
]=]
Squash.int.ser = function(x: number, bytes: Bytes?): string
	local bytes = bytes or 4
	bytesAssert(bytes)

	local sx = if x < 0 then x + 256 ^ bytes else x
	return Squash.uint.ser(sx, bytes)
end

--[=[
	@within int
	@function des
	@param y string
	@param bytes Bytes?
	@return number
]=]
Squash.int.des = function(y: string, bytes: Bytes?): number
	local bytes = bytes or 4
	bytesAssert(bytes)

	local x = Squash.uint.des(y, bytes)
	return if x > 0.5 * 256 ^ bytes - 1 then x - 256 ^ bytes else x
end

--[=[
	@within int
	@function serarr
	@param x { number }
	@param bytes Bytes?
	@return string
]=]
Squash.int.serarr = serArrayNumber(Squash.int.ser)

--[=[
	@within int
	@function desarr
	@param y string
	@param bytes Bytes?
	@return { number }
]=]
Squash.int.desarr = desArrayNumber(Squash.int.des)

--[=[
	@class number
]=]
Squash.number = {}

--[=[
	@within number
	@function ser
	@param x number
	@param bytes FloatBytes?
	@return string
]=]
Squash.number.ser = function(x: number, bytes: FloatBytes?): string
	local bytes = bytes or 4
	floatAssert(bytes)
	return string.pack(if bytes == 4 then 'f' else 'd', x)
end

--[=[
	@within number
	@function des
	@param y string
	@param bytes FloatBytes?
	@return number
]=]
Squash.number.des = function(y: string, bytes: FloatBytes?): number
	local bytes = bytes or 4
	floatAssert(bytes)
	local x = string.unpack(if bytes == 4 then 'f' else 'd', y) --! This is to avoid returning multiple values
	return x
end

--[=[
	@within number
	@function serarr
	@param x { number }
	@param bytes FloatBytes?
	@return string
]=]
Squash.number.serarr = serArrayNumber(Squash.number.ser)

--[=[
	@within number
	@function desarr
	@param y string
	@param bytes FloatBytes?
	@return { number }
]=]
Squash.number.desarr = desArrayNumber(Squash.number.des)

--[=[
	@class string
]=]
Squash.string = {}

--[=[
	@within string
	@function alphabet
	@param source string
	@return Alphabet

	Maps a string to the smallest sorted alphabet that represents it.
]=]
Squash.string.alphabet = function(source: string): Alphabet
	local lookup = {}
	local alphabet = table.create(#source)
	for i = 1, #source do
		local char = string.sub(source, i, i)
		if not lookup[char] then
			lookup[char] = true
			table.insert(alphabet, char)
		end
	end
	table.sort(alphabet)
	return table.concat(alphabet)
end

--[=[
	@within string
	@function convert
	@param x string
	@param inAlphabet Alphabet
	@param outAlphabet Alphabet
	@return string

	Converts a string from one alphabet to another.
]=]
Squash.string.convert = function(x: string, inAlphabet: Alphabet, outAlphabet: Alphabet): string
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
	@within string
	@function ser
	@param x string
	@param alphabet Alphabet?
	@return string
]=]
Squash.string.ser = function(x: string, alphabet: Alphabet?): string
	local inAlphabet = Squash.delimiter .. (alphabet or Squash.english)
	return Squash.string.convert(x, inAlphabet, Squash.utf8)
end

--[=[
	@within string
	@function des
	@param y string
	@param alphabet Alphabet?
	@return string
]=]
Squash.string.des = function(y: string, alphabet: Alphabet?): string
	local outAlphabet = Squash.delimiter .. (alphabet or Squash.english)
	return Squash.string.convert(y, Squash.utf8, outAlphabet)
end

--[=[
	@within string
	@function serarr
	@param x { string }
	@param alphabet Alphabet?
	@return string
]=]
Squash.string.serarr = function(x: { string }, alphabet: Alphabet?)
	local y = {}
	for i, v in x do
		y[i] = Squash.string.ser(v, alphabet)
	end
	return table.concat(y, Squash.delimiter)
end

--[=[
	@within string
	@function desarr
	@param y string
	@param alphabet Alphabet?
	@return { string }
]=]
Squash.string.desarr = function(y: string, alphabet: Alphabet?): { string }
	local x = {}
	for v in string.gmatch(y, '[^' .. Squash.delimiter .. ']+') do
		table.insert(x, Squash.string.des(v, alphabet))
	end
	return x
end

--[=[
	@class Vector2
]=]
Squash.Vector2 = {}

--[=[
	@within Vector2
	@function ser
	@param x Vector2
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.Vector2.ser = function(x: Vector2, serdes: NumberSerDes?, bytes: Bytes?): string
	local ser = if serdes then serdes.ser else Squash.number.ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.X, bytes) .. ser(x.Y, bytes)
end

--[=[
	@within Vector2
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return Vector2
]=]
Squash.Vector2.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): Vector2
	local des = if serdes then serdes.des else Squash.number.des :: NumberDes
	local bytes = bytes or 4
	return Vector2.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, 1 + bytes, 2 * bytes), bytes))
end

--[=[
	@within Vector2
	@function serarr
	@param x { Vector2 }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.Vector2.serarr = serArrayVector(Squash.Vector2)

--[=[
	@within Vector2
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { Vector2 }
]=]
Squash.Vector2.desarr = desArrayVector(Squash.Vector2, 2, 0)

--[=[
	@class Vector3
]=]
Squash.Vector3 = {}

--[=[
	@within Vector3
	@function ser
	@param x Vector3
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.Vector3.ser = function(x: Vector3, serdes: NumberSerDes?, bytes: Bytes?): string
	local ser = if serdes then serdes.ser else Squash.number.ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.X, bytes) .. ser(x.Y, bytes) .. ser(x.Z, bytes)
end

--[=[
	@within Vector3
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return Vector3
]=]
Squash.Vector3.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): Vector3
	local des = if serdes then serdes.des else Squash.number.des :: NumberDes
	local bytes = bytes or 4
	return Vector3.new(
		des(string.sub(y, 1 + 0 * bytes, 1 * bytes), bytes),
		des(string.sub(y, 1 + 1 * bytes, 2 * bytes), bytes),
		des(string.sub(y, 1 + 2 * bytes, 3 * bytes), bytes)
	)
end

--[=[
	@within Vector3
	@function serarr
	@param x { Vector3 }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.Vector3.serarr = serArrayVector(Squash.Vector3)

--[=[
	@within Vector3
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { Vector3 }
]=]
Squash.Vector3.desarr = desArrayVector(Squash.Vector3, 3, 0)

--[=[
	@class Vector2int16
	Default bytes is 2, because int16 is 2 bytes.
]=]
Squash.Vector2int16 = {}

--[=[
	@within Vector2int16
	@function ser
	@param x Vector2int16
	@return string
]=]
Squash.Vector2int16.ser = function(x: Vector2int16, serdes: NumberSerDes?, bytes: Bytes?): string
	local ser = if serdes then serdes.ser else Squash.int.ser :: NumberSer
	local bytes = bytes or 2
	return ser(x.X, bytes) .. ser(x.Y, bytes)
end

--[=[
	@within Vector2int16
	@function des
	@param y string
	@return Vector2int16
]=]
Squash.Vector2int16.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): Vector2int16
	local des = if serdes then serdes.des else Squash.int.des :: NumberDes
	local bytes = bytes or 2
	return Vector2int16.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, 1 + bytes, 2 * bytes), bytes))
end

--[=[
	@within Vector2int16
	@function serarr
	@param x { Vector2int16 }
	@return string
]=]
Squash.Vector2int16.serarr = serArrayVector(Squash.Vector2int16)

--[=[
	@within Vector2int16
	@function desarr
	@param y string
	@return { Vector2int16 }
]=]
Squash.Vector2int16.desarr = desArrayVector(Squash.Vector2int16, 3, 0)

--[=[
	@class Vector3int16
	Default bytes is 2, because int16 is 2 bytes.
]=]
Squash.Vector3int16 = {}

--[=[
	@within Vector3int16
	@function ser
	@param x Vector3int16
	@return string
]=]
Squash.Vector3int16.ser = function(x: Vector3int16, serdes: NumberSerDes?, bytes: Bytes?)
	local ser = if serdes then serdes.ser else Squash.int.ser :: NumberSer
	local bytes = bytes or 2
	return ser(x.X, bytes) .. ser(x.Y, bytes) .. ser(x.Z, bytes)
end

--[=[
	@within Vector3int16
	@function des
	@param y string
	@return Vector3int16
]=]
Squash.Vector3int16.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): Vector3int16
	local des = if serdes then serdes.des else Squash.int.des :: NumberDes
	local bytes = bytes or 2
	return Vector3int16.new(
		des(string.sub(y, 1 + 0 * bytes, 1 * bytes), bytes),
		des(string.sub(y, 1 + 1 * bytes, 2 * bytes), bytes),
		des(string.sub(y, 1 + 2 * bytes, 3 * bytes), bytes)
	)
end

--[=[
	@within Vector3int16
	@function serarr
	@param x { Vector3int16 }
	@return string
]=]
Squash.Vector3int16.serarr = serArrayVector(Squash.Vector3int16)

--[=[
	@within Vector3int16
	@function desarr
	@param y string
	@return { Vector3int16 }
]=]
Squash.Vector3int16.desarr = desArrayVector(Squash.Vector3int16, 3, 0)

--[=[
	@class CFrame
]=]
Squash.CFrame = {}

--[=[
	@within CFrame
	@function ser
	@param x CFrame
	@param serdes NumberSerDes?
	@param posBytes Bytes?
	@return string
]=]
Squash.CFrame.ser = function(x: CFrame, serdes: NumberSerDes?, posBytes: Bytes?): string
	local ser = if serdes then serdes.ser else Squash.number.ser :: NumberSer
	local posBytes = posBytes or 4

	local rx, ry, rz = x:ToEulerAnglesYXZ()
	local px, py, pz = x.Position.X, x.Position.Y, x.Position.Z

	return serAngle(rx) .. serAngle(ry) .. serAngle(rz) .. ser(px, posBytes) .. ser(py, posBytes) .. ser(pz, posBytes)
end

--[=[
	@within CFrame
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param posBytes number?
	@return CFrame
]=]
Squash.CFrame.des = function(y: string, serdes: NumberSerDes?, posBytes: number?): CFrame
	local des = if serdes then serdes.des else Squash.number.des :: NumberDes
	local posBytes = posBytes or 4

	local rx = desAngle(string.sub(y, 1, 2))
	local ry = desAngle(string.sub(y, 3, 4))
	local rz = desAngle(string.sub(y, 5, 6))

	local px = des(string.sub(y, 7 + 0 * posBytes, 7 + 1 * posBytes - 1), posBytes)
	local py = des(string.sub(y, 7 + 1 * posBytes, 7 + 2 * posBytes - 1), posBytes)
	local pz = des(string.sub(y, 7 + 2 * posBytes, 7 + 3 * posBytes - 1), posBytes)

	return CFrame.fromOrientation(rx, ry, rz) + Vector3.new(px, py, pz)
end

--[=[
	@within CFrame
	@function serarr
	@param x { CFrame }
	@param serdes NumberSerDes?
	@param posBytes number?
	@return string
]=]
Squash.CFrame.serarr = serArrayVector(Squash.CFrame)

--[=[
	@within CFrame
	@function desarr
	@param y string
	@param posBytes number
	@param serdes NumberSerDes?
	@return { CFrame }
]=]
Squash.CFrame.desarr = function(y: string, posBytes: number, serdes: NumberSerDes?): { CFrame }
	local decoding = serdes or Squash.number
	local bytes = 7 + 3 * posBytes

	local x = {}
	for i = 1, #y / bytes do
		local a = bytes * (i - 1) + 1
		local b = bytes * i
		x[i] = Squash.CFrame.des(string.sub(y, a, b), decoding, posBytes)
	end
	return x
end

--[=[
	@class Enum
]=]
Squash.Enum = {}

--[=[
	@within Enum
	@function ser
	@param x Enum
	@return string
]=]
Squash.Enum.ser = function(x: Enum): string
	local enumId = enumData.lookup[x] :: number
	return Squash.uint.ser(enumId, enumData.bytes)
end

--[=[
	@within Enum
	@function des
	@param y string
	@return Enum
]=]
Squash.Enum.des = function(y: string): Enum
	local enumId = Squash.uint.des(y, enumData.bytes)
	return enumData.items[enumId]
end

--[=[
	@within Enum
	@function serarr
	@param x { Enum }
	@return string
]=]
Squash.Enum.serarr = serArrayVariable(Squash.Enum)

--[=[
	@within Enum
	@function desarr
	@param y string
	@return { Enum }
]=]
Squash.Enum.desarr = desArrayVariable(Squash.Enum)

--[=[
	@class EnumItem
]=]
Squash.EnumItem = {}

--[=[
	@within EnumItem
	@function ser
	@param x EnumItem
	@return string
]=]
Squash.EnumItem.ser = function(enumItem: EnumItem, enum: Enum): string
	local enumData = enumItemData[enum]
	local enumItemId = enumData.lookup[enumItem] :: number
	return Squash.uint.ser(enumItemId, enumData.bytes)
end

--[=[
	@within EnumItem
	@function des
	@param y string
	@param enum Enum
	@return EnumItem
]=]
Squash.EnumItem.des = function(y: string, enum: Enum): EnumItem
	local enumData = enumItemData[enum]
	local enumItemId = Squash.uint.des(y, enumData.bytes)
	return enumData.items[enumItemId]
end

--[=[
	@within EnumItem
	@function serarr
	@param x { EnumItem }
	@return string
]=]
Squash.EnumItem.serarr = function(x: { EnumItem }, enum: Enum)
	local y = {}
	for i, v in x do
		y[i] = Squash.EnumItem.ser(v, enum)
	end
	return table.concat(y)
end

--[=[
	@within EnumItem
	@function desarr
	@param y string
	@param enum Enum
	@return { EnumItem }
]=]
Squash.EnumItem.desarr = function(y: string, enum: Enum): { EnumItem }
	local bytes = enumItemData[enum].bytes
	local x = {}
	for i = 1, #y / bytes do
		x[i] = Squash.EnumItem.des(string.sub(y, bytes * (i - 1) + 1, bytes * i), enum)
	end
	return x
end

--[=[
	@class Axes
]=]
Squash.Axes = {}

--[=[
	@within Axes
	@function ser
	@param x Axes
	@return string
]=]
Squash.Axes.ser = function(x: Axes)
	return Squash.boolean.ser(x.X, x.Y, x.Z) .. Squash.boolean.ser(x.Top, x.Bottom, x.Left, x.Right, x.Back, x.Front)
end

--[=[
	@within Axes
	@function des
	@param y string
	@return Axes
]=]
Squash.Axes.des = function(y: string): Axes
	local fx, fy, fz = Squash.boolean.des(string.sub(y, 1, 1))
	local top, bottom, left, right, back, front = Squash.boolean.des(string.sub(y, 2, 2))
	return Axes.new(
		fx and Enum.Axis.X,
		fy and Enum.Axis.Y,
		fz and Enum.Axis.Z,
		top and Enum.NormalId.Top,
		bottom and Enum.NormalId.Bottom,
		left and Enum.NormalId.Left,
		right and Enum.NormalId.Right,
		back and Enum.NormalId.Back,
		front and Enum.NormalId.Front
	)
end

--[=[
	@within Axes
	@function serarr
	@param x { Axes }
	@return string
]=]
Squash.Axes.serarr = serArrayFixed(Squash.Axes)

--[=[
	@within Axes
	@function desarr
	@param y string
	@return { Axes }
]=]
Squash.Axes.desarr = desArrayFixed(Squash.Axes, 8)

--[=[
	@class BrickColor
]=]
Squash.BrickColor = {}

--[=[
	@within BrickColor
	@function ser
	@param x BrickColor
	@return string
]=]
Squash.BrickColor.ser = function(x: BrickColor): string
	return Squash.uint.ser(x.Number, 2)
end

--[=[
	@within BrickColor
	@function des
	@param y string
	@return BrickColor
]=]
Squash.BrickColor.des = function(y: string): BrickColor
	return BrickColor.new(Squash.uint.des(y, 2))
end

--[=[
	@within BrickColor
	@function serarr
	@param x { BrickColor }
	@return string
]=]
Squash.BrickColor.serarr = serArrayFixed(Squash.BrickColor)

--[=[
	@within BrickColor
	@function desarr
	@param y string
	@return { BrickColor }
]=]
Squash.BrickColor.desarr = desArrayFixed(Squash.BrickColor, 2)

--[=[
	@class Color3
]=]
Squash.Color3 = {}

--[=[
	@within Color3
	@function ser
	@param x Color3
	@return string
]=]
Squash.Color3.ser = function(x: Color3): string
	return string.char(x.R * 255, x.G * 255, x.B * 255)
end

--[=[
	@within Color3
	@function des
	@param y string
	@return Color3
]=]
Squash.Color3.des = function(y: string): Color3
	return Color3.fromRGB(string.byte(y, 1), string.byte(y, 2), string.byte(y, 3))
end

--[=[
	@within Color3
	@function serarr
	@param x { Color3 }
	@return string
]=]
Squash.Color3.serarr = serArrayFixed(Squash.Color3)

--[=[
	@within Color3
	@function desarr
	@param y string
	@return { Color3 }
]=]
Squash.Color3.desarr = desArrayFixed(Squash.Color3, 3)

--[=[
	@class CatalogSearchParams
]=]
Squash.CatalogSearchParams = {}

--[=[
	@within CatalogSearchParams
	@function ser
	@param x CatalogSearchParams
	@param alphabet Alphabet?
	@return string
]=]
Squash.CatalogSearchParams.ser = function(x: CatalogSearchParams, alphabet: Alphabet?): string
	local alphabet = alphabet or Squash.english

	local avatarAssetTypeData = enumItemData[Enum.AvatarAssetType]
	local bundleTypeData = enumItemData[Enum.BundleType]

	local assetIndices = {}
	for i, v in x.AssetTypes do
		assetIndices[i] = table.find(avatarAssetTypeData.items, v) :: number
	end

	local bundleIndices = {}
	for i, v in x.BundleTypes do
		bundleIndices[i] = table.find(bundleTypeData.items, v) :: number
	end

	return Squash.boolean.ser(x.IncludeOffSale)
		.. Squash.uint.ser(x.MinPrice, 4)
		.. Squash.uint.ser(x.MaxPrice, 4)
		.. Squash.EnumItem.ser(x.SalesTypeFilter, Enum.SalesTypeFilter)
		.. Squash.EnumItem.ser(x.CategoryFilter, Enum.CatalogCategoryFilter)
		.. Squash.EnumItem.ser(x.SortAggregation, Enum.CatalogSortAggregation)
		.. Squash.EnumItem.ser(x.SortType, Enum.CatalogSortType)
		.. packBits(assetIndices, avatarAssetTypeData.bits)
		.. Squash.delimiter
		.. packBits(bundleIndices, bundleTypeData.bits)
		.. Squash.delimiter
		.. Squash.string.ser(x.SearchKeyword, alphabet)
		.. Squash.delimiter
		.. Squash.string.ser(x.CreatorName, alphabet)
end

--[=[
	@within CatalogSearchParams
	@function des
	@param y string
	@param alphabet Alphabet?
	@return CatalogSearchParams
]=]
Squash.CatalogSearchParams.des = function(y: string, alphabet: Alphabet): CatalogSearchParams
	local alphabet = alphabet or Squash.english

	local avatarAssetTypeData = enumItemData[Enum.AvatarAssetType]
	local bundleTypeData = enumItemData[Enum.BundleType]

	local x = CatalogSearchParams.new()
	x.IncludeOffSale = Squash.boolean.des(string.sub(y, 1, 1))
	x.MinPrice = Squash.uint.des(string.sub(y, 2, 5), 4)
	x.MaxPrice = Squash.uint.des(string.sub(y, 6, 9), 4)

	local offset = 10
	offset, x.SalesTypeFilter = desEnumItem(y, offset, Enum.SalesTypeFilter)
	offset, x.CategoryFilter = desEnumItem(y, offset, Enum.CatalogCategoryFilter)
	offset, x.SortAggregation = desEnumItem(y, offset, Enum.CatalogSortAggregation)
	offset, x.SortType = desEnumItem(y, offset, Enum.CatalogSortType)

	local assetTypes = {}
	local delimiter1 = string.find(y, Squash.delimiter, offset, true) :: number
	for i, v in unpackBits(string.sub(y, offset, delimiter1 - 1), avatarAssetTypeData.bits) do
		assetTypes[i] = avatarAssetTypeData.items[v]
	end
	x.AssetTypes = assetTypes
	offset = delimiter1 + 1

	local bundleTypes = {}
	local delimiter2 = string.find(y, Squash.delimiter, offset, true) :: number
	for i, v in unpackBits(string.sub(y, offset, delimiter2 - 1), bundleTypeData.bits) do
		bundleTypes[i] = bundleTypeData.items[v]
	end
	x.BundleTypes = bundleTypes
	offset = delimiter2 + 1

	local delimiter3 = string.find(y, Squash.delimiter, offset, true) :: number
	x.SearchKeyword = Squash.string.des(string.sub(y, offset, delimiter3 - 1), alphabet)
	x.CreatorName = Squash.string.des(string.sub(y, delimiter3 + 1), alphabet)
	return x
end

--[=[
	@within CatalogSearchParams
	@function serarr
	@param x { CatalogSearchParams }
	@param alphabet Alphabet?
	@return string
]=]
Squash.CatalogSearchParams.serarr = serArrayVariable(Squash.CatalogSearchParams)

--[=[
	@within CatalogSearchParams
	@function desarr
	@param y string
	@param alphabet Alphabet?
	@return { CatalogSearchParams }
]=]
Squash.CatalogSearchParams.desarr = desArrayVariable(Squash.CatalogSearchParams)

--[=[
	@class DateTime
]=]
Squash.DateTime = {}

local dateTimeOffset = 17_987_443_200

--[=[
	@within DateTime
	@function ser
	@param x DateTime
	@return string
]=]
Squash.DateTime.ser = function(x: DateTime): string
	return Squash.uint.ser(x.UnixTimestamp + dateTimeOffset, 5)
end

--[=[
	@within DateTime
	@function des
	@param y string
	@return DateTime
]=]
Squash.DateTime.des = function(y: string): DateTime
	return DateTime.fromUnixTimestamp(Squash.uint.des(y, 5) - dateTimeOffset)
end

--[=[
	@within DateTime
	@function serarr
	@param x { DateTime }
	@return string
]=]
Squash.DateTime.serarr = serArrayFixed(Squash.DateTime)

--[=[
	@within DateTime
	@function desarr
	@param y string
	@return { DateTime }
]=]
Squash.DateTime.desarr = desArrayFixed(Squash.DateTime, 5)

--[=[
	@class DockWidgetPluginGuiInfo

	This is broken. Roblox doesn't allow us to access any of the fields even though they've made it very clear they should be accessible. Until this is addressed, this type's serdes functions will not function properly.
]=]
Squash.DockWidgetPluginGuiInfo = {}

--[=[
	@within DockWidgetPluginGuiInfo
	@function ser
	@param x DockWidgetPluginGuiInfo
	@return string
]=]
Squash.DockWidgetPluginGuiInfo.ser = function(x: DockWidgetPluginGuiInfo): string
	-- return Squash.boolean.ser(x.InitialEnabled, x.InitialEnabledShouldOverrideRestore)
	-- 	.. Squash.int.ser(x.FloatingXSize, 2)
	-- 	.. Squash.int.ser(x.FloatingYSize, 2)
	-- 	.. Squash.int.ser(x.MinWidth, 2)
	-- 	.. Squash.int.ser(x.MinHeight, 2)

	return ''
end

--[=[
	@within DockWidgetPluginGuiInfo
	@function des
	@param y string
	@return DockWidgetPluginGuiInfo
]=]
Squash.DockWidgetPluginGuiInfo.des = function(y: string): DockWidgetPluginGuiInfo
	local x = DockWidgetPluginGuiInfo.new()
	-- x.InitialEnabled, x.InitialEnabledShouldOverrideRestore = Squash.boolean.des(string.sub(y, 1, 1)) -- TODO: Fix this when possible.
	-- x.FloatingXSize = Squash.int.des(string.sub(y, 2, 3), 2)
	-- x.FloatingYSize = Squash.int.des(string.sub(y, 4, 5), 2)
	-- x.MinWidth = Squash.int.des(string.sub(y, 6, 7), 2)
	-- x.MinHeight = Squash.int.des(string.sub(y, 8, 9), 2)
	return x
end

--[=[
	@within DockWidgetPluginGuiInfo
	@function serarr
	@param x { DockWidgetPluginGuiInfo }
	@return string
]=]
Squash.DockWidgetPluginGuiInfo.serarr = serArrayFixed(Squash.DockWidgetPluginGuiInfo)

--[=[
	@within DockWidgetPluginGuiInfo
	@function desarr
	@param y string
	@return { DockWidgetPluginGuiInfo }
]=]
Squash.DockWidgetPluginGuiInfo.desarr = desArrayFixed(Squash.DockWidgetPluginGuiInfo, 9)

--[=[
	@class ColorSequenceKeypoint
]=]
Squash.ColorSequenceKeypoint = {}

--[=[
	@within ColorSequenceKeypoint
	@function ser
	@param x ColorSequenceKeypoint
	@return string
]=]
Squash.ColorSequenceKeypoint.ser = function(x: ColorSequenceKeypoint): string
	return string.char(x.Time * 255) .. Squash.Color3.ser(x.Value)
end

--[=[
	@within ColorSequenceKeypoint
	@function des
	@param y string
	@return ColorSequenceKeypoint
]=]
Squash.ColorSequenceKeypoint.des = function(y: string): ColorSequenceKeypoint
	return ColorSequenceKeypoint.new(string.byte(y, 1) / 255, Squash.Color3.des(string.sub(y, 2, 4)))
end

--[=[
	@within ColorSequenceKeypoint
	@function serarr
	@param x { ColorSequenceKeypoint }
	@return string
]=]
Squash.ColorSequenceKeypoint.serarr = serArrayFixed(Squash.ColorSequenceKeypoint)

--[=[
	@within ColorSequenceKeypoint
	@function desarr
	@param y string
	@return { ColorSequenceKeypoint }
]=]
Squash.ColorSequenceKeypoint.desarr = desArrayFixed(Squash.ColorSequenceKeypoint, 4)

--[=[
	@class ColorSequence
]=]
Squash.ColorSequence = {}

--[=[
	@within ColorSequence
	@function ser
	@param x ColorSequence
	@return string
]=]
Squash.ColorSequence.ser = function(x: ColorSequence): string
	return Squash.ColorSequenceKeypoint.serarr(x.Keypoints)
end

--[=[
	@within ColorSequence
	@function des
	@param y string
	@return ColorSequence
]=]
Squash.ColorSequence.des = function(y: string): ColorSequence
	return ColorSequence.new(Squash.ColorSequenceKeypoint.desarr(y))
end

--[=[
	@within ColorSequence
	@function serarr
	@param x { ColorSequence }
	@return string
]=]
Squash.ColorSequence.serarr = serArrayVariable(Squash.ColorSequence)

--[=[
	@within ColorSequence
	@function desarr
	@param y string
	@return { ColorSequence }
]=]
Squash.ColorSequence.desarr = desArrayVariable(Squash.ColorSequence)

--[=[
	@class Faces
]=]
Squash.Faces = {}

--[=[
	@within Faces
	@function ser
	@param x Faces
	@return string
]=]
Squash.Faces.ser = function(x: Faces): string
	return Squash.boolean.ser(x.Top, x.Bottom, x.Left, x.Right, x.Back, x.Front)
end

--[=[
	@within Faces
	@function des
	@param y string
	@return Faces
]=]
Squash.Faces.des = function(y: string): Faces
	local top, bottom, left, right, back, front = Squash.boolean.des(y)
	return Faces.new(
		top and Enum.NormalId.Top,
		bottom and Enum.NormalId.Bottom,
		left and Enum.NormalId.Left,
		right and Enum.NormalId.Right,
		back and Enum.NormalId.Back,
		front and Enum.NormalId.Front
	)
end

--[=[
	@within Faces
	@function serarr
	@param x { Faces }
	@return string
]=]
Squash.Faces.serarr = serArrayFixed(Squash.Faces)

--[=[
	@within Faces
	@function desarr
	@param y string
	@return { Faces }
]=]
Squash.Faces.desarr = desArrayFixed(Squash.Faces, 1)

--[=[
	@class FloatCurveKey
]=]
Squash.FloatCurveKey = {}

--[=[
	@within FloatCurveKey
	@function ser
	@param x FloatCurveKey
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.FloatCurveKey.ser = function(x: FloatCurveKey): string
	local y = Squash.EnumItem.ser(x.Interpolation, Enum.KeyInterpolationMode)
		.. Squash.number.ser(x.Time)
		.. Squash.number.ser(x.Value)

	if x.Interpolation == Enum.KeyInterpolationMode.Cubic then
		y ..= Squash.number.ser(x.LeftTangent) .. Squash.number.ser(x.RightTangent)
	end

	return y
end

--[=[
	@within FloatCurveKey
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return FloatCurveKey
]=]
Squash.FloatCurveKey.des = function(y: string): FloatCurveKey
	local offset = enumItemData[Enum.KeyInterpolationMode].bytes
	local x = FloatCurveKey.new(
		Squash.number.des(string.sub(y, offset + 1, offset + 4)),
		Squash.number.des(string.sub(y, offset + 5, offset + 8)),
		Squash.EnumItem.des(string.sub(y, 1, offset), Enum.KeyInterpolationMode) :: Enum.KeyInterpolationMode
	)

	if x.Interpolation == Enum.KeyInterpolationMode.Cubic then
		offset += 8
		x.LeftTangent = Squash.number.des(string.sub(y, offset + 1, offset + 4))
		offset += 4
		x.RightTangent = Squash.number.des(string.sub(y, offset + 1, offset + 4))
	end

	return x
end

--[=[
	@within FloatCurveKey
	@function serarr
	@param x { FloatCurveKey }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.FloatCurveKey.serarr = serArrayVariable(Squash.FloatCurveKey)

--[=[
	@within FloatCurveKey
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { FloatCurveKey }
]=]
Squash.FloatCurveKey.desarr = desArrayVariable(Squash.FloatCurveKey)

--[=[
	@class Font
]=]
Squash.Font = {}

--[=[
	@within Font
	@function ser
	@param x Font
	@return string
]=]
Squash.Font.ser = function(x: Font): string
	local family = string.match(x.Family, '(.+)%..+$')
	if not family then
		error 'Font Family must be a Roblox Font'
	end

	return Squash.EnumItem.ser(x.Style, Enum.FontStyle)
		.. Squash.EnumItem.ser(x.Weight, Enum.FontWeight)
		.. Squash.string.ser(family, Squash.filepath)
end

--[=[
	@within Font
	@function des
	@param y string
	@return Font
]=]
Squash.Font.des = function(y: string): Font
	local a, b = 1, enumItemData[Enum.FontStyle].bytes
	local style = Squash.EnumItem.des(string.sub(y, a, b), Enum.FontStyle) :: Enum.FontStyle
	a += b
	b += enumItemData[Enum.FontWeight].bytes
	local fontWeight = Squash.EnumItem.des(string.sub(y, a, b), Enum.FontWeight) :: Enum.FontWeight
	local family = Squash.string.des(string.sub(y, b + 1), Squash.filepath) .. '.json'
	return Font.new(family, fontWeight, style)
end

--[=[
	@within Font
	@function serarr
	@param x { Font }
	@return string
]=]
Squash.Font.serarr = serArrayVariable(Squash.Font)

--[=[
	@within Font
	@function desarr
	@param y string
	@return { Font }
]=]
Squash.Font.desarr = desArrayVariable(Squash.Font)

--[=[
	@class NumberRange
]=]
Squash.NumberRange = {}

--[=[
	@within NumberRange
	@function ser
	@param x NumberRange
	@param serdes NumberSerDes?
	@param bytes Bytes?
]=]
Squash.NumberRange.ser = function(x: NumberRange, serdes: NumberSerDes?, bytes: Bytes?): string
	local ser = if serdes then serdes.ser else Squash.number.ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.Min, bytes) .. ser(x.Max, bytes)
end

--[=[
	@within NumberRange
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return NumberRange
]=]
Squash.NumberRange.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): NumberRange
	local des = if serdes then serdes.des else Squash.number.des :: NumberDes
	local bytes = bytes or 4
	return NumberRange.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[=[
	@within NumberRange
	@function serarr
	@param x { NumberRange }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.NumberRange.serarr = serArrayVector(Squash.NumberRange)

--[=[
	@within NumberRange
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { NumberRange }
]=]
Squash.NumberRange.desarr = desArrayVector(Squash.NumberRange, 2, 0)

--[=[
	@class NumberSequenceKeypoint
]=]
Squash.NumberSequenceKeypoint = {}

--[=[
	@within NumberSequenceKeypoint
	@function ser
	@param x NumberSequenceKeypoint
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.NumberSequenceKeypoint.ser = function(x: NumberSequenceKeypoint, serdes: NumberSerDes?, bytes: Bytes?): string
	local ser = if serdes then serdes.ser else Squash.number.ser :: NumberSer
	local bytes = bytes or 4
	return string.char(x.Time * 255) .. ser(x.Value, bytes) .. ser(x.Envelope, bytes)
end

--[=[
	@within NumberSequenceKeypoint
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return NumberSequenceKeypoint
]=]
Squash.NumberSequenceKeypoint.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): NumberSequenceKeypoint
	local des = if serdes then serdes.des else Squash.number.des :: NumberDes
	local bytes = bytes or 4
	return NumberSequenceKeypoint.new(
		string.byte(y, 1) / 255,
		des(string.sub(y, 2, 1 + bytes), bytes),
		des(string.sub(y, 2 + bytes, 1 + 2 * bytes), bytes)
	)
end

--[=[
	@within NumberSequenceKeypoint
	@function serarr
	@param x { NumberSequenceKeypoint }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.NumberSequenceKeypoint.serarr = serArrayVector(Squash.NumberSequenceKeypoint)

--[=[
	@within NumberSequenceKeypoint
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { NumberSequenceKeypoint }
]=]
Squash.NumberSequenceKeypoint.desarr = desArrayVector(Squash.NumberSequenceKeypoint, 2, 1)

--[=[
	@class NumberSequence
]=]
Squash.NumberSequence = {}

--[=[
	@within NumberSequence
	@function ser
	@param x NumberSequence
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string

	Careful when calling this with Squash.uint,
]=]
Squash.NumberSequence.ser = function(x: NumberSequence, serdes: NumberSerDes?, bytes: Bytes?): string
	return Squash.NumberSequenceKeypoint.serarr(x.Keypoints, serdes, bytes) --TODO: Recognize that the start and end times are always 0 and 1 and omit them.
end

--[=[
	@within NumberSequence
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return NumberSequence
]=]
Squash.NumberSequence.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): NumberSequence
	return NumberSequence.new(Squash.NumberSequenceKeypoint.desarr(y, serdes, bytes))
end

--[=[
	@within NumberSequence
	@function serarr
	@param x { NumberSequence }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.NumberSequence.serarr = serArrayVariable(Squash.NumberSequence)

--[=[
	@within NumberSequence
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { NumberSequence }
]=]
Squash.NumberSequence.desarr = desArrayVariable(Squash.NumberSequence)

--[=[
	@class OverlapParams
]=]
Squash.OverlapParams = {}

--[=[
	@within OverlapParams
	@function ser
	@param x OverlapParams
	@return string

	The FilterDescedantsInstances property is not serialized because is an array of Instance objects, which are not supported.
]=]
Squash.OverlapParams.ser = function(x: OverlapParams): string
	return string.char(
		(if x.FilterType == Enum.RaycastFilterType.Include then 1 else 0) + (if x.RespectCanCollide then 2 else 0)
	) .. Squash.uint.ser(x.MaxParts, 2) .. Squash.string.ser(x.CollisionGroup) -- I wish we could use GetCollisionGroupId and restrict this to 1 or 2 bytes, but that was deprecated.
end

--[=[
	@within OverlapParams
	@function des
	@param y string
	@return OverlapParams
]=]
Squash.OverlapParams.des = function(y: string): OverlapParams
	local filterTypeAndRespectCanCollide = string.byte(y, 1)

	local x = OverlapParams.new()
	x.CollisionGroup = Squash.string.des(string.sub(y, 4))
	x.MaxParts = Squash.uint.des(string.sub(y, 2, 3), 2)
	x.RespectCanCollide = filterTypeAndRespectCanCollide >= 2
	x.FilterType = if filterTypeAndRespectCanCollide % 2 == 1
		then Enum.RaycastFilterType.Include
		else Enum.RaycastFilterType.Exclude

	return x
end

--[=[
	@within OverlapParams
	@function serarr
	@param x { OverlapParams }
	@return string
]=]
Squash.OverlapParams.serarr = serArrayVariable(Squash.OverlapParams)

--[=[
	@within OverlapParams
	@function desarr
	@param y string
	@return { OverlapParams }
]=]
Squash.OverlapParams.desarr = desArrayVariable(Squash.OverlapParams)

--[=[
	@class RaycastParams
]=]
Squash.RaycastParams = {}

--[=[
	@within RaycastParams
	@function ser
	@param x RaycastParams
	@return string
]=]
Squash.RaycastParams.ser = function(x: RaycastParams): string
	return Squash.boolean.ser(x.FilterType == Enum.RaycastFilterType.Include, x.IgnoreWater, x.RespectCanCollide)
		.. Squash.string.ser(x.CollisionGroup)
end

--[=[
	@within RaycastParams
	@function des
	@param y string
	@return RaycastParams
]=]
Squash.RaycastParams.des = function(y: string): RaycastParams
	local isInclude, ignoreWater, respectCanCollide = Squash.boolean.des(string.sub(y, 1, 1))

	local x = RaycastParams.new()
	x.CollisionGroup = Squash.string.des(string.sub(y, 2))
	x.RespectCanCollide = respectCanCollide
	x.IgnoreWater = ignoreWater
	x.FilterType = if isInclude then Enum.RaycastFilterType.Include else Enum.RaycastFilterType.Exclude

	return x
end

--[=[
	@within RaycastParams
	@function serarr
	@param x { RaycastParams }
	@return string
]=]
Squash.RaycastParams.serarr = serArrayVariable(Squash.RaycastParams)

--[=[
	@within RaycastParams
	@function desarr
	@param y string
	@return { RaycastParams }
]=]
Squash.RaycastParams.desarr = desArrayVariable(Squash.RaycastParams)

--[=[
	@class PathWaypoint
]=]
Squash.PathWaypoint = {}

--[=[
	@within PathWaypoint
	@function ser
	@param x PathWaypoint
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.PathWaypoint.ser = function(x: PathWaypoint, serdes: NumberSerDes?, bytes: Bytes?): string
	local bytes = bytes or 4
	return Squash.EnumItem.ser(x.Action, Enum.PathWaypointAction)
		.. Squash.Vector3.ser(x.Position, serdes, bytes)
		.. Squash.string.ser(x.Label)
end

--[=[
	@within PathWaypoint
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return PathWaypoint
]=]
Squash.PathWaypoint.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): PathWaypoint
	local bytes = bytes or 4
	local offset, action = 1, nil
	offset, action = desEnumItem(y, offset, Enum.PathWaypointAction)
	local position = Squash.Vector3.des(string.sub(y, offset, offset + 3 * bytes), serdes, bytes)
	offset += 3 * bytes
	local label = Squash.string.des(string.sub(y, offset + 1))
	return PathWaypoint.new(position, action :: Enum.PathWaypointAction, label)
end

--[=[
	@within PathWaypoint
	@function serarr
	@param x { PathWaypoint }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.PathWaypoint.serarr = serArrayVector(Squash.PathWaypoint)

--[=[
	@within PathWaypoint
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { PathWaypoint }
]=]
Squash.PathWaypoint.desarr = desArrayVector(Squash.PathWaypoint, 3, enumItemData[Enum.PathWaypointAction].bytes)

--[=[
	@class PhysicalProperties
]=]
Squash.PhysicalProperties = {}

--[=[
	@within PhysicalProperties
	@function ser
	@param x PhysicalProperties
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.PhysicalProperties.ser = function(x: PhysicalProperties, serdes: NumberSerDes?, bytes: Bytes?): string
	local ser = if serdes then serdes.ser else Squash.number.ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.Density, bytes)
		.. ser(x.Friction, bytes)
		.. ser(x.Elasticity, bytes)
		.. ser(x.FrictionWeight, bytes)
		.. ser(x.ElasticityWeight, bytes)
end

--[=[
	@within PhysicalProperties
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return PhysicalProperties

	The minimum density is 0.009999999776482582, so if the serialization rounds down to 0, it will be set to 0.009999999776482582 when deserialized.
]=]
Squash.PhysicalProperties.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): PhysicalProperties
	local des = if serdes then serdes.des else Squash.number.des :: NumberDes
	local bytes = bytes or 4
	return PhysicalProperties.new(
		des(string.sub(y, 1 + 0 * bytes, 1 * bytes), bytes),
		des(string.sub(y, 1 + 1 * bytes, 2 * bytes), bytes),
		des(string.sub(y, 1 + 2 * bytes, 3 * bytes), bytes),
		des(string.sub(y, 1 + 3 * bytes, 4 * bytes), bytes),
		des(string.sub(y, 1 + 4 * bytes, 5 * bytes), bytes)
	)
end

--[=[
	@within PhysicalProperties
	@function serarr
	@param x { PhysicalProperties }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.PhysicalProperties.serarr = serArrayVector(Squash.PhysicalProperties)

--[=[
	@within PhysicalProperties
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { PhysicalProperties }
]=]
Squash.PhysicalProperties.desarr = desArrayVector(Squash.PhysicalProperties, 5, 0)

--[=[
	@class Ray
]=]
Squash.Ray = {}

--[=[
	@within Ray
	@function ser
	@param x Ray
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.Ray.ser = function(x: Ray, serdes: NumberSerDes?, bytes: Bytes?): string
	local bytes = bytes or 4
	return Squash.Vector3.ser(x.Origin, serdes, bytes) .. Squash.Vector3.ser(x.Direction, serdes, bytes)
end

--[=[
	@within Ray
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return Ray
]=]
Squash.Ray.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): Ray
	local bytes = bytes or 4
	return Ray.new(
		Squash.Vector3.des(string.sub(y, 1 + 0 * bytes, 3 * bytes), serdes, bytes),
		Squash.Vector3.des(string.sub(y, 1 + 3 * bytes, 6 * bytes), serdes, bytes)
	)
end

--[=[
	@within Ray
	@function serarr
	@param x { Ray }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.Ray.serarr = serArrayVector(Squash.Ray)

--[=[
	@within Ray
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { Ray }
]=]
Squash.Ray.desarr = desArrayVector(Squash.Ray, 2, 0)

--[=[
	@class RaycastResult
]=]
Squash.RaycastResult = {}

--[=[
	@within RaycastResult
	@function ser
	@param x RaycastResult
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.RaycastResult.ser = function(x: RaycastResult, serdes: NumberSerDes?, bytes: Bytes?): string
	local bytes = bytes or 4
	return Squash.EnumItem.ser(x.Material, Enum.Material)
		.. Squash.uint.ser(x.Distance, bytes)
		.. Squash.Vector3.ser(x.Position, serdes, bytes)
		.. Squash.Vector3.ser(x.Normal, serdes, bytes)
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
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { Material: Enum.Material, Distance: number, Position: Vector3, Normal: Vector3 }
]=]
Squash.RaycastResult.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): SquashRaycastResult
	local bytes = bytes or 4

	local offset, material = 1, nil
	offset, material = desEnumItem(y, offset, Enum.Material)
	offset -= 1

	local distance = Squash.uint.des(string.sub(y, offset + 1, offset + 1 * bytes), bytes)
	offset += bytes

	local position = Squash.Vector3.des(string.sub(y, offset + 1, offset + 3 * bytes), serdes, bytes)
	offset += 3 * bytes

	local normal = Squash.Vector3.des(string.sub(y, offset + 1, offset + 3 * bytes), serdes, bytes)

	return {
		Material = material :: Enum.Material,
		Distance = distance,
		Position = position,
		Normal = normal,
	}
end

--[=[
	@within RaycastResult
	@function serarr
	@param x { RaycastResult }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.RaycastResult.serarr = serArrayVector(Squash.RaycastResult)

--[=[
	@within RaycastResult
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { RaycastResult }
]=]
Squash.RaycastResult.desarr = desArrayVector(Squash.RaycastResult, 7, enumItemData[Enum.Material].bytes)

--[=[
	@class Rect
]=]
Squash.Rect = {}

--[=[
	@within Rect
	@function ser
	@param x Rect
	@param bytes Bytes?
	@return string
]=]
Squash.Rect.ser = function(x: Rect, bytes: Bytes?)
	local bytes = bytes or 4
	return Squash.uint.ser(x.Min.X, bytes)
		.. Squash.uint.ser(x.Min.Y, bytes)
		.. Squash.uint.ser(x.Max.X, bytes)
		.. Squash.uint.ser(x.Max.Y, bytes)
end

--[=[
	@within Rect
	@function des
	@param y string
	@param bytes Bytes?
	@return Rect
]=]
Squash.Rect.des = function(y: string, bytes: Bytes?): Rect
	local bytes = bytes or 4
	return Rect.new(
		Squash.uint.des(string.sub(y, 1 + 0 * bytes, 1 * bytes), bytes),
		Squash.uint.des(string.sub(y, 1 + 1 * bytes, 2 * bytes), bytes),
		Squash.uint.des(string.sub(y, 1 + 2 * bytes, 3 * bytes), bytes),
		Squash.uint.des(string.sub(y, 1 + 3 * bytes, 4 * bytes), bytes)
	)
end

--[=[
	@within Rect
	@function serarr
	@param x { Rect }
	@param bytes Bytes?
	@return string
]=]
Squash.Rect.serarr = serArrayVectorNoCoding(Squash.Rect)

--[=[
	@within Rect
	@function desarr
	@param y string
	@param bytes Bytes?
	@return { Rect }
]=]
Squash.Rect.desarr = desArrayVectorNoCoding(Squash.Rect, 4, 0)

--[=[
	@class Region3
	Finnicky with uints, beware.
]=]
Squash.Region3 = {}

--[=[
	@within Region3
	@function ser
	@param x Region3
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.Region3.ser = function(x: Region3, serdes: NumberSerDes?, bytes: Bytes?): string
	local bytes = bytes or 4
	return Squash.Vector3.ser(x.Size, serdes, bytes) .. Squash.Vector3.ser(x.CFrame.Position, serdes, bytes)
end

--[=[
	@within Region3
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return Region3
]=]
Squash.Region3.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): Region3
	local bytes = bytes or 4
	local size = 0.5 * Squash.Vector3.des(string.sub(y, 1 + 0 * bytes, 3 * bytes), serdes, bytes)
	local position = Squash.Vector3.des(string.sub(y, 1 + 3 * bytes, 6 * bytes), serdes, bytes)
	return Region3.new(position - size, position + size)
end

--[=[
	@within Region3
	@function serarr
	@param x { Region3 }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.Region3.serarr = serArrayVector(Squash.Region3)

--[=[
	@within Region3
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { Region3 }
]=]
Squash.Region3.desarr = desArrayVector(Squash.Region3, 9, 6)

--[=[
	@class Region3int16
	Default bytes is 2, because int16 is 2 bytes. Region3int16 internally uses 2's compliment, where for example a value of 64700 is treated as -836. Beware of this when serdes-ing with uint.
]=]
Squash.Region3int16 = {}

--[=[
	@within Region3int16
	@function ser
	@param x Region3int16
	@return string
]=]
Squash.Region3int16.ser = function(x: Region3int16, serdes: NumberSerDes?, bytes: number?): string
	local bytes = bytes or 2
	return Squash.Vector3int16.ser(x.Min, serdes, bytes) .. Squash.Vector3int16.ser(x.Max, serdes, bytes)
end

--[=[
	@within Region3int16
	@function des
	@param y string
	@return Region3int16
]=]
Squash.Region3int16.des = function(y: string, serdes: NumberSerDes?, bytes: number?): Region3int16
	local bytes = bytes or 2
	return Region3int16.new(
		Squash.Vector3int16.des(string.sub(y, 1 + 0 * bytes, 3 * bytes), serdes, bytes),
		Squash.Vector3int16.des(string.sub(y, 1 + 3 * bytes, 6 * bytes), serdes, bytes)
	)
end

--[=[
	@within Region3int16
	@function serarr
	@param x { Region3int16 }
	@return string
]=]
Squash.Region3int16.serarr = serArrayFixed(Squash.Region3int16)

--[=[
	@within Region3int16
	@function desarr
	@param y string
	@return { Region3int16 }
]=]
Squash.Region3int16.desarr = desArrayFixed(Squash.Region3int16, 12)

--[=[
	@class TweenInfo
]=]
Squash.TweenInfo = {}

--[=[
	@within TweenInfo
	@function ser
	@param x TweenInfo
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.TweenInfo.ser = function(x: TweenInfo, serdes: NumberSerDes?, bytes: Bytes?): string
	local ser = if serdes then serdes.ser else Squash.number.ser :: NumberSer
	local bytes = bytes or 4
	return Squash.boolean.ser(x.Reverses)
		.. Squash.EnumItem.ser(x.EasingStyle, Enum.EasingStyle)
		.. Squash.EnumItem.ser(x.EasingDirection, Enum.EasingDirection)
		.. Squash.uint.ser(x.RepeatCount, bytes)
		.. ser(x.Time, bytes)
		.. ser(x.DelayTime, bytes)
end

--[=[
	@within TweenInfo
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return TweenInfo
]=]
Squash.TweenInfo.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): TweenInfo
	local des = if serdes then serdes.des else Squash.number.des :: NumberDes
	local bytes = bytes or 4

	local offset = 1
	local reverses = Squash.boolean.des(string.sub(y, offset, offset))
	offset += 1

	local easingStyle
	offset, easingStyle = desEnumItem(y, offset, Enum.EasingStyle)

	local easingDirection
	offset, easingDirection = desEnumItem(y, offset, Enum.EasingDirection)

	local repeatCount = Squash.uint.des(string.sub(y, offset, offset + bytes - 1), bytes)
	offset += bytes

	local tweenTime = des(string.sub(y, offset, offset + bytes - 1), bytes)
	offset += bytes

	local delayTime = des(string.sub(y, offset, offset + bytes - 1), bytes)

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
	@function serarr
	@param x { TweenInfo }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.TweenInfo.serarr = serArrayVector(Squash.TweenInfo)

--[=[
	@within TweenInfo
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { TweenInfo }
]=]
Squash.TweenInfo.desarr = desArrayVector(
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
	@function ser
	@param x UDim
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.UDim.ser = function(x: UDim, serdes: NumberSerDes?, bytes: Bytes?): string
	local ser = if serdes then serdes.ser else Squash.number.ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.Scale, bytes) .. ser(x.Offset, bytes)
end

--[=[
	@within UDim
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return UDim
]=]
Squash.UDim.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): UDim
	local des = if serdes then serdes.des else Squash.number.des :: NumberDes
	local bytes = bytes or 4
	return UDim.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[=[
	@within UDim
	@function serarr
	@param x { UDim }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.UDim.serarr = serArrayVector(Squash.UDim)

--[=[
	@within UDim
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { UDim }
]=]
Squash.UDim.desarr = desArrayVector(Squash.UDim, 2, 0)

--[=[
	@class UDim2
]=]
Squash.UDim2 = {}

--[=[
	@within UDim2
	@function ser
	@param x UDim2
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.UDim2.ser = function(x: UDim2, serdes: NumberSerDes?, bytes: Bytes?): string
	local bytes = bytes or 4
	return Squash.UDim.ser(x.X, serdes, bytes) .. Squash.UDim.ser(x.Y, serdes, bytes)
end

--[=[
	@within UDim2
	@function des
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return UDim2
]=]
Squash.UDim2.des = function(y: string, serdes: NumberSerDes?, bytes: Bytes?): UDim2
	local bytes = bytes or 4
	return UDim2.new(
		Squash.UDim.des(string.sub(y, 1, 2 * bytes), serdes, bytes),
		Squash.UDim.des(string.sub(y, 2 * bytes + 1, 4 * bytes), serdes, bytes)
	)
end

--[=[
	@within UDim2
	@function serarr
	@param x { UDim2 }
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return string
]=]
Squash.UDim2.serarr = serArrayVector(Squash.UDim2)

--[=[
	@within UDim2
	@function desarr
	@param y string
	@param serdes NumberSerDes?
	@param bytes Bytes?
	@return { UDim2 }
]=]
Squash.UDim2.desarr = desArrayVector(Squash.UDim2, 4, 0)

return Squash
