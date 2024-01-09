--!strict

local Squash = require 'src/init'

local function toBits(num)
	-- returns a table of bits
	local t = {} -- will contain the bits
	for b = 1, 8 do
		local rest = math.fmod(num, 2)
		t[b] = rest
		num = (num - rest) / 2
	end
	if num == 0 then
		return table.concat(t)
	else
		return 'Not enough bits to represent this number'
	end
end

local function tostring(buf: buffer)
	local bytes = {}
	for i = 0, buffer.len(buf) - 1 do
		bytes[i + 1] = toBits(buffer.readu8(buf, i))
	end
	return table.concat(bytes, '-')
end

local function result<T>(name: string, x: T, y: buffer, z: T)
	print(name)
	print(x)
	print(tostring(y))
	print(z)
	print()
end

local function resultarr<T>(name: string, x: { T }, y: buffer, z: { T })
	print(name)
	print(table.unpack(x))
	print(tostring(y))
	print(table.unpack(z))
	print()
end

--print()

--print('zero')
--print(Squash.bytes(0))

--print('uint')
--print(Squash.bytes(1))
--print(Squash.bytes(2))
--print(Squash.bytes(254))
--print(Squash.bytes(255))
--print(Squash.bytes(256))
--print(Squash.bytes(257))
--print(Squash.bytes(65535))
--print(Squash.bytes(65536))
--print(Squash.bytes(65537))

--print('int')
--print(Squash.bytes(-1))
--print(Squash.bytes(-2))
--print(Squash.bytes(-126))
--print(Squash.bytes(-127))
--print(Squash.bytes(-128))
--print(Squash.bytes(-129))
--print(Squash.bytes(-65535))
--print(Squash.bytes(-65536))
--print(Squash.bytes(-65537))

--print('positive floating point')
--print(Squash.bytes(0.5))
--print(Squash.bytes(1.5))
--print(Squash.bytes(2.5))
--print(Squash.bytes(254.5))
--print(Squash.bytes(255.5))
--print(Squash.bytes(256.5))
--print(Squash.bytes(257.5))
--print(Squash.bytes(65535.5))
--print(Squash.bytes(65536.5))
--print(Squash.bytes(65537.5))
--print(Squash.bytes(123838642887.5))

--print('negative floating point')
--print(Squash.bytes(-0.5))
--print(Squash.bytes(-1.5))
--print(Squash.bytes(-2.5))
--print(Squash.bytes(-254.5))
--print(Squash.bytes(-255.5))
--print(Squash.bytes(-256.5))
--print(Squash.bytes(-257.5))
--print(Squash.bytes(-65535.5))
--print(Squash.bytes(-65536.5))
--print(Squash.bytes(-65537.5))

--print()

--do
--	local x = { true, true, false, true, false, false, true }
--	local y = Squash.boolean().ser(table.unpack(x))
--	local z = { Squash.boolean().des(y) }
--	resultarr('boolean', x, y, z)

--	local xs = { true, false, true, true, false, false, true, true, true, false, false, false, true }
--	local ys = Squash.boolean().serarr(xs)
--	local zs = Squash.boolean().desarr(ys)
--	resultarr('booleans', xs, ys, zs)
--end

--do
--	local x = 257
--	local y = Squash.uint(1).ser(x)
--	local z = Squash.uint(1).des(y)
--	result('uint 1', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
--	local ys = Squash.uint(1).serarr(xs)
--	local zs = Squash.uint(1).desarr(ys)
--	resultarr('uints 1', xs, ys, zs)
--end

--do
--	local x = 2573
--	local y = Squash.uint(2).ser(x)
--	local z = Squash.uint(2).des(y)
--	result('uint 2', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
--	local ys = Squash.uint(2).serarr(xs)
--	local zs = Squash.uint(2).desarr(ys)
--	resultarr('uints 2', xs, ys, zs)
--end

--do
--	local x = 257381
--	local y = Squash.uint(3).ser(x)
--	local z = Squash.uint(3).des(y)
--	result('uint 3', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
--	local ys = Squash.uint(3).serarr(xs)
--	local zs = Squash.uint(3).desarr(ys)
--	resultarr('uints 3', xs, ys, zs)
--end

--do
--	local x = 25738192
--	local y = Squash.uint(4).ser(x)
--	local z = Squash.uint(4).des(y)
--	result('uint 4', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
--	local ys = Squash.uint(4).serarr(xs)
--	local zs = Squash.uint(4).desarr(ys)
--	resultarr('uints 4', xs, ys, zs)
--end

--do
--	local x = 25738192927
--	local y = Squash.uint(5).ser(x)
--	local z = Squash.uint(5).des(y)
--	result('uint 5', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
--	local ys = Squash.uint(5).serarr(xs)
--	local zs = Squash.uint(5).desarr(ys)
--	resultarr('uints 5', xs, ys, zs)
--end

--do
--	local x = 25738192927
--	local y = Squash.uint(6).ser(x)
--	local z = Squash.uint(6).des(y)
--	result('uint 6', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
--	local ys = Squash.uint(6).serarr(xs)
--	local zs = Squash.uint(6).desarr(ys)
--	resultarr('uints 6', xs, ys, zs)
--end

--do
--	local x = 2573819292792
--	local y = Squash.uint(7).ser(x)
--	local z = Squash.uint(7).des(y)
--	result('uint 7', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
--	local ys = Squash.uint(7).serarr(xs)
--	local zs = Squash.uint(7).desarr(ys)
--	resultarr('uints 7', xs, ys, zs)
--end

--do
--	local x = 2573819292792293
--	local y = Squash.uint(8).ser(x)
--	local z = Squash.uint(8).des(y)
--	result('uint 8', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887999999, -28362, 18632 }
--	local ys = Squash.uint(8).serarr(xs)
--	local zs = Squash.uint(8).desarr(ys)
--	resultarr('uints 8', xs, ys, zs)
--end

--do
--	local x = -54.5
--	local y = Squash.int(1).ser(x)
--	local z = Squash.int(1).des(y)
--	result('int 1', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, -123838642887, -28362, 18632 }
--	local ys = Squash.int(1).serarr(xs)
--	local zs = Squash.int(1).desarr(ys)
--	resultarr('ints 1', xs, ys, zs)
--end

--do
--	local x = -50927
--	local y = Squash.int(2).ser(x)
--	local z = Squash.int(2).des(y)
--	result('int 2', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, -123838642887, -28362, 18632 }
--	local ys = Squash.int(2).serarr(xs)
--	local zs = Squash.int(2).desarr(ys)
--	resultarr('ints 2', xs, ys, zs)
--end

--do
--	local x = -5092792
--	local y = Squash.int(3).ser(x)
--	local z = Squash.int(3).des(y)
--	result('int 3', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, -123838642887, -28362, 18632 }
--	local ys = Squash.int(3).serarr(xs)
--	local zs = Squash.int(3).desarr(ys)
--	resultarr('ints 3', xs, ys, zs)
--end

--do
--	local x = -509279229
--	local y = Squash.int(4).ser(x)
--	local z = Squash.int(4).des(y)
--	result('int 4', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, -164, -123838642887, -28362, 18632 }
--	local ys = Squash.int(4).serarr(xs)
--	local zs = Squash.int(4).desarr(ys)
--	resultarr('ints 4', xs, ys, zs)
--end

--do
--	local x = -509279229279
--	local y = Squash.int(5).ser(x)
--	local z = Squash.int(5).des(y)
--	result('int 5', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, -3873, -164, -123838642887, -28362, 18632 }
--	local ys = Squash.int(5).serarr(xs)
--	local zs = Squash.int(5).desarr(ys)
--	resultarr('ints 5', xs, ys, zs)
--end

--do
--	local x = -509279229279229
--	local y = Squash.int(6).ser(x)
--	local z = Squash.int(6).des(y)
--	result('int 6', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, -3873, -164, -123838642887, -28362, 18632 }
--	local ys = Squash.int(6).serarr(xs)
--	local zs = Squash.int(6).desarr(ys)
--	resultarr('ints 6', xs, ys, zs)
--end

--do
--	local x = -5092792292979229
--	local y = Squash.int(7).ser(x)
--	local z = Squash.int(7).des(y)
--	result('int 7', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, -3873, -164, -123838642887, -28362, 18632 }
--	local ys = Squash.int(7).serarr(xs)
--	local zs = Squash.int(7).desarr(ys)
--	resultarr('ints 7', xs, ys, zs)
--end

--do
--	local x = -509279229277869229
--	local y = Squash.int(8).ser(x)
--	local z = Squash.int(8).des(y)
--	result('int 8', x, y, z)

--	local xs = { 92, 0, -19, 8302, 93928, 6, -3873, -164, -123838642887, -28362, 18632 }
--	local ys = Squash.int(8).serarr(xs)
--	local zs = Squash.int(8).desarr(ys)
--	resultarr('ints 8', xs, ys, zs)
--end

--do
--	local x = 198362.28936
--	local y = Squash.number(4).ser(x)
--	local z = Squash.number(4).des(y)
--	result('number 4', x, y, z)

--	local xs = {
--		92.2,
--		0,
--		-19.9999999999999999,
--		8302,
--		93928.03986138560192358,
--		6,
--		-3873.320863,
--		-164,
--		-123838642887.286402,
--		-28362.02689462,
--		18632.29863,
--	}
--	local ys = Squash.number(4).serarr(xs)
--	local zs = Squash.number(4).desarr(ys)
--	resultarr('numbers 4', xs, ys, zs)
--end

--do
--	local x = 198362.28936
--	local y = Squash.number(8).ser(x)
--	local z = Squash.number(8).des(y)
--	result('number 8', x, y, z)

--	local xs = {
--		92.2,
--		0,
--		-19.9999999999999999,
--		8302,
--		93928.03986138560192358,
--		6,
--		-3873.320863,
--		-164,
--		-123838642887.286402,
--		-28362.02689462,
--		18632.29863,
--	}
--	local ys = Squash.number(8).serarr(xs)
--	local zs = Squash.number(8).desarr(ys)
--	resultarr('numbers 8', xs, ys, zs)
--end

--do
--	local x = 'hello world'
--	local y = Squash.string(Squash.lower).ser(x)
--	local z = Squash.string(Squash.lower).des(y)
--	result('string lower', x, y, z)

--	local xs = {
--		'hello world',
--		'koa   eslaf wft',
--		'goodbyewokasaort   lrld',
--	}
--	local ys = Squash.string(Squash.lower .. ' ').serarr(xs)
--	local zs = Squash.string(Squash.lower .. ' ').desarr(ys)
--	print(`Old length: {#xs[1] + #xs[2] + #xs[3]}, Compressed length: {buffer.len(ys)}`)
--	print('strings lower', '\n', table.concat(xs, '\t\t'), '\n', tostring(ys))
--	print(zs[1])
--	print(zs[2])
--	print(zs[3])
--	print()
--end

do
	local serdes = Squash.variadic(Squash.boolean(), Squash.int(4), Squash.number(8), Squash.Vector3(Squash.uint(1)), Squash.string(Squash.lower)) :: Squash.SerDesVar<boolean, number, number, Vector3, string>
	local x0 = { true, -1903, 400000000000000001, Vector3.new(1, 2, 3), 'whatareyoudoing' }
	local y0 = serdes.ser(table.unpack(x0))
	local z0 = { serdes.des(y0) }
	resultarr('variadic boolean int number Vector3 string', x0, y0, z0)
end

--do
--	for bytes = 1, 8 do
--		local x = Vector3.new(1, 2, 3)
--		local y = Squash.Vector3(Squash.uint(bytes)).ser(x)
--		local z = Squash.Vector3(Squash.uint(bytes)).des(y)
--		result('Vector3 ' .. bytes, x, y, z)

--		local xs = {
--			Vector3.new(1, 2, 3),
--			Vector3.new(0, 0, 0),
--			Vector3.new(-19, -390.28635, 9830),
--			Vector3.new(8302, 93928.03986138560192358, 6),
--			Vector3.new(-3873.320863, -164, -123838642887.286402),
--			Vector3.new(-28362.02689462, 18632.29863, 0),
--		}
--		local ys = Squash.Vector3(Squash.uint(bytes)).serarr(xs)
--		local zs = Squash.Vector3(Squash.uint(bytes)).desarr(ys)
--		resultarr('Vector3s ' .. bytes, xs, ys, zs)
--	end
--end

--do
--	for bytes = 1, 8 do
--		local x = Vector2.new(1, 2)
--		local y = Squash.Vector2(Squash.uint(bytes)).ser(x)
--		local z = Squash.Vector2(Squash.uint(bytes)).des(y)
--		result('Vector2 ' .. bytes, x, y, z)

--		local xs = {
--			Vector2.new(1, 2),
--			Vector2.new(0, 0),
--			Vector2.new(-19, -390.28635),
--			Vector2.new(8302, 93928.03986138560192358),
--			Vector2.new(-3873.320863, -164),
--			Vector2.new(-28362.02689462, 18632.29863),
--		}
--		local ys = Squash.Vector2(Squash.uint(bytes)).serarr(xs)
--		local zs = Squash.Vector2(Squash.uint(bytes)).desarr(ys)
--		resultarr('Vector2s ' .. bytes, xs, ys, zs)
--	end
--end