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
		return { 'Not enough bits to represent this number' }
	end
end

local function tostring(buf: buffer)
	local bytes = {}
	for i = 0, buffer.len(buf) - 1 do
		bytes[i + 1] = toBits(buffer.readu8(buf, i))
	end
	return table.concat(bytes, ' ')
end

local function result<T>(name: string, x: T, y: buffer, z: T)
	print(name)
	print(x)
	print(tostring(y))
	print(z)
	print()
end

local function resultarr<T>(name: string, x: {T}, y: buffer, z: {T})
	print(name)
	print(table.unpack(x))
	print(tostring(y))
	print(table.unpack(z))
	print()
end

print()

do
	local x = { true, true, false, true, false, false, true }
	local y = Squash.boolean().ser(table.unpack(x))
	local z = { Squash.boolean().des(y) }
	resultarr('boolean', x, y, z)

	local xs = { true, false, true, true, false, false, true, true, true, false, false, false, true }
	local ys = Squash.boolean().serarr(xs)
	local zs = Squash.boolean().desarr(ys)
	resultarr('booleans', xs, ys, zs)
end

do
	local x = 257
	local y = Squash.uint(1).ser(x)
	local z = Squash.uint(1).des(y)
	result('uint 1', x, y, z)

	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
	local ys = Squash.uint(1).serarr(xs)
	local zs = Squash.uint(1).desarr(ys)
	resultarr('uints 1', xs, ys, zs)
end

do
	local x = 2573
	local y = Squash.uint(2).ser(x)
	local z = Squash.uint(2).des(y)
	result('uint 2', x, y, z)

	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
	local ys = Squash.uint(2).serarr(xs)
	local zs = Squash.uint(2).desarr(ys)
	resultarr('uints 2', xs, ys, zs)
end

do
	local x = 257381
	local y = Squash.uint(3).ser(x)
	local z = Squash.uint(3).des(y)
	result('uint 3', x, y, z)

	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
	local ys = Squash.uint(3).serarr(xs)
	local zs = Squash.uint(3).desarr(ys)
	resultarr('uints 3', xs, ys, zs)
end

do
	local x = 25738192
	local y = Squash.uint(4).ser(x)
	local z = Squash.uint(4).des(y)
	result('uint 4', x, y, z)

	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
	local ys = Squash.uint(4).serarr(xs)
	local zs = Squash.uint(4).desarr(ys)
	resultarr('uints 4', xs, ys, zs)
end

do
	local x = 25738192927
	local y = Squash.uint(5).ser(x)
	local z = Squash.uint(5).des(y)
	result('uint 5', x, y, z)

	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
	local ys = Squash.uint(5).serarr(xs)
	local zs = Squash.uint(5).desarr(ys)
	resultarr('uints 5', xs, ys, zs)
end

do
	local x = 25738192927
	local y = Squash.uint(6).ser(x)
	local z = Squash.uint(6).des(y)
	result('uint 6', x, y, z)

	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
	local ys = Squash.uint(6).serarr(xs)
	local zs = Squash.uint(6).desarr(ys)
	resultarr('uints 6', xs, ys, zs)
end

do
	local x = 2573819292792
	local y = Squash.uint(7).ser(x)
	local z = Squash.uint(7).des(y)
	result('uint 7', x, y, z)

	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887, -28362, 18632 }
	local ys = Squash.uint(7).serarr(xs)
	local zs = Squash.uint(7).desarr(ys)
	resultarr('uints 7', xs, ys, zs)
end

do
	local x = 2573819292792293
	local y = Squash.uint(8).ser(x)
	local z = Squash.uint(8).des(y)
	result('uint 8', x, y, z)

	local xs = { 92, 0, -19, 8302, 93928, 6, 3873, 164, 123838642887999999, -28362, 18632 }
	local ys = Squash.uint(8).serarr(xs)
	local zs = Squash.uint(8).desarr(ys)
	resultarr('uints 8', xs, ys, zs)
end
