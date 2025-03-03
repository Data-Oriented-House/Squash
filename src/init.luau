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

local function tryrealloc(cursor: Cursor, bytes: number)
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
	buffer.writeu8(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 1
end

local function popu1(cursor: Cursor)
	cursor.Pos -= 1
	return buffer.readu8(cursor.Buf, cursor.Pos)
end

local function pushu2(cursor: Cursor, x: number)
	buffer.writeu16(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 2
end

local function popu2(cursor: Cursor)
	cursor.Pos -= 2
	return buffer.readu16(cursor.Buf, cursor.Pos)
end

local function pushu3(cursor: Cursor, x: number)
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
	buffer.writeu32(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 4
end

local function popu4(cursor: Cursor)
	cursor.Pos -= 4
	return buffer.readu32(cursor.Buf, cursor.Pos)
end

local function pushu5(cursor: Cursor, x: number)
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
	buffer.writei8(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 1
end

local function popi1(cursor: Cursor)
	cursor.Pos -= 1
	return buffer.readi8(cursor.Buf, cursor.Pos)
end

local function pushi2(cursor: Cursor, x: number)
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
	buffer.writef32(cursor.Buf, cursor.Pos, x)
	cursor.Pos += 4
end

local function popf4(cursor: Cursor)
	cursor.Pos -= 4
	return buffer.readf32(cursor.Buf, cursor.Pos)
end

local function pushf8(cursor: Cursor, x: number)
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

local function pushvlqrealloc(cursor: Cursor, x: number)
	local x0 = x // 128 ^ 0 % 128
	local x1 = x // 128 ^ 1 % 128
	local x2 = x // 128 ^ 2 % 128
	local x3 = x // 128 ^ 3 % 128
	local x4 = x // 128 ^ 4 % 128
	local x5 = x // 128 ^ 5 % 128
	local x6 = x // 128 ^ 6 % 128
	local x7 = x // 128 ^ 7 % 128

	if x7 ~= 0 then
		tryrealloc(cursor, 8)
		pushu8(cursor, x0 * 256 ^ 7 + x1 * 256 ^ 6 + x2 * 256 ^ 5 + x3 * 256 ^ 4 + x4 * 256 ^ 3 + x5 * 256 ^ 2 + x6 * 256 + x7 + 128)
	elseif x6 ~= 0 then
		tryrealloc(cursor, 7)
		pushu7(cursor, x0 * 256 ^ 6 + x1 * 256 ^ 5 + x2 * 256 ^ 4 + x3 * 256 ^ 3 + x4 * 256 ^ 2 + x5 * 256 + x6 + 128)
	elseif x5 ~= 0 then
		tryrealloc(cursor, 6)
		pushu6(cursor, x0 * 256 ^ 5 + x1 * 256 ^ 4 + x2 * 256 ^ 3 + x3 * 256 ^ 2 + x4 * 256 + x5 + 128)
	elseif x4 ~= 0 then
		tryrealloc(cursor, 5)
		pushu5(cursor, x0 * 256 ^ 4 + x1 * 256 ^ 3 + x2 * 256 ^ 2 + x3 * 256 + x4 + 128)
	elseif x3 ~= 0 then
		tryrealloc(cursor, 4)
		pushu4(cursor, x0 * 256 ^ 3 + x1 * 256 ^ 2 + x2 * 256 + x3 + 128)
	elseif x2 ~= 0 then
		tryrealloc(cursor, 3)
		pushu3(cursor, x0 * 256 ^ 2 + x1 * 256 + x2 + 128)
	elseif x1 ~= 0 then
		tryrealloc(cursor, 2)
		pushu2(cursor, x0 * 256 + x1 + 128)
	else
		tryrealloc(cursor, 1)
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
	buffer.writestring(cursor.Buf, cursor.Pos, x)
	cursor.Pos += len

	if not length then
		pushvlqrealloc(cursor, len)
	end
end

local function popstr(cursor: Cursor, length: number?)
	local len = length or popvlq(cursor)
	cursor.Pos -= len
	return buffer.readstring(cursor.Buf, cursor.Pos, len)
end

local function pushbuf(cursor: Cursor, x: buffer, length: number?)
	local len = length or buffer.len(x)
	buffer.copy(cursor.Buf, cursor.Pos, x, 0, len)
	cursor.Pos += len

	if not length then
		pushvlqrealloc(cursor, len)
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
Squash.tryrealloc = tryrealloc

export type SerDes<T...> = {
	ser: (cursor: Cursor, T...) -> (),
	des: (cursor: Cursor) -> T...,
}

function Squash.T<T>(x: SerDes<T>): T
	return x :: any
end

local function pushboolrealloc(cursor: Cursor, a, b, c, d, e, f, g, h)
	tryrealloc(cursor, 1)
	pushbool(cursor, a, b, c, d, e, f, g, h)
end
local booleanCache = {
	ser = pushboolrealloc,
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
		ser = function(cursor, x)
			tryrealloc(cursor, bytes)
			push(cursor, x)
		end,
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
		ser = function(cursor, x)
			tryrealloc(cursor, bytes)
			push(cursor, x)
		end,
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
		ser = function(cursor, x)
			tryrealloc(cursor, bytes)
			push(cursor, x)
		end,
		des = pop,
	}
	numberCache[bytes] = num
	return num
end
Squash.number = num

local stringSerDes: SerDes<string> = {
	ser = function(cursor, x)
		local len = #x
		tryrealloc(cursor, len)
		pushstr(cursor, x, len)
	end,
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
				tryrealloc(cursor, length)
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

local optMap = {}
local optCache = {}
function Squash.opt<T>(serdes: SerDes<T>): SerDes<T?>
	if optCache[serdes] then
		return optCache[serdes]
	end

	local optSerDes: SerDes<T?> = {
		ser = function(cursor, x)
			if x == nil then
				tryrealloc(cursor, 1)
				pushu1(cursor, 0)
			else
				serdes.ser(cursor, x)
				tryrealloc(cursor, 1)
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
	optMap[optSerDes] = serdes
	return optSerDes
end

local bufSerDes: SerDes<buffer> = {
	ser = function(cursor, x)
		tryrealloc(cursor, buffer.len(x))
		pushbuf(cursor, x)
	end,
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
			tryrealloc(cursor, length)
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
	ser = pushvlqrealloc,
	des = popvlq,
}
function Squash.vlq(): SerDes<number>
	return vlqCache
end

local arrayCache = {}

local function array<T>(serdes: SerDes<T>, length: number?, ignoreBitpacking: boolean?): SerDes<{T}>
	local cached = arrayCache[serdes]
	local key = 2 * (length or 0) + if ignoreBitpacking then 1 else 0
	if cached then
		if cached[key] then
			return cached[key]
		end
	else
		cached = {}
		arrayCache[serdes] = cached
	end

	if not ignoreBitpacking and serdes == booleanCache then
		local arr = {
			ser = function(cursor, xs: {boolean})
				local n = length or #xs
				local groups = 1 + n // 8
				for group = 0, groups - 1 do
					local base = group * 8
					pushbool(cursor,
						xs[base + 1],
						xs[base + 2],
						xs[base + 3],
						xs[base + 4],
						xs[base + 5],
						xs[base + 6],
						xs[base + 7],
						xs[base + 8]
					)
				end

				if not length then
					pushvlq(cursor, n)
				end
			end,
			des = function(cursor): {boolean}
				local n = length or popvlq(cursor)
				local groups = 1 + n // 8
				local result = {}

				for group = groups - 1, 0, -1 do
					local a, b, c, d, e, f, g, h = popbool(cursor)
					local base = group * 8
					result[base + 1] = a
					result[base + 2] = b
					result[base + 3] = c
					result[base + 4] = d
					result[base + 5] = e
					result[base + 6] = f
					result[base + 7] = g
					result[base + 8] = h
				end

				for i = n, #result do
					result[i] = nil
				end

				return result
			end,
		} :: any
		cached[key] = arr
		return arr
	elseif not ignoreBitpacking and optMap[serdes :: any] then
		local underlyingSerDes = optMap[serdes :: any]
		local arr = {
			ser = function(cursor, xs: {T?})
				local n = length or #xs
				for i = 1, n do
					if xs[i] ~= nil then
						underlyingSerDes.ser(cursor, xs[i] :: any)
					end
				end

				local groups = 1 + n // 8
				for group = 0, groups - 1 do
					local base = group * 8
					pushbool(cursor,
						xs[base + 1] ~= nil,
						xs[base + 2] ~= nil,
						xs[base + 3] ~= nil,
						xs[base + 4] ~= nil,
						xs[base + 5] ~= nil,
						xs[base + 6] ~= nil,
						xs[base + 7] ~= nil,
						xs[base + 8] ~= nil
					)
				end

				if not length then
					pushvlq(cursor, n)
				end
			end,
			des = function(cursor): {T?}
				local n = length or popvlq(cursor)
				local groups = 1 + n // 8
				local flags = {}

				for group = groups - 1, 0, -1 do
					local a, b, c, d, e, f, g, h = popbool(cursor)
					local base = group * 8
					flags[base + 1] = a
					flags[base + 2] = b
					flags[base + 3] = c
					flags[base + 4] = d
					flags[base + 5] = e
					flags[base + 6] = f
					flags[base + 7] = g
					flags[base + 8] = h
				end

				local result = {} :: any
				for i = n, 1, -1 do
					if flags[i] then
						result[i] = underlyingSerDes.des(cursor)
					end
				end
				return result
			end,
		} :: any
		cached[key] = arr
		return arr
	else
		local push, pop = serdes.ser, serdes.des
		local arr: SerDes<{T}> = {
			ser = if length then
				function(cursor, xs)
					local push = push
					for i = 1, length do
						push(cursor, xs[i])
					end
				end
			else
				function(cursor, xs)
					local push = push
					for _, x in xs do
						push(cursor, x)
					end
					pushvlq(cursor, #xs)
				end,

			des = function(cursor)
				local pop = pop
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
	local properties = {}
	local optProperties = {}
	local boolProperties = {}
	local optboolProperties = {}
	for prop, val in schema :: any do
		if type(prop) == 'string' then
			local optVal = optMap[val]
			if optVal == booleanCache then
				table.insert(optboolProperties, prop)
			elseif optVal then
				table.insert(optProperties, prop)
			elseif val == booleanCache then
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

	local optCount = #optProperties
	local optSerDes = {}
	if optCount > 0 then
		table.sort(optProperties)
		for i, prop in optProperties do
			optSerDes[i] = optMap[(schema :: any)[prop]]
		end
	end

	local optboolCount = #optboolProperties
	if optboolCount > 0 then
		table.sort(optboolProperties)
		table.move(optboolProperties, 1, #optboolProperties, #boolProperties + 1, boolProperties)
	end

	local flagCount = optCount + optboolCount
	local maxBoolCount = boolCount + optboolCount

	--[[
		Booleans+OptionalBooleans Optionals BooleanFlags+Flags Properties

		OptBoolCount = 16
		TFTNFTNF NTFNTNTF
		TTTFTTFT FTTFTFTT

		TFTFTFTF TTF
		TTFTFTTF TTFTFTTT
	]]

	return {
		ser = function(cursor, tab)
			local rec = tab :: any

			-- Bools .. OptBools

			-- OptBoolFlags .. OptFlags
			local optFlags = table.create(flagCount)
			do
				local bools = table.create(maxBoolCount)
				for i, prop in boolProperties do
					bools[i] = rec[prop]
				end
				for i, optProp in optboolProperties do
					local val = rec[optProp]
					if val ~= nil then
						table.insert(bools, val)
						optFlags[i] = true
					else
						optFlags[i] = false
					end
				end

				local boolBytes = #bools // 8
				tryRealloc(cursor, 1 + boolBytes)
				for i = 0, boolBytes do
					local j = i * 8
					pushbool(cursor,
						bools[j + 1], -- tab[nil] == nil
						bools[j + 2],
						bools[j + 3],
						bools[j + 4],
						bools[j + 5],
						bools[j + 6],
						bools[j + 7],
						bools[j + 8]
					)
				end
			end

			-- Opts & Flags
			do
				for i, prop in optProperties do
					local j = i + optboolCount
					local val = rec[prop]
					if val ~= nil then
						optSerDes[i].ser(cursor, val)
						optFlags[j] = true
					else
						optFlags[j] = false
					end
				end

				local flagBytes = flagCount // 8
				tryRealloc(cursor, 1 + flagBytes)
				for i = 0, flagBytes do
					local j = i * 8
					pushbool(cursor,
						optFlags[j + 1],
						optFlags[j + 2],
						optFlags[j + 3],
						optFlags[j + 4],
						optFlags[j + 5],
						optFlags[j + 6],
						optFlags[j + 7],
						optFlags[j + 8]
					)
				end
			end

			-- Props
			for _, prop in properties do
				local ser = (schema :: any)[prop].ser
				local x = rec[prop]
				ser(cursor, x)
			end
		end,

		des = function(cursor)
			local tab = {} :: any

			-- Props
			for i = #properties, 1, -1 do
				local prop = properties[i]
				local des = (schema :: any)[prop].des
				tab[prop] = des(cursor)
			end

			-- Flags & Opts
			local optFlags = table.create(flagCount)
			do
				local flagBytes = flagCount // 8
				do
					local j = flagBytes * 8
					local flagsOver = flagCount % 8
					if flagsOver > 0 then
						local b0, b1, b2, b3, b4, b5, b6 = popbool(cursor)
						optFlags[j + 1] = b0
						optFlags[j + 2] = (if flagsOver > 1 then b1 else nil) :: boolean
						optFlags[j + 3] = (if flagsOver > 2 then b2 else nil) :: boolean
						optFlags[j + 4] = (if flagsOver > 3 then b3 else nil) :: boolean
						optFlags[j + 5] = (if flagsOver > 4 then b4 else nil) :: boolean
						optFlags[j + 6] = (if flagsOver > 5 then b5 else nil) :: boolean
						optFlags[j + 7] = (if flagsOver > 6 then b6 else nil) :: boolean
					end
				end

				for i = flagBytes - 1, 0, -1 do
					local j = i * 8
					optFlags[j + 1], optFlags[j + 2], optFlags[j + 3], optFlags[j + 4], optFlags[j + 5], optFlags[j + 6], optFlags[j + 7], optFlags[j + 8] = popbool(cursor)
				end

				for i = optCount, 1, -1 do
					local j = i + optboolCount
					if optFlags[j] then
						local underlyingSerDes = optSerDes[i]
						tab[optProperties[i]] = underlyingSerDes.des(cursor)
					end
				end
			end

			-- Bools .. OptBools
			do

				local bools = table.create(maxBoolCount)

				local actualBoolCount = boolCount
				for i = 1, optboolCount do
					if optFlags[i] then
						actualBoolCount += 1
					end
				end

				local actualBoolBytes = actualBoolCount // 8
				do
					local j = actualBoolBytes * 8
					local boolsOver = actualBoolCount % 8
					if boolsOver > 0 then
						local b0, b1, b2, b3, b4, b5, b6 = popbool(cursor)
						bools[j + 1] = b0
						bools[j + 2] = (if boolsOver > 1 then b1 else nil) :: boolean
						bools[j + 3] = (if boolsOver > 2 then b2 else nil) :: boolean
						bools[j + 4] = (if boolsOver > 3 then b3 else nil) :: boolean
						bools[j + 5] = (if boolsOver > 4 then b4 else nil) :: boolean
						bools[j + 6] = (if boolsOver > 5 then b5 else nil) :: boolean
						bools[j + 7] = (if boolsOver > 6 then b6 else nil) :: boolean
					end
				end

				for i = actualBoolBytes - 1, 0, -1 do
					local j = i * 8
					bools[j + 1], bools[j + 2], bools[j + 3], bools[j + 4], bools[j + 5], bools[j + 6], bools[j + 7], bools[j + 8] = popbool(cursor)
				end

				for i = 1, boolCount do
					tab[boolProperties[i]] = bools[i]
				end

				local j = boolCount + 1
				for i = 1, optboolCount do
					if optFlags[i] then
						tab[optboolProperties[i]] = bools[j]
						j += 1
						if j > actualBoolCount then
							break
						end
					end
				end
			end

			return tab
		end,
	}
end
Squash.record = record

-- do
-- 	local T = Squash.T
-- 	local B = Squash.boolean()
-- 	local O = Squash.opt
-- 	local U = Squash.uint(1)

-- 	local s = {
-- 		a = T(B),
-- 		b = T(B),
-- 		c = T(B),
-- 		d = T(B),
-- 		e = T(B),
-- 		f = T(B),
-- 		g = T(B),
-- 		h = T(B),
-- 		i = T(B),

-- 		j = T(O(U)),
-- 		k = T(O(U)),
-- 		l = T(O(U)),
-- 		m = T(O(U)),
-- 		n = T(O(U)),
-- 		o = T(O(U)),
-- 		p = T(O(U)),
-- 		q = T(O(U)),
-- 		r = T(O(U)),

-- 		s = T(O(B)),
-- 		t = T(O(B)),
-- 		u = T(O(B)),
-- 		v = T(O(B)),
-- 		w = T(O(B)),
-- 		x = T(O(B)),
-- 		y = T(O(B)),
-- 		z = T(O(B)),
-- 		aa = T(O(B)),
-- 	}

-- 	local n, serdes, data = 1e4, Squash.record(s), {
-- 		a = true,
-- 		b = false,
-- 		c = true,
-- 		d = false,
-- 		e = true,
-- 		f = false,
-- 		g = true,
-- 		h = false,
-- 		i = true,

-- 		j = 1,
-- 		k = 2,
-- 		l = 3,
-- 		m = 4,
-- 		n = nil,
-- 		o = 6,
-- 		p = 7,
-- 		q = 8,
-- 		r = 9,

-- 		s = true,
-- 		t = false,
-- 		-- u = nil,
-- 		-- v = true,
-- 		-- w = false,
-- 		-- x = nil,
-- 		-- y = true,
-- 		-- z = false,
-- 		-- aa = nil,
-- 	}

-- 	do
-- 		local c = Squash.cursor()
-- 		serdes.ser(c, data)
-- 		Squash.print(c)
-- 		local b = Squash.tobuffer(c)
-- 		local c = Squash.frombuffer(b)
-- 		local t = serdes.des(c)

-- 		local ks = {}
-- 		for k in t do
-- 			table.insert(ks, k)
-- 		end
-- 		table.sort(ks)
-- 		for _, k in ks do
-- 			print(k, t[k])
-- 		end
-- 	end
-- end

local function map<K, V>(keySerDes: SerDes<K>, valueSerDes: SerDes<V>): SerDes<{[K]: V}>
	return {
		ser = function(cursor, map)
			local size = 0
			for k, v in map :: any do
				(valueSerDes :: any).ser(cursor, v)
				;(keySerDes :: any).ser(cursor, k)
				size += 1
			end
			pushvlqrealloc(cursor, size)
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
			tryrealloc(cursor, 1)
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
	local maptype = {}

	for key in schema do
		local i = #typemap + 1
		typemap[i] = key
		maptype[key] = i
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
				local vid = maptype[vtype] or error(``)
				tryrealloc(cursor, 1)
				pushu1(cursor, vid - 1)

				kserdes.ser(cursor, k)
				local kid = maptype[ktype] or error(``)
				tryrealloc(cursor, 1)
				pushu1(cursor, kid - 1)

				size += 1
			end

			pushvlqrealloc(cursor, size)
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
		tryrealloc(cursor, 2)
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
		tryrealloc(cursor, 2)
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
			pushvlqrealloc(cursor, itemsToIds[item])
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
		tryrealloc(cursor, 1 + 1 + 4 + 4 + #params.CreatorName + #params.SearchKeyword)
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
		pushvlqrealloc(cursor, #params.AssetTypes)
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
		tryrealloc(cursor, 1)
		pushu1(cursor, specialId)
	else
		local axis, theta = cframe:ToAxisAngle()
		axis *= math.sin(theta / 2)
		tryrealloc(cursor, 7)
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

	local pushrealloc, pop = positionSerDes.ser, positionSerDes.des

	local cframeserdes: SerDes<CFrame> = {
		ser = function(cursor, cframe)
			rotser(cursor, cframe)

			local pos = cframe.Position
			pushrealloc(cursor, pos.Z)
			pushrealloc(cursor, pos.Y)
			pushrealloc(cursor, pos.X)
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
	ser = function(cursor, x)
		tryrealloc(cursor, 3)
		pushcolor3(cursor, x)
	end,
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
	ser = function(cursor, x)
		tryrealloc(cursor, 4)
		pushcolorsequencekeypoint(cursor, x)
	end,
	des = popcolorsequencekeypoint,
}
function Squash.ColorSequenceKeypoint(): SerDes<ColorSequenceKeypoint>
	return colorSequenceKeypointCache
end

local colorSequenceCache: SerDes<ColorSequence> = {
	ser = function(cursor, sequence)
		tryrealloc(cursor, 4 * #sequence.Keypoints)
		for _, keypoint in sequence.Keypoints do
			pushcolorsequencekeypoint(cursor, keypoint)
		end
		pushvlqrealloc(cursor, #sequence.Keypoints)
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
		tryrealloc(cursor, 6)
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
		tryrealloc(cursor, 1)
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
		tryrealloc(cursor, 8)
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
		tryrealloc(cursor, #family + 1)
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local numrange: SerDes<NumberRange> = {
		ser = function(cursor, range)
			pushrealloc(cursor, range.Max)
			pushrealloc(cursor, range.Min)
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local sequencekeypoint: SerDes<NumberSequenceKeypoint> = {
		ser = function(cursor, keypoint)
			pushrealloc(cursor, keypoint.Value)
			pushrealloc(cursor, keypoint.Envelope)
			tryrealloc(cursor, 4)
			pushf4(cursor, keypoint.Time)
		end,

		des = function(cursor)
			local keypointTime = popf4(cursor)
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

	local pushrealloc, pop = numbersequencekeypoint(serdes).ser, numbersequencekeypoint(serdes).des

	local numsequence: SerDes<NumberSequence> = {
		ser = function(cursor, sequence)
			local pushrealloc = pushrealloc
			for _, keypoint in sequence.Keypoints do
				pushrealloc(cursor, keypoint)
			end
			pushvlqrealloc(cursor, #sequence.Keypoints)
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
		tryrealloc(cursor, 1 + 2 + #params.CollisionGroup)
		pushbool(cursor, params.BruteForceAllSlow, params.RespectCanCollide)
		pushu2(cursor, params.MaxParts)
		pushstr(cursor, params.CollisionGroup)
		enumitem(Enum.RaycastFilterType).ser(cursor, params.FilterType)
	end,

	des = function(cursor)
		local params = OverlapParams.new()
		params.FilterType = enumitem(Enum.RaycastFilterType).des(cursor) :: Enum.RaycastFilterType
		params.CollisionGroup = popstr(cursor)
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
		tryrealloc(cursor, 1 + #params.CollisionGroup)
		pushbool(cursor, params.BruteForceAllSlow, params.RespectCanCollide, params.IgnoreWater)
		pushstr(cursor, params.CollisionGroup)
		enumitem(Enum.RaycastFilterType).ser(cursor, params.FilterType)
	end,

	des = function(cursor)
		local params = RaycastParams.new()
		params.FilterType = enumitem(Enum.RaycastFilterType).des(cursor) :: Enum.RaycastFilterType
		params.CollisionGroup = popstr(cursor)
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local vec: SerDes<Vector3> = {
		ser = function(cursor, vector3)
			pushrealloc(cursor, vector3.Z)
			pushrealloc(cursor, vector3.Y)
			pushrealloc(cursor, vector3.X)
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local path: SerDes<PathWaypoint> = {
		ser = function(cursor, waypoint)
			tryrealloc(cursor, #waypoint.Label)
			pushstr(cursor, waypoint.Label)
			enumitem(Enum.PathWaypointAction).ser(cursor, waypoint.Action)
			pushrealloc(cursor, waypoint.Position.Z)
			pushrealloc(cursor, waypoint.Position.Y)
			pushrealloc(cursor, waypoint.Position.X)
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
		tryrealloc(cursor, 20)
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local raycached: SerDes<Ray> = {
		ser = function(cursor, ray)
			pushrealloc(cursor, ray.Direction.Z)
			pushrealloc(cursor, ray.Direction.Y)
			pushrealloc(cursor, ray.Direction.X)
			pushrealloc(cursor, ray.Origin.Z)
			pushrealloc(cursor, ray.Origin.Y)
			pushrealloc(cursor, ray.Origin.X)
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local raycastresult = {
		ser = function(cursor, result: RaycastResult)
			tryrealloc(cursor, 4)
			pushf4(cursor, result.Distance)
			pushrealloc(cursor, result.Position.Z)
			pushrealloc(cursor, result.Position.Y)
			pushrealloc(cursor, result.Position.X)
			pushrealloc(cursor, result.Normal.Z)
			pushrealloc(cursor, result.Normal.Y)
			pushrealloc(cursor, result.Normal.X)
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local vec2: SerDes<Vector2> = {
		ser = function(cursor, v)
			pushrealloc(cursor, v.Y)
			pushrealloc(cursor, v.X)
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local rectserdes: SerDes<Rect> = {
		ser = function(cursor, rect)
			pushrealloc(cursor, rect.Max.Y)
			pushrealloc(cursor, rect.Max.X)
			pushrealloc(cursor, rect.Min.Y)
			pushrealloc(cursor, rect.Min.X)
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local reg: SerDes<Region3> = {
		ser = function(cursor, region)
			local size = region.Size
			pushrealloc(cursor, size.Z)
			pushrealloc(cursor, size.Y)
			pushrealloc(cursor, size.X)
			local pos = region.CFrame.Position
			pushrealloc(cursor, pos.Z)
			pushrealloc(cursor, pos.Y)
			pushrealloc(cursor, pos.X)
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
		tryrealloc(cursor, 12)
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

	local pushrealloc, pop = cframe(positionSerDes).ser, cframe(positionSerDes).des

	local rot: SerDes<RotationCurveKey> = {
		ser = function(cursor, key)
			enumitem(Enum.KeyInterpolationMode).ser(cursor, key.Interpolation)
			pushrealloc(cursor, key.Value)
			tryrealloc(cursor, 4)
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
		tryrealloc(cursor, 9)
		pushf4(cursor, info.DelayTime)
		pushf4(cursor, info.Time)
		pushbool(cursor, info.Reverses)
		pushvlqrealloc(cursor, info.RepeatCount)
		enumitem(Enum.EasingDirection).ser(cursor, info.EasingDirection)
		enumitem(Enum.EasingStyle).ser(cursor, info.EasingStyle)
	end,

	des = function(cursor)
		local easing = enumitem(Enum.EasingStyle).des(cursor) :: Enum.EasingStyle
		local direction = enumitem(Enum.EasingDirection).des(cursor) :: Enum.EasingDirection
		local repeats = popvlq(cursor)
		local reverses = popbool(cursor)
		local duration = popf4(cursor)
		local delayTime = popf4(cursor)
		return TweenInfo.new(
			duration,
			easing,
			direction,
			repeats,
			reverses,
			delayTime
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local udim: SerDes<UDim> = {
		ser = function(cursor, u)
			pushrealloc(cursor, u.Offset)
			pushrealloc(cursor, u.Scale)
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

	local pushrealloc, pop = serdes.ser, serdes.des

	local udim2: SerDes<UDim2> = {
		ser = function(cursor, u)
			pushrealloc(cursor, u.Y.Offset)
			pushrealloc(cursor, u.Y.Scale)
			pushrealloc(cursor, u.X.Offset)
			pushrealloc(cursor, u.X.Scale)
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
		tryrealloc(cursor, 4)
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
		tryrealloc(cursor, 6)
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