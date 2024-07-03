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
	pushu1(cursor,
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

local function popbool(cursor: Cursor): (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean)
	local x = popu1(cursor)
	return
		(x / 1) % 2 >= 1,
		(x / 2) % 2 >= 1,
		(x / 4) % 2 >= 1,
		(x / 8) % 2 >= 1,
		(x / 16) % 2 >= 1,
		(x / 32) % 2 >= 1,
		(x / 64) % 2 >= 1,
		(x / 128) % 2 >= 1
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

local function pushbuf(cursor: Cursor, x: buffer)
	local len = buffer.len(x)
	tryRealloc(cursor, len)
	buffer.copy(cursor.Buf, cursor.Pos, x, 0, len)
	cursor.Pos += len
	pushvlq(cursor, len)
end

local function popbuf(cursor: Cursor)
	local len = popvlq(cursor)
	cursor.Pos -= len
	local buf = buffer.create(len)
	buffer.copy(buf, 0, cursor.Buf, cursor.Pos, len)
	return buf
end

local Squash = {}

Squash.cursor = newCursor
Squash.frombuffer = fromBuffer
Squash.tobuffer = toBuffer

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
function Squash.boolean(): SerDes<boolean, boolean?, boolean?, boolean?, boolean?, boolean?, boolean?, boolean?>
	return booleanCache
end

local uintCache = {}
local function uint(bytes: number): SerDes<number>
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

	local num: SerDes<number> = {
		ser = push,
		des = pop,
	}
	uintCache[bytes] = num
	return num
end
Squash.uint = uint

local intCache = {}
local function int(bytes: number): SerDes<number>
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

	local num: SerDes<number> = {
		ser = push,
		des = pop,
	}
	intCache[bytes] = num
	return num
end
Squash.int = int

local numberCache = {}
local function num(bytes: number): SerDes<number>
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

	local num: SerDes<number> = {
		ser = push,
		des = pop,
	}
	intCache[bytes] = num
	return num
end
Squash.number = num

local stringCache: SerDes<string> = {
	ser = pushstr,
	des = popstr,
}
local stringMeta = {
	__call = function(_)
		return stringCache
	end,
}
local str = setmetatable({}, stringMeta)
Squash.string = str

local bufCache: SerDes<buffer> = {
	ser = pushbuf,
	des = popbuf,
}
function Squash.buffer(): SerDes<buffer>
	return bufCache
end

local arrayCache = {}
local function array<T>(serdes: SerDes<T>): SerDes<{T}>
	if arrayCache[serdes] then
		return arrayCache[serdes]
	end

	local ser, des = serdes.ser, serdes.des

	local arr: SerDes<{T}> = {
		ser = function(cursor, xs)
			for _, x in xs do
				ser(cursor, x)
			end
			pushvlq(cursor, #xs)
		end,
		
		des = function(cursor)
			local len = popvlq(cursor)
			local xs = table.create(len)
			for i = len, 1, -1 do
				xs[i] = des(cursor)
			end
			return xs
		end,
	}

	arrayCache[serdes] = arr
	return arr
end
Squash.array = array

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

	return {
		ser = function(cursor, rec)
			for _, prop in properties do
				local ser = (schema :: any)[prop].ser
				local x = (rec :: any)[prop]
				ser(cursor, x)
			end
		end,

		des = function(cursor)
			local tab = {}
			for i = #properties, 1, -1 do
				local prop = properties[i]
				local des = (schema :: any)[prop].des
				tab[prop] = des(cursor)
			end
			return tab :: any
		end,
	}
end
Squash.record = record

local function map<K, V>(keySerDes: K, valueSerDes: V): SerDes<{[K]: V}>
	return {
		ser = function(cursor, map)
			local count = 0
			for k, v in map :: any do
				(valueSerDes :: any).ser(cursor, v)
				;(keySerDes :: any).ser(cursor, k)
				count += 1
			end
			pushvlq(cursor, count)
		end,

		des = function(cursor: Cursor)
			local map = {}

			local count = popvlq(cursor)
			for _ = 1, count do
				local key = (keySerDes :: any).des(cursor)
				local value = (valueSerDes :: any).des(cursor)
				map[key] = value
			end

			return map :: any
		end,
	}
end
Squash.map = map

local pushangle, popangle = uint(1).ser, uint(1).des
local angleCache: SerDes<number> = {
	ser = function(cursor, angle)
		pushangle(cursor, angle * 128 / math.pi)
	end,

	des = function(cursor)
		return popangle(cursor) * math.pi / 128
	end,
}
local function angle(): SerDes<number>
	return angleCache
end
Squash.angle = angle

local axesCache: SerDes<Axes> = {
	ser = function(cursor, axes)
		pushbool(cursor, axes.Back, axes.Bottom, axes.Front, axes.Left, axes.Right, axes.Top)
		pushbool(cursor, axes.X, axes.Y, axes.Z)
	end,

	des = function(cursor)
		local x, y, z = popbool(cursor)
		local back, bottom, front, left, right, top = popbool(cursor)
		return Axes.new(
			x and Enum.Axis.X,
			y and Enum.Axis.Y,
			z and Enum.Axis.Z,
			back and Enum.NormalId.Back,
			bottom and Enum.NormalId.Bottom,
			front and Enum.NormalId.Front,
			left and Enum.NormalId.Left,
			right and Enum.NormalId.Right,
			top and Enum.NormalId.Top,
		)
	end,
}
function Squash.Axes(): SerDes<Axes>
	return axesCache
end

local brickcolorCache: SerDes<BrickColor> = {
	ser = function(cursor, brickcolor)
		pushu2(cursor, brickcolor.Number)
	end,

	des = function(cursor)
		local number = popu2(cursor)
		return BrickColor.new(number)
	end,
}
function Squash.BrickColor(): SerDes<BrickColor>
	return brickcolorCache
end

local enums: { Enum } = {}
local enumIds: { [Enum]: number }
do
	local names = {}
	for enumName in pairs(Enum) do
		table.insert(names, enumName :: string)
	end
	table.sort(names)

	for i, enumName in names do
		local enum: Enum = (Enum :: any)[enumName]
		enums[i] = enum
		enumIds[enum] = i
	end
end
local function pushenum(cursor, enum)
	local id = enumIds[enum]
	pushvlq(cursor, id)
end
local function popenum(cursor)
	local id = popvlq(cursor)
	return enums[id]
end
local enumCache: SerDes<Enum> = {
	ser = pushenum,
	des = popenum,
}
function Squash.Enum()
	return enumCache
end

local enumItems = {}
do
	for _, enum in Enum:GetEnums() do
		local items = {}
		for _, item in enum:GetEnumItems() do
			items[item.Value] = item
		end
	
		enumItems[enum] = items 
	end
end

local enumItemCache = {}
local function enumitem(enum: Enum): SerDes<EnumItem>
	if enumItemCache[enum] then
		return enumItemCache[enum]
	end

	local sortedItems = enum:GetEnumItems()
	table.sort(sortedItems, function(a, b) return a.Value < b.Value end)

	local itemsToIds = {}
	local idsToItems = table.create(#sortedItems)
	for i, item in sortedItems do
		itemsToIds[item] = i
		idsToItems[i] = item
	end

	local item: SerDes<EnumItem> = {
		ser = function(cursor, item)
			pushvlq(cursor, itemsToIds[item])
		end,

		des = function(cursor)
			return idsToItems[popvlq(cursor)]
		end,
	}

	enumItemCache[enum] = item
	return item
end
Squash.EnumItem = enumitem

local catalogsorttype = enumitem(Enum.CatalogSortType)
local catalogsortaggregation = enumitem(Enum.CatalogSortAggregation)
local catalogcategoryfilter = enumitem(Enum.CatalogCategoryFilter)
local salestypefilter = enumitem(Enum.SalesTypeFilter)
local assettype = enumitem(Enum.AssetType)
local catalogueSearchParamsCache: SerDes<CatalogSearchParams> = {
	ser = function(cursor, params)
		pushbool(cursor, params.IncludeOffSale)
		pushu1(cursor, params.Limit)
		pushu4(cursor, params.MinPrice)
		pushu4(cursor, params.MaxPrice)
		pushstr(cursor, params.CreatorName)
		pushstr(cursor, params.SearchKeyword)
		catalogsorttype.ser(cursor, params.SortType)
		catalogsortaggregation.ser(cursor, params.SortAggregation)
		catalogcategoryfilter.ser(cursor, params.CategoryFilter)
		salestypefilter.ser(cursor, params.SalesTypeFilter)
		for _, assetType in params.AssetTypes do
			assettype.ser(cursor, assetType)
		end
		pushvlq(cursor, #params.AssetTypes)
	end,

	des = function(cursor)
		local params = CatalogSearchParams.new()
		local assetCount = popvlq(cursor)
		local assetTypes = table.create(assetCount)
		for i = assetCount, 1, -1 do
			assetTypes[i] = enumItems[Enum.AssetType][popu1(cursor)]
		end
		params.AssetTypes = assetTypes
		
		params.SalesTypesFilter = salestypefilter.des(cursor)
		params.CategoryFilter = catalogcategoryfilter.des(cursor)
		params.SortAggregation = catalogsortaggregation.des(cursor)
		params.SortType =  catalogsorttype.des(cursor)
		params.SearchKeyword = popstr(cursor)
		params.CreatorName = popstr(cursor)
		params.MaxPrice = popu4(cursor)
		params.MinPrice = popu4(cursor)
		params.Limit = popu1(cursor)
		params.IncludeOffSale = popbool(cursor)
	end,
}
function Squash.CatalogueSearchParams(): SerDes<CatalogSearchParams>
	return catalogueSearchParamsCache
end

local idToCFrame = {
	CFrame.Angles(0, 0, 0),
	CFrame.Angles(math.rad(90), 0, 0),
	CFrame.Angles(0, math.rad(180), math.rad(180)),
	CFrame.Angles(math.rad(-90), 0, 0),
	CFrame.Angles(0, math.rad(180), math.rad(90)),
	CFrame.Angles(0, math.rad(90), math.rad(90)),
	CFrame.Angles(0, 0, math.rad(90)),
	CFrame.Angles(0, math.rad(-90), math.rad(90)),
	CFrame.Angles(math.rad(-90), math.rad(-90), 0),
	CFrame.Angles(0, math.rad(-90), 0),
	CFrame.Angles(math.rad(90), math.rad(-90), 0),
	CFrame.Angles(0, math.rad(90), math.rad(180)),
	CFrame.Angles(0, math.rad(-90), math.rad(180)),
	CFrame.Angles(0, math.rad(180), math.rad(0)),
	CFrame.Angles(math.rad(-90), math.rad(-180), math.rad(0)),
	CFrame.Angles(0, math.rad(0), math.rad(180)),
	CFrame.Angles(math.rad(90), math.rad(180), math.rad(0)),
	CFrame.Angles(0, math.rad(0), math.rad(-90)),
	CFrame.Angles(0, math.rad(-90), math.rad(-90)),
	CFrame.Angles(0, math.rad(-180), math.rad(-90)),
	CFrame.Angles(0, math.rad(90), math.rad(-90)),
	CFrame.Angles(math.rad(90), math.rad(90), 0),
	CFrame.Angles(0, math.rad(90), 0),
	CFrame.Angles(math.rad(-90), math.rad(90), 0),
}
local cframeCache: SerDes<CFrame> = {
	ser = function(cursor, cframe)
		local specialId = table.find(idToCFrame, cframe.Rotation)
		if specialId then
			pushu1(cursor, specialId)
		else
			local axis, theta = cframe:ToAxisAngle()
			local rotaxis = axis * theta * 256
			pushi2(cursor, rotaxis.Z)
			pushi2(cursor, rotaxis.Y)
			pushi2(cursor, rotaxis.X)
			pushu1(cursor, 0)
		end
		local pos = cframe.Position
		pushf4(cursor, pos.Z)
		pushf4(cursor, pos.Y)
		pushf4(cursor, pos.X)
	end,

	des = function(cursor)
		local pos = Vector3.new(popf4(cursor), popf4(cursor), popf4(cursor))
		
		local specialId = popu1(cursor)
		if specialId ~= 0 then
			return idToCFrame[specialId] + pos
		end

		local rotaxis = Vector3.new(popi2(cursor), popi2(cursor), popi2(cursor)) / 256
		return CFrame.fromAxisAngle(rotaxis.Unit, rotaxis.Magnitude) + pos
	end,
}
function Squash.CFrame(): SerDes<CFrame>
	return cframeCache
end

local function pushcolor3(cursor, color3)
	pushu1(cursor, color3.B * 256)
	pushu1(cursor, color3.G * 256)
	pushu1(cursor, color3.R * 256)
end
local function popcolor3(cursor)
	return Color3.new(popu1(cursor), popu1(cursor), popu1(cursor))
end
local color3Cache: SerDes<Color3> = {
	ser = pushcolor3,
	des = popcolor3,
}
function Squash.Color3(): SerDes<Color3>
	return color3Cache
end

local function pushcolorsequencekeypoint(cursor, keypoint)
	pushcolor3(cursor, keypoint.Value)
	pushu1(cursor, keypoint.Time * 256)
end
local function popcolorsequencekeypoint(cursor)
	return ColorSequenceKeypoint.new(
		popu8(cursor) / 256,
		popcolor3(cursor)
	)
end
local colorSequenceKeypointCache: SerDes<ColorSequenceKeypoint> = {
	ser = pushcolorsequencekeypoint,
	des = popcolorsequencekeypoint,
}
function Squash.ColorSequenceKeypoint(): SerDes<ColorSequenceKeypoint>
	return colorSequenceKeypointCache
end

local colorSequenceCache: SerDes<ColorSequence> = {
	ser = function(cursor, sequence)
		for _, keypoint in sequence.Keypoints do
			pushcolorsequencekeypoint(cursor, keypoint)
		end
		pushvlq(cursor, #sequence.Keypoints)
	end,

	des = function(cursor)
		local keypointCount = popvlq(cursor)
		local keypoints = table.create(keypointCount)
		for i = keypointCount, 1, -1 do
			keypoints[i] = popcolorsequencekeypoint(cursor)
		end
		return ColorSequence.new(keypoints)
	end,
}
function Squash.ColorSequence(): SerDes<ColorSequence>
	return colorSequenceCache
end

local dateTimeCache: SerDes<DateTime> = {
	ser = function(cursor, date)
		pushu6(cursor, date.UnixTimestampMillis)
	end,
	des = function(cursor)
		return DateTime.fromUnixTimestampMillis(popu6(cursor))
	end,
}
function Squash.DateTime(): SerDes<DateTime>
	return dateTimeCache
end

local dockWidgetPluginGuiInfoCache: SerDes<DockWidgetPluginGuiInfo> = {
	ser = function(cursor, info)
		pushbool(cursor, info.InitialEnabled, info.InitialEnabledShouldOverrideRestore)
		pushu2(cursor, info.FloatingYSize)
		pushu2(cursor, info.FloatingXSize)
		pushu2(cursor, info.MinHeight)
		pushu2(cursor, info.MinWidth)
	end,

	des = function(cursor)
		local minWidth = popu2(cursor)
		local minHeight = popu2(cursor)
		local xSize = popu2(cursor)
		local ySize = popu2(cursor)
		local initEnabled, override = popbool(cursor)

		return DockWidgetPluginGuiInfo.new(
			nil,
			initEnabled,
			override,
			xSize,
			ySize,
			minWidth,
			minHeight
		)
	end,
}
function Squash.DockWidgetPluginGuiInfo(): SerDes<DockWidgetPluginGuiInfo>
	return dockWidgetPluginGuiInfoCache
end

local facesCache: SerDes<Faces> = {
	ser = function(cursor, face)
		pushbool(cursor, face.Back, face.Bottom, face.Front, face.Left, face.Right, face.Top)
	end,

	des = function(cursor)
		local back, bottom, front, left, right, top = popbool(cursor)
		return Faces.new(back, bottom, front, left, right, top)
	end,
}
function Squash.Faces(): SerDes<Faces>
	return facesCache
end

local keyinterpolationmode = enumitem(Enum.KeyInterpolationMode)
local floatCurveKeyCache: SerDes<FloatCurveKey> = {
	ser = function(cursor, key)
		if key.Interpolation == Enum.KeyInterpolationMode.Cubic then
			pushf4(cursor, key.LeftTangent)
			pushf4(cursor, key.RightTangent)
		end

		keyinterpolationmode.ser(cursor, key.Interpolation)

		pushf4(cursor, key.Value)
		pushf4(cursor, key.Time)
	end,

	des = function(cursor)
		local key = FloatCurveKey.new(
			popf4(cursor),
			popf4(cursor),
			keyinterpolationmode.des(cursor) :: any,
		)
		if key.Interpolation == Enum.KeyInterpolationMode.Cubic then
			key.RightTangent = popf4(cursor)
			key.LeftTangent = popf4(cursor)
		end
		return key
	end,
}
function Squash.FloatCurveKey(): SerDes<FloatCurveKey>
	return floatCurveKeyCache
end

local fontweight = enumitem(Enum.FontWeight)
local fontstyle = enumitem(Enum.FontStyle)
local fontCache: SerDes<Font> = {
	ser = function(cursor, font)
		local family = string.match(font.Family, "rbxasset://fonts/families/(.+).json") or error(`Invalid font family {font.Family}`)
		pushstr(cursor, family)
		pushbool(cursor, font.Bold)
		fontweight.ser(cursor, font.Weight)
		fontstyle.ser(cursor, font.Style)
	end,

	des = function(cursor)
		local style = fontstyle.des(cursor) :: Enum.FontStyle
		local weight = fontstyle.des(cursor) :: Enum.FontWeight
		local bold = popbool(cursor)
		local family = popstr(cursor)
		local font = Font.new(`rbxasset://fonts/families/{family}.json`, weight, style)
		font.Bold = bold
		return font
	end,
}
function Squash.Font(): SerDes<Font>
	return fontCache
end

local numberRangeCache = {}
local function numberrange(serdes: SerDes<number>): SerDes<NumberRange>
	if numberRangeCache[serdes] then
		return numberRangeCache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local numrange: SerDes<NumberRange> = {
		ser = function(cursor, range)
			push(cursor, range.Max)
			push(cursor, range.Min)
		end,
	
		des = function(cursor)
			return NumberRange.new(pop(cursor), pop(cursor))
		end,
	}
	numberRangeCache[serdes] = numrange
	return numrange
end
Squash.NumberRange = numberrange

local numberSequenceKeypointCache = {}
local function numbersequencekeypoint(serdes: SerDes<number>): SerDes<NumberSequenceKeypoint>
	if numberSequenceKeypointCache[serdes] then
		return numberSequenceKeypointCache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local sequencekeypoint: SerDes<NumberSequenceKeypoint> = {
		ser = function(cursor, keypoint)
			push(cursor, keypoint.Value)
			push(cursor, keypoint.Envelope)
			pushu8(cursor, keypoint.Time * 255)
		end,

		des = function(cursor)
			local keypointTime = popu8(cursor) / 255
			local envelope = pop(cursor)
			local value = pop(cursor)
			return NumberSequenceKeypoint.new(keypointTime, value, envelope)
		end,
	}
	numberSequenceKeypointCache[serdes] = sequencekeypoint
	return sequencekeypoint
end
Squash.NumberSequenceEnvelope = numbersequencekeypoint

local numberSequenceCache = {}
local function numbersequence(serdes: SerDes<number>): SerDes<NumberSequence>
	if numberSequenceCache[serdes] then
		return numberSequenceCache[serdes]
	end

	local push, pop = numbersequencekeypoint(serdes).ser, numbersequencekeypoint(serdes).des

	local numsequence: SerDes<NumberSequence> = {
		ser = function(cursor, sequence)
			for _, keypoint in sequence.Keypoints do
				push(cursor, keypoint)
			end
			pushvlq(cursor, #sequence.Keypoints)
		end,

		des = function(cursor)
			local count = popvlq(cursor)
			local keypoints = table.create(count)
			for i = count,  1, -1 do
				keypoints[i] = pop(cursor)
			end
			return NumberSequence.new(keypoints)
		end,
	}

	numberSequenceCache[serdes] = numsequence
	return numsequence
end
Squash.NumberSequence = numbersequence

local raycastfiltertype = enumitem(Enum.RaycastFilterType)
--- Does not encode instance data at all.
local overlapParamsCache: SerDes<OverlapParams> = {
	ser = function(cursor, params)
		pushbool(cursor, params.BruteForceAllSlow, params.RespectCanCollide)
		pushu2(cursor, params.MaxParts)
		raycastfiltertype.ser(cursor, params.FilterType)
		pushstr(cursor, params.CollisionGroup)
	end,

	des = function(cursor)
		local params = OverlapParams.new()
		params.CollisionGroup = popstr(cursor)
		params.FilterType = raycastfiltertype.des(cursor) :: Enum.RaycastFilterType
		params.MaxParts = popu2(cursor)
		params.BruteForceAllSlow, params.RespectCanCollide = popbool(cursor)
		return params
	end,
}
function Squash.OverlapParams(): SerDes<OverlapParams>
	return overlapParamsCache
end

local raycastParamsCache: SerDes<RaycastParams> = {
	ser = function(cursor, params)
		pushbool(cursor, params.BruteForceAllSlow, params.RespectCanCollide, params.IgnoreWater)
		raycastfiltertype.ser(cursor, params.FilterType)
		pushstr(cursor, params.CollisionGroup)
	end,

	des = function(cursor)
		local params = RaycastParams.new()
		params.CollisionGroup = popstr(cursor)
		params.FilterType = raycastfiltertype.des(cursor) :: Enum.RaycastFilterType
		params.BruteForceAllSlow, params.RespectCanCollide, params.IgnoreWater = popbool(cursor)
		return params
	end,
}
function Squash.RaycastParams(): SerDes<RaycastParams>
	return raycastParamsCache
end

local vector3Cache = {}
local function vector3(serdes: SerDes<number>): SerDes<Vector3>
	if vector3Cache[serdes] then
		return vector3Cache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local vec: SerDes<Vector3> = {
		ser = function(cursor, vector3)
			push(cursor, vector3.Z)
			push(cursor, vector3.Y)
			push(cursor, vector3.X)
		end,

		des = function(cursor)
			return Vector3.new(pop(cursor), pop(cursor), pop(cursor))
		end,
	}
	vector3Cache[serdes] = vec
	return vec
end
Squash.Vector3 = vector3

local pathwaypointaction = enumitem(Enum.PathWaypointAction)
local pathWaypointCache = {}
local function pathwaypoint(serdes: SerDes<number>): SerDes<PathWaypoint>
	if pathWaypointCache[serdes] then
		return pathWaypointCache[serdes]
	end

	local push, pop = vector3(serdes).ser, vector3(serdes).des

	local path: SerDes<PathWaypoint> = {
		ser = function(cursor, waypoint)
			pushstr(cursor, waypoint.Label)
			pathwaypointaction.ser(cursor, waypoint.Action)
			push(cursor, waypoint.Position)
		end,

		des = function(cursor)
			return PathWaypoint.new(
				pop(cursor),
				pathwaypointaction.des(cursor) :: Enum.PathWaypointAction,
				popstr(cursor)
			)
		end,
	}
	pathWaypointCache[serdes] = path
	return path
end
Squash.PathWaypoint = pathwaypoint

local vector2Cache = {}
function Squash.Vector2(serdes: SerDes<number>): SerDes<Vector2>
	if vector2Cache[serdes] then
		return vector2Cache[serdes]
	end

	local ser, des = serdes.ser, serdes.des
	local vec2: SerDes<Vector2> = {
		ser = function(cursor, v)
			ser(cursor, v.X)
			ser(cursor, v.Y)
		end,
		
		des = function(cursor)
			local y, x = des(cursor), des(cursor)
			return Vector2.new(x, y)
		end,
	}

	vector2Cache[serdes] = vec2
	return vec2
end

return Squash