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

local function pushi3(cursor, x)
	local x = if x >= 0 then x * 2 else -x * 2 - 1
	buffer.writeu8(cursor.Buf, cursor.Pos, x % 256)
	buffer.writeu16(cursor.Buf, cursor.Pos + 1, x // 256)
	cursor.Pos += 3
end

local function popi3(cursor)
	cursor.Pos -= 3
	local x1 = buffer.readu8 (cursor.Buf, cursor.Pos    )
	local x2 = buffer.readu16(cursor.Buf, cursor.Pos + 1)
	local x = x1 + x2 * 256
	return if x % 2 == 0 then x // 2 else -( (x + 1) // 2 )
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
	local x = if x >= 0 then x * 2 else -x * 2 - 1
	buffer.writeu8(cursor.Buf, cursor.Pos, x)
	buffer.writeu32(cursor.Buf, cursor.Pos + 1, x // 256)
	cursor.Pos += 5
end

local function popi5(cursor: Cursor)
	cursor.Pos -= 5
	local x1 = buffer.readu8(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu32(cursor.Buf, cursor.Pos + 1)
	local x = x1 + x2 * 256
	return if x % 2 == 0 then x // 2 else -( (x + 1) // 2 )
end

local function pushi6(cursor: Cursor, x: number)
	local x = if x >= 0 then x * 2 else -x * 2 - 1
	buffer.writeu16(cursor.Buf, cursor.Pos, x)
	buffer.writeu32(cursor.Buf, cursor.Pos + 2, x // 256 ^ 2)
	cursor.Pos += 6
end

local function popi6(cursor: Cursor)
	cursor.Pos -= 6
	local x1 = buffer.readu16(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu32(cursor.Buf, cursor.Pos + 2)
	local x = x1 + x2 * 256 ^ 2
	return if x % 2 == 0 then x // 2 else -( (x + 1) // 2 )
end

local function pushi7(cursor: Cursor, x: number)
	local x = if x >= 0 then x * 2 else -x * 2 - 1
	buffer.writeu8(cursor.Buf, cursor.Pos, x)
	buffer.writeu16(cursor.Buf, cursor.Pos + 1, x // 256)
	buffer.writeu32(cursor.Buf, cursor.Pos + 3, x // 256 ^ 3)
	cursor.Pos += 7
end

local function popi7(cursor: Cursor)
	cursor.Pos -= 7
	local x1 = buffer.readu8(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu16(cursor.Buf, cursor.Pos + 1)
	local x3 = buffer.readu32(cursor.Buf, cursor.Pos + 3)
	local x = x1 + x2 * 256 + x3 * 256 ^ 3
	return if x % 2 == 0 then x // 2 else -( (x + 1) // 2 )
end

local function pushi8(cursor: Cursor, x: number)
	local x = if x >= 0 then x * 2 else -x * 2 - 1
	buffer.writeu32(cursor.Buf, cursor.Pos, x)
	buffer.writeu32(cursor.Buf, cursor.Pos + 4, x // 256 ^ 4)
	cursor.Pos += 8
end

local function popi8(cursor: Cursor)
	cursor.Pos -= 8
	local x1 = buffer.readu32(cursor.Buf, cursor.Pos)
	local x2 = buffer.readu32(cursor.Buf, cursor.Pos + 4)
	local x = x1 + x2 * 256 ^ 4
	return if x % 2 == 0 then x // 2 else -( (x + 1) // 2 )
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

local function pushbool(
	cursor: Cursor,
	a: boolean,
	b: boolean?,
	c: boolean?,
	d: boolean?,
	e: boolean?,
	f: boolean?,
	g: boolean?,
	h: boolean?
)
	pushu1(
		cursor,
		(if a then 1 else 0)
			+ (if b then 2 else 0)
			+ (if c then 4 else 0)
			+ (if d then 8 else 0)
			+ (if e then 16 else 0)
			+ (if f then 32 else 0)
			+ (if g then 64 else 0)
			+ (if h then 128 else 0)
	)
end

local function popbool(cursor: Cursor): (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean)
	local x = popu1(cursor)
	return x % 2 >= 1, x % 4 >= 2, x % 8 >= 4, x % 16 >= 8, x % 32 >= 16, x % 64 >= 32, x % 128 >= 64, x % 256 >= 128
end

local pushvlqrealloc, popvlq
do
	local SHIFT32 = 2 ^ 32
	local SHIFT25 = 2 ^ 25
	local BASE    = 2 ^ 7

	function pushvlqrealloc(cursor: Cursor, x: number)
		local count = 1
		if     x >= 2 ^ 49 then count = 8
		elseif x >= 2 ^ 42 then count = 7
		elseif x >= 2 ^ 35 then count = 6
		elseif x >= 2 ^ 28 then count = 5
		elseif x >= 2 ^ 21 then count = 4
		elseif x >= 2 ^ 14 then count = 3
		elseif x >= 2 ^ 7 then count = 2
		end

		tryrealloc(cursor, count)

		local hi = x // SHIFT32
		local lo = x - hi * SHIFT32

		pushu1(cursor, lo % BASE)

		if count >= 2 then
			local prevHi = hi
			local rem    = prevHi % BASE
			local newLo  = rem * SHIFT25 + (lo // BASE)
			local newHi  = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count >= 3 then
			local prevHi = hi
			local rem    = prevHi % BASE
			local newLo  = rem * SHIFT25 + (lo // BASE)
			local newHi  = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count >= 4 then
			local prevHi = hi
			local rem    = prevHi % BASE
			local newLo  = rem * SHIFT25 + (lo // BASE)
			local newHi  = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count >= 5 then
			local prevHi = hi
			local rem    = prevHi % BASE
			local newLo  = rem * SHIFT25 + (lo // BASE)
			local newHi  = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count >= 6 then
			local prevHi = hi
			local rem    = prevHi % BASE
			local newLo  = rem * SHIFT25 + (lo // BASE)
			local newHi  = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count >= 7 then
			local prevHi = hi
			local rem    = prevHi % BASE
			local newLo  = rem * SHIFT25 + (lo // BASE)
			local newHi  = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count == 8 then
			local prevHi = hi
			local rem    = prevHi % BASE
			local newLo  = rem * SHIFT25 + (lo // BASE)
			pushu1(cursor, (newLo % BASE) + BASE)
		end
	end

	function popvlq(cursor: Cursor)
		local b1: number = popu1(cursor)
		local v1 = b1 % BASE
		if b1 < BASE then
			return v1
		end

		local b2 = popu1(cursor)
		local v2 = v1 * BASE + (b2 % BASE)
		if b2 < BASE then
			return v2
		end

		local b3 = popu1(cursor)
		local v3 = v2 * BASE + (b3 % BASE)
		if b3 < BASE then
			return v3
		end

		local b4 = popu1(cursor)
		local v4 = v3 * BASE + (b4 % BASE)
		if b4 < BASE then
			return v4
		end

		local b5 = popu1(cursor)
		local v5 = v4 * BASE + (b5 % BASE)
		if b5 < BASE then
			return v5
		end

		local b6 = popu1(cursor)
		local v6 = v5 * BASE + (b6 % BASE)
		if b6 < BASE then
			return v6
		end

		local b7 = popu1(cursor)
		local v7 = v6 * BASE + (b7 % BASE)
		if b7 < BASE then
			return v7
		end

		local b8 = popu1(cursor)
		local v8 = v7 * BASE + (b8 % BASE)
		return v8
	end
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
	local bytes = { string.byte(buffer.tostring(cursor.Buf), 1, -1) }
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

local booleanCache
do
	booleanCache = {
		ser = function(cursor: Cursor, a, b, c, d, e, f, g, h)
			tryrealloc(cursor, 1)
			pushbool(cursor, a, b, c, d, e, f, g, h)
		end,
		des = popbool,
	}
	function Squash.boolean()
		return booleanCache
	end
end

do
	local uintCache = {}
	function Squash.uint(bytes: number): SerDes<number>
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
end

do
	local intCache = {}
	function Squash.int(bytes: number): SerDes<number>
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
end

do
	local numberCache = {}
	function Squash.number(bytes: number): SerDes<number>
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
end

do
	local rangeCache = {}
	-- Encodes an integer in the interval [min, max] using uints with as few bytes as possible
	function Squash.range(min: number, max: number): SerDes<number>
		local hash = `{min}_{max}`
		local cached = rangeCache[hash]
		if cached then
			return cached
		end
		assert(min == min // 1 and max == max // 1 and min < max, 'min and max must be integers, and min < max')

		local push, pop, bytes
		local difference = max - min
		if difference < 256 ^ 1 then
			push, pop, bytes = pushu1, popu1, 1
		elseif difference < 256 ^ 2 then
			push, pop, bytes = pushu2, popu2, 2
		elseif difference < 256 ^ 3 then
			push, pop, bytes = pushu3, popu3, 3
		elseif difference < 256 ^ 4 then
			push, pop, bytes = pushu4, popu4, 4
		elseif difference < 256 ^ 5 then
			push, pop, bytes = pushu5, popu5, 5
		elseif difference < 256 ^ 6 then
			push, pop, bytes = pushu6, popu6, 6
		elseif difference < 256 ^ 7 then
			push, pop, bytes = pushu7, popu7, 7
		else
			push, pop, bytes = pushu8, popu8, 8
		end

		local range: SerDes<number> = {
			ser = function(cursor, x)
				tryrealloc(cursor, bytes)
				push(cursor, x - min)
			end,
			des = function(cursor)
				return pop(cursor) + min
			end,
		}
		rangeCache[hash] = range

		return range
	end
end

do
	local stringSerDes: SerDes<string> = {
		ser = function(cursor, x)
			local len = #x
			tryrealloc(cursor, len)
			pushstr(cursor, x)
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
end

local optMap
do
	optMap = {}
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
end

do
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
end

do
	local vlqCache: SerDes<number> = {
		ser = pushvlqrealloc,
		des = popvlq,
	}
	function Squash.vlq(): SerDes<number>
		return vlqCache
	end
end

export type Length = number | SerDes<number>

local function serbitarr(cursor: Cursor, bits: { boolean }, length: number?)
	local bitCount = length or #bits
	if bitCount == 0 then
		return
	end

	local bitsOver = bitCount % 8

	local bytesInBits = bitCount - bitsOver
	for i = 0, bytesInBits - 1, 8 do
		pushbool(cursor, bits[i + 1], bits[i + 2], bits[i + 3], bits[i + 4], bits[i + 5], bits[i + 6], bits[i + 7], bits[i + 8])
	end

	do
		local i = bytesInBits
		if bitsOver == 1 then
			pushbool(cursor, bits[i + 1])
		elseif bitsOver == 2 then
			pushbool(cursor, bits[i + 1], bits[i + 2])
		elseif bitsOver == 3 then
			pushbool(cursor, bits[i + 1], bits[i + 2], bits[i + 3])
		elseif bitsOver == 4 then
			pushbool(cursor, bits[i + 1], bits[i + 2], bits[i + 3], bits[i + 4])
		elseif bitsOver == 5 then
			pushbool(cursor, bits[i + 1], bits[i + 2], bits[i + 3], bits[i + 4], bits[i + 5])
		elseif bitsOver == 6 then
			pushbool(cursor, bits[i + 1], bits[i + 2], bits[i + 3], bits[i + 4], bits[i + 5], bits[i + 6])
		elseif bitsOver == 7 then
			pushbool(cursor, bits[i + 1], bits[i + 2], bits[i + 3], bits[i + 4], bits[i + 5], bits[i + 6], bits[i + 7])
		end
	end
end
local function desbitarr(cursor: Cursor, bitcount: number): { boolean }
	if bitcount == 0 then
		return {}
	end

	local arr = table.create(bitcount)

	local bytes = bitcount // 8
	do
		local j = bytes * 8
		local bitsOver = bitcount % 8
		if bitsOver > 0 then
			local b0, b1, b2, b3, b4, b5, b6 = popbool(cursor)
			arr[j + 1] = b0
			arr[j + 2] = (if bitsOver > 1 then b1 else nil) :: boolean
			arr[j + 3] = (if bitsOver > 2 then b2 else nil) :: boolean
			arr[j + 4] = (if bitsOver > 3 then b3 else nil) :: boolean
			arr[j + 5] = (if bitsOver > 4 then b4 else nil) :: boolean
			arr[j + 6] = (if bitsOver > 5 then b5 else nil) :: boolean
			arr[j + 7] = (if bitsOver > 6 then b6 else nil) :: boolean
		end
	end

	for i = bytes - 1, 0, -1 do
		local j = i * 8
		arr[j + 1], arr[j + 2], arr[j + 3], arr[j + 4], arr[j + 5], arr[j + 6], arr[j + 7], arr[j + 8] = popbool(cursor)
	end

	return arr
end
do
	local arrayCache = {}
	function Squash.array<T>(serdes: SerDes<T>, length: Length?): SerDes<{ T }>
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

		if serdes == booleanCache then
			local arr: SerDes<{ boolean }> = {
				ser = function(cursor, xs)
					local n = if type(length) == 'number' then length else #xs
					serbitarr(cursor, xs, n)
					if not length then
						pushvlqrealloc(cursor, n)
					elseif type(length) ~= 'number' then
						length.ser(cursor, n)
					end
				end,
				des = function(cursor)
					local n = if not length then popvlq(cursor) elseif type(length) == 'number' then length else length.des(cursor)
					return desbitarr(cursor, n)
				end,
			}
			cached[key] = arr
			return arr :: any
		elseif optMap[serdes :: any] then
			local underlyingSerDes = optMap[serdes :: any]
			if underlyingSerDes == booleanCache then
				local arr: SerDes<{ boolean? }> = {
					ser = function(cursor, xs)
						local n = if type(length) == 'number' then length else table.maxn(xs)
						local bools = table.create(n)
						local flags = table.create(n)
						for i = 1, n do
							local x = xs[i]
							if x ~= nil then
								table.insert(bools, x)
								flags[i] = true
							else
								flags[i] = false
							end
						end
						local actualBoolCount = #bools
						local boolBytes = 1 + actualBoolCount // 8
						local flagBytes = 1 + n // 8
						tryrealloc(cursor, boolBytes + flagBytes)
						serbitarr(cursor, bools)
						serbitarr(cursor, flags)
						if not length then
							pushvlqrealloc(cursor, n)
						elseif type(length) ~= 'number' then
							length.ser(cursor, n)
						end
					end,
					des = function(cursor)
						local n = if not length then popvlq(cursor) elseif type(length) == 'number' then length else length.des(cursor)
						local flags = desbitarr(cursor, n)

						local actualBoolCount = 0
						for _, flag in flags do
							actualBoolCount += if flag then 1 else 0
						end
						local bools = desbitarr(cursor, actualBoolCount)

						local xs = table.create(n)
						local j = 1
						for i, flag in flags do
							if flag then
								xs[i] = bools[j]
								j += 1
							end
						end
						return xs
					end,
				}
				cached[key] = arr
				return arr :: any
			else
				local arr: SerDes<{ T? }> = {
					ser = function(cursor, xs: { T? }): ()
						local push = underlyingSerDes.ser

						local n = if type(length) == 'number' then length else table.maxn(xs)
						local flags = table.create(n)
						for i = 1, n do
							local x = xs[i]
							if x ~= nil then
								push(cursor, x :: any)
								flags[i] = true
							else
								flags[i] = false
							end
						end
						local flagBytes = 1 + n // 8
						tryrealloc(cursor, flagBytes)
						serbitarr(cursor, flags)
						if not length then
							pushvlqrealloc(cursor, n)
						elseif type(length) ~= 'number' then
							length.ser(cursor, n)
						end
					end,
					des = function(cursor)
						local pop = underlyingSerDes.des

						local n = if not length then popvlq(cursor) elseif type(length) == 'number' then length else length.des(cursor)
						local flags = desbitarr(cursor, n)

						local xs = table.create(n)
						for i = n, 1, -1 do
							if flags[i] then
								xs[i] = pop(cursor)
							end
						end
						return xs :: any
					end,
				}
				cached[key] = arr
				return arr :: any
			end
		else
			local arr: SerDes<{ T }> = {
				ser = function(cursor, xs)
					local push = serdes.ser

					local n = if type(length) == 'number' then length else #xs
					for i = 1, n do
						push(cursor, xs[i])
					end
					if not length then
						pushvlqrealloc(cursor, n)
					elseif type(length) ~= 'number' then
						length.ser(cursor, n)
					end
				end,
				des = function(cursor)
					local pop = serdes.des

					local n = if not length then popvlq(cursor) elseif type(length) == 'number' then length else length.des(cursor)
					local xs = table.create(n)
					for i = n, 1, -1 do
						xs[i] = pop(cursor)
					end
					return xs
				end,
			}
			cached[key] = arr
			return arr
		end
	end
end

do
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
end

do
	function Squash.record<T>(schema: T & {}): SerDes<T>
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

		local propCount = #properties
		table.sort(properties)

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
		end

		return {
			ser = function(cursor, record)
				for _, prop in properties do
					local val = (record :: any)[prop]
					local serdes = (schema :: any)[prop]
					serdes.ser(cursor, val)
				end

				local bools = table.create(boolCount + optboolCount) -- oversizing
				for i, prop in boolProperties do
					local val = (record :: any)[prop]
					bools[i] = val
				end

				local actualBoolCount = boolCount
				local flags = table.create(optboolCount + optCount)
				for i, prop in optboolProperties do
					local val = (record :: any)[prop]
					if val == nil then
						flags[i] = false
					else
						actualBoolCount += 1
						bools[actualBoolCount] = val
						flags[i] = true
					end
				end

				for i, prop in optProperties do
					local f = i + optboolCount
					local val = (record :: any)[prop]
					if val == nil then
						flags[f] = false
					else
						optSerDes[i].ser(cursor, val)
						flags[f] = true
					end
				end

				tryrealloc(cursor, actualBoolCount + optboolCount + optCount)
				serbitarr(cursor, bools, actualBoolCount)
				serbitarr(cursor, flags, optboolCount + optCount)
			end,

			des = function(cursor)
				local new: any = {}

				local flags = desbitarr(cursor, optboolCount + optCount)

				local actualBoolCount = boolCount
				for i = 1, optboolCount do
					actualBoolCount += if flags[i] then 1 else 0
				end

				local bools = desbitarr(cursor, actualBoolCount)

				for i, prop in boolProperties do
					new[prop] = bools[i]
				end

				local b = actualBoolCount
				for i = optboolCount, 1, -1 do
					local flag = flags[i]
					if flag then
						local prop = optboolProperties[i]
						new[prop] = bools[b]
						b -= 1
					end
				end

				for i = optCount, 1, -1 do
					local flag = flags[i + optboolCount]
					if flag then
						local prop = optProperties[i]
						local serdes = (schema :: any)[prop]
						new[prop] = optSerDes[i].des(cursor)
					end
				end

				for i = propCount, 1, -1 do
					local prop = properties[i]
					local serdes = (schema :: any)[prop]
					new[prop] = serdes.des(cursor)
				end

				return new
			end,
		}
	end
end

do
	function Squash.map<K, V>(keySerDes: SerDes<K>, valueSerDes: SerDes<V>, length: Length?): SerDes<{ [K]: V }>
		return {
			ser = function(cursor, map)
				local size = 0
				for k, v in map :: any do
					(valueSerDes :: any).ser(cursor, v);
					(keySerDes :: any).ser(cursor, k)
					size += 1
				end
				if not length then
					pushvlqrealloc(cursor, size)
				elseif type(length) ~= 'number' then
					length.ser(cursor, size)
				end
			end,

			des = function(cursor)
				local map = {}

				local size = if not length then popvlq(cursor) elseif type(length) == 'number' then length else length.des(cursor)

				for _ = 1, size do
					local key = (keySerDes :: any).des(cursor)
					local value = (valueSerDes :: any).des(cursor)
					map[key] = value
				end

				return map :: any
			end,
		}
	end
end

do
	function Squash.literal(...: any): SerDes<any>
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
end

do
	function Squash.table(schema: { [string]: SerDes<any> }, length: Length?): SerDes<any>
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

				if not length then
					pushvlqrealloc(cursor, size)
				elseif type(length) ~= 'number' then
					length.ser(cursor, size)
				end
			end,

			des = function(cursor)
				local tab = {}
				local size = if not length then popvlq(cursor) elseif type(length) == 'number' then length else length.des(cursor)
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
end

do
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
end

do
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
end

local enumitem
do
	local enumItemCache = {}
	function Squash.EnumItem(enum: Enum): SerDes<EnumItem>
		if enumItemCache[enum] then
			return enumItemCache[enum]
		end

		local sortedItems = enum:GetEnumItems()
		table.sort(sortedItems, function(a, b)
			return a.Value < b.Value
		end)

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
	enumitem = Squash.EnumItem
end

do
	local catalogSearchParamsCache: SerDes<CatalogSearchParams> = {
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

			params.SalesTypeFilter = enumitem(Enum.SalesTypeFilter).des(cursor)
			params.CategoryFilter = enumitem(Enum.CatalogCategoryFilter).des(cursor) :: Enum.CatalogCategoryFilter
			params.SortAggregation = enumitem(Enum.CatalogSortAggregation).des(cursor)
			params.SortType = enumitem(Enum.CatalogSortType).des(cursor) :: Enum.CatalogSortType
			params.SearchKeyword = popstr(cursor)
			params.CreatorName = popstr(cursor)
			params.MaxPrice = popu4(cursor)
			params.MinPrice = popu4(cursor)
			params.Limit = popu1(cursor)
			params.IncludeOffSale = popbool(cursor)
			return params
		end,
	}
	function Squash.CatalogSearchParams(): SerDes<CatalogSearchParams>
		return catalogSearchParamsCache
	end
end

local rotser, rotdes
do
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

	function rotser(cursor, cframe: CFrame)
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
			local z = math.round((axis.Z + 1) * 2 ^ 15 - 1)
			local y = math.round((axis.Y + 1) * 2 ^ 15 - 1)
			local x = math.round((axis.X + 1) * 2 ^ 15 - 1)
			pushu2(cursor, z)
			pushu2(cursor, y)
			pushu2(cursor, x)
			pushu1(cursor, 0)
		end
	end

	function rotdes(cursor)
		local specialId = popu1(cursor)
		if specialId ~= 0 then
			return idToRotation[specialId]
		end

		local qx = (popu2(cursor) + 1) * 2 ^ -15 - 1
		local qy = (popu2(cursor) + 1) * 2 ^ -15 - 1
		local qz = (popu2(cursor) + 1) * 2 ^ -15 - 1
		local qw = math.sqrt(1 - math.clamp(qx * qx + qy * qy + qz * qz, 0, 1))
		return CFrame.new(0, 0, 0, qx, qy, qz, qw)
	end

	local rotationCache: SerDes<CFrame> = {
		ser = rotser,
		des = rotdes,
	}
	function Squash.rotation()
		return rotationCache
	end
end

local cframe
do
	local cframeCache = {}
	function Squash.CFrame(positionSerDes: SerDes<number>): SerDes<CFrame>
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
	cframe = Squash.CFrame
end

local function pushcolor3(cursor, color3)
	pushu1(cursor, color3.B * 255)
	pushu1(cursor, color3.G * 255)
	pushu1(cursor, color3.R * 255)
end
local function popcolor3(cursor)
	return Color3.fromRGB(popu1(cursor), popu1(cursor), popu1(cursor))
end
do
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
end

local function pushcolorsequencekeypoint(cursor, keypoint)
	pushcolor3(cursor, keypoint.Value)
	pushu1(cursor, keypoint.Time * 255)
end
local function popcolorsequencekeypoint(cursor)
	return ColorSequenceKeypoint.new(popu1(cursor) / 255, popcolor3(cursor))
end
do
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
end

do
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
end

do
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
end

do
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
end

do
	local floatCurveKeyCache: SerDes<FloatCurveKey> = {
		ser = function(cursor, key)
			enumitem(Enum.KeyInterpolationMode).ser(cursor, key.Interpolation)
			tryrealloc(cursor, 8)
			pushf4(cursor, key.Value)
			pushf4(cursor, key.Time)
		end,

		des = function(cursor)
			return FloatCurveKey.new(popf4(cursor), popf4(cursor), enumitem(Enum.KeyInterpolationMode).des(cursor) :: any)
		end,
	}
	function Squash.FloatCurveKey(): SerDes<FloatCurveKey>
		return floatCurveKeyCache
	end
end

do
	local fontCache: SerDes<Font> = {
		ser = function(cursor, font)
			local family = string.match(font.Family, 'rbxasset://fonts/families/(.+).json') or error(`Invalid font family {font.Family}`)
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
end

do
	local numberRangeCache = {}
	function Squash.NumberRange(serdes: SerDes<number>): SerDes<NumberRange>
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
end

local numbersequencekeypoint
do
	local numberSequenceKeypointCache = {}
	function Squash.NumberSequenceKeypoint(serdes: SerDes<number>): SerDes<NumberSequenceKeypoint>
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
	numbersequencekeypoint = Squash.NumberSequenceKeypoint
end

do
	local numberSequenceCache = {}
	function Squash.NumberSequence(serdes: SerDes<number>): SerDes<NumberSequence>
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
				for i = count, 1, -1 do
					keypoints[i] = pop(cursor)
				end
				return NumberSequence.new(keypoints)
			end,
		}

		numberSequenceCache[serdes] = numsequence
		return numsequence
	end
end

do
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
end

do
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
end

do
	local vector3Cache = {}
	function Squash.Vector3(serdes: SerDes<number>): SerDes<Vector3>
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
end

do
	local pathWaypointCache = {}
	function Squash.PathWaypoint(serdes: SerDes<number>): SerDes<PathWaypoint>
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
end

do
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
			return PhysicalProperties.new(popf4(cursor), popf4(cursor), popf4(cursor), popf4(cursor), popf4(cursor))
		end,
	}
	function Squash.PhysicalProperties(): SerDes<PhysicalProperties>
		return physicalPropertiesCache
	end
end

do
	local rayCache = {}
	function Squash.Ray(serdes: SerDes<number>): SerDes<Ray>
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
				return Ray.new(Vector3.new(pop(cursor), pop(cursor), pop(cursor)), Vector3.new(pop(cursor), pop(cursor), pop(cursor)))
			end,
		}
		rayCache[serdes] = raycached
		return raycached
	end
end

export type SquashRaycastResult = {
	Distance: number,
	Position: Vector3,
	Normal: Vector3,
	Material: Enum.Material,
}

do
	local raycastResultCache = {}
	function Squash.RaycastResult(serdes: SerDes<number>): { ser: (Cursor, RaycastResult) -> (), des: (Cursor) -> SquashRaycastResult }
		if raycastResultCache[serdes] then
			return raycastResultCache[serdes]
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
end

do
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
end

do
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
end

do
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
end

do
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
end

do
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
end

do
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
			return TweenInfo.new(duration, easing, direction, repeats, reverses, delayTime)
		end,
	}
	function Squash.TweenInfo()
		return tweenInfoCache
	end
end

do
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
end

do
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
end

do
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
end

do
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
end

return Squash
