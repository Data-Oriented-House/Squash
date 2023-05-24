--!strict

local function bytesAssert(bytes: number)
	assert(
		bytes == 1 or bytes == 2 or bytes == 3 or bytes == 4 or bytes == 5 or bytes == 6 or bytes == 7 or bytes == 8,
		'bytes must be 1, 2, 3, 4, 5, 6, 7, or 8'
	)
end

local function serArrayNumber<T>(ser: (number, T) -> string)
	return function(bytes: number, x: { T }): string
		bytesAssert(bytes)

		local y = {}
		for i, v in x do
			y[i] = ser(bytes, v)
		end
		return table.concat(y)
	end
end

local function desArrayNumber<T>(des: (number, string) -> T)
	return function(bytes: number, y: string): { T }
		bytesAssert(bytes)

		local x = {}
		for i = 1, #y / bytes do
			local a = bytes * (i - 1) + 1
			local b = bytes * i
			x[i] = des(bytes, string.sub(y, a, b))
		end
		return x
	end
end

local function serArrayInstance<T>(ser: (T) -> string)
	return function(x: { T }): string
		local y = {}
		for i, v in x do
			y[i] = ser(v)
		end
		return table.concat(y)
	end
end

local function desArrayInstance<T>(bytes: number, des: (string) -> T)
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

--[[
	@class Squash

	Provides a set of functions for serializing and deserializing data.
]]
local Squash = {}

Squash.Ser = { Array = {} }
Squash.Des = { Array = {} }

--[[
	@within Squash
]]
function Squash.Ser.Boolean(
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
function Squash.Ser.Array.Boolean(x: { boolean }): string
	local y = {}
	for i = 1, math.ceil(#x / 8) do
		y[i] = Squash.Ser.Boolean(x[i + 0], x[i + 1], x[i + 2], x[i + 3], x[i + 4], x[i + 5], x[i + 6], x[i + 7])
	end
	return table.concat(y)
end

--[[
	@within Squash
--]]
function Squash.Des.Array.Boolean(y: string): { boolean }
	local x = {}
	for i = 1, #y do
		local j = 8 * i
		x[j - 7], x[j - 6], x[j - 5], x[j - 4], x[j - 3], x[j - 2], x[j - 1], x[j] =
			Squash.Des.Boolean(string.sub(y, i, i))
	end
	return x
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
Squash.Ser.Array.Uint = serArrayNumber(Squash.Ser.Uint)

--[[
	@within Squash
--]]
Squash.Des.Array.Uint = desArrayNumber(Squash.Des.Uint)

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
Squash.Ser.Array.Int = serArrayNumber(Squash.Ser.Int)

--[[
	@within Squash
--]]
Squash.Des.Array.Int = desArrayNumber(Squash.Des.Int)

--[[
	@within Squash
]]
function Squash.Ser.Axes(x: Axes)
	return Squash.Ser.Boolean(x.X, x.Y, x.Z) .. Squash.Ser.Boolean(x.Top, x.Bottom, x.Left, x.Right, x.Back, x.Front)
end

--[[
	@within Squash
]]
function Squash.Des.Axes(y: string): Axes
	local axes = Axes.new()
	axes.X, axes.Y, axes.Z = Squash.Des.Boolean(string.sub(y, 1))
	axes.Top, axes.Bottom, axes.Left, axes.Right, axes.Back, axes.Front = Squash.Des.Boolean(string.sub(y, 2))
	return axes
end

--[[
	@within Squash
--]]
Squash.Ser.Array.Axes = serArrayInstance(Squash.Ser.Axes)

--[[
	@within Squash
--]]
Squash.Des.Array.Axes = desArrayInstance(8, Squash.Des.Axes)

--[[
	@within Squash
]]
function Squash.Ser.BrickColor(x: BrickColor): string
	return Squash.Ser.Uint(2, x.Number)
end

--[[
	@within Squash
]]
function Squash.Des.BrickColor(y: string): BrickColor
	return BrickColor.new(Squash.Des.Uint(2, y))
end

--[[
	@within Squash
]]
Squash.Ser.Array.BrickColor = serArrayInstance(Squash.Ser.BrickColor)

--[[
	@within Squash
]]
Squash.Des.Array.BrickColor = desArrayInstance(2, Squash.Des.BrickColor)

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
Squash.Ser.Array.Color3 = serArrayInstance(Squash.Ser.Color3)

--[[
	@within Squash
]]
Squash.Des.Array.Color3 = desArrayInstance(3, Squash.Des.Color3)

--[[
	@within Squash
]]
function Squash.Ser.DateTime(x: DateTime): string
	return Squash.Ser.Uint(5, x.UnixTimestamp + 17_987_443_200)
end

--[[
	@within Squash
]]
function Squash.Des.DateTime(y: string): DateTime
	return DateTime.fromUnixTimestamp(Squash.Des.Uint(5, y) - 17_987_443_200)
end

--[[
	@within Squash
]]
Squash.Ser.ArrayDateTime = serArrayInstance(Squash.Ser.DateTime)

--[[
	@within Squash
]]
Squash.Des.ArrayDateTime = desArrayInstance(5, Squash.Des.DateTime)

--[[
	@within Squash
]]
function Squash.Ser.DockWidgetPluginGuiInfo(x: DockWidgetPluginGuiInfo): string
	return table.concat {
		Squash.Ser.Boolean(x.InitialEnabled, x.InitialEnabledShouldOverrideRestore),
		Squash.Ser.Int(2, x.FloatingXSize),
		Squash.Ser.Int(2, x.FloatingYSize),
		Squash.Ser.Int(2, x.MinWidth),
		Squash.Ser.Int(2, x.MinHeight),
	}
end

--[[
	@within Squash
]]
function Squash.Des.DockWidgetPluginGuiInfo(y: string): DockWidgetPluginGuiInfo
	local x = DockWidgetPluginGuiInfo.new()
	x.InitialEnabled, x.InitialEnabledShouldOverrideRestore = Squash.Des.Boolean(string.sub(y, 1))
	x.FloatingXSize = Squash.Des.Int(2, string.sub(y, 2, 3))
	x.FloatingYSize = Squash.Des.Int(2, string.sub(y, 4, 5))
	x.MinWidth = Squash.Des.Int(2, string.sub(y, 6, 7))
	x.MinHeight = Squash.Des.Int(2, string.sub(y, 8, 9))
	return x
end

--[[
	@within Squash
]]
Squash.Ser.ArrayDockWidgetPluginGuiInfo = serArrayInstance(Squash.Ser.DockWidgetPluginGuiInfo)

--[[
	@within Squash
]]
Squash.Des.ArrayDockWidgetPluginGuiInfo = desArrayInstance(9, Squash.Des.DockWidgetPluginGuiInfo)

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
Squash.Ser.Array.ColorSequenceKeypoint = serArrayInstance(Squash.Ser.ColorSequenceKeypoint)

--[[
	@within Squash
]]
Squash.Des.Array.ColorSequenceKeypoint = desArrayInstance(4, Squash.Des.ColorSequenceKeypoint)

--[[
	@within Squash
]]
function Squash.Ser.ColorSequence(x: ColorSequence): string
	return Squash.Ser.Array.ColorSequenceKeypoint(x.Keypoints)
end

--[[
	@within Squash
]]
function Squash.Des.ColorSequence(y: string): ColorSequence
	return ColorSequence.new(Squash.Des.Array.ColorSequenceKeypoint(y))
end

--[[
	@within Squash
]]
Squash.Ser.Array.ColorSequence = serArrayInstance(Squash.Ser.ColorSequence)

--[[
	@within Squash
]]
Squash.Des.Array.ColorSequence = desArrayInstance(4, Squash.Des.ColorSequence)

--[[
	@within Squash
]]
function Squash.Ser.Faces(x: Faces): string
	return Squash.Ser.Boolean(x.Top, x.Bottom, x.Left, x.Right, x.Back, x.Front) --This marty, is how we squash 6 booleans into 1 byte
end

--[[
	@within Squash
]]
function Squash.Des.Faces(y: string): Faces
	local faces = Faces.new()
	faces.Top, faces.Bottom, faces.Left, faces.Right, faces.Back, faces.Front = Squash.Des.Boolean(y)
	return faces
end

--[[
	@within Squash
]]
Squash.Ser.Array.Faces = serArrayInstance(Squash.Ser.Faces)

--[[
	@within Squash
]]
Squash.Des.Array.Faces = desArrayInstance(1, Squash.Des.Faces)

--[[
	@within Squash
]]
function Squash.Ser.RbxAssetId(x: number): string
	return Squash.Ser.Uint(6, x)
end

--[[
	@within Squash
]]
function Squash.Des.RbxAssetId(y: string): number
	return Squash.Des.Uint(6, y)
end

--[[
	@within Squash
]]
Squash.Ser.Array.RbxAssetId = serArrayInstance(Squash.Ser.RbxAssetId)

--[[
	@within Squash
]]
Squash.Des.Array.RbxAssetId = desArrayInstance(6, Squash.Des.RbxAssetId)

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
