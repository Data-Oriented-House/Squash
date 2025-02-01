--!strict
--!native
--!optimize 2

--- An import of the [Redblox Buffit Cursor](https://github.com/red-blox/Util/blob/main/libs/Buffit/Buffit.luau) type for better cross-library interaction
export type Cursor = {
	Buf: buffer,
	Pos: number,
}

local function newcursor(size: number?, position: number?): Cursor
	return {
		Buf = buffer.create(size or 8), --? Chosen to not use too much space and not resize too quickly as a starting point
		Pos = position or 0,
	}
end

local function frombuffer(buf: buffer)
	return {
		Buf = buf,
		Pos = buffer.len(buf),
	}
end

local function tobuffer(cursor: Cursor): buffer
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
	x = if x < 0 then 256 ^ 3 + x else x
	tryRealloc(cursor, 3)
	buffer.writeu8(cursor.Buf, cursor.Pos, x)
	buffer.writeu16(cursor.Buf, cursor.Pos + 1, x // 256)
	cursor.Pos += 3
end

local function popi3(cursor: Cursor)
	cursor.Pos -= 3
	local x1 = buffer.readu8(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu16(cursor.Buf, cursor.Pos + 1)
	local x = x1 + x2 * 256
	return if x > 256 ^ 2 - 1 then x - 256 ^ 3 else x
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
	x = if x < 0 then 256 ^ 5 + x else x
	tryRealloc(cursor, 5)
	buffer.writei8(cursor.Buf, cursor.Pos, x)
	buffer.writei32(cursor.Buf, cursor.Pos + 1, x // 256)
	cursor.Pos += 5
end

local function popi5(cursor: Cursor)
	cursor.Pos -= 5
	local x1 = buffer.readi8(cursor.Buf, cursor.Pos)
	local x2 = buffer.readi32(cursor.Buf, cursor.Pos + 1)
	local x = x1 + x2 * 256
	return if x > 256 ^ 4 - 1 then x - 256 ^ 5 else x
end

local function pushi6(cursor: Cursor, x: number)
	x %= 256 ^ 6
	x = if x < 0 then 256 ^ 6 + x else x
	tryRealloc(cursor, 6)
	buffer.writei16(cursor.Buf, cursor.Pos, x)
	buffer.writei32(cursor.Buf, cursor.Pos + 2, x // 256 ^ 2)
	cursor.Pos += 6
end

local function popi6(cursor: Cursor)
	cursor.Pos -= 6
	local x1 = buffer.readi16(cursor.Buf, cursor.Pos)
	local x2 = buffer.readi32(cursor.Buf, cursor.Pos + 2)
	local x = x1 + x2 * 256 ^ 2
	return if x > 256 ^ 5 - 1 then x - 256 ^ 6 else x
end

local function pushi7(cursor: Cursor, x: number)
	x %= 256 ^ 7
	x = if x < 0 then 256 ^ 7 + x else x
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
	local x = x1 + x2 * 256 + x3 * 256 ^ 3
	return if x > 256 ^ 6 - 1 then x - 256 ^ 7 else x
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
	local x = x1 + x2 * 256 ^ 4
	return if x > 256 ^ 7 - 1 then x - 256 ^ 8 else x
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
		(if a then 1 else 0) +
		(if b then 2 else 0) +
		(if c then 4 else 0) +
		(if d then 8 else 0) +
		(if e then 16 else 0) +
		(if f then 32 else 0) +
		(if g then 64 else 0) +
		(if h then 128 else 0)
	)
end

local function popbool(cursor: Cursor): (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean)
	local x = popu1(cursor)
	return
		x % 2 >= 1,
		x % 4 >= 2,
		x % 8 >= 4,
		x % 16 >= 8,
		x % 32 >= 16,
		x % 64 >= 32,
		x % 128 >= 64,
		x % 256 >= 128
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
	x += b * 128 ^ 7

	error(`Not a valid vlq: {x} = {buffer.tostring(cursor.Buf)}`)
end

local function pushstr(cursor: Cursor, x: string, length: number?)
	local len = length or #x
	tryRealloc(cursor, len)
	buffer.writestring(cursor.Buf, cursor.Pos, x)
	cursor.Pos += len

	if not length then
		pushvlq(cursor, len)
	end
end

local function popstr(cursor: Cursor, length: number?)
	local len = length or popvlq(cursor)
	cursor.Pos -= len
	return buffer.readstring(cursor.Buf, cursor.Pos, len)
end

local function pushbuf(cursor: Cursor, x: buffer, length: number?)
	local len = length or buffer.len(x)
	tryRealloc(cursor, len)
	buffer.copy(cursor.Buf, cursor.Pos, x, 0, len)
	cursor.Pos += len

	if not length then
		pushvlq(cursor, len)
	end
end

local function popbuf(cursor: Cursor, length: number?)
	local len = length or popvlq(cursor)
	cursor.Pos -= len
	local buf = buffer.create(len)
	buffer.copy(buf, 0, cursor.Buf, cursor.Pos, len)
	return buf
end

local function printcursor(cursor: Cursor): ()
	local bytes = {string.byte(buffer.tostring(cursor.Buf), 1, -1)}
	local offset = 7
	for i = 1, cursor.Pos do
		local byte = bytes[i]
		local digits = if byte == 0 then 1 else math.ceil(math.log10(1 + byte))
		offset += digits + 1
	end

	local lastByte = bytes[cursor.Pos + 1]
	if lastByte then
		local lastDigits = if lastByte == 0 then 1 else math.ceil(math.log10(1 + lastByte))
		offset += lastDigits // 2
	end

	if #bytes == 0 or cursor.Pos == buffer.len(cursor.Buf) then
		table.insert(bytes, ' ' :: any)
	end

	print(`Pos: {cursor.Pos} / {buffer.len(cursor.Buf)}\nBuf: \{ {table.concat(bytes, ' ')} \}\n{string.rep(' ', offset)}^`)
end

local Squash = {}

Squash.print = printcursor
Squash.cursor = newcursor
Squash.frombuffer = frombuffer
Squash.tobuffer = tobuffer

export type SerDes<T...> = {
	ser: (cursor: Cursor, T...) -> (),
	des: (cursor: Cursor) -> T...,
}

function Squash.T<T>(x: SerDes<T>): T
	return x :: any
end

local booleanCache = {
	ser = pushbool,
	des = popbool,
}
function Squash.boolean()
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

local stringSerDes: SerDes<string> = {
	ser = pushstr,
	des = popstr,
}
local stringCache = {}
local stringMeta = {
	__call = function(_, length: number?): SerDes<string>
		if not length then
			return stringSerDes
		end

		if stringCache[length] then
			return stringCache[length]
		end

		local serdes: SerDes<string> = {
			ser = function(cursor, string)
				pushstr(cursor, string, length)
			end,

			des = function(cursor)
				return popstr(cursor, length)
			end,
		}
		stringCache[length] = serdes
		return serdes
	end,
}
local str = {}
function str.convert(str: string, inAlphabet: string, outAlphabet: string): string
	local sourceDigits = {}
	for i = 1, #inAlphabet do
		sourceDigits[string.byte(inAlphabet, i)] = i - 1
	end

	local targetDigits = {}
	for i = 1, #outAlphabet do
		targetDigits[i - 1] = string.byte(outAlphabet, i)
	end

	local inputDigits = {}
	for i = 1, #str do
		table.insert(inputDigits, sourceDigits[string.byte(str, i)])
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
function str.alphabet(source: string): string
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
str.binary = '01'
str.octal = '01234567'
str.decimal = '0123456789'
str.duodecimal = '0123456789AB'
str.hexadecimal = '0123456789ABCDEF'
local utf8Characters = table.create(256)
for i = 0, 255 do
	utf8Characters[i + 1] = string.char(i)
end
str.utf8 = table.concat(utf8Characters)
str.lower = 'abcdefghijklmnopqrstuvwxyz'
str.upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
str.letters = str.lower .. str.upper
str.punctuation = ' .,?!:;\'"-_'
str.english = str.letters .. str.punctuation
str.filepath = str.letters .. ':/'
str.datastore = ' !#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~'

local str = setmetatable(str, stringMeta)
Squash.string = str

local optCache = {}
function Squash.opt<T>(serdes: SerDes<T>): SerDes<T?>
	if optCache[serdes] then
		return optCache[serdes]
	end

	local optSerDes: SerDes<T?> = {
		ser = function(cursor, x)
			if x == nil then
				pushu1(cursor, 0)
			else
				serdes.ser(cursor, x)
				pushu1(cursor, 1)
			end
		end,

		des = function(cursor)
			if popu1(cursor) == 1 then
				return serdes.des(cursor)
			else
				return nil
			end
		end,
	}
	optCache[serdes] = optSerDes
	return optSerDes
end

local bufSerDes: SerDes<buffer> = {
	ser = pushbuf,
	des = popbuf,
}
local bufCache = {}
function Squash.buffer(length: number?): SerDes<buffer>
	if not length then
		return bufSerDes
	end

	if bufCache[length] then
		return bufCache[length]
	end

	local serdes: SerDes<buffer> = {
		ser = function(cursor, buf)
			pushbuf(cursor, buf, length)
		end,

		des = function(cursor)
			return popbuf(cursor, length)
		end,
	}
	bufCache[length] = serdes
	return serdes
end

local vlqCache: SerDes<number> = {
	ser = pushvlq,
	des = popvlq,
}
function Squash.vlq(): SerDes<number>
	return vlqCache
end

local arrayCache = {}
local function array<T>(serdes: SerDes<T>, length: number?): SerDes<{T}>
	local cached = arrayCache[serdes]
	local key = length or 0
	if cached then
		if cached[key] then
			return cached[key]
		end
	else
		cached = {}
		arrayCache[serdes] = cached
	end

	local push, pop = serdes.ser, serdes.des

	local arr: SerDes<{T}> = {
		ser = if length then function(cursor, xs)
			local push = push --? Store repeatedly-accessed Upvalue in local variable
			for i = 1, length do
				push(cursor, xs[i])
			end
		end else function(cursor, xs)
			local push = push --? Store repeatedly-accessed Upvalue in local variable
			for _, x in xs do
				push(cursor, x)
			end
			pushvlq(cursor, #xs)
		end,

		des = function(cursor)
			local pop = pop --? Store repeatedly-accessed Upvalue in local variable
			local len = length or popvlq(cursor)
			local xs = table.create(len)
			for i = len, 1, -1 do
				xs[i] = pop(cursor)
			end
			return xs
		end,
	}

	cached[key] = arr
	return arr
end
Squash.array = array

function Squash.tuple<T...>(...: T...): SerDes<T...>
	local serdesargs: { any } = { ... }
	local count = #serdesargs
	if count == 1 then
		return serdesargs[1]
	end

	local tuple: SerDes<T...> = {
		ser = function(cursor, ...)
			for i, x in { ... } :: { any } do
				serdesargs[i].ser(cursor, x)
			end
		end,

		des = function(cursor)
			local xs = table.create(count)
			for i = count, 1, -1 do
				xs[i] = serdesargs[i].des(cursor)
			end
			return table.unpack(xs)
		end,
	}

	return tuple
end

local function record<T>(schema: T & {}): SerDes<T>
	local boolProperties = {}
	local properties = {}
	for prop, val in schema :: any do
		if type(prop) == 'string' then
			if val == booleanCache then
				table.insert(boolProperties, prop)
			else
				table.insert(properties, prop)
			end
		end
	end

	table.sort(properties)
	table.insert(properties, (schema :: any)[true])
	table.insert(properties, (schema :: any)[false])

	local boolCount = #boolProperties
	if boolCount > 0 then
		table.sort(boolProperties)
	end

	return {
		ser = if boolCount == 0 then function(cursor, rec)
			for _, prop in properties do
				local ser = (schema :: any)[prop].ser
				local x = (rec :: any)[prop]
				ser(cursor, x)
			end
		end else function(cursor, rec)
			for i = 0, boolCount // 8 do
				local j = 1 + i * 8
				pushbool(cursor,
					(rec :: any)[boolProperties[j + 0]], -- tab[nil] = nil
					(rec :: any)[boolProperties[j + 1]],
					(rec :: any)[boolProperties[j + 2]],
					(rec :: any)[boolProperties[j + 3]],
					(rec :: any)[boolProperties[j + 4]],
					(rec :: any)[boolProperties[j + 5]],
					(rec :: any)[boolProperties[j + 6]],
					(rec :: any)[boolProperties[j + 7]]
				)
			end

			for _, prop in properties do
				local ser = (schema :: any)[prop].ser
				local x = (rec :: any)[prop]
				ser(cursor, x)
			end
		end,

		des = if boolCount == 0 then function(cursor)
			local tab = {}
			for i = #properties, 1, -1 do
				local prop = properties[i]
				local des = (schema :: any)[prop].des
				tab[prop] = des(cursor)
			end
			return tab :: any
		end else function(cursor)
			local tab = {}
			for i = #properties, 1, -1 do
				local prop = properties[i]
				local des = (schema :: any)[prop].des
				tab[prop] = des(cursor)
			end

			do
				local i = boolCount // 8
				local j = 1 + i * 8
				local k = boolCount % 8
				local b0, b1, b2, b3, b4, b5, b6, b7 = popbool(cursor)
				if k == 1 then
					tab[boolProperties[j + 0]] = b0
				elseif k == 2 then
					tab[boolProperties[j + 0]] = b0
					tab[boolProperties[j + 1]] = b1
				elseif k == 3 then
					tab[boolProperties[j + 0]] = b0
					tab[boolProperties[j + 1]] = b1
					tab[boolProperties[j + 2]] = b2
				elseif k == 4 then
					tab[boolProperties[j + 0]] = b0
					tab[boolProperties[j + 1]] = b1
					tab[boolProperties[j + 2]] = b2
					tab[boolProperties[j + 3]] = b3
				elseif k == 5 then
					tab[boolProperties[j + 0]] = b0
					tab[boolProperties[j + 1]] = b1
					tab[boolProperties[j + 2]] = b2
					tab[boolProperties[j + 3]] = b3
					tab[boolProperties[j + 4]] = b4
				elseif k == 6 then
					tab[boolProperties[j + 0]] = b0
					tab[boolProperties[j + 1]] = b1
					tab[boolProperties[j + 2]] = b2
					tab[boolProperties[j + 3]] = b3
					tab[boolProperties[j + 4]] = b4
					tab[boolProperties[j + 5]] = b5
				elseif k == 7 then
					tab[boolProperties[j + 0]] = b0
					tab[boolProperties[j + 1]] = b1
					tab[boolProperties[j + 2]] = b2
					tab[boolProperties[j + 3]] = b3
					tab[boolProperties[j + 4]] = b4
					tab[boolProperties[j + 5]] = b5
					tab[boolProperties[j + 6]] = b6
				else
					tab[boolProperties[j + 0]] = b0
					tab[boolProperties[j + 1]] = b1
					tab[boolProperties[j + 2]] = b2
					tab[boolProperties[j + 3]] = b3
					tab[boolProperties[j + 4]] = b4
					tab[boolProperties[j + 5]] = b5
					tab[boolProperties[j + 6]] = b6
					tab[boolProperties[j + 7]] = b7
				end
			end

			for i = boolCount // 8 - 1, 0, -1 do
				local j = 1 + i * 8
				local prop0 = boolProperties[j + 0]
				local prop1 = boolProperties[j + 1]
				local prop2 = boolProperties[j + 2]
				local prop3 = boolProperties[j + 3]
				local prop4 = boolProperties[j + 4]
				local prop5 = boolProperties[j + 5]
				local prop6 = boolProperties[j + 6]
				local prop7 = boolProperties[j + 7]
				tab[prop0], tab[prop1], tab[prop2], tab[prop3], tab[prop4], tab[prop5], tab[prop6], tab[prop7] = popbool(cursor)
			end

			return tab :: any
		end,
	}
end
Squash.record = record

local function map<K, V>(keySerDes: SerDes<K>, valueSerDes: SerDes<V>): SerDes<{[K]: V}>
	return {
		ser = function(cursor, map)
			local size = 0
			for k, v in map :: any do
				(valueSerDes :: any).ser(cursor, v)
				;(keySerDes :: any).ser(cursor, k)
				size += 1
			end
			pushvlq(cursor, size)
		end,

		des = function(cursor)
			local map = {}

			local size = popvlq(cursor)
			for _ = 1, size do
				local key = (keySerDes :: any).des(cursor)
				local value = (valueSerDes :: any).des(cursor)
				map[key] = value
			end

			return map :: any
		end,
	}
end
Squash.map = map

local function literal(...: any): SerDes<any>
	local literals = { ... }
	local lookup = {}

	for i, literal in literals do
		lookup[literal] = i - 1
	end

	return {
		ser = function(cursor, literal)
			pushu1(cursor, lookup[literal])
		end,

		des = function(cursor)
			return literals[popu1(cursor) + 1]
		end,
	}
end
Squash.literal = literal

local function tableserdes(schema: { [string]: SerDes<any> }): SerDes<any>
	local typemap = {}

	for key, serdes in schema do
		table.insert(typemap, key)
	end

	return {
		ser = function(cursor, tab)
			local size = 0
			for k, v in tab :: any do
				local vtype = typeof(v)
				local vserdes = schema[vtype]
				if not vserdes then
					continue
				end

				local ktype = typeof(k)
				local kserdes = schema[ktype]
				if not kserdes then
					continue
				end

				vserdes.ser(cursor, v)
				local vid = table.find(typemap, vtype) or error(``)
				pushu1(cursor, vid - 1)

				kserdes.ser(cursor, k)
				local kid = table.find(typemap, ktype) or error(``)
				pushu1(cursor, kid - 1)

				size += 1
			end

			pushvlq(cursor, size)
		end,

		des = function(cursor)
			local tab = {}
			local size = popvlq(cursor)
			for _ = 1, size do
				local kid = popu1(cursor) + 1
				local ktype = typemap[kid]
				local kserdes = schema[ktype]
				local k = kserdes.des(cursor)

				local vid = popu1(cursor) + 1
				local vtype = typemap[vid]
				local vserdes = schema[vtype]
				local v = vserdes.des(cursor)

				tab[k] = v
			end
			return tab
		end,
	}
end
Squash.table = tableserdes

local axesCache: SerDes<Axes> = {
	ser = function(cursor, axes)
		pushbool(cursor, axes.Back, axes.Bottom, axes.Front, axes.Left, axes.Right, axes.Top)
		pushbool(cursor, axes.X, axes.Y, axes.Z)
	end,

	des = function(cursor)
		local x, y, z = popbool(cursor)
		local back, bottom, front, left, right, top = popbool(cursor)
		return Axes.new(
			x and Enum.Axis.X :: any,
			y and Enum.Axis.Y :: any,
			z and Enum.Axis.Z :: any,
			back and Enum.NormalId.Back :: any,
			bottom and Enum.NormalId.Bottom :: any,
			front and Enum.NormalId.Front :: any,
			left and Enum.NormalId.Left :: any,
			right and Enum.NormalId.Right :: any,
			top and Enum.NormalId.Top :: any
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
			local itemId = popvlq(cursor)
			return idsToItems[itemId]
		end,
	}

	enumItemCache[enum] = item
	return item
end
Squash.EnumItem = enumitem

local catalogueSearchParamsCache: SerDes<CatalogSearchParams> = {
	ser = function(cursor, params)
		pushbool(cursor, params.IncludeOffSale)
		pushu1(cursor, params.Limit)
		pushu4(cursor, params.MinPrice)
		pushu4(cursor, params.MaxPrice)
		pushstr(cursor, params.CreatorName)
		pushstr(cursor, params.SearchKeyword)
		enumitem(Enum.CatalogSortType).ser(cursor, params.SortType)
		enumitem(Enum.CatalogSortAggregation).ser(cursor, params.SortAggregation)
		enumitem(Enum.CatalogCategoryFilter).ser(cursor, params.CategoryFilter)
		enumitem(Enum.SalesTypeFilter).ser(cursor, params.SalesTypeFilter)
		for _, assetType in params.AssetTypes do
			enumitem(Enum.AssetType).ser(cursor, assetType)
		end
		pushvlq(cursor, #params.AssetTypes)
	end,

	des = function(cursor)
		local params = CatalogSearchParams.new()
		local assetCount = popvlq(cursor)
		local assetTypes = table.create(assetCount)
		for i = assetCount, 1, -1 do
			assetTypes[i] = enumitem(Enum.AssetType).des(cursor) :: Enum.AssetType
		end
		params.AssetTypes = assetTypes

		params.SalesTypesFilter = enumitem(Enum.SalesTypeFilter).des(cursor)
		params.CategoryFilter = enumitem(Enum.CatalogCategoryFilter).des(cursor) :: Enum.CatalogCategoryFilter
		params.SortAggregation = enumitem(Enum.CatalogSortAggregation).des(cursor)
		params.SortType = enumitem(Enum.CatalogSortType).des(cursor) :: Enum.CatalogSortType
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

local function cframeLookupEntries()
	return {
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
end

local function cframeSpecialCaseLookup(entries: { CFrame })
	local lookup = {}

	for i, v in entries do
		lookup[Vector3.new(v:ToOrientation())] = i
	end

	return lookup
end

local idToRotation
local rotationToId
local function rotser(cursor, cframe)
	--? Not defined outside so pure Luau users don't suffer errors
	idToRotation = idToRotation or cframeLookupEntries()
	rotationToId = rotationToId or cframeSpecialCaseLookup(idToRotation)

	local specialId = rotationToId[Vector3.new(cframe:ToOrientation())]
	if specialId then
		pushu1(cursor, specialId)
	else
		local axis, theta = cframe:ToAxisAngle()
		axis *= math.sin(theta / 2)
		pushu2(cursor, (axis.Z + 1) * (65535 / 2))
		pushu2(cursor, (axis.Y + 1) * (65535 / 2))
		pushu2(cursor, (axis.X + 1) * (65535 / 2))
		pushu1(cursor, 0)
	end
end

local function rotdes(cursor)
	local specialId = popu1(cursor)
	if specialId ~= 0 then
		return idToRotation[specialId]
	end

	local qx = popu2(cursor) * (2 / 65535) - 1
	local qy = popu2(cursor) * (2 / 65535) - 1
	local qz = popu2(cursor) * (2 / 65535) - 1
	local qw = math.sqrt(1 - qx * qx - qy * qy - qz * qz)
	return CFrame.new(0, 0, 0, qx, qy, qz, qw)
end

local rotationCache: SerDes<CFrame> = {
	ser = rotser,
	des = rotdes,
}
function Squash.rotation()
	return rotationCache
end

local cframeCache = {}
local function cframe(positionSerDes: SerDes<number>): SerDes<CFrame>
	if cframeCache[positionSerDes] then
		return cframeCache[positionSerDes]
	end

	local push, pop = positionSerDes.ser, positionSerDes.des

	local cframeserdes: SerDes<CFrame> = {
		ser = function(cursor, cframe)
			rotser(cursor, cframe)

			local pos = cframe.Position
			push(cursor, pos.Z)
			push(cursor, pos.Y)
			push(cursor, pos.X)
		end,

		des = function(cursor)
			local x, y, z = pop(cursor), pop(cursor), pop(cursor)
			local rotation = rotdes(cursor)
			return rotation + Vector3.new(x, y, z)
		end,
	}
	cframeCache[positionSerDes] = cframeserdes
	return cframeserdes
end
Squash.CFrame = cframe

local function pushcolor3(cursor, color3)
	pushu1(cursor, color3.B * 255)
	pushu1(cursor, color3.G * 255)
	pushu1(cursor, color3.R * 255)
end
local function popcolor3(cursor)
	return Color3.fromRGB(popu1(cursor), popu1(cursor), popu1(cursor))
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
	pushu1(cursor, keypoint.Time * 255)
end
local function popcolorsequencekeypoint(cursor)
	return ColorSequenceKeypoint.new(
		popu1(cursor) / 255,
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

local facesCache: SerDes<Faces> = {
	ser = function(cursor, face)
		pushbool(cursor, face.Back, face.Bottom, face.Front, face.Left, face.Right, face.Top)
	end,

	des = function(cursor)
		local back, bottom, front, left, right, top = popbool(cursor)
		return Faces.new(
			back and Enum.NormalId.Back :: any,
			bottom and Enum.NormalId.Bottom :: any,
			front and Enum.NormalId.Front :: any,
			left and Enum.NormalId.Left :: any,
			right and Enum.NormalId.Right :: any,
			top and Enum.NormalId.Top :: any
		)
	end,
}
function Squash.Faces(): SerDes<Faces>
	return facesCache
end

local floatCurveKeyCache: SerDes<FloatCurveKey> = {
	ser = function(cursor, key)
		enumitem(Enum.KeyInterpolationMode).ser(cursor, key.Interpolation)
		pushf4(cursor, key.Value)
		pushf4(cursor, key.Time)
	end,

	des = function(cursor)
		return FloatCurveKey.new(
			popf4(cursor),
			popf4(cursor),
			enumitem(Enum.KeyInterpolationMode).des(cursor) :: any
		)
	end,
}
function Squash.FloatCurveKey(): SerDes<FloatCurveKey>
	return floatCurveKeyCache
end

local fontCache: SerDes<Font> = {
	ser = function(cursor, font)
		local family = string.match(font.Family, "rbxasset://fonts/families/(.+).json") or error(`Invalid font family {font.Family}`)
		pushstr(cursor, family)
		pushbool(cursor, font.Bold)
		enumitem(Enum.FontWeight).ser(cursor, font.Weight)
		enumitem(Enum.FontStyle).ser(cursor, font.Style)
	end,

	des = function(cursor)
		local style = enumitem(Enum.FontStyle).des(cursor) :: Enum.FontStyle
		local weight = enumitem(Enum.FontWeight).des(cursor) :: Enum.FontWeight
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
Squash.NumberSequenceKeypoint = numbersequencekeypoint

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

--- Does not encode instance data at all.
local overlapParamsCache: SerDes<OverlapParams> = {
	ser = function(cursor, params)
		pushbool(cursor, params.BruteForceAllSlow, params.RespectCanCollide)
		pushu2(cursor, params.MaxParts)
		enumitem(Enum.RaycastFilterType).ser(cursor, params.FilterType)
		pushstr(cursor, params.CollisionGroup)
	end,

	des = function(cursor)
		local params = OverlapParams.new()
		params.CollisionGroup = popstr(cursor)
		params.FilterType = enumitem(Enum.RaycastFilterType).des(cursor) :: Enum.RaycastFilterType
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
		enumitem(Enum.RaycastFilterType).ser(cursor, params.FilterType)
		pushstr(cursor, params.CollisionGroup)
	end,

	des = function(cursor)
		local params = RaycastParams.new()
		params.CollisionGroup = popstr(cursor)
		params.FilterType = enumitem(Enum.RaycastFilterType).des(cursor) :: Enum.RaycastFilterType
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

local pathWaypointCache = {}
local function pathwaypoint(serdes: SerDes<number>): SerDes<PathWaypoint>
	if pathWaypointCache[serdes] then
		return pathWaypointCache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local path: SerDes<PathWaypoint> = {
		ser = function(cursor, waypoint)
			pushstr(cursor, waypoint.Label)
			enumitem(Enum.PathWaypointAction).ser(cursor, waypoint.Action)
			push(cursor, waypoint.Position.Z)
			push(cursor, waypoint.Position.Y)
			push(cursor, waypoint.Position.X)
		end,

		des = function(cursor)
			return PathWaypoint.new(
				Vector3.new(pop(cursor), pop(cursor), pop(cursor)),
				enumitem(Enum.PathWaypointAction).des(cursor) :: Enum.PathWaypointAction,
				popstr(cursor)
			)
		end,
	}
	pathWaypointCache[serdes] = path
	return path
end
Squash.PathWaypoint = pathwaypoint

local physicalPropertiesCache: SerDes<PhysicalProperties> = {
	ser = function(cursor, props)
		pushf4(cursor, props.ElasticityWeight)
		pushf4(cursor, props.FrictionWeight)
		pushf4(cursor, props.Elasticity)
		pushf4(cursor, props.Friction)
		pushf4(cursor, props.Density)
	end,

	des = function(cursor)
		return PhysicalProperties.new(
			popf4(cursor),
			popf4(cursor),
			popf4(cursor),
			popf4(cursor),
			popf4(cursor)
		)
	end,
}
function Squash.PhysicalProperties(): SerDes<PhysicalProperties>
	return physicalPropertiesCache
end

local rayCache = {}
local function rayserdes(serdes: SerDes<number>): SerDes<Ray>
	if rayCache[serdes] then
		return rayCache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local raycached: SerDes<Ray> = {
		ser = function(cursor, ray)
			push(cursor, ray.Direction.Z)
			push(cursor, ray.Direction.Y)
			push(cursor, ray.Direction.X)
			push(cursor, ray.Origin.Z)
			push(cursor, ray.Origin.Y)
			push(cursor, ray.Origin.X)
		end,

		des = function(cursor)
			return Ray.new(
				Vector3.new(pop(cursor), pop(cursor), pop(cursor)),
				Vector3.new(pop(cursor), pop(cursor), pop(cursor))
			)
		end,
	}
	rayCache[serdes] = raycached
	return raycached
end
Squash.Ray = rayserdes

export type SquashRaycastResult = {
	Distance: number,
	Position: Vector3,
	Normal: Vector3,
	Material: Enum.Material,
}

local raycastResultCache = {}
function Squash.RaycastResult(serdes: SerDes<number>): { ser: (Cursor, RaycastResult) -> (), des: (Cursor) -> SquashRaycastResult }
	if raycastResultCache[serdes] then
		return raycastParamsCache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local raycastresult = {
		ser = function(cursor, result: RaycastResult)
			pushf4(cursor, result.Distance)
			push(cursor, result.Position.Z)
			push(cursor, result.Position.Y)
			push(cursor, result.Position.X)
			push(cursor, result.Normal.Z)
			push(cursor, result.Normal.Y)
			push(cursor, result.Normal.X)
			enumitem(Enum.Material).ser(cursor, result.Material)
		end,

		des = function(cursor)
			return {
				Material = enumitem(Enum.Material).des(cursor) :: any,
				Normal = Vector3.new(pop(cursor), pop(cursor), pop(cursor)),
				Position = Vector3.new(pop(cursor), pop(cursor), pop(cursor)),
				Distance = popf4(cursor),
				Instance = nil,
			} :: SquashRaycastResult
		end,
	}

	raycastResultCache[serdes] = raycastresult
	return raycastresult
end

local vector2Cache = {}
function Squash.Vector2(serdes: SerDes<number>): SerDes<Vector2>
	if vector2Cache[serdes] then
		return vector2Cache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local vec2: SerDes<Vector2> = {
		ser = function(cursor, v)
			push(cursor, v.Y)
			push(cursor, v.X)
		end,

		des = function(cursor)
			return Vector2.new(pop(cursor), pop(cursor))
		end,
	}

	vector2Cache[serdes] = vec2
	return vec2
end

local rectCache = {}
function Squash.Rect(serdes: SerDes<number>): SerDes<Rect>
	if rectCache[serdes] then
		return rectCache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local rectserdes: SerDes<Rect> = {
		ser = function(cursor, rect)
			push(cursor, rect.Max.Y)
			push(cursor, rect.Max.X)
			push(cursor, rect.Min.Y)
			push(cursor, rect.Min.X)
		end,

		des = function(cursor)
			return Rect.new(pop(cursor), pop(cursor), pop(cursor), pop(cursor))
		end,
	}
	rectCache[serdes] = rectserdes
	return rectserdes
end

local region3Cache = {}
function Squash.Region3(serdes: SerDes<number>): SerDes<Region3>
	if region3Cache[serdes] then
		return region3Cache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local reg: SerDes<Region3> = {
		ser = function(cursor, region)
			local size = region.Size
			push(cursor, size.Z)
			push(cursor, size.Y)
			push(cursor, size.X)
			local pos = region.CFrame.Position
			push(cursor, pos.Z)
			push(cursor, pos.Y)
			push(cursor, pos.X)
		end,

		des = function(cursor)
			local position = Vector3.new(pop(cursor), pop(cursor), pop(cursor))
			local size = 0.5 * Vector3.new(pop(cursor), pop(cursor), pop(cursor))
			return Region3.new(position - size, position + size)
		end,
	}
	region3Cache[serdes] = reg
	return reg
end

local region3int16Cache: SerDes<Region3int16> = {
	ser = function(cursor, region)
		local max = region.Max
		pushi2(cursor, max.Z)
		pushi2(cursor, max.Y)
		pushi2(cursor, max.X)
		local min = region.Min
		pushi2(cursor, min.Z)
		pushi2(cursor, min.Y)
		pushi2(cursor, min.X)
	end,

	des = function(cursor)
		local min = Vector3int16.new(popi2(cursor), popi2(cursor), popi2(cursor))
		local max = Vector3int16.new(popi2(cursor), popi2(cursor), popi2(cursor))
		return Region3int16.new(min, max)
	end,
}
function Squash.Region3int16()
	return region3int16Cache
end

local rotationCurveKeyCache = {}
function Squash.RotationCurveKey(positionSerDes: SerDes<number>): SerDes<RotationCurveKey>
	if rotationCurveKeyCache[positionSerDes] then
		return rotationCurveKeyCache[positionSerDes]
	end

	local push, pop = cframe(positionSerDes).ser, cframe(positionSerDes).des

	local rot: SerDes<RotationCurveKey> = {
		ser = function(cursor, key)
			enumitem(Enum.KeyInterpolationMode).ser(cursor, key.Interpolation)
			push(cursor, key.Value)
			pushf4(cursor, key.Time)
		end,

		des = function(cursor)
			return RotationCurveKey.new(
				popf4(cursor),
				pop(cursor),
				enumitem(Enum.KeyInterpolationMode).des(cursor) :: Enum.KeyInterpolationMode
			)
		end,
	}
	rotationCurveKeyCache[positionSerDes] = rot
	return rot
end

local tweenInfoCache: SerDes<TweenInfo> = {
	ser = function(cursor, info)
		pushf4(cursor, info.DelayTime)
		pushbool(cursor, info.Reverses)
		pushvlq(cursor, info.RepeatCount)
		enumitem(Enum.EasingDirection).ser(cursor, info.EasingDirection)
		enumitem(Enum.EasingStyle).ser(cursor, info.EasingStyle)
		pushf4(cursor, info.Time)
	end,

	des = function(cursor)
		return TweenInfo.new(
			popf4(cursor),
			enumitem(Enum.EasingStyle).des(cursor) :: Enum.EasingStyle,
			enumitem(Enum.EasingDirection).des(cursor) :: Enum.EasingDirection,
			popvlq(cursor),
			popbool(cursor),
			popf4(cursor)
		)
	end
}
function Squash.TweenInfo()
	return tweenInfoCache
end

local udimCache = {}
function Squash.UDim(serdes: SerDes<number>): SerDes<UDim>
	if udimCache[serdes] then
		return udimCache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local udim: SerDes<UDim> = {
		ser = function(cursor, u)
			push(cursor, u.Offset)
			push(cursor, u.Scale)
		end,

		des = function(cursor)
			return UDim.new(pop(cursor), pop(cursor))
		end,
	}

	udimCache[serdes] = udim
	return udim
end

local udim2Cache = {}
function Squash.UDim2(serdes: SerDes<number>): SerDes<UDim2>
	if udim2Cache[serdes] then
		return udim2Cache[serdes]
	end

	local push, pop = serdes.ser, serdes.des

	local udim2: SerDes<UDim2> = {
		ser = function(cursor, u)
			push(cursor, u.Y.Offset)
			push(cursor, u.Y.Scale)
			push(cursor, u.X.Offset)
			push(cursor, u.X.Scale)
		end,

		des = function(cursor)
			return UDim2.new(pop(cursor), pop(cursor), pop(cursor), pop(cursor))
		end,
	}

	udim2Cache[serdes] = udim2
	return udim2
end

local vector2int16Cache: SerDes<Vector2int16> = {
	ser = function(cursor, v)
		pushi2(cursor, v.Y)
		pushi2(cursor, v.X)
	end,

	des = function(cursor)
		return Vector2int16.new(popi2(cursor), popi2(cursor))
	end,
}
function Squash.Vector2int16(): SerDes<Vector2int16>
	return vector2int16Cache
end

local vector3int16Cache: SerDes<Vector3int16> = {
	ser = function(cursor, v)
		pushi2(cursor, v.Z)
		pushi2(cursor, v.Y)
		pushi2(cursor, v.X)
	end,

	des = function(cursor)
		return Vector3int16.new(popi2(cursor), popi2(cursor), popi2(cursor))
	end,
}
function Squash.Vector3int16(): SerDes<Vector3int16>
	return vector3int16Cache
end

return Squash