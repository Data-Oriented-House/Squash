--!strict
--!native
--!optimize 2

-- local Vector3 = {}

-- export type Vector3 = {
-- 	X: number,
-- 	Y: number,
-- 	Z: number,
-- 	Magnitude: number,
-- 	Unit: Vector3,
-- }

-- local Vector3Meta = {}
-- Vector3Meta.__index = function(t: Vector3, k: string): any
-- 	if k == 'Magnitude' then
-- 		return math.sqrt(t.X^2 + t.Y^2 + t.Z^2)
-- 	end

-- 	if k == 'Unit' then
-- 		local m = 1 / math.sqrt(t.X^2 + t.Y^2 + t.Z^2)
-- 		return Vector3.new(t.X * m, t.Y * m, t.Z * m)
-- 	end

-- 	return nil
-- end

-- function Vector3.new(x: number?, y: number?, z: number?): Vector3
-- 	return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, Vector3Meta) :: any
-- end

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
export type SerDes<T> = {
	min: number,
	max: number,
	ser: (x0: T) -> buffer,
	des: (y0: buffer) -> T,

	minvar: number?,
	maxvar: number?,
	servar: ((x0: T) -> buffer)?,
	desvar: ((y0: buffer) -> T)?,

	split: ((y0: buffer) -> number)?,

	serarr: (xs: { T }) -> buffer,
	desarr: (ys: buffer) -> { T },
}

export type SerDesVar<T...> = {
	min: number,
	max: number,
	ser: (T...) -> buffer,
	des: (y0: buffer) -> T...,
}

--* Properties *--

--[=[
	@within Squash
	@prop delimiter string

	The delimiter used to separate strings or other types in variable sized arrays and act as the 0 element for base conversions.
]=]
local zero = 0 -- \0
local zeroChar = string.char(zero)
Squash.zero = zero

local delimiter = 1 -- \1
local delimiterChar = string.char(delimiter)
Squash.delimiter = delimiter

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
	@prop compressed Alphabet

	As many characters as possible in UTF-8 without Squash.zero
]=]
local list = table.clone(utf8Characters)
table.remove(list, table.find(list, zeroChar))
Squash.list = table.concat(list) :: Alphabet

--[=[
	@within Squash
	@prop list Alphabet

	As many characters as possible in UTF-8 without Squash.zero and Squash.delimiter
	]=]
local compressed = table.clone(utf8Characters)
table.remove(compressed, table.find(compressed, zeroChar))
table.remove(list, table.find(list, delimiterChar))
Squash.compressed = table.concat(compressed) :: Alphabet

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

local bytesAssert = function(bytes: number): never
	error(`Expected 1, 2, 3, 4, 5, 6, 7, 8 bytes. Invalid number of bytes for integer: {bytes}`)
end

local floatAssert = function(bytes: number): never
	error(`Expected 4 or 8 bytes. Invalid number of bytes for floating point: {bytes}`)
end

--* Actual API *--

function Squash.bytes(x0: number)
	if x0 == 0 then -- 0
		return 1
	elseif x0 ~= x0 // 1 then -- floating point
		local x1 = string.unpack('f', string.pack('f', x0))
		return if x0 == x1 then 4 else 8
	elseif x0 < 1 then -- negative int
		return math.ceil(math.log(math.abs(2 * x0), 256))
	else -- positive uint
		return math.ceil(math.log(math.abs(1 + x0), 256))
	end
end

do
	local cache = {}

	cache.min = 0
	cache.max = 1

	function cache.ser(
		x0: boolean?,
		x1: boolean?,
		x2: boolean?,
		x3: boolean?,
		x4: boolean?,
		x5: boolean?,
		x6: boolean?,
		x7: boolean?
	)
		local y = (if x0 then 1 else 0)
			+ (if x1 then 2 else 0)
			+ (if x2 then 4 else 0)
			+ (if x3 then 8 else 0)
			+ (if x4 then 16 else 0)
			+ (if x5 then 32 else 0)
			+ (if x6 then 64 else 0)
			+ (if x7 then 128 else 0)
		if y == 0 then
			return buffer.create(0)
		end

		local y0 = buffer.create(1)
		buffer.writeu8(y0, 0, y)
		return y0
	end

	function cache.des(y0: buffer)
		if buffer.len(y0) == 0 then
			return false, false, false, false, false, false, false, false
		end

		local x0 = buffer.readu8(y0, 0)
		return (x0 / 1) % 2 >= 1,
			(x0 / 2) % 2 >= 1,
			(x0 / 4) % 2 >= 1,
			(x0 / 8) % 2 >= 1,
			(x0 / 16) % 2 >= 1,
			(x0 / 32) % 2 >= 1,
			(x0 / 64) % 2 >= 1,
			(x0 / 128) % 2 >= 1
	end

	cache.minvar = 1

	function cache.servar(
		x0: boolean,
		x1: boolean?,
		x2: boolean?,
		x3: boolean?,
		x4: boolean?,
		x5: boolean?,
		x6: boolean?,
		x7: boolean?
	)
		local y = (if x0 then 1 else 0)
			+ (if x1 then 2 else 0)
			+ (if x2 then 4 else 0)
			+ (if x3 then 8 else 0)
			+ (if x4 then 16 else 0)
			+ (if x5 then 32 else 0)
			+ (if x6 then 64 else 0)
			+ (if x7 then 128 else 0)
		local y0 = buffer.create(1)
		buffer.writeu8(y0, 0, y)
		return y0
	end

	function cache.desvar(y0: buffer, offset: number)
		local x0 = buffer.readu8(y0, offset)
		return (x0 / 1) % 2 >= 1,
			(x0 / 2) % 2 >= 1,
			(x0 / 4) % 2 >= 1,
			(x0 / 8) % 2 >= 1,
			(x0 / 16) % 2 >= 1,
			(x0 / 32) % 2 >= 1,
			(x0 / 64) % 2 >= 1,
			(x0 / 128) % 2 >= 1
	end

	function cache.serarr(xs: { boolean })
		local len = math.ceil(#xs / 8)
		local ys = buffer.create(len)

		for i = 0, len - 1 do
			local j = i * 8
			buffer.writeu8(
				ys,
				i,
				(if xs[j + 1] then 1 else 0)
					+ (if xs[j + 2] then 2 else 0)
					+ (if xs[j + 3] then 4 else 0)
					+ (if xs[j + 4] then 8 else 0)
					+ (if xs[j + 5] then 16 else 0)
					+ (if xs[j + 6] then 32 else 0)
					+ (if xs[j + 7] then 64 else 0)
					+ (if xs[j + 8] then 128 else 0)
			)
		end

		return ys
	end

	function cache.desarr(ys: buffer)
		local xs = {}

		for i = 0, buffer.len(ys) - 1 do
			local x0 = buffer.readu8(ys, i)
			local j = i * 8
			xs[j + 1] = (x0 / 1) % 2 >= 1
			xs[j + 2] = (x0 / 2) % 2 >= 1
			xs[j + 3] = (x0 / 4) % 2 >= 1
			xs[j + 4] = (x0 / 8) % 2 >= 1
			xs[j + 5] = (x0 / 16) % 2 >= 1
			xs[j + 6] = (x0 / 32) % 2 >= 1
			xs[j + 7] = (x0 / 64) % 2 >= 1
			xs[j + 8] = (x0 / 128) % 2 >= 1
		end

		return xs
	end

	local meta = {
		__call = function(_)
			return cache
		end,
	}
	Squash.boolean = setmetatable({}, meta)
end

do
	local bytes1 = {}
	local bytes2 = {}
	local bytes3 = {}
	local bytes4 = {}
	local bytes5 = {}
	local bytes6 = {}
	local bytes7 = {}
	local bytes8 = {}
	local cache = { bytes1, bytes2, bytes3, bytes4, bytes5, bytes6, bytes7, bytes8 }

	-- 1

	bytes1.min = 1
	bytes1.max = 1

	function bytes1.ser(x0: number)
		local y0 = buffer.create(1)
		buffer.writeu8(y0, 0, x0)
		return y0
	end

	function bytes1.des(y0: buffer)
		return buffer.readu8(y0, 0)
	end

	function bytes1.serarr(xs: { number })
		local ys = buffer.create(#xs)
		for i, x0 in ipairs(xs) do
			buffer.writeu8(ys, i - 1, x0)
		end
		return ys
	end

	function bytes1.desarr(ys: buffer)
		local len = buffer.len(ys)
		local xs = table.create(len)
		for i = 1, len do
			xs[i] = buffer.readu8(ys, i - 1)
		end
		return xs
	end

	-- 2

	bytes2.min = 2
	bytes2.max = 2

	function bytes2.ser(x0: number)
		local y0 = buffer.create(2)
		buffer.writeu16(y0, 0, x0)
		return y0
	end

	function bytes2.des(y0: buffer)
		return buffer.readu16(y0, 0)
	end

	function bytes2.serarr(xs: { number })
		local ys = buffer.create(#xs * 2)
		for i, x0 in ipairs(xs) do
			buffer.writeu16(ys, (i - 1) * 2, x0)
		end
		return ys
	end

	function bytes2.desarr(ys: buffer)
		local len = buffer.len(ys) / 2
		local xs = table.create(len)
		for i = 1, len do
			xs[i] = buffer.readu16(ys, (i - 1) * 2)
		end
		return xs
	end

	-- 3

	bytes3.min = 3
	bytes3.max = 3

	function bytes3.ser(x0: number)
		x0 %= 256 ^ 3
		local y0 = buffer.create(3)
		buffer.writeu16(y0, 0, x0 // 256 ^ 0)
		buffer.writeu8(y0, 2, x0 // 256 ^ 2)
		return y0
	end

	function bytes3.des(y0: buffer)
		return buffer.readu16(y0, 0) + buffer.readu8(y0, 2) * 256 ^ 2
	end

	function bytes3.serarr(xs: { number })
		local ys = buffer.create(#xs * 3)
		for i, x0 in ipairs(xs) do
			x0 %= 256 ^ 3
			local j = (i - 1) * 3
			buffer.writeu16(ys, j + 0, x0 // 256 ^ 0)
			buffer.writeu8(ys, j + 2, x0 // 256 ^ 2)
		end
		return ys
	end

	function bytes3.desarr(ys: buffer)
		local len = buffer.len(ys) / 3
		local xs = table.create(len)
		for i = 1, len do
			local j = (i - 1) * 3
			xs[i] = buffer.readu16(ys, j + 0) + buffer.readu8(ys, j + 2) * 256 ^ 2
		end
		return xs
	end

	-- 4

	bytes4.min = 4
	bytes4.max = 4

	function bytes4.ser(x0: number)
		local y0 = buffer.create(4)
		buffer.writeu32(y0, 0, x0)
		return y0
	end

	function bytes4.des(y0: buffer)
		return buffer.readu32(y0, 0)
	end

	function bytes4.serarr(xs: { number })
		local ys = buffer.create(#xs * 4)
		for i, x0 in ipairs(xs) do
			buffer.writeu32(ys, (i - 1) * 4, x0)
		end
		return ys
	end

	function bytes4.desarr(ys: buffer)
		local len = buffer.len(ys) / 4
		local xs = table.create(len)
		for i = 1, len do
			xs[i] = buffer.readu32(ys, (i - 1) * 4)
		end
		return xs
	end

	-- 5

	bytes5.min = 5
	bytes5.max = 5

	function bytes5.ser(x0: number)
		x0 %= 256 ^ 5
		local y0 = buffer.create(5)
		buffer.writeu32(y0, 0, x0 // 256 ^ 0)
		buffer.writeu8(y0, 4, x0 // 256 ^ 4)
		return y0
	end

	function bytes5.des(y0: buffer)
		return buffer.readu32(y0, 0) + buffer.readu8(y0, 4) * 256 ^ 4
	end

	function bytes5.serarr(xs: { number })
		local ys = buffer.create(#xs * 5)
		for i, x0 in ipairs(xs) do
			x0 %= 256 ^ 5
			local j = (i - 1) * 5
			buffer.writeu32(ys, j + 0, x0 // 256 ^ 0)
			buffer.writeu8(ys, j + 4, x0 // 256 ^ 4)
		end
		return ys
	end

	function bytes5.desarr(ys: buffer)
		local len = buffer.len(ys) / 5
		local xs = table.create(len)
		for i = 1, len do
			local j = (i - 1) * 5
			xs[i] = buffer.readu32(ys, j + 0) + buffer.readu8(ys, j + 4) * 256 ^ 4
		end
		return xs
	end

	-- 6

	bytes6.min = 6
	bytes6.max = 6

	function bytes6.ser(x0: number)
		x0 %= 256 ^ 6
		local y0 = buffer.create(6)
		buffer.writeu32(y0, 0, x0 // 256 ^ 0)
		buffer.writeu16(y0, 4, x0 // 256 ^ 4)
		return y0
	end

	function bytes6.des(y0: buffer)
		return buffer.readu32(y0, 0) + buffer.readu16(y0, 4) * 256 ^ 4
	end

	function bytes6.serarr(xs: { number })
		local ys = buffer.create(#xs * 6)
		for i, x0 in ipairs(xs) do
			x0 %= 256 ^ 6
			local j = (i - 1) * 6
			buffer.writeu32(ys, j + 0, x0 // 256 ^ 0)
			buffer.writeu16(ys, j + 4, x0 // 256 ^ 4)
		end
		return ys
	end

	function bytes6.desarr(ys: buffer)
		local len = buffer.len(ys) / 6
		local xs = table.create(len)
		for i = 1, len do
			local j = (i - 1) * 6
			xs[i] = buffer.readu32(ys, j + 0) + buffer.readu16(ys, j + 4) * 256 ^ 4
		end
		return xs
	end

	-- 7

	bytes7.min = 7
	bytes7.max = 7

	function bytes7.ser(x0: number)
		x0 %= 256 ^ 7
		local y0 = buffer.create(7)
		buffer.writeu32(y0, 0, x0 // 256 ^ 0)
		buffer.writeu16(y0, 4, x0 // 256 ^ 4)
		buffer.writeu8(y0, 6, x0 // 256 ^ 6)
		return y0
	end

	function bytes7.des(y0: buffer)
		return buffer.readu32(y0, 0) + buffer.readu16(y0, 4) * 256 ^ 4 + buffer.readu8(y0, 6) * 256 ^ 6
	end

	function bytes7.serarr(xs: { number })
		local ys = buffer.create(#xs * 7)
		for i, x0 in ipairs(xs) do
			x0 %= 256 ^ 7
			local j = (i - 1) * 7
			buffer.writeu32(ys, j + 0, x0 // 256 ^ 0)
			buffer.writeu16(ys, j + 4, x0 // 256 ^ 4)
			buffer.writeu8(ys, j + 6, x0 // 256 ^ 6)
		end
		return ys
	end

	function bytes7.desarr(ys: buffer)
		local len = buffer.len(ys) / 7
		local xs = table.create(len)
		for i = 1, len do
			local j = (i - 1) * 7
			xs[i] = buffer.readu32(ys, j + 0) + buffer.readu16(ys, j + 4) * 256 ^ 4 + buffer.readu8(ys, j + 6) * 256 ^ 6
		end
		return xs
	end

	-- 8

	bytes8.min = 8
	bytes8.max = 8

	function bytes8.ser(x0: number)
		x0 %= 256 ^ 8
		local y0 = buffer.create(8)
		buffer.writeu32(y0, 0, x0 // 256 ^ 0)
		buffer.writeu32(y0, 4, x0 // 256 ^ 4)
		return y0
	end

	function bytes8.des(y0: buffer)
		return buffer.readu32(y0, 0) + buffer.readu32(y0, 4) * 256 ^ 4
	end

	function bytes8.serarr(xs: { number })
		local ys = buffer.create(#xs * 8)
		for i, x0 in ipairs(xs) do
			x0 %= 256 ^ 8
			local j = (i - 1) * 8
			buffer.writeu32(ys, j + 0, x0 // 256 ^ 0)
			buffer.writeu32(ys, j + 4, x0 // 256 ^ 4)
		end
		return ys
	end

	function bytes8.desarr(ys: buffer)
		local len = buffer.len(ys) / 8
		local xs = table.create(len)
		for i = 1, len do
			local j = (i - 1) * 8
			xs[i] = buffer.readu32(ys, j + 0) + buffer.readu32(ys, j + 4) * 256 ^ 4
		end
		return xs
	end

	local meta = {
		__call = function(_, bytes: number)
			return cache[bytes] or bytesAssert(bytes)
		end,
	}
	Squash.uint = setmetatable({}, meta)
end

do
	local bytes1 = {}
	local bytes2 = {}
	local bytes3 = {}
	local bytes4 = {}
	local bytes5 = {}
	local bytes6 = {}
	local bytes7 = {}
	local bytes8 = {}
	local cache = { bytes1, bytes2, bytes3, bytes4, bytes5, bytes6, bytes7, bytes8 }

	-- 1

	bytes1.min = 1
	bytes1.max = 1

	function bytes1.ser(x0: number)
		local y0 = buffer.create(1)
		buffer.writei8(y0, 0, x0)
		return y0
	end

	function bytes1.des(y0: buffer)
		return buffer.readi8(y0, 0)
	end

	function bytes1.serarr(xs: { number })
		local ys = buffer.create(#xs)
		for i, x0 in ipairs(xs) do
			buffer.writei8(ys, i - 1, x0)
		end
		return ys
	end

	function bytes1.desarr(ys: buffer)
		local len = buffer.len(ys)
		local xs = table.create(len)
		for i = 1, len do
			xs[i] = buffer.readi8(ys, i - 1)
		end
		return xs
	end

	-- 2

	bytes2.min = 2
	bytes2.max = 2

	function bytes2.ser(x0: number)
		local y0 = buffer.create(2)
		buffer.writei16(y0, 0, x0)
		return y0
	end

	function bytes2.des(y0: buffer)
		return buffer.readi16(y0, 0)
	end

	function bytes2.serarr(xs: { number })
		local ys = buffer.create(#xs * 2)
		for i, x0 in ipairs(xs) do
			buffer.writei16(ys, (i - 1) * 2, x0)
		end
		return ys
	end

	function bytes2.desarr(ys: buffer)
		local len = buffer.len(ys) / 2
		local xs = table.create(len)
		for i = 1, len do
			xs[i] = buffer.readi16(ys, (i - 1) * 2)
		end
		return xs
	end

	-- 3

	bytes3.min = 3
	bytes3.max = 3

	function bytes3.ser(x0: number)
		x0 = if x0 < 0 then x0 + 256 ^ 3 else x0
		x0 %= 256 ^ 3
		local y0 = buffer.create(3)
		buffer.writeu16(y0, 0, x0 // 256 ^ 0)
		buffer.writeu8(y0, 2, x0 // 256 ^ 2)
		return y0
	end

	function bytes3.des(y0: buffer)
		local x0 = buffer.readu16(y0, 0) + buffer.readu8(y0, 2) * 256 ^ 2
		return if x0 > 256 ^ 2 * 128 then x0 - 256 ^ 3 else x0
	end

	function bytes3.serarr(xs: { number })
		local ys = buffer.create(#xs * 3)
		for i, x0 in ipairs(xs) do
			x0 = if x0 < 0 then x0 + 256 ^ 3 else x0
			x0 %= 256 ^ 3
			local j = (i - 1) * 3
			buffer.writeu16(ys, j + 0, x0 // 256 ^ 0)
			buffer.writeu8(ys, j + 2, x0 // 256 ^ 2)
		end
		return ys
	end

	function bytes3.desarr(ys: buffer)
		local len = buffer.len(ys) / 3
		local xs = table.create(len)
		for i = 1, len do
			local j = (i - 1) * 3
			local x0 = buffer.readu16(ys, j + 0) + buffer.readu8(ys, j + 2) * 256 ^ 2
			xs[i] = if x0 > 256 ^ 2 * 128 then x0 - 256 ^ 3 else x0
		end
		return xs
	end

	-- 4

	bytes4.min = 4
	bytes4.max = 4

	function bytes4.ser(x0: number)
		local y0 = buffer.create(4)
		buffer.writei32(y0, 0, x0)
		return y0
	end

	function bytes4.des(y0: buffer)
		return buffer.readi32(y0, 0)
	end

	function bytes4.serarr(xs: { number })
		local ys = buffer.create(#xs * 4)
		for i, x0 in ipairs(xs) do
			buffer.writei32(ys, (i - 1) * 4, x0)
		end
		return ys
	end

	function bytes4.desarr(ys: buffer)
		local len = buffer.len(ys) / 4
		local xs = table.create(len)
		for i = 1, len do
			xs[i] = buffer.readi32(ys, (i - 1) * 4)
		end
		return xs
	end

	-- 5

	bytes5.min = 5
	bytes5.max = 5

	function bytes5.ser(x0: number)
		x0 = if x0 < 0 then x0 + 256 ^ 5 else x0
		x0 %= 256 ^ 5
		local y0 = buffer.create(5)
		buffer.writeu32(y0, 0, x0 // 256 ^ 0)
		buffer.writeu8(y0, 4, x0 // 256 ^ 4)
		return y0
	end

	function bytes5.des(y0: buffer)
		local x0 = buffer.readu32(y0, 0) + buffer.readu8(y0, 4) * 256 ^ 4
		return if x0 > 256 ^ 4 * 128 then x0 - 256 ^ 5 else x0
	end

	function bytes5.serarr(xs: { number })
		local ys = buffer.create(#xs * 5)
		for i, x0 in ipairs(xs) do
			x0 = if x0 < 0 then x0 + 256 ^ 5 else x0
			x0 %= 256 ^ 5
			local j = (i - 1) * 5
			buffer.writeu32(ys, j + 0, x0 // 256 ^ 0)
			buffer.writeu8(ys, j + 4, x0 // 256 ^ 4)
		end
		return ys
	end

	function bytes5.desarr(ys: buffer)
		local len = buffer.len(ys) / 5
		local xs = table.create(len)
		for i = 1, len do
			local j = (i - 1) * 5
			local x0 = buffer.readu32(ys, j + 0) + buffer.readu8(ys, j + 4) * 256 ^ 4
			xs[i] = if x0 > 256 ^ 4 * 128 then x0 - 256 ^ 5 else x0
		end
		return xs
	end

	-- 6

	bytes6.min = 6
	bytes6.max = 6

	function bytes6.ser(x0: number)
		x0 = if x0 < 0 then x0 + 256 ^ 6 else x0
		x0 %= 256 ^ 6
		local y0 = buffer.create(6)
		buffer.writeu32(y0, 0, x0 // 256 ^ 0)
		buffer.writeu16(y0, 4, x0 // 256 ^ 4)
		return y0
	end

	function bytes6.des(y0: buffer)
		local x0 = buffer.readu32(y0, 0) + buffer.readu16(y0, 4) * 256 ^ 4
		return if x0 > 256 ^ 4 * 128 then x0 - 256 ^ 6 else x0
	end

	function bytes6.serarr(xs: { number })
		local ys = buffer.create(#xs * 6)
		for i, x0 in ipairs(xs) do
			x0 = if x0 < 0 then x0 + 256 ^ 6 else x0
			x0 %= 256 ^ 6
			local j = (i - 1) * 6
			buffer.writeu32(ys, j + 0, x0 // 256 ^ 0)
			buffer.writeu16(ys, j + 4, x0 // 256 ^ 4)
		end
		return ys
	end

	function bytes6.desarr(ys: buffer)
		local len = buffer.len(ys) / 6
		local xs = table.create(len)
		for i = 1, len do
			local j = (i - 1) * 6
			local x0 = buffer.readu32(ys, j + 0) + buffer.readu16(ys, j + 4) * 256 ^ 4
			xs[i] = if x0 > 256 ^ 4 * 128 then x0 - 256 ^ 6 else x0
		end
		return xs
	end

	-- 7

	bytes7.min = 7
	bytes7.max = 7

	function bytes7.ser(x0: number)
		x0 = if x0 < 0 then x0 + 256 ^ 7 else x0
		x0 %= 256 ^ 7
		local y0 = buffer.create(7)
		buffer.writeu32(y0, 0, x0 // 256 ^ 0)
		buffer.writeu16(y0, 4, x0 // 256 ^ 4)
		buffer.writeu8(y0, 6, x0 // 256 ^ 6)
		return y0
	end

	function bytes7.des(y0: buffer)
		local x0 = buffer.readu32(y0, 0) + buffer.readu16(y0, 4) * 256 ^ 4 + buffer.readu8(y0, 6) * 256 ^ 6
		return if x0 > 256 ^ 6 * 128 then x0 - 256 ^ 7 else x0
	end

	function bytes7.serarr(xs: { number })
		local ys = buffer.create(#xs * 7)
		for i, x0 in ipairs(xs) do
			x0 = if x0 < 0 then x0 + 256 ^ 7 else x0
			x0 %= 256 ^ 7
			local j = (i - 1) * 7
			buffer.writeu32(ys, j + 0, x0 // 256 ^ 0)
			buffer.writeu16(ys, j + 4, x0 // 256 ^ 4)
			buffer.writeu8(ys, j + 6, x0 // 256 ^ 6)
		end
		return ys
	end

	function bytes7.desarr(ys: buffer)
		local len = buffer.len(ys) / 7
		local xs = table.create(len)
		for i = 1, len do
			local j = (i - 1) * 7
			local x0 = buffer.readu32(ys, j + 0)
				+ buffer.readu16(ys, j + 4) * 256 ^ 4
				+ buffer.readu8(ys, j + 6) * 256 ^ 6
			xs[i] = if x0 > 256 ^ 6 * 128 then x0 - 256 ^ 7 else x0
		end
		return xs
	end

	-- 8

	bytes8.min = 8
	bytes8.max = 8

	function bytes8.ser(x0: number)
		x0 = if x0 < 0 then x0 + 256 ^ 8 else x0
		x0 %= 256 ^ 8
		local y0 = buffer.create(8)
		buffer.writeu32(y0, 0, x0 // 256 ^ 0)
		buffer.writeu32(y0, 4, x0 // 256 ^ 4)
		return y0
	end

	function bytes8.des(y0: buffer)
		local x0 = buffer.readu32(y0, 0) + buffer.readu32(y0, 4) * 256 ^ 4
		return if x0 > 256 ^ 7 * 128 then x0 - 256 ^ 8 else x0
	end

	function bytes8.serarr(xs: { number })
		local ys = buffer.create(#xs * 8)
		for i, x0 in ipairs(xs) do
			x0 = if x0 < 0 then x0 + 256 ^ 8 else x0
			x0 %= 256 ^ 8
			local j = (i - 1) * 8
			buffer.writeu32(ys, j + 0, x0 // 256 ^ 0)
			buffer.writeu32(ys, j + 4, x0 // 256 ^ 4)
		end
		return ys
	end

	function bytes8.desarr(ys: buffer)
		local len = buffer.len(ys) / 8
		local xs = table.create(len)
		for i = 1, len do
			local j = (i - 1) * 8
			local x0 = buffer.readu32(ys, j + 0) + buffer.readu32(ys, j + 4) * 256 ^ 4
			xs[i] = if x0 > 256 ^ 7 * 128 then x0 - 256 ^ 8 else x0
		end
		return xs
	end

	local meta = {
		__call = function(_, bytes: number)
			return cache[bytes] or bytesAssert(bytes)
		end,
	}
	Squash.int = setmetatable({}, meta)
end

do
	local bytes4 = {}
	local bytes8 = {}
	local cache = { [4] = bytes4, [8] = bytes8 }

	-- 4

	bytes4.min = 4
	bytes4.max = 4

	function bytes4.ser(x0: number)
		local y0 = buffer.create(4)
		buffer.writef32(y0, 0, x0)
		return y0
	end

	function bytes4.des(y0: buffer)
		return buffer.readf32(y0, 0)
	end

	function bytes4.serarr(xs: { number })
		local ys = buffer.create(#xs * 4)
		for i, x0 in ipairs(xs) do
			buffer.writef32(ys, (i - 1) * 4, x0)
		end
		return ys
	end

	function bytes4.desarr(ys: buffer)
		local len = buffer.len(ys) / 4
		local xs = table.create(len)
		for i = 1, len do
			xs[i] = buffer.readf32(ys, (i - 1) * 4)
		end
		return xs
	end

	-- 8

	bytes8.min = 8
	bytes8.max = 8

	function bytes8.ser(x0: number)
		local y0 = buffer.create(8)
		buffer.writef64(y0, 0, x0)
		return y0
	end

	function bytes8.des(y0: buffer)
		return buffer.readf64(y0, 0)
	end

	function bytes8.serarr(xs: { number })
		local ys = buffer.create(#xs * 8)
		for i, x0 in ipairs(xs) do
			buffer.writef64(ys, (i - 1) * 8, x0)
		end
		return ys
	end

	function bytes8.desarr(ys: buffer)
		local len = buffer.len(ys) / 8
		local xs = table.create(len)
		for i = 1, len do
			xs[i] = buffer.readf64(ys, (i - 1) * 8)
		end
		return xs
	end

	local meta = {
		__call = function(_, bytes: number)
			return cache[bytes] or floatAssert(bytes)
		end,
	}
	Squash.number = setmetatable({}, meta)
end

do
	local cache = {}

	local function alphabet(source: string)
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
		return table.concat(alphabet) :: Alphabet
	end

	local function convert(x: string, inAlphabet: Alphabet, outAlphabet: Alphabet)
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
				inputDigits[i] = value // targetBase
				carry = value % targetBase
			end

			while #inputDigits > 0 and inputDigits[1] == 0 do
				table.remove(inputDigits, 1)
			end

			table.insert(output, 1, string.char(targetDigits[carry]))
		end

		return table.concat(output)
	end

	local function split(y: buffer)
		local ys = buffer.tostring(y)
		return string.find(ys, delimiterChar, 1) or #ys
	end

	local meta = {
		__call = function(_, alphabet: Alphabet)
			local cached = cache[alphabet] :: SerDes<string>
			if cached then
				return cached
			end

			local serdes = {}
			cache[alphabet] = serdes

			serdes.min = 0
			serdes.max = math.huge

			function serdes.ser(x0: string)
				return buffer.fromstring(convert(x0, zeroChar .. alphabet, Squash.compressed))
			end

			function serdes.des(y0: buffer)
				return convert(buffer.tostring(y0), Squash.compressed, zeroChar .. alphabet) :: string
			end

			function serdes.servar(x0: string)
				return buffer.fromstring(convert(x0, zeroChar .. alphabet, Squash.list))
			end

			function serdes.desvar(y0: buffer)
				return convert(buffer.tostring(y0), Squash.list, zeroChar .. alphabet)
			end

			function serdes.serarr(xs: { string })
				local ys = table.create(#xs)
				for i, x0 in ipairs(xs) do
					ys[i] = convert(x0, zeroChar .. alphabet, Squash.list)
				end
				return buffer.fromstring(table.concat(ys, delimiterChar))
			end

			function serdes.desarr(ys: buffer)
				local xs = string.split(buffer.tostring(ys), delimiterChar)
				for i, x0 in ipairs(xs) do
					xs[i] = convert(x0, Squash.list, zeroChar .. alphabet)
				end
				return xs
			end

			serdes.split = split

			return serdes
		end,
	}
	Squash.string = setmetatable({
		convert = convert,
		alphabet = alphabet,
	}, meta)

	-- --[=[
	-- 	@within string
	-- 	@function des
	-- 	@param y string
	-- 	@param alphabet Alphabet?
	-- 	@return string
	-- ]=]
	-- Squash.string.des = function(y: string, alphabet: Alphabet?): string
	-- 	local outAlphabet = Squash.delimiter .. (alphabet or Squash.english)
	-- 	return Squash.string.convert(y, Squash.utf8, outAlphabet)
	-- end

	-- --[=[
	-- 	@within string
	-- 	@function serarr
	-- 	@tag WARNING: Array serialization is unstable due to implementation oversight, use carefully
	-- 	@param x { string }
	-- 	@param alphabet Alphabet?
	-- 	@return string
	-- ]=]
	-- Squash.string.serarr = function(x: { string }, alphabet: Alphabet?)
	-- 	local y = {}
	-- 	for i, v in x do
	-- 		y[i] = Squash.string.ser(v, alphabet)
	-- 	end
	-- 	return table.concat(y, Squash.delimiter)
	-- end

	-- --[=[
	-- 	@within string
	-- 	@function desarr
	-- 	@param y string
	-- 	@param alphabet Alphabet?
	-- 	@return { string }
	-- ]=]
	-- Squash.string.desarr = function(y: string, alphabet: Alphabet?): { string }
	-- 	local x = {}
	-- 	for v in string.gmatch(y, '[^' .. Squash.delimiter .. ']+') do
	-- 		table.insert(x, Squash.string.des(v, alphabet))
	-- 	end
	-- 	return x
	-- end
end

do
	local cache = {}

	local meta = {
		__call = function(_, encoding: SerDes<number>)
			local cached = cache[encoding] :: SerDes<Vector2>
			if cached then
				return cached
			end

			local serdes = {}
			cache[encoding] = serdes

			local encodingmax = encoding.max
			local encodingser = encoding.ser
			local encodingdes = encoding.des

			local max = 2 * encodingmax
			serdes.min = 0
			serdes.max = max

			function serdes.ser(x0: Vector2)
				if x0 == Vector2.zero then
					return buffer.create(0)
				elseif x0 == Vector2.one then
					return buffer.create(1)
				elseif x0 == Vector2.xAxis then
					local y0 = buffer.create(1)
					buffer.writeu8(y0, 0, 1)
					return y0
				elseif x0 == Vector2.yAxis then
					local y0 = buffer.create(1)
					buffer.writeu8(y0, 0, 2)
					return y0
				end

				local y0 = buffer.create(max)
				buffer.copy(y0, 0 * encodingmax, encodingser(x0.X))
				buffer.copy(y0, 1 * encodingmax, encodingser(x0.Y))
				return y0
			end

			function serdes.des(y0: buffer)
				local len = buffer.len(y0)
				if len == 0 then
					return Vector2.zero
				elseif len == 1 then
					local id = buffer.readu8(y0, 0)
					if id == 0 then
						return Vector2.one
					elseif id == 1 then
						return Vector2.xAxis
					elseif id == 2 then
						return Vector2.yAxis
					else
						error(`Vector2 Special-Case Buffer of size 1 has invalid ID {id}, expected 0, 1, 2`)
					end
				end

				local y1 = buffer.create(encodingmax)
				local x = encodingdes(y0)

				buffer.copy(y1, 0, y0, encodingmax, encodingmax)
				local y = encodingdes(y1)

				return Vector2.new(x, y)
			end

			serdes.minvar = max

			function serdes.servar(x0: Vector2)
				local y0 = buffer.create(max)
				buffer.copy(y0, 0 * encodingmax, encodingser(x0.X))
				buffer.copy(y0, 1 * encodingmax, encodingser(x0.Y))
				return y0
			end

			function serdes.desvar(y0: buffer)
				local y1 = buffer.create(encodingmax)
				local x = encodingdes(y0)

				buffer.copy(y1, 0, y0, encodingmax, encodingmax)
				local y = encodingdes(y1)

				return Vector2.new(x, y)
			end

			function serdes.serarr(xs: { Vector2 })
				local ys = buffer.create(max * #xs)
				for i, x0 in xs do
					local j = 2 * i
					buffer.copy(ys, j - 2, encodingser(x0.X))
					buffer.copy(ys, j - 1, encodingser(x0.Y))
				end

				return ys
			end

			function serdes.desarr(ys: buffer)
				local len = buffer.len(ys) / max
				local xs = table.create(len)
				local buf = buffer.create(encodingmax)

				for i = 0, len - 1 do
					local j = 2 * i
					buffer.copy(buf, 0, ys, (j + 0) * encodingmax, encodingmax)
					local x = encodingdes(buf)

					buffer.copy(buf, 0, ys, (j + 1) * encodingmax, encodingmax)
					local y = encodingdes(buf)

					xs[i + 1] = Vector2.new(x, y)
				end

				return xs
			end

			return serdes
		end,
	}
	Squash.Vector2 = setmetatable({}, meta)
end

do
	local cache = {}

	local meta = {
		__call = function(_, encoding: SerDes<number>)
			local cached = cache[encoding] :: SerDes<Vector3>
			if cached then
				return cached
			end

			local serdes = {}
			cache[encoding] = serdes

			local encodingmax = encoding.max
			local encodingser = encoding.ser
			local encodingdes = encoding.des

			local max = 3 * encodingmax
			serdes.min = 0
			serdes.max = max

			function serdes.ser(x0: Vector3)
				if x0 == Vector3.zero then
					return buffer.create(0)
				elseif x0 == Vector3.one then
					return buffer.create(1)
				elseif x0 == Vector3.xAxis then
					local y0 = buffer.create(1)
					buffer.writeu8(y0, 0, 1)
					return y0
				elseif x0 == Vector3.yAxis then
					local y0 = buffer.create(1)
					buffer.writeu8(y0, 0, 2)
					return y0
				elseif x0 == Vector3.zAxis then
					local y0 = buffer.create(1)
					buffer.writeu8(y0, 0, 3)
					return y0
				end

				local y0 = buffer.create(max)
				buffer.copy(y0, 0 * encodingmax, encodingser(x0.X))
				buffer.copy(y0, 1 * encodingmax, encodingser(x0.Y))
				buffer.copy(y0, 2 * encodingmax, encodingser(x0.Z))
				return y0
			end

			function serdes.des(y0: buffer)
				local len = buffer.len(y0)
				if len == 0 then
					return Vector3.zero
				elseif len == 1 then
					local id = buffer.readu8(y0, 0)
					if id == 0 then
						return Vector3.one
					elseif id == 1 then
						return Vector3.xAxis
					elseif id == 2 then
						return Vector3.yAxis
					elseif id == 3 then
						return Vector3.zAxis
					else
						error(`Vector3 Special-Case Buffer of size 1 has invalid ID {id}, expected 0, 1, 2, 3`)
					end
				end

				local y1 = buffer.create(encodingmax)
				local x = encodingdes(y0)

				buffer.copy(y1, 0, y0, encodingmax, encodingmax)
				local y = encodingdes(y1)

				buffer.copy(y1, 0, y0, 2 * encodingmax, encodingmax)
				local z = encodingdes(y1)

				return Vector3.new(x, y, z)
			end

			serdes.minvar = max

			function serdes.servar(x0: Vector3)
				local y0 = buffer.create(max)
				buffer.copy(y0, 0 * encodingmax, encodingser(x0.X))
				buffer.copy(y0, 1 * encodingmax, encodingser(x0.Y))
				buffer.copy(y0, 2 * encodingmax, encodingser(x0.Z))
				return y0
			end

			function serdes.desvar(y0: buffer)
				local y1 = buffer.create(encodingmax)
				local x = encodingdes(y0)

				buffer.copy(y1, 0, y0, encodingmax, encodingmax)
				local y = encodingdes(y1)

				buffer.copy(y1, 0, y0, 2 * encodingmax, encodingmax)
				local z = encodingdes(y1)

				return Vector3.new(x, y, z)
			end

			function serdes.serarr(xs: { Vector3 })
				local ys = buffer.create(max * #xs)
				for i, x0 in xs do
					local j = 3 * i
					buffer.copy(ys, j - 3, encodingser(x0.X))
					buffer.copy(ys, j - 2, encodingser(x0.Y))
					buffer.copy(ys, j - 1, encodingser(x0.Z))
				end

				return ys
			end

			function serdes.desarr(ys: buffer)
				local len = buffer.len(ys) / max
				local xs = table.create(len)
				local buf = buffer.create(encodingmax)

				for i = 0, len - 1 do
					local j = 3 * i
					buffer.copy(buf, 0, ys, (j + 0) * encodingmax, encodingmax)
					local x = encodingdes(buf)

					buffer.copy(buf, 0, ys, (j + 1) * encodingmax, encodingmax)
					local y = encodingdes(buf)

					buffer.copy(buf, 0, ys, (j + 2) * encodingmax, encodingmax)
					local z = encodingdes(buf)

					xs[i + 1] = Vector3.new(x, y, z)
				end

				return xs
			end

			return serdes
		end,
	}
	Squash.Vector3 = setmetatable({}, meta)
end

do
	local meta = {
		__call = function<T...>(_, ...: SerDes<any>)
			local args = { ... }
			local argc = #args

			if argc == 0 then
				error 'Cannot create tuple serdes with no arguments'
			elseif argc == 1 then
				return (args[1] :: any) :: SerDesVar<T...>
			end

			local serdes = {}

			serdes.min = 0
			serdes.max = 0

			for i, arg in args do
				local min = arg.minvar or arg.min
				local max = arg.maxvar or arg.max
				serdes.min += min
				serdes.max += max + if max == math.huge and i < argc then 1 else 0
			end

			print('MIN', serdes.min, 'MAX', serdes.max)

			if serdes.max == math.huge then
				print 'UNBOUNDED SIZE'
				local ys = table.create(argc)

				function serdes.ser(...: T...)
					print 'SER'

					local xs = { ... }

					for i, arg in args do
						local ser = arg.servar or arg.ser
						ys[i] = ser(xs[i])
					end
				end

				function serdes.des(ys: buffer): T...
					print 'DES'
				end
			elseif serdes.max ~= serdes.min then
				print 'BOUNDED SIZE'

				function serdes.ser(...: T...)
					local xs = { ... }

					local yss = {}
					local sizes = table.create(argc)

					local size = 0
					for i, arg in ipairs(args) do
						local ser = arg.servar or arg.ser
						local y0 = ser(xs[i])
						table.insert(yss, y0)

						local len = buffer.len(y0)
						size += len
						sizes[i] = len
					end

					local offset = 0
					local ys = buffer.create(size)
					for i, y0 in yss do
						buffer.copy(ys, offset, y0)
						offset += sizes[i]
					end

					return ys
				end

				function serdes.des(ys: buffer)
					local xs = table.create(argc)

					local yss = ys

					local offset = 0
					for _, arg in args do
						local cutoff = if arg.split then arg.split(yss) else offset + (arg.maxvar or arg.max)

						local segment = buffer.create(cutoff - offset)
						offset = cutoff + 1
						buffer.copy(segment, 0, yss, cutoff)

						local des = arg.desvar or arg.des
						table.insert(xs, des(segment))

						local len = buffer.len(yss) - offset
						local last = buffer.create(len)
						buffer.copy(last, 0, yss, offset)
						yss = last
					end
				end
			else
				print 'FIXED SIZE'
				local buf = buffer.create(serdes.max)

				function serdes.ser(...: T...)
					local xs = { ... }

					local offset = 0
					for i, arg in ipairs(args) do
						local y0 = arg.ser(xs[i])
						buffer.copy(buf, offset, y0)
						local len = arg.maxvar or arg.max
						offset += len
					end

					return buf
				end

				function serdes.des(ys: buffer): T...
					local xs = table.create(#args)

					local offset = 0
					for i, arg in ipairs(args) do
						local len = arg.maxvar or arg.max
						local y0 = buffer.create(len)
						buffer.copy(y0, 0, ys, offset, len)
						offset += len

						local x0 = arg.des(y0)
						table.insert(xs, x0)
					end

					return table.unpack(xs)
				end
			end

			return serdes
		end,
	}
	Squash.tuple = setmetatable({}, meta)
end

return Squash
