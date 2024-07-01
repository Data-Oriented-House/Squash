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

--- An import of the [Redblox Buffit Cursor](https://github.com/red-blox/Util/blob/main/libs/Buffit/Buffit.luau) type for better cross-library interaction
export type Cursor = {
	Buf: buffer,
	Pos: number,
}

local function newCursor(size: number?, position: number?): Cursor
	return {
		Buf = buffer.create(size or 8), --? Chosen to not use too much space and not resize too quickly as a starting point
		Pos = position or 0,
	}
end

local function fromBuffer(buf: buffer)
	return {
		Buf = buf,
		Pos = buffer.len(buf),
	}
end

local function toBuffer(cursor: Cursor): buffer
	local buf = buffer.create(cursor.Pos)
	buffer.copy(buf, 0, cursor.Buf, 0, cursor.Pos)
	return buf
end

local function tryRealloc(cursor: Cursor, bytes: number)
	local b = cursor.Buf
	local p = cursor.Pos
	local len = buffer.len(b)
	if len < p + bytes then
		local exponent = math.ceil(math.log((bytes + p) / len, 1.5))
		local new = buffer.create(len * 1.5 ^ exponent)
		buffer.copy(new, 0, b, 0)
		cursor.Buf = new
	end
end

local function pushu1(cursor: Cursor, x: number)
	tryRealloc(cursor, 1)
	buffer.writeu8(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 1
end

local function popu1(cursor: Cursor)
	cursor.Pos -= 1
	return buffer.readu8(cursor.Buf, cursor.Pos)
end

local function pushu2(cursor: Cursor, x: number)
	tryRealloc(cursor, 2)
	buffer.writeu16(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 2
end

local function popu2(cursor: Cursor)
	cursor.Pos -= 2
	return buffer.readu16(cursor.Buf, cursor.Pos)
end

local function pushu3(cursor: Cursor, x: number)
	tryRealloc(cursor, 3)
	buffer.writeu8(cursor.Buf, cursor.Pos, x)
	buffer.writeu16(cursor.Buf, cursor.Pos + 1, x // 256)
	cursor.Pos += 3
end

local function popu3(cursor: Cursor)
	cursor.Pos -= 3
	local x1 = buffer.readu8(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu16(cursor.Buf, cursor.Pos + 1)
	return x1 + x2 * 256
end

local function pushu4(cursor: Cursor, x: number)
	tryRealloc(cursor, 4)
	buffer.writeu32(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 4
end

local function popu4(cursor: Cursor)
	cursor.Pos -= 4
	return buffer.readu32(cursor.Buf, cursor.Pos)
end

local function pushu5(cursor: Cursor, x: number)
	tryRealloc(cursor, 5)
	buffer.writeu8(cursor.Buf, cursor.Pos, x)
	buffer.writeu32(cursor.Buf, cursor.Pos + 1, x // 256)
	cursor.Pos += 5
end

local function popu5(cursor: Cursor)
	cursor.Pos -= 5
	local x1 = buffer.readu8(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu32(cursor.Buf, cursor.Pos + 1)
	return x1 + x2 * 256
end

local function pushu6(cursor: Cursor, x: number)
	tryRealloc(cursor, 6)
	buffer.writeu16(cursor.Buf, cursor.Pos, x)
	buffer.writeu32(cursor.Buf, cursor.Pos + 2, x // 256 ^ 2)
	cursor.Pos += 6
end

local function popu6(cursor: Cursor)
	cursor.Pos -= 6
	local x1 = buffer.readu16(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu32(cursor.Buf, cursor.Pos + 2)
	return x1 + x2 * (256 ^ 2)
end

local function pushu7(cursor: Cursor, x: number)
	tryRealloc(cursor, 7)
	buffer.writeu8(cursor.Buf, cursor.Pos, x)
	buffer.writeu16(cursor.Buf, cursor.Pos + 1, x // 256)
	buffer.writeu32(cursor.Buf, cursor.Pos + 3, x // 256 ^ 3)
	cursor.Pos += 7
end

local function popu7(cursor: Cursor)
	cursor.Pos -= 7
	local x1 = buffer.readu8(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu16(cursor.Buf, cursor.Pos + 1)
	local x3 = buffer.readu32(cursor.Buf, cursor.Pos + 3)
	return x1 + x2 * 256 + x3 * (256 ^ 3)
end

local function pushu8(cursor: Cursor, x: number)
	tryRealloc(cursor, 8)
	buffer.writeu32(cursor.Buf, cursor.Pos, x)
	buffer.writeu32(cursor.Buf, cursor.Pos + 4, x // 256 ^ 4)
	cursor.Pos += 8
end

local function popu8(cursor: Cursor)
	cursor.Pos -= 8
	local x1 = buffer.readu32(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu32(cursor.Buf, cursor.Pos + 4)
	return x1 + x2 * (256 ^ 4)
end

local function pushi1(cursor: Cursor, x: number)
	tryRealloc(cursor, 1)
	buffer.writei8(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 1
end

local function popi1(cursor: Cursor)
	cursor.Pos -= 1
	return buffer.readi8(cursor.Buf, cursor.Pos)
end

local function pushi2(cursor: Cursor, x: number)
	tryRealloc(cursor, 2)
	buffer.writei16(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 2
end

local function popi2(cursor: Cursor)
	cursor.Pos -= 2
	return buffer.readi16(cursor.Buf, cursor.Pos)
end

local function pushi3(cursor: Cursor, x: number)
	x %= 256 ^ 3
	x = if x < 0 then 256 ^ 3 - x else x
	tryRealloc(cursor, 3)
	buffer.writeu8(cursor.Buf, cursor.Pos, x)
	buffer.writeu16(cursor.Buf, cursor.Pos + 1, x // 256)
	cursor.Pos += 3
end

local function popi3(cursor: Cursor)
	cursor.Pos -= 3
	local x1 = buffer.readu8(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu16(cursor.Buf, cursor.Pos + 1)
	return x1 + x2 * 256
end

local function pushi4(cursor: Cursor, x: number)
	tryRealloc(cursor, 4)
	buffer.writei32(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 4
end

local function popi4(cursor: Cursor)
	cursor.Pos -= 4
	return buffer.readi32(cursor.Buf, cursor.Pos)
end

local function pushi5(cursor: Cursor, x: number)
	x %= 256 ^ 5
	x = if x < 0 then 256 ^ 5 - x else x
	tryRealloc(cursor, 5)
	buffer.writei8(cursor.Buf, cursor.Pos, x)
	buffer.writei32(cursor.Buf, cursor.Pos + 1, x // 256)
	cursor.Pos += 5
end

local function popi5(cursor: Cursor)
	cursor.Pos -= 5
	local x1 = buffer.readi8(cursor.Buf, cursor.Pos)
	local x2 = buffer.readi32(cursor.Buf, cursor.Pos + 1)
	return x1 + x2 * 256
end

local function pushi6(cursor: Cursor, x: number)
	x %= 256 ^ 6
	x = if x < 0 then 256 ^ 6 - x else x
	tryRealloc(cursor, 6)
	buffer.writei16(cursor.Buf, cursor.Pos, x)
	buffer.writei32(cursor.Buf, cursor.Pos + 2, x // 256 ^ 2)
	cursor.Pos += 6
end

local function popi6(cursor: Cursor)
	cursor.Pos -= 6
	local x1 = buffer.readi16(cursor.Buf, cursor.Pos)
	local x2 = buffer.readi32(cursor.Buf, cursor.Pos + 2)
	return x1 + x2 * (256 ^ 2)
end

local function pushi7(cursor: Cursor, x: number)
	x %= 256 ^ 7
	x = if x < 0 then 256 ^ 7 - x else x
	tryRealloc(cursor, 7)
	buffer.writei8(cursor.Buf, cursor.Pos, x)
	buffer.writei16(cursor.Buf, cursor.Pos + 1, x // 256)
	buffer.writei32(cursor.Buf, cursor.Pos + 3, x // 256 ^ 3)
	cursor.Pos += 7
end

local function popi7(cursor: Cursor)
	cursor.Pos -= 7
	local x1 = buffer.readi8(cursor.Buf, cursor.Pos)
	local x2 = buffer.readi16(cursor.Buf, cursor.Pos + 1)
	local x3 = buffer.readi32(cursor.Buf, cursor.Pos + 3)
	return x1 + x2 * 256 + x3 * (256 ^ 3)
end

local function pushi8(cursor: Cursor, x: number)
	x %= 256 ^ 8
	x = if x < 0 then 256 ^ 8 - x else x
	tryRealloc(cursor, 8)
	buffer.writei32(cursor.Buf, cursor.Pos, x)
	buffer.writei32(cursor.Buf, cursor.Pos + 4, x // 256 ^ 4)
	cursor.Pos += 8
end

local function popi8(cursor: Cursor)
	cursor.Pos -= 8
	local x1 = buffer.readi32(cursor.Buf, cursor.Pos)
	local x2 = buffer.readi32(cursor.Buf, cursor.Pos + 4)
	return x1 + x2 * (256 ^ 4)
end

local function pushf4(cursor: Cursor, x: number)
	tryRealloc(cursor, 4)
	buffer.writef32(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 4
end

local function popf4(cursor: Cursor)
	cursor.Pos -= 4
	return buffer.readf32(cursor.Buf, cursor.Pos)
end

local function pushf8(cursor: Cursor, x: number)
	tryRealloc(cursor, 8)
	buffer.writef64(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 8
end

local function popf8(cursor: Cursor)
	cursor.Pos -= 8
	return buffer.readf64(cursor.Buf, cursor.Pos)
end

local function pushbool(cursor: Cursor, a: boolean, b: boolean?, c: boolean?, d: boolean?, e: boolean?, f: boolean?, g: boolean?, h: boolean?)
	pushu8(cursor,
		if a then 1 else 0 +
		if b then 2 else 0 +
		if c then 4 else 0 +
		if d then 8 else 0 +
		if e then 16 else 0 +
		if f then 32 else 0 +
		if g then 64 else 0 +
		if h then 128 else 0
	)
end

local function popbool(cursor: Cursor)
	local x = popu8(cursor)
	return
		(x / 1) % 2 >= 1,
		(x / 2) % 2 >= 1,
		(x / 4) % 2 >= 1,
		(x / 8) % 2 >= 1,
		(x / 16) % 2 >= 1,
		(x / 32) % 2 >= 1,
		(x / 64) % 2 >= 1,
		(0 / 128) % 2 >= 1
end

local function pushvlq(cursor: Cursor, x: number)
	local x0 = x // 128 ^ 0 % 128
	local x1 = x // 128 ^ 1 % 128
	local x2 = x // 128 ^ 2 % 128
	local x3 = x // 128 ^ 3 % 128
	local x4 = x // 128 ^ 4 % 128
	local x5 = x // 128 ^ 5 % 128
	local x6 = x // 128 ^ 6 % 128
	local x7 = x // 128 ^ 7 % 128

	if x7 ~= 0 then
		pushu8(cursor, x0 * 256 ^ 7 + x1 * 256 ^ 6 + x2 * 256 ^ 5 + x3 * 256 ^ 4 + x4 * 256 ^ 3 + x5 * 256 ^ 2 + x6 * 256 + x7 + 128)
	elseif x6 ~= 0 then
		pushu7(cursor, x0 * 256 ^ 6 + x1 * 256 ^ 5 + x2 * 256 ^ 4 + x3 * 256 ^ 3 + x4 * 256 ^ 2 + x5 * 256 + x6 + 128)
	elseif x5 ~= 0 then
		pushu6(cursor, x0 * 256 ^ 5 + x1 * 256 ^ 4 + x2 * 256 ^ 3 + x3 * 256 ^ 2 + x4 * 256 + x5 + 128)
	elseif x4 ~= 0 then
		pushu5(cursor, x0 * 256 ^ 4 + x1 * 256 ^ 3 + x2 * 256 ^ 2 + x3 * 256 + x4 + 128)
	elseif x3 ~= 0 then
		pushu4(cursor, x0 * 256 ^ 3 + x1 * 256 ^ 2 + x2 * 256 + x3 + 128)
	elseif x2 ~= 0 then
		pushu3(cursor, x0 * 256 ^ 2 + x1 * 256 + x2 + 128)
	elseif x1 ~= 0 then
		pushu2(cursor, x0 * 256 + x1 + 128)
	else
		pushu1(cursor, x0 + 128)
	end
end

local function popvlq(cursor: Cursor)
	local b = popu1(cursor)
	if b >= 128 then
		return b - 128
	end
	local x = b

	b = popu1(cursor)
	if b >= 128 then
		return x + (b - 128) * 128
	end
	x += b * 128

	b = popu1(cursor)
	if b >= 128 then
		return x + (b - 128) * 128 ^ 2
	end
	x += b * 128 ^ 2

	b = popu1(cursor)
	if b >= 128 then
		return x + (b - 128) * 128 ^ 3
	end
	x += b * 128 ^ 3

	b = popu1(cursor)
	if b >= 128 then
		return x + (b - 128) * 128 ^ 4
	end
	x += b * 128 ^ 4

	b = popu1(cursor)
	if b >= 128 then
		return x + (b - 128) * 128 ^ 5
	end
	x += b * 128 ^ 5

	b = popu1(cursor)
	if b >= 128 then
		return x + (b - 128) * 128 ^ 6
	end
	x += b * 128 ^ 6

	b = popu1(cursor)
	if b >= 128 then
		return x + (b - 128) * 128 ^ 7
	end

	error(`Not a valid vlq: {x + b * 128 ^ 7} = {buffer.tostring(cursor.Buf)}`)
end

local function pushstr(cursor: Cursor, x: string)
	local len = #x
	tryRealloc(cursor, len)
	buffer.writestring(cursor.Buf, cursor.Pos, x)
	cursor.Pos += len
	pushvlq(cursor, len)
end

local function popstr(cursor: Cursor)
	local len = popvlq(cursor)
	cursor.Pos -= len
	return buffer.readstring(cursor.Buf, cursor.Pos, len)
end

local Squash = {}

export type SerDes<T...> = {
	ser: (cursor: Cursor, T...) -> (),
	des: (cursor: Cursor) -> T...,
}

function Squash.T<T>(x: SerDes<T>): T
	return x :: any
end

local booleanCache: SerDes<boolean, boolean?, boolean?, boolean?, boolean?, boolean?, boolean?, boolean?> = {
	ser = pushbool,
	des = popbool,
}
function Squash.boolean()
	return booleanCache
end

local uintCache = {} :: { SerDes<number> }
function Squash.uint(bytes: number)
	if uintCache[bytes] then
		return uintCache[bytes]
	end

	local push, pop
	if bytes == 1 then
		push, pop = pushu1, popu1
	elseif bytes == 2 then
		push, pop = pushu2, popu2
	elseif bytes == 3 then
		push, pop = pushu3, popu3
	elseif bytes == 4 then
		push, pop = pushu4, popu4
	elseif bytes == 5 then
		push, pop = pushu5, popu5
	elseif bytes == 6 then
		push, pop = pushu6, popu6
	elseif bytes == 7 then
		push, pop = pushu7, popu7
	elseif bytes == 8 then
		push, pop = pushu8, popu8
	else
		error(`uint bytes must be integer between [1, 8], got {bytes}`)
	end

	local num = {
		ser = push,
		des = pop,
	}
	uintCache[bytes] = num
	return num
end

local intCache = {} :: { SerDes<number> }
function Squash.int(bytes: number)
	if intCache[bytes] then
		return intCache[bytes]
	end

	local push, pop
	if bytes == 1 then
		push, pop = pushi1, popi1
	elseif bytes == 2 then
		push, pop = pushi2, popi2
	elseif bytes == 3 then
		push, pop = pushi3, popi3
	elseif bytes == 4 then
		push, pop = pushi4, popi4
	elseif bytes == 5 then
		push, pop = pushi5, popi5
	elseif bytes == 6 then
		push, pop = pushi6, popi6
	elseif bytes == 7 then
		push, pop = pushi7, popi7
	elseif bytes == 8 then
		push, pop = pushi8, popi8
	else
		error(`int bytes must be integer between [1, 8], got {bytes}`)
	end

	local num = {
		ser = push,
		des = pop,
	}
	intCache[bytes] = num
	return num
end

local numberCache = {} :: { SerDes<number> }
function Squash.number(bytes: number)
	if numberCache[bytes] then
		return numberCache[bytes]
	end

	local push, pop
	if bytes == 4 then
		push, pop = pushf4, popf4
	elseif bytes == 8 then
		push, pop = pushf8, popf8
	else
		error(`number bytes must be integer 4 or 8, got {bytes}`)
	end

	local num = {
		ser = push,
		des = pop,
	}
	intCache[bytes] = num
	return num
end

local stringCache: SerDes<string> = {
	ser = pushstr,
	des = popstr,
}
local stringMeta = {
	__call = function(_)
		return stringCache
	end,
}
Squash.string = setmetatable({}, stringMeta)

local arrayCache = {}
local function array<T>(serdes: SerDes<T>): SerDes<{T}>
	if arrayCache[serdes] then
		return arrayCache[serdes]
	end

	local ser, des = serdes.ser, serdes.des

	local arr = {}

	function arr.ser(cursor: Cursor, xs: {T})
		for _, x in xs do
			ser(cursor, x)
		end
		pushvlq(cursor, #xs)
	end

	function arr.des(cursor: Cursor)
		local len = popvlq(cursor)
		local xs = table.create(len)
		for i = len, 1, -1 do
			xs[i] = des(cursor)
		end
		return xs
	end

	arrayCache[serdes] = arr
	return arr
end
Squash.array = array

local angleCache: SerDes<number> = {
	ser = function(cursor: Cursor, angle: number)
		pushu8(cursor, angle * 180 / math.pi)
	end,
	des = function(cursor: Cursor)
		return popu8(cursor) * math.pi / 180
	end,
}
function Squash.angle()
	return angleCache
end

function Squash.tuple<T...>(...: T...): SerDes<T...>
	local serdesargs: { any } = { ... }
	local count = #serdesargs

	local tuple = {}

	function tuple.ser(cursor: Cursor, ...: T...)
		for i, x in { ... } :: { any } do
			serdesargs[i].ser(cursor, x)
		end
	end

	function tuple.des(cursor: Cursor)
		local xs = table.create(count)
		for i = count, 1, -1 do 
			xs[i] = serdesargs[i].des(cursor)
		end
		return table.unpack(xs)
	end

	return tuple
end

local function record<T>(schema: T & {}): SerDes<T>
	local properties = {}
	for prop in schema :: any do
		if type(prop) == 'string' then
			table.insert(properties, prop)
		end
	end
	table.sort(properties)
	table.insert(properties, (schema :: any)[true])
	table.insert(properties, (schema :: any)[false])

	local rec = {}

	function rec.ser(cursor: Cursor, rec: T)
		for _, prop in properties do
			local ser = (schema :: any)[prop].ser
			local x = (rec :: any)[prop]
			ser(cursor, x)
		end
	end

	function rec.des(cursor: Cursor)
		local tab = {}
		for i = #properties, 1, -1 do
			local prop = properties[i]
			local des = (schema :: any)[prop].des
			tab[prop] = des(cursor)
		end
		return tab :: any
	end

	return rec
end
Squash.record = record

local function map<K, V>(keySerDes: K, valueSerDes: V): SerDes<{[K]: V}>
	local map = {}

	function map.ser(cursor: Cursor, map: {[K]: V})
		local count = 0
		for k, v in map :: any do
			(valueSerDes :: any).ser(cursor, v)
			;(keySerDes :: any).ser(cursor, k)
			count += 1
		end
		pushvlq(cursor, count)
	end

	function map.des(cursor: Cursor): {[K]: V}
		local map = {}

		local count = popvlq(cursor)
		for _ = 1, count do
			local key = (keySerDes :: any).des(cursor)
			local value = (valueSerDes :: any).des(cursor)
			map[key] = value
		end

		return map :: any
	end

	return map
end
Squash.map = map

local T = Squash.T
local arr = Squash.array
local uint = Squash.uint
local int = Squash.int
local number = Squash.number
local string = Squash.string
local tuple = Squash.tuple
local record = Squash.record
local map = Squash.map

local cursor = newCursor()
local serdes = map(T(arr(uint(4))), T(record {
	x = T(number(4)),
	y = T(number(4)),
	z = T(number(4)),
}))

serdes.ser(cursor, {
	[{84.3, 45324.3, 2436/63456}] = {
		x = 1,
		y = 2,
		z = 4,
	},
})
local send = toBuffer(cursor)

local receive = fromBuffer(send)
local tab = serdes.des(receive)

for k, v in tab do
	if type(v) == 'table' then
		print(`tab[{k}] = \{`)
		for l, v in v do
			print(`\t{k}[{l}] = {v}`)
		end
		print(`\}`)
	else
		print(`tab[{k}] = {v}`)
	end
end

local vector2Cache = {}
function Squash.Vector2(serdes: SerDes<number>): SerDes<Vector2>
	if vector2Cache[serdes] then
		return vector2Cache[serdes]
	end

	local ser, des = serdes.ser, serdes.des

	local vec2 = {}

	function vec2.ser(cursor: Cursor, v: Vector2)
		ser(cursor, v.X)
		ser(cursor, v.Y)
	end

	function vec2.des(cursor: Cursor)
		local y, x = des(cursor), des(cursor)
		return Vector2.new(x, y)
	end

	vector2Cache[serdes] = vec2
	return vec2
end

-- --[=[
-- 	@class Squash
-- ]=]
-- local Squash = {}

-- Squash.newCursor = newCursor
-- Squash.trimCursor = trimCursor

-- --* Types *--

-- --[=[
-- 	@within Squash
-- 	@type Alphabet string

-- 	A string of unique characters that represent the basis of other strings.
-- ]=]
-- export type Alphabet = string

-- --[=[
-- 	@within Squash
-- 	@type Bytes number

-- 	1, 2, 3, 4, 5, 6, 7, 8

-- 	The number of bytes used to represent a number.
-- ]=]
-- export type Bytes = number

-- --[=[
-- 	@within Squash
-- 	@type FloatBytes number

-- 	4, 8

-- 	The number of bytes used to represent a floating point number.
-- ]=]
-- export type FloatBytes = number

-- --[=[
-- 	@within Squash
-- 	@type NumberSer (x: number, bytes: Bytes?) -> string

-- 	A function that serializes a number into a string. Usually this is Squash's uint, int, or number ser methods.
-- ]=]
-- export type SerDes<T> = {
-- 	ser: (cursor: Cursor, x0: T) -> Cursor,
-- 	des: (cursor: Cursor) -> T,
-- 	serarr: (cursor: Cursor, xs: { T }) -> Cursor,
-- 	desarr: (cursor: Cursor) -> { T },
-- }

-- --* Properties *--

-- -- Alphabets
-- do
-- 	--[=[
-- 		@within Squash
-- 		@prop binary Alphabet
	
-- 		All digits in base 2.
-- 	]=]
-- 	Squash.binary = '01' :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop octal Alphabet
	
-- 		All digits in base 8.
-- 	]=]
-- 	Squash.octal = '01234567' :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop decimal Alphabet
	
-- 		All digits in base 10.
-- 	]=]
-- 	Squash.decimal = '0123456789' :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop duodecimal Alphabet
	
-- 		All digits in base 12.
-- 	]=]
-- 	Squash.duodecimal = '0123456789AB' :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop hexadecimal Alphabet
	
-- 		All digits in base 16.
-- 	]=]
-- 	Squash.hexadecimal = '0123456789ABCDEF' :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop utf8 Alphabet
	
-- 		All digits in base 256. The UTF-8 character set.
-- 	]=]
-- 	local utf8Characters = table.create(256)
-- 	for i = 0, 255 do
-- 		utf8Characters[i + 1] = string.char(i)
-- 	end
-- 	Squash.utf8 = table.concat(utf8Characters) :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop lower Alphabet
	
-- 		All lowercase letters in the english language.
-- 	]=]
-- 	Squash.lower = 'abcdefghijklmnopqrstuvwxyz' :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop upper Alphabet
	
-- 		All uppercase letters in the english language.
-- 	]=]
-- 	Squash.upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop letters Alphabet
	
-- 		All letters in the english language.
-- 	]=]
-- 	Squash.letters = Squash.lower .. Squash.upper :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop punctuation Alphabet
	
-- 		All punctuation symbols in the english language.
-- 	]=]
-- 	Squash.punctuation = ' .,?!:;\'"-_' :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop english Alphabet
	
-- 		All symbols in the english language.
-- 	]=]
-- 	Squash.english = Squash.letters .. Squash.punctuation :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop filepath Alphabet
	
-- 		All characters that may be used in a filepath.
-- 	]=]
-- 	Squash.filepath = Squash.letters .. Squash.letters .. ':/-_ ' :: Alphabet

-- 	--[=[
-- 		@within Squash
-- 		@prop datastore Alphabet
	
-- 		All characters that will not be expanded when JSONEncoded.
-- 	]=]
-- 	Squash.datastore = ' !#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~'
-- end

-- --* Duplication Reducers *--

-- --? inlined
-- local function bytesAssert(bytes: number): never
-- 	error(`Expected 1, 2, 3, 4, 5, 6, 7, 8 bytes. Invalid number of bytes for integer: {bytes}`)
-- end

-- --? inlined
-- local function floatAssert(bytes: number): never
-- 	error(`Expected 4 or 8 bytes. Invalid number of bytes for floating point: {bytes}`)
-- end

-- local function numberSerDes(bytes: number, push: (cursor: Cursor, x0: number) -> (), pop: (cursor: Cursor) -> number)
-- 	local num = {}

-- 	function num.ser(cursor: Cursor?, x0: number)
-- 		local cursor = cursor or newCursor(bytes)
-- 		push(cursor, x0)
-- 		return cursor
-- 	end

-- 	num.des = pop

-- 	function num.serarr(cursor: Cursor, xs: { number })
-- 		local cursor = cursor or newCursor(bytes * #xs)
-- 		for _, x0 in xs do
-- 			push(cursor, x0)
-- 		end
-- 		return cursor
-- 	end

-- 	function num.desarr(cursor: Cursor)
-- 		local len = cursor.Pos // bytes
-- 		local xs = table.create(len)
-- 		for i = 1, len do
-- 			xs[i] = pop(cursor)
-- 		end
-- 		return xs
-- 	end

-- 	return num
-- end

-- --* Actual API *--

-- function Squash.bytes(x0: number)
-- 	if x0 == 0 then -- 0
-- 		return 1
-- 	elseif x0 ~= x0 // 1 then -- floating point
-- 		local x1 = string.unpack('f', string.pack('f', x0))
-- 		return if x0 == x1 then 4 else 8
-- 	elseif x0 < 1 then -- negative int
-- 		return math.ceil(math.log(math.abs(2 * x0), 256))
-- 	else -- positive uint
-- 		return math.ceil(math.log(math.abs(1 + x0), 256))
-- 	end
-- end

-- do
-- 	local booleans = {}

-- 	function booleans.ser(
-- 		cursor: Cursor?,
-- 		x0: boolean?,
-- 		x1: boolean?,
-- 		x2: boolean?,
-- 		x3: boolean?,
-- 		x4: boolean?,
-- 		x5: boolean?,
-- 		x6: boolean?,
-- 		x7: boolean?
-- 	)
-- 		local cursor = cursor or newCursor()
-- 		local y = (if x0 then 1 else 0)
-- 			+ (if x1 then 2 else 0)
-- 			+ (if x2 then 4 else 0)
-- 			+ (if x3 then 8 else 0)
-- 			+ (if x4 then 16 else 0)
-- 			+ (if x5 then 32 else 0)
-- 			+ (if x6 then 64 else 0)
-- 			+ (if x7 then 128 else 0)
-- 		pushu1(cursor, y)
-- 		return cursor
-- 	end

-- 	function booleans.des(cursor: Cursor)
-- 		local x0 = popu1(cursor)
-- 		return (x0 / 1) % 2 >= 1,
-- 			(x0 / 2) % 2 >= 1,
-- 			(x0 / 4) % 2 >= 1,
-- 			(x0 / 8) % 2 >= 1,
-- 			(x0 / 16) % 2 >= 1,
-- 			(x0 / 32) % 2 >= 1,
-- 			(x0 / 64) % 2 >= 1,
-- 			(x0 / 128) % 2 >= 1
-- 	end

-- 	function booleans.serarr(cursor: Cursor?, xs: { boolean })
-- 		local cursor = cursor or newCursor()

-- 		for i = 0, math.ceil(#xs / 8) - 1 do
-- 			local j = i * 8
-- 			pushu8(
-- 				cursor,
-- 				(if xs[j + 1] then 1 else 0)
-- 					+ (if xs[j + 2] then 2 else 0)
-- 					+ (if xs[j + 3] then 4 else 0)
-- 					+ (if xs[j + 4] then 8 else 0)
-- 					+ (if xs[j + 5] then 16 else 0)
-- 					+ (if xs[j + 6] then 32 else 0)
-- 					+ (if xs[j + 7] then 64 else 0)
-- 					+ (if xs[j + 8] then 128 else 0)
-- 			)
-- 		end

-- 		return cursor
-- 	end

-- 	function booleans.desarr(cursor: Cursor)
-- 		local xs = {}

-- 		for i = 0, cursor.Pos - 1 do
-- 			local x0 = popu8(cursor)
-- 			local j = i * 8
-- 			xs[j + 1] = (x0 / 1) % 2 >= 1
-- 			xs[j + 2] = (x0 / 2) % 2 >= 1
-- 			xs[j + 3] = (x0 / 4) % 2 >= 1
-- 			xs[j + 4] = (x0 / 8) % 2 >= 1
-- 			xs[j + 5] = (x0 / 16) % 2 >= 1
-- 			xs[j + 6] = (x0 / 32) % 2 >= 1
-- 			xs[j + 7] = (x0 / 64) % 2 >= 1
-- 			xs[j + 8] = (x0 / 128) % 2 >= 1
-- 		end

-- 		return xs
-- 	end

-- 	local meta = {
-- 		__call = function(_)
-- 			return booleans
-- 		end,
-- 	}
-- 	Squash.boolean = setmetatable({}, meta)
-- end

-- do
-- 	local cache = {}
-- 	local meta = {
-- 		__call = function(_, bytes: number)
-- 			local cached: SerDes<number>? = cache[bytes]
-- 			if cached then
-- 				return cached
-- 			end

-- 			local push, pop
-- 			if bytes == 1 then
-- 				push, pop = pushu1, popu1
-- 			elseif bytes == 2 then
-- 				push, pop = pushu2, popu2
-- 			elseif bytes == 3 then
-- 				push, pop = pushu3, popu3
-- 			elseif bytes == 4 then
-- 				push, pop = pushu4, popu4
-- 			elseif bytes == 5 then
-- 				push, pop = pushu5, popu5
-- 			elseif bytes == 6 then
-- 				push, pop = pushu6, popu6
-- 			elseif bytes == 7 then
-- 				push, pop = pushu7, popu7
-- 			elseif bytes == 8 then
-- 				push, pop = pushu8, popu8
-- 			else
-- 				bytesAssert(bytes)
-- 			end

-- 			local uint = numberSerDes(bytes, push, pop)
-- 			cache[bytes] = uint
-- 			return uint
-- 		end,
-- 	}
-- 	Squash.uint = setmetatable({}, meta)
-- end

-- do
-- 	local cache = {}
-- 	local meta = {
-- 		__call = function(_, bytes: number)
-- 			local cached: SerDes<number>? = cache[bytes]
-- 			if cached then
-- 				return cached
-- 			end

-- 			local push, pop
-- 			if bytes == 1 then
-- 				push, pop = pushi1, popi1
-- 			elseif bytes == 2 then
-- 				push, pop = pushi2, popi2
-- 			elseif bytes == 3 then
-- 				push, pop = pushi3, popi3
-- 			elseif bytes == 4 then
-- 				push, pop = pushi4, popi4
-- 			elseif bytes == 5 then
-- 				push, pop = pushi5, popi5
-- 			elseif bytes == 6 then
-- 				push, pop = pushi6, popi6
-- 			elseif bytes == 7 then
-- 				push, pop = pushi7, popi7
-- 			elseif bytes == 8 then
-- 				push, pop = pushi8, popi8
-- 			else
-- 				bytesAssert(bytes)
-- 			end

-- 			local int = numberSerDes(bytes, push, pop)
-- 			cache[bytes] = int
-- 			return int
-- 		end,
-- 	}
-- 	Squash.int = setmetatable({}, meta)
-- end

-- do
-- 	local cache = {}

-- 	local meta = {
-- 		__call = function(_, bytes: number)
-- 			local cached: SerDes<number>? = cache[bytes]
-- 			if cached then
-- 				return cached
-- 			end

-- 			local push, pop
-- 			if bytes == 4 then
-- 				push, pop = pushf4, popf4
-- 			elseif bytes == 8 then
-- 				push, pop = pushf8, popf8
-- 			else
-- 				floatAssert(bytes)
-- 			end

-- 			local number = numberSerDes(bytes, push, pop)
-- 			cache[bytes] = number
-- 			return number
-- 		end,
-- 	}
-- 	Squash.number = setmetatable({}, meta)
-- end

-- do
-- 	local cache = {}

-- 	local function alphabet(source: string)
-- 		local lookup = {}
-- 		local alphabet = table.create(#source)
-- 		for i = 1, #source do
-- 			local char = string.sub(source, i, i)
-- 			if not lookup[char] then
-- 				lookup[char] = true
-- 				table.insert(alphabet, char)
-- 			end
-- 		end
-- 		table.sort(alphabet)
-- 		return table.concat(alphabet) :: Alphabet
-- 	end

-- 	local function convert(x: string, inAlphabet: Alphabet, outAlphabet: Alphabet)
-- 		local sourceDigits = {}
-- 		for i = 1, #inAlphabet do
-- 			sourceDigits[string.byte(inAlphabet, i)] = i - 1
-- 		end

-- 		local targetDigits = {}
-- 		for i = 1, #outAlphabet do
-- 			targetDigits[i - 1] = string.byte(outAlphabet, i)
-- 		end

-- 		local inputDigits = {}
-- 		for i = 1, #x do
-- 			table.insert(inputDigits, sourceDigits[string.byte(x, i)])
-- 		end

-- 		local output = {}
-- 		local sourceBase = #inAlphabet
-- 		local targetBase = #outAlphabet
-- 		local carry, value
-- 		while #inputDigits > 0 do
-- 			carry = 0

-- 			for i = 1, #inputDigits do
-- 				value = inputDigits[i] + carry * sourceBase
-- 				inputDigits[i] = value // targetBase
-- 				carry = value % targetBase
-- 			end

-- 			while #inputDigits > 0 and inputDigits[1] == 0 do
-- 				table.remove(inputDigits, 1)
-- 			end

-- 			table.insert(output, 1, string.char(targetDigits[carry]))
-- 		end

-- 		return table.concat(output)
-- 	end

-- 	local meta = {
-- 		__call = function(_, alphabet: Alphabet)
-- 			local cached = cache[alphabet] :: SerDes<string>
-- 			if cached then
-- 				return cached
-- 			end

-- 			local serdes = {}
-- 			cache[alphabet] = serdes

-- 			serdes.min = 0
-- 			serdes.max = math.huge

-- 			function serdes.ser(x0: string)
-- 				return buffer.fromstring(convert(x0, zeroChar .. alphabet, Squash.compressed))
-- 			end

-- 			function serdes.des(y0: buffer)
-- 				return convert(buffer.tostring(y0), Squash.compressed, zeroChar .. alphabet) :: string
-- 			end

-- 			function serdes.servar(x0: string)
-- 				return buffer.fromstring(convert(x0, zeroChar .. alphabet, Squash.list))
-- 			end

-- 			function serdes.desvar(y0: buffer)
-- 				return convert(buffer.tostring(y0), Squash.list, zeroChar .. alphabet)
-- 			end

-- 			function serdes.serarr(xs: { string })
-- 				local ys = table.create(#xs)
-- 				for i, x0 in ipairs(xs) do
-- 					ys[i] = convert(x0, zeroChar .. alphabet, Squash.list)
-- 				end
-- 				return buffer.fromstring(table.concat(ys, delimiterChar))
-- 			end

-- 			function serdes.desarr(ys: buffer)
-- 				local xs = string.split(buffer.tostring(ys), delimiterChar)
-- 				for i, x0 in ipairs(xs) do
-- 					xs[i] = convert(x0, Squash.list, zeroChar .. alphabet)
-- 				end
-- 				return xs
-- 			end

-- 			serdes.split = split

-- 			return serdes
-- 		end,
-- 	}
-- 	Squash.string = setmetatable({
-- 		convert = convert,
-- 		alphabet = alphabet,
-- 	}, meta)

-- 	-- --[=[
-- 	-- 	@within string
-- 	-- 	@function des
-- 	-- 	@param y string
-- 	-- 	@param alphabet Alphabet?
-- 	-- 	@return string
-- 	-- ]=]
-- 	-- Squash.string.des = function(y: string, alphabet: Alphabet?): string
-- 	-- 	local outAlphabet = Squash.delimiter .. (alphabet or Squash.english)
-- 	-- 	return Squash.string.convert(y, Squash.utf8, outAlphabet)
-- 	-- end

-- 	-- --[=[
-- 	-- 	@within string
-- 	-- 	@function serarr
-- 	-- 	@tag WARNING: Array serialization is unstable due to implementation oversight, use carefully
-- 	-- 	@param x { string }
-- 	-- 	@param alphabet Alphabet?
-- 	-- 	@return string
-- 	-- ]=]
-- 	-- Squash.string.serarr = function(x: { string }, alphabet: Alphabet?)
-- 	-- 	local y = {}
-- 	-- 	for i, v in x do
-- 	-- 		y[i] = Squash.string.ser(v, alphabet)
-- 	-- 	end
-- 	-- 	return table.concat(y, Squash.delimiter)
-- 	-- end

-- 	-- --[=[
-- 	-- 	@within string
-- 	-- 	@function desarr
-- 	-- 	@param y string
-- 	-- 	@param alphabet Alphabet?
-- 	-- 	@return { string }
-- 	-- ]=]
-- 	-- Squash.string.desarr = function(y: string, alphabet: Alphabet?): { string }
-- 	-- 	local x = {}
-- 	-- 	for v in string.gmatch(y, '[^' .. Squash.delimiter .. ']+') do
-- 	-- 		table.insert(x, Squash.string.des(v, alphabet))
-- 	-- 	end
-- 	-- 	return x
-- 	-- end
-- end

-- do
-- 	local cache = {}

-- 	local meta = {
-- 		__call = function(_, encoding: SerDes<number>)
-- 			local cached = cache[encoding] :: SerDes<Vector2>
-- 			if cached then
-- 				return cached
-- 			end

-- 			local serdes = {}
-- 			cache[encoding] = serdes

-- 			local encodingmax = encoding.max
-- 			local encodingser = encoding.ser
-- 			local encodingdes = encoding.des

-- 			local max = 2 * encodingmax
-- 			serdes.min = 0
-- 			serdes.max = max

-- 			function serdes.ser(cursor: Cursor, x0: Vector2)
-- 				if x0 == Vector2.zero then
-- 					return buffer.create(0)
-- 				elseif x0 == Vector2.one then
-- 					return buffer.create(1)
-- 				elseif x0 == Vector2.xAxis then
-- 					local y0 = buffer.create(1)
-- 					buffer.writeu8(y0, 0, 1)
-- 					return y0
-- 				elseif x0 == Vector2.yAxis then
-- 					local y0 = buffer.create(1)
-- 					buffer.writeu8(y0, 0, 2)
-- 					return y0
-- 				end

-- 				local y0 = buffer.create(max)
-- 				buffer.copy(y0, 0 * encodingmax, encodingser(x0.X))
-- 				buffer.copy(y0, 1 * encodingmax, encodingser(x0.Y))
-- 				return y0
-- 			end

-- 			function serdes.des(y0: buffer)
-- 				local len = buffer.len(y0)
-- 				if len == 0 then
-- 					return Vector2.zero
-- 				elseif len == 1 then
-- 					local id = buffer.readu8(y0, 0)
-- 					if id == 0 then
-- 						return Vector2.one
-- 					elseif id == 1 then
-- 						return Vector2.xAxis
-- 					elseif id == 2 then
-- 						return Vector2.yAxis
-- 					else
-- 						error(`Vector2 Special-Case Buffer of size 1 has invalid ID {id}, expected 0, 1, 2`)
-- 					end
-- 				end

-- 				local y1 = buffer.create(encodingmax)
-- 				local x = encodingdes(y0)

-- 				buffer.copy(y1, 0, y0, encodingmax, encodingmax)
-- 				local y = encodingdes(y1)

-- 				return Vector2.new(x, y)
-- 			end

-- 			function serdes.serarr(xs: { Vector2 })
-- 				local ys = buffer.create(max * #xs)
-- 				for i, x0 in xs do
-- 					local j = 2 * i
-- 					buffer.copy(ys, j - 2, encodingser(x0.X))
-- 					buffer.copy(ys, j - 1, encodingser(x0.Y))
-- 				end

-- 				return ys
-- 			end

-- 			function serdes.desarr(ys: buffer)
-- 				local len = buffer.len(ys) / max
-- 				local xs = table.create(len)
-- 				local buf = buffer.create(encodingmax)

-- 				for i = 0, len - 1 do
-- 					local j = 2 * i
-- 					buffer.copy(buf, 0, ys, (j + 0) * encodingmax, encodingmax)
-- 					local x = encodingdes(buf)

-- 					buffer.copy(buf, 0, ys, (j + 1) * encodingmax, encodingmax)
-- 					local y = encodingdes(buf)

-- 					xs[i + 1] = Vector2.new(x, y)
-- 				end

-- 				return xs
-- 			end

-- 			return serdes
-- 		end,
-- 	}
-- 	Squash.Vector2 = setmetatable({}, meta)
-- end

-- do
-- 	local cache = {}

-- 	local meta = {
-- 		__call = function(_, encoding: SerDes<number>)
-- 			local cached = cache[encoding] :: SerDes<Vector3>
-- 			if cached then
-- 				return cached
-- 			end

-- 			local serdes = {}
-- 			cache[encoding] = serdes

-- 			local encodingmax = encoding.max
-- 			local encodingser = encoding.ser
-- 			local encodingdes = encoding.des

-- 			local max = 3 * encodingmax
-- 			serdes.min = 0
-- 			serdes.max = max

-- 			function serdes.ser(x0: Vector3)
-- 				if x0 == Vector3.zero then
-- 					return buffer.create(0)
-- 				elseif x0 == Vector3.one then
-- 					return buffer.create(1)
-- 				elseif x0 == Vector3.xAxis then
-- 					local y0 = buffer.create(1)
-- 					buffer.writeu8(y0, 0, 1)
-- 					return y0
-- 				elseif x0 == Vector3.yAxis then
-- 					local y0 = buffer.create(1)
-- 					buffer.writeu8(y0, 0, 2)
-- 					return y0
-- 				elseif x0 == Vector3.zAxis then
-- 					local y0 = buffer.create(1)
-- 					buffer.writeu8(y0, 0, 3)
-- 					return y0
-- 				end

-- 				local y0 = buffer.create(max)
-- 				buffer.copy(y0, 0 * encodingmax, encodingser(x0.X))
-- 				buffer.copy(y0, 1 * encodingmax, encodingser(x0.Y))
-- 				buffer.copy(y0, 2 * encodingmax, encodingser(x0.Z))
-- 				return y0
-- 			end

-- 			function serdes.des(y0: buffer)
-- 				local len = buffer.len(y0)
-- 				if len == 0 then
-- 					return Vector3.zero
-- 				elseif len == 1 then
-- 					local id = buffer.readu8(y0, 0)
-- 					if id == 0 then
-- 						return Vector3.one
-- 					elseif id == 1 then
-- 						return Vector3.xAxis
-- 					elseif id == 2 then
-- 						return Vector3.yAxis
-- 					elseif id == 3 then
-- 						return Vector3.zAxis
-- 					else
-- 						error(`Vector3 Special-Case Buffer of size 1 has invalid ID {id}, expected 0, 1, 2, 3`)
-- 					end
-- 				end

-- 				local y1 = buffer.create(encodingmax)
-- 				local x = encodingdes(y0)

-- 				buffer.copy(y1, 0, y0, encodingmax, encodingmax)
-- 				local y = encodingdes(y1)

-- 				buffer.copy(y1, 0, y0, 2 * encodingmax, encodingmax)
-- 				local z = encodingdes(y1)

-- 				return Vector3.new(x, y, z)
-- 			end

-- 			serdes.minvar = max

-- 			function serdes.servar(x0: Vector3)
-- 				local y0 = buffer.create(max)
-- 				buffer.copy(y0, 0 * encodingmax, encodingser(x0.X))
-- 				buffer.copy(y0, 1 * encodingmax, encodingser(x0.Y))
-- 				buffer.copy(y0, 2 * encodingmax, encodingser(x0.Z))
-- 				return y0
-- 			end

-- 			function serdes.desvar(y0: buffer)
-- 				local y1 = buffer.create(encodingmax)
-- 				local x = encodingdes(y0)

-- 				buffer.copy(y1, 0, y0, encodingmax, encodingmax)
-- 				local y = encodingdes(y1)

-- 				buffer.copy(y1, 0, y0, 2 * encodingmax, encodingmax)
-- 				local z = encodingdes(y1)

-- 				return Vector3.new(x, y, z)
-- 			end

-- 			function serdes.serarr(xs: { Vector3 })
-- 				local ys = buffer.create(max * #xs)
-- 				for i, x0 in xs do
-- 					local j = 3 * i
-- 					buffer.copy(ys, j - 3, encodingser(x0.X))
-- 					buffer.copy(ys, j - 2, encodingser(x0.Y))
-- 					buffer.copy(ys, j - 1, encodingser(x0.Z))
-- 				end

-- 				return ys
-- 			end

-- 			function serdes.desarr(ys: buffer)
-- 				local len = buffer.len(ys) / max
-- 				local xs = table.create(len)
-- 				local buf = buffer.create(encodingmax)

-- 				for i = 0, len - 1 do
-- 					local j = 3 * i
-- 					buffer.copy(buf, 0, ys, (j + 0) * encodingmax, encodingmax)
-- 					local x = encodingdes(buf)

-- 					buffer.copy(buf, 0, ys, (j + 1) * encodingmax, encodingmax)
-- 					local y = encodingdes(buf)

-- 					buffer.copy(buf, 0, ys, (j + 2) * encodingmax, encodingmax)
-- 					local z = encodingdes(buf)

-- 					xs[i + 1] = Vector3.new(x, y, z)
-- 				end

-- 				return xs
-- 			end

-- 			return serdes
-- 		end,
-- 	}
-- 	Squash.Vector3 = setmetatable({}, meta)
-- end

-- do
-- 	local meta = {
-- 		__call = function<T...>(_, ...: SerDes<any>)
-- 			local args = { ... }
-- 			local argc = #args

-- 			if argc == 0 then
-- 				error 'Cannot create tuple serdes with no arguments'
-- 			elseif argc == 1 then
-- 				return (args[1] :: any) :: SerDesVar<T...>
-- 			end

-- 			local serdes = {}

-- 			serdes.min = 0
-- 			serdes.max = 0

-- 			for i, arg in args do
-- 				local min = arg.minvar or arg.min
-- 				local max = arg.maxvar or arg.max
-- 				serdes.min += min
-- 				serdes.max += max + if max == math.huge and i < argc then 1 else 0
-- 			end

-- 			print('MIN', serdes.min, 'MAX', serdes.max)

-- 			if serdes.max == math.huge then
-- 				print 'UNBOUNDED SIZE'
-- 				local ys = table.create(argc)

-- 				function serdes.ser(...: T...)
-- 					print 'SER'

-- 					local xs = { ... }

-- 					for i, arg in args do
-- 						local ser = arg.servar or arg.ser
-- 						ys[i] = ser(xs[i])
-- 					end
-- 				end

-- 				function serdes.des(ys: buffer): T...
-- 					print 'DES'
-- 				end
-- 			elseif serdes.max ~= serdes.min then
-- 				print 'BOUNDED SIZE'

-- 				function serdes.ser(...: T...)
-- 					local xs = { ... }

-- 					local yss = {}
-- 					local sizes = table.create(argc)

-- 					local size = 0
-- 					for i, arg in ipairs(args) do
-- 						local ser = arg.servar or arg.ser
-- 						local y0 = ser(xs[i])
-- 						table.insert(yss, y0)

-- 						local len = buffer.len(y0)
-- 						size += len
-- 						sizes[i] = len
-- 					end

-- 					local offset = 0
-- 					local ys = buffer.create(size)
-- 					for i, y0 in yss do
-- 						buffer.copy(ys, offset, y0)
-- 						offset += sizes[i]
-- 					end

-- 					return ys
-- 				end

-- 				function serdes.des(ys: buffer)
-- 					local xs = table.create(argc)

-- 					local yss = ys

-- 					local offset = 0
-- 					for _, arg in args do
-- 						local cutoff = if arg.split then arg.split(yss) else offset + (arg.maxvar or arg.max)

-- 						local segment = buffer.create(cutoff - offset)
-- 						offset = cutoff + 1
-- 						buffer.copy(segment, 0, yss, cutoff)

-- 						local des = arg.desvar or arg.des
-- 						table.insert(xs, des(segment))

-- 						local len = buffer.len(yss) - offset
-- 						local last = buffer.create(len)
-- 						buffer.copy(last, 0, yss, offset)
-- 						yss = last
-- 					end
-- 				end
-- 			else
-- 				print 'FIXED SIZE'
-- 				local buf = buffer.create(serdes.max)

-- 				function serdes.ser(...: T...)
-- 					local xs = { ... }

-- 					local offset = 0
-- 					for i, arg in ipairs(args) do
-- 						local y0 = arg.ser(xs[i])
-- 						buffer.copy(buf, offset, y0)
-- 						local len = arg.maxvar or arg.max
-- 						offset += len
-- 					end

-- 					return buf
-- 				end

-- 				function serdes.des(ys: buffer): T...
-- 					local xs = table.create(#args)

-- 					local offset = 0
-- 					for i, arg in ipairs(args) do
-- 						local len = arg.maxvar or arg.max
-- 						local y0 = buffer.create(len)
-- 						buffer.copy(y0, 0, ys, offset, len)
-- 						offset += len

-- 						local x0 = arg.des(y0)
-- 						table.insert(xs, x0)
-- 					end

-- 					return table.unpack(xs)
-- 				end
-- 			end

-- 			return serdes
-- 		end,
-- 	}
-- 	Squash.tuple = setmetatable({}, meta)
-- end

-- return Squash
