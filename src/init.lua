--!strict

--[[
	@class Squash

	Provides a set of functions for serializing and deserializing data.
]]
local Squash = {}

Squash.Ser = {}
Squash.Des = {}

--[[
	@within Squash
]]
function Squash.Ser.Boolean(
	x1: boolean,
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

--[[
	@within Squash
]]
function Squash.Des.Boolean(y: string): (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean)
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

--[[
	@within Squash
--]]
function Squash.Ser.ArrayBoolean(x: { boolean }): string
	local y = {}
	for i = 1, math.ceil(#x / 8) do
		y[i] = Squash.Ser.Boolean(x[i + 0], x[i + 1], x[i + 2], x[i + 3], x[i + 4], x[i + 5], x[i + 6], x[i + 7])
	end
	return table.concat(y)
end

--[[
	@within Squash
--]]
function Squash.Des.ArrayBoolean(y: string): { boolean }
	local x = {}
	for i = 1, #y do
		local j = 8 * i
		x[j - 7], x[j - 6], x[j - 5], x[j - 4], x[j - 3], x[j - 2], x[j - 1], x[j] =
			Squash.Des.Boolean(string.sub(y, i, i))
	end
	return x
end

local function bytesAssert(bytes: number)
	assert(
		bytes == 1 or bytes == 2 or bytes == 3 or bytes == 4 or bytes == 5 or bytes == 6 or bytes == 7 or bytes == 8,
		"bytes must be 1, 2, 3, 4, 5, 6, 7, or 8"
	)
end

--[[
	@within Squash
]]
function Squash.Ser.Uint(bytes: number, x: number): string
	bytesAssert(bytes)

	local chars = {}
	for i = 1, bytes do
		chars[i] = math.floor(x * 256 ^ (1 - i)) % 256
	end
	return string.char(table.unpack(chars))
end

--[[
	@within Squash
]]
function Squash.Des.Uint(bytes: number, y: string): number
	bytesAssert(bytes)

	local sum = 0
	for i = 1, bytes do
		sum += string.byte(y, i) * 256 ^ (i - 1)
	end
	return sum
end

--[[
	@within Squash
--]]
function Squash.Ser.ArrayUint(bytes: number, x: { number }): string
	bytesAssert(bytes)

	local y = {}
	for i, v in x do
		y[i] = Squash.Ser.Uint(bytes, v)
	end
	return table.concat(y)
end

--[[
	@within Squash
--]]
function Squash.Des.ArrayUint(bytes: number, y: string): { number }
	bytesAssert(bytes)

	local x = {}
	for i = 1, #y / bytes do
		local a = bytes * (i - 1) + 1
		local b = bytes * i
		x[i] = Squash.Des.Uint(bytes, string.sub(y, a, b))
	end
	return x
end

--[[
	@within Squash
]]
function Squash.Ser.Int(bytes: number, x: number): string
	bytesAssert(bytes)

	local sx = if x < 0 then x + 256 ^ bytes else x
	return Squash.Ser.Uint(bytes, sx)
end

--[[
	@within Squash
]]
function Squash.Des.Int(bytes: number, y: string): number
	bytesAssert(bytes)

	local x = Squash.Des.Uint(bytes, y)
	return if x > 0.5 * 256 ^ bytes - 1 then x - 256 ^ bytes else x
end

--[[
	@within Squash
--]]
function Squash.Ser.ArrayInt(bytes: number, x: { number }): string
	bytesAssert(bytes)

	local y = {}
	for i, v in x do
		y[i] = Squash.Ser.Int(bytes, v)
	end
	return table.concat(y)
end

--[[
	@within Squash
--]]
function Squash.Des.ArrayInt(bytes: number, y: string): { number }
	bytesAssert(bytes)

	local x = {}
	for i = 1, #y / bytes do
		local a = bytes * (i - 1) + 1
		local b = bytes * i
		x[i] = Squash.Des.Int(bytes, string.sub(y, a, b))
	end
	return x
end

--[[
	@within Squash
]]
function Squash.Ser.Color3(x: Color3): string
	return string.char(x.R * 255, x.G * 255, x.B * 255)
end

--[[
	@within Squash
]]
function Squash.Des.Color3(y: string): Color3
	return Color3.fromRGB(string.byte(y, 1), string.byte(y, 2), string.byte(y, 3))
end

--[[
	@within Squash
]]
function Squash.Ser.ArrayColor3(x: { Color3 }): string
	local y = {}
	for i, v in x do
		y[i] = Squash.Ser.Color3(v)
	end
	return table.concat(y)
end

--[[
	@within Squash
]]
function Squash.Des.ArrayColor3(y: string): { Color3 }
	local x = {}
	for i = 1, #y / 3 do
		local a = 3 * (i - 1) + 1
		local b = 3 * i
		x[i] = Squash.Des.Color3(string.sub(y, a, b))
	end
	return x
end

--[[
	@within Squash
]]
function Squash.Ser.ColorSequenceKeypoint(x: ColorSequenceKeypoint): string
	return string.char(x.Time * 255) .. Squash.Ser.Color3(x.Value)
end

--[[
	@within Squash
]]
function Squash.Des.ColorSequenceKeypoint(y: string): ColorSequenceKeypoint
	return ColorSequenceKeypoint.new(string.byte(y, 1) / 255, Squash.Des.Color3(string.sub(y, 2, 4)))
end

--[[
	@within Squash
]]
function Squash.Ser.ArrayColorSequenceKeypoint(x: { ColorSequenceKeypoint }): string
	local y = {}
	for i, v in x do
		y[i] = Squash.Ser.ColorSequenceKeypoint(v)
	end
	return table.concat(y)
end

--[[
	@within Squash
]]
function Squash.Des.ArrayColorSequenceKeypoint(y: string): { ColorSequenceKeypoint }
	local x = {}
	for i = 1, #y / 4 do
		local a = 4 * (i - 1) + 1
		local b = 4 * i
		x[i] = Squash.Des.ColorSequenceKeypoint(string.sub(y, a, b))
	end
	return x
end

--[[
	@within Squash
]]
function Squash.Ser.ColorSequence(x: ColorSequence): string
	return Squash.Ser.ArrayColorSequenceKeypoint(x.Keypoints)
end

--[[
	@within Squash
]]
function Squash.Des.ColorSequence(y: string): ColorSequence
	return ColorSequence.new(Squash.Des.ArrayColorSequenceKeypoint(y))
end

--[[
	@within Squash
]]
function Squash.Ser.ArrayColorSequence(x: { ColorSequence }): string
	local y = {}
	for i, v in x do
		y[i] = Squash.Ser.ColorSequence(v)
	end
	return table.concat(y)
end

--[[
	@within Squash
]]
function Squash.Des.ArrayColorSequence(y: string): { ColorSequence }
	local x = {}
	for i = 1, #y / 4 do
		local a = 4 * (i - 1) + 1
		local b = 4 * i
		x[i] = Squash.Des.ColorSequence(string.sub(y, a, b))
	end
	return x
end

return Squash

-- String Stuff

-- local a = string.byte("a")
-- local A = string.byte("A")

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.Ser.StringCased(
-- 	x: string,
-- 	upper: boolean?
-- ): string
-- 	local case = upper and A or a
-- 	local sum = 0
-- 	local result = {}

-- 	for i = 1, #x do
-- 		sum = sum * 26 + string.byte(x, i) - case
-- 		table.insert(
-- 			result,
-- 			string.char(sum % 256)
-- 		)
-- 		sum = math.floor(sum / 256)
-- 	end

-- 	while sum > 0 do
-- 		table.insert(
-- 			result,
-- 			string.char(sum % 256)
-- 		)
-- 		sum = math.floor(sum / 256)
-- 	end

-- 	return table.concat(result)
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.Des.StringCased(
-- 	x: string,
-- 	upper: boolean?
-- ): string
-- 	local case = upper and A or a
-- 	local sum = 0
-- 	local result = {}

-- 	for i = 1, #x do
-- 		sum = sum * 256 + string.byte(x, i)
-- 		table.insert(
-- 			result,
-- 			string.char(case + sum % 26)
-- 		)
-- 		sum = math.floor(sum / 26)
-- 	end

-- 	while sum > 0 do
-- 		table.insert(
-- 			result,
-- 			string.char(case + sum % 26)
-- 		)
-- 		sum = math.floor(sum / 26)
-- 	end

-- 	return table.concat(result)
-- end

-- Array Stuff

-- local function printarray(arr: { number })
-- 	return "[" .. table.concat(arr, ", ") .. "]"
-- end

-- local function test(name: string, size: number, x: number | { number })
-- 	local y = Squash.Ser[name](size, x)
-- 	local z = Squash.Des[name](size, y)
-- 	print(
-- 		name .. size,
-- 		if typeof(x) == "table" then printarray(x) else x,
-- 		"->",
-- 		if typeof(y) == "table" then printarray(y) else y,
-- 		"->",
-- 		if typeof(z) == "table" then printarray(z) else z
-- 	)
-- end

-- local numbers = { math.random(0, 9) }
-- for j = 0, 10 do
-- 	table.insert(numbers, math.random(2 ^ (j*3)))
-- end

-- for i = 1, 8 do
-- 	test("ArrayUint", i, numbers)
-- end
