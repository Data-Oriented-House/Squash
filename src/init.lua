--!strict

--[[
	@class Squash

	Provides a set of functions for serializing and deserializing data in both single and array forms.
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

local function bytesAssert(bytes: number)
	if bytes ~= math.floor(bytes) or bytes < 1 or bytes > 8 then error 'bytes must be 1, 2, 3, 4, 5, 6, 7, or 8' end
end

local function serArrayNumber<T>(ser: (x: T, bytes: number?) -> string)
	return function(x: { T }, bytes: number?): string
		local bytes = bytes or 4
		bytesAssert(bytes)

		local y = {}
		for i, v in x do
			y[i] = ser(v, bytes)
		end
		return table.concat(y)
	end
end

local function desArrayNumber<T>(des: (y: string, bytes: number?) -> T)
	return function(y: string, bytes: number?): { T }
		local bytes = bytes or 4
		bytesAssert(bytes)

		local x = {}
		for i = 1, #y / bytes do
			local a = bytes * (i - 1) + 1
			local b = bytes * i
			x[i] = des(string.sub(y, a, b), bytes)
		end
		return x
	end
end

--[[
	@within Squash
]]
function Squash.Ser.Uint(
	x: number,
	bytes: number?
): string --TODO: Consider using string.pack and working around the 3, 5, 6, and 7 byte limitations
	local bytes = bytes or 4
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
function Squash.Des.Uint(y: string, bytes: number?): number
	local bytes = bytes or 4
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
function Squash.Ser.Int(x: number, bytes: number?): string
	local bytes = bytes or 4
	bytesAssert(bytes)

	local sx = if x < 0 then x + 256 ^ bytes else x
	return Squash.Ser.Uint(bytes, sx)
end

--[[
	@within Squash
]]
function Squash.Des.Int(y: string, bytes: number?): number
	local bytes = bytes or 4
	bytesAssert(bytes)

	local x = Squash.Des.Uint(y, bytes)
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

local function floatAssert(bytes: number)
	if not (bytes == 4 or bytes == 8) then
		error(`Expected 4 or 8 bytes. Invalid number of bytes for floating point: {bytes}`)
	end
end

--[[
	@within Squash
]]
function Squash.Ser.Float(x: number, bytes: number?): string
	local bytes = bytes or 4
	floatAssert(bytes)
	return string.pack(if bytes == 4 then 'f' else 'd', x)
end

--[[
	@within Squash
]]
function Squash.Des.Float(y: string, bytes: number?): number
	local bytes = bytes or 4
	floatAssert(bytes)
	return string.unpack(if bytes == 4 then 'f' else 'd', y)
end

--[[
	@within Squash
--]]
Squash.Ser.Array.Float = serArrayNumber(Squash.Ser.Float)

--[[
	@within Squash
--]]
Squash.Des.Array.Float = desArrayNumber(Squash.Des.Float)

type NumberSer = typeof(Squash.Ser.Int)
type NumberDes = typeof(Squash.Des.Int)

local function serArrayVector<T>(serializer: (vector: T, ser: NumberSer, bytes: number?) -> string)
	return function(x: { T }, ser: NumberSer?, bytes: number?): string
		local bytes = bytes or 4
		local encoding = ser or Squash.Ser.Int
		local y = {}
		for i, v in x do
			y[i] = serializer(v, encoding, bytes)
		end
		return table.concat(y)
	end
end

local function desArrayVector<T>(elements: number, deserializer: (y: string, des: NumberDes?, bytes: number?) -> T)
	return function(y: string, des: NumberDes?, bytes: number?): { T }
		local bytes = bytes or 4
		local decoding = des or Squash.Des.Int
		local x = {}
		for i = 1, #y / (elements * bytes) do
			local a = elements * bytes * (i - 1) + 1
			local b = elements * bytes * i
			x[i] = deserializer(string.sub(y, a, b), decoding, bytes)
		end
		return x
	end
end

--[[
	@within Squash
]]
function Squash.Ser.Vector2(x: Vector2, ser: NumberSer?, bytes: number?): string
	local bytes = bytes or 4
	local encoding = ser or Squash.Ser.Int
	return encoding(bytes, x.X) .. encoding(bytes, x.Y)
end

--[[
	@within Squash
]]
function Squash.Des.Vector2(y: string, des: NumberDes?, bytes: number?): Vector2
	local bytes = bytes or 4
	local decoding = des or Squash.Des.Int
	return Vector2.new(decoding(string.sub(y, 1, bytes), bytes), decoding(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[[
	@within Squash
--]]
Squash.Ser.Array.Vector2 = serArrayVector(Squash.Ser.Vector2)

--[[
	@within Squash
--]]
Squash.Des.Array.Vector2 = desArrayVector(2, Squash.Des.Vector2)

--[[
	@within Squash
]]
function Squash.Ser.Vector3(x: Vector3, ser: NumberSer?, bytes: number?): string
	local bytes = bytes or 4
	local encoding = ser or Squash.Ser.Int
	return encoding(bytes, x.X) .. encoding(bytes, x.Y) .. encoding(bytes, x.Z)
end

--[[
	@within Squash
]]
function Squash.Des.Vector3(y: string, des: NumberDes?, bytes: number?): Vector3
	local bytes = bytes or 4
	local decoding = des or Squash.Des.Int
	return Vector3.new(
		decoding(string.sub(y, 1, bytes), bytes),
		decoding(string.sub(y, bytes + 1, 2 * bytes), bytes),
		decoding(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes)
	)
end

--[[
	@within Squash
--]]
Squash.Ser.Array.Vector3 = serArrayVector(Squash.Ser.Vector3)

--[[
	@within Squash
--]]
Squash.Des.Array.Vector3 = desArrayVector(3, Squash.Des.Vector3)

local function serArrayFixed<T>(ser: (T) -> string)
	return function(x: { T }): string
		local y = {}
		for i, v in x do
			y[i] = ser(v)
		end
		return table.concat(y)
	end
end

local function desArrayFixed<T>(des: (string) -> T, bytes: number?)
	local bytes = bytes or 4
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
	@within Squash
]]
function Squash.Ser.Vector2int16(x: Vector2int16)
	return Squash.Ser.Int(2, x.X) .. Squash.Ser.Int(2, x.Y)
end

--[[
	@within Squash
]]
function Squash.Des.Vector2int16(y: string): Vector2int16
	return Vector2int16.new(Squash.Des.Int(string.sub(y, 1, 2), 2), Squash.Des.Int(string.sub(y, 3, 4), 2))
end

--[[
	@within Squash
]]
Squash.Ser.Array.Vector2int16 = serArrayFixed(Squash.Ser.Vector2int16)

--[[
	@within Squash
]]
Squash.Des.Array.Vector2int16 = desArrayFixed(Squash.Des.Vector2int16, 4)

--[[
	@within Squash
]]
function Squash.Ser.Vector3int16(x: Vector3int16)
	return Squash.Ser.Int(2, x.X) .. Squash.Ser.Int(2, x.Y) .. Squash.Ser.Int(2, x.Z)
end

--[[
	@within Squash
]]
function Squash.Des.Vector3int16(y: string): Vector3int16
	return Vector3int16.new(
		Squash.Des.Int(string.sub(y, 1, 2), 2),
		Squash.Des.Int(string.sub(y, 3, 4), 2),
		Squash.Des.Int(string.sub(y, 5, 6), 2)
	)
end

--[[
	@within Squash
]]
Squash.Ser.Array.Vector3int16 = serArrayFixed(Squash.Ser.Vector3int16)

--[[
	@within Squash
]]
Squash.Des.Array.Vector3int16 = desArrayFixed(Squash.Des.Vector3int16, 6)

local function serAngle(x: number): string
	return Squash.Ser.Uint(2, (x + math.pi) % (2 * math.pi) * 65535)
end

local function desAngle(y: string): number
	return Squash.Des.Uint(y, 2) / 65535 - math.pi
end

--[[
	@within Squash
]]
function Squash.Ser.CFrame(x: CFrame, ser: NumberSer?, posBytes: number?): string
	local posBytes = posBytes or 4
	local encoding = ser or Squash.Ser.Int

	local rx, ry, rz = x:ToOrientation()
	local px, py, pz = x.Position.X, x.Position.Y, x.Position.Z

	return serAngle(rx)
		.. serAngle(ry)
		.. serAngle(rz)
		.. encoding(posBytes, px)
		.. encoding(posBytes, py)
		.. encoding(posBytes, pz)
end

--[[
	@within Squash
]]
function Squash.Des.CFrame(y: string, des: NumberDes?, posBytes: number?): CFrame
	local posBytes = posBytes or 4
	local decoding = des or Squash.Des.Int

	local rx = desAngle(string.sub(y, 1, 2))
	local ry = desAngle(string.sub(y, 3, 4))
	local rz = desAngle(string.sub(y, 5, 6))

	local px = decoding(string.sub(y, 7, 7 + posBytes - 1), posBytes)
	local py = decoding(string.sub(y, 7 + posBytes, 7 + 2 * posBytes - 1), posBytes)
	local pz = decoding(string.sub(y, 7 + 2 * posBytes, 7 + 3 * posBytes - 1), posBytes)

	return CFrame.Angles(rx, ry, rz) + Vector3.new(px, py, pz)
end

--[[
	@within Squash
]]
Squash.Ser.Array.CFrame = serArrayVector(Squash.Ser.CFrame)

--[[
	@within Squash
]]
function Squash.Des.Array.CFrame(posBytes: number, y: string, des: NumberDes?): { CFrame }
	local decoding = des or Squash.Des.Int
	local bytes = 7 + 3 * posBytes

	local x = {}
	for i = 1, #y / bytes do
		local a = bytes * (i - 1) + 1
		local b = bytes * i
		x[i] = Squash.Des.CFrame(string.sub(y, a, b), decoding, posBytes)
	end
	return x
end

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
Squash.Ser.Array.Axes = serArrayFixed(Squash.Ser.Axes)

--[[
	@within Squash
--]]
Squash.Des.Array.Axes = desArrayFixed(Squash.Des.Axes, 8)

--[[
	@within Squash
]]
function Squash.Ser.BrickColor(x: BrickColor): string
	return Squash.Ser.Uint(x.Number, 2)
end

--[[
	@within Squash
]]
function Squash.Des.BrickColor(y: string): BrickColor
	return BrickColor.new(Squash.Des.Uint(y, 2))
end

--[[
	@within Squash
]]
Squash.Ser.Array.BrickColor = serArrayFixed(Squash.Ser.BrickColor)

--[[
	@within Squash
]]
Squash.Des.Array.BrickColor = desArrayFixed(Squash.Des.BrickColor, 2)

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
Squash.Ser.Array.Color3 = serArrayFixed(Squash.Ser.Color3)

--[[
	@within Squash
]]
Squash.Des.Array.Color3 = desArrayFixed(Squash.Des.Color3, 3)

local function getBitSize(x: number): number
	return math.ceil(math.log(x, 2 ^ 1))
end

-- local function getByteSize(x: number): number
-- 	return math.ceil(math.log(x, 2 ^ 8))
-- end

local function getEnumData(enum: Enum): ({ EnumItem }, number)
	local enumItems = enum:GetEnumItems()
	local enumSize = getBitSize(#enumItems)
	return enumItems, enumSize
end

local bundleTypes, bundleTypeSize = getEnumData(Enum.BundleType)
local avatarAssetTypes, avatarAssetSize = getEnumData(Enum.AvatarAssetType)
local salesTypeFilters, salesTypeFilterSize = getEnumData(Enum.SalesTypeFilter)
local catalogCategoryFilters, catalogCategoryFilterSize = getEnumData(Enum.CatalogCategoryFilter)
local catalogSortAggregations, catalogSortAggregationSize = getEnumData(Enum.CatalogSortAggregation)
local catalogSortTypes, catalogSortSize = getEnumData(Enum.CatalogSortType)

local function packBits(x: { number }, bits: number): string
	local packed = {}
	local byte = 0
	local count = 0
	for i = 1, #x do
		for b = bits - 1, 0, -1 do
			byte = byte * 2 + math.floor(x[i] / 2 ^ b) % 2
			count = count + 1
			if count == 8 then
				table.insert(packed, string.char(byte))
				byte = 0
				count = 0
			end
		end
	end
	if count > 0 then
		byte = byte * 2 ^ (8 - count)
		table.insert(packed, string.char(byte))
	end
	return table.concat(packed)
end

local function unpackBits(y: string, bits: number): { number }
	local x = {}
	local value = 0
	local count = 0
	for i = 1, #y do
		local byte = string.byte(y, i)
		for b = 7, 0, -1 do
			value = value * 2 + math.floor(byte / 2 ^ b) % 2
			count = count + 1
			if count == bits then
				table.insert(x, value)
				value = 0
				count = 0
			end
		end
	end
	return x
end

--[[
	@within Squash
]]
function Squash.Ser.CatalogSearchParams(x: CatalogSearchParams): string
	local assetIndices = {}
	for i, v in x.AssetTypes do
		assetIndices[i] = table.find(avatarAssetTypes, v) :: number
	end

	local bundleIndices = {}
	for i, v in x.BundleTypes do
		bundleIndices[i] = table.find(bundleTypes, v) :: number
	end

	return Squash.Ser.Boolean(x.IncludeOffSale)
		.. Squash.Ser.Uint(x.MinPrice, 4)
		.. Squash.Ser.Uint(x.MaxPrice, 4)
		.. Squash.Ser.Uint(table.find(salesTypeFilters, x.SalesTypeFilter) :: number, salesTypeFilterSize)
		.. Squash.Ser.Uint(table.find(catalogCategoryFilters, x.CategoryFilter) :: number, catalogCategoryFilterSize)
		.. Squash.Ser.Uint(table.find(catalogSortAggregations, x.SortAggregation) :: number, catalogSortAggregationSize)
		.. Squash.Ser.Uint(table.find(catalogSortTypes, x.SortType) :: number, catalogSortSize)
		.. packBits(assetIndices, avatarAssetSize)
		.. packBits(bundleIndices, bundleTypeSize)
		.. x.Keyword -- TODO: Squash.Ser.String(x.Keyword)
		.. '\0'
		.. x.Creator -- TODO: Squash.Ser.String(x.Creator)
end

--[[
	@within Squash
]]
function Squash.Des.CatalogSearchParams(y: string): CatalogSearchParams
	local x = CatalogSearchParams.new()
	x.IncludeOffSale = Squash.Des.Boolean(string.sub(y, 1, 1))
	x.MinPrice = Squash.Des.Uint(string.sub(y, 2, 5), 4)
	x.MaxPrice = Squash.Des.Uint(string.sub(y, 6, 9), 4)
	local offset = 10

	x.SalesTypeFilter =
		salesTypeFilters[Squash.Des.Uint(string.sub(y, offset, offset + salesTypeFilterSize - 1), salesTypeFilterSize)]
	offset += salesTypeFilterSize

	x.CategoryFilter = catalogCategoryFilters[Squash.Des.Uint(
		string.sub(y, offset, offset + catalogCategoryFilterSize - 1),
		catalogCategoryFilterSize
	)] :: Enum.CatalogCategoryFilter
	offset += catalogCategoryFilterSize

	x.SortAggregation = catalogSortAggregations[Squash.Des.Uint(
		string.sub(y, offset, offset + catalogSortAggregationSize - 1),
		catalogSortAggregationSize
	)] :: Enum.CatalogSortAggregation
	offset += catalogSortAggregationSize

	x.SortType =
		catalogSortTypes[Squash.Des.Uint(string.sub(y, offset, offset + catalogSortSize - 1), catalogSortSize)] :: Enum.CatalogSortType
	offset += catalogSortSize

	for i, v in unpackBits(string.sub(y, offset, offset + avatarAssetSize - 1), avatarAssetSize) do
		x.AssetTypes[i] = avatarAssetTypes[v] :: Enum.AssetType
	end
	offset += avatarAssetSize

	for i, v in unpackBits(string.sub(y, offset, offset + bundleTypeSize - 1), bundleTypeSize) do
		x.BundleTypes[i] = bundleTypes[v] :: Enum.BundleType
	end
	offset += bundleTypeSize

	local keywordEnd = string.find(sub, '\0')
	x.Keyword = string.sub(sub, offset, keywordEnd - 1)
	x.Creator = string.sub(sub, keywordEnd + 1)
	return x
end

--[[
	@within Squash
]]
Squash.Ser.Array.CatalogSearchParams = serArrayFixed(Squash.Ser.CatalogSearchParams)

--[[
	@within Squash
]]
Squash.Des.Array.CatalogSearchParams = desArrayFixed(Squash.Des.CatalogSearchParams, -1) --TODO: same story

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
	return DateTime.fromUnixTimestamp(Squash.Des.Uint(y, 5) - 17_987_443_200)
end

--[[
	@within Squash
]]
Squash.Ser.Array.DateTime = serArrayFixed(Squash.Ser.DateTime)

--[[
	@within Squash
]]
Squash.Des.Array.DateTime = desArrayFixed(Squash.Des.DateTime, 5)

--[[
	@within Squash
]]
function Squash.Ser.DockWidgetPluginGuiInfo(x: DockWidgetPluginGuiInfo): string
	return Squash.Ser.Boolean(x.InitialEnabled, x.InitialEnabledShouldOverrideRestore)
		.. Squash.Ser.Int(2, x.FloatingXSize)
		.. Squash.Ser.Int(2, x.FloatingYSize)
		.. Squash.Ser.Int(2, x.MinWidth)
		.. Squash.Ser.Int(2, x.MinHeight)
end

--[[
	@within Squash
]]
function Squash.Des.DockWidgetPluginGuiInfo(y: string): DockWidgetPluginGuiInfo
	local x = DockWidgetPluginGuiInfo.new()
	x.InitialEnabled, x.InitialEnabledShouldOverrideRestore = Squash.Des.Boolean(string.sub(y, 1, 1))
	x.FloatingXSize = Squash.Des.Int(string.sub(y, 2, 3), 2)
	x.FloatingYSize = Squash.Des.Int(string.sub(y, 4, 5), 2)
	x.MinWidth = Squash.Des.Int(string.sub(y, 6, 7), 2)
	x.MinHeight = Squash.Des.Int(string.sub(y, 8, 9), 2)
	return x
end

--[[
	@within Squash
]]
Squash.Ser.Array.DockWidgetPluginGuiInfo = serArrayFixed(Squash.Ser.DockWidgetPluginGuiInfo)

--[[
	@within Squash
]]
Squash.Des.Array.DockWidgetPluginGuiInfo = desArrayFixed(Squash.Des.DockWidgetPluginGuiInfo, 9)

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
Squash.Ser.Array.ColorSequenceKeypoint = serArrayFixed(Squash.Ser.ColorSequenceKeypoint)

--[[
	@within Squash
]]
Squash.Des.Array.ColorSequenceKeypoint = desArrayFixed(Squash.Des.ColorSequenceKeypoint, 4)

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
Squash.Ser.Array.ColorSequence = serArrayFixed(Squash.Ser.ColorSequence)

--[[
	@within Squash
]]
Squash.Des.Array.ColorSequence = desArrayFixed(Squash.Des.ColorSequence, 4)

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
Squash.Ser.Array.Faces = serArrayFixed(Squash.Ser.Faces)

--[[
	@within Squash
]]
Squash.Des.Array.Faces = desArrayFixed(Squash.Des.Faces, 1)

local keyInterpolationModes, keyInterpolationModeSize = getEnumData(Enum.KeyInterpolationMode)

--[[
	@within Squash
]]
function Squash.Ser.FloatCurveKey(x: FloatCurveKey): string
	return Squash.Ser.Uint(table.find(keyInterpolationModes, x.Interpolation) :: number, keyInterpolationModeSize)
		.. Squash.Ser.Float(x.Time, 4)
		.. Squash.Ser.Float(x.Value, 4)
		.. Squash.Ser.Float(x.LeftTangent, 4)
		.. Squash.Ser.Float(x.RightTangent, 4)
end

--[[
	@within Squash
]]
function Squash.Des.FloatCurveKey(y: string): FloatCurveKey
	local x = FloatCurveKey.new(
		Squash.Des.Float(string.sub(y, keyInterpolationModeSize + 1, keyInterpolationModeSize + 4), 4),
		Squash.Des.Float(string.sub(y, keyInterpolationModeSize + 5, keyInterpolationModeSize + 8), 4),
		keyInterpolationModes[Squash.Des.Uint(string.sub(y, 1, keyInterpolationModeSize), keyInterpolationModeSize)] :: Enum.KeyInterpolationMode
	)
	x.LeftTangent = Squash.Des.Float(string.sub(y, keyInterpolationModeSize + 9, keyInterpolationModeSize + 12), 4)
	x.RightTangent = Squash.Des.Float(string.sub(y, keyInterpolationModeSize + 13, keyInterpolationModeSize + 16), 4)
	return x
end

--[[
	@within Squash
]]
Squash.Ser.Array.FloatCurveKey = serArrayFixed(Squash.Ser.FloatCurveKey)

--[[
	@within Squash
]]
Squash.Des.Array.FloatCurveKey = desArrayFixed(Squash.Des.FloatCurveKey, keyInterpolationModeSize)

local fontWeights, _ = getEnumData(Enum.FontWeight)

--[[
	@within Squash
]]
function Squash.Ser.Font(x: Font): string
	local family = string.match(x.Family, '(.+)%..+$')
	if not family then error 'Font Family must be a Roblox font' end

	local weightId = table.find(fontWeights, x.Weight) :: number
	local styleAndWeight = string.char(2 * weightId + if x.Style == Enum.FontStyle.Normal then 1 else 0) -- Weight.Value is 100, 200, 300, etc. We want 2, 4, 6, etc. so that we can fit it into a byte without overriding the style bit

	return styleAndWeight .. family -- TODO: This needs a way to be serialized still
end

--[[
	@within Squash
]]
function Squash.Des.Font(y: string): Font
	local styleAndWeight = string.byte(y, 1, 1)
	local family = string.sub(y, 2)

	local style = if styleAndWeight % 2 == 1 then Enum.FontStyle.Normal else Enum.FontStyle.Italic
	local weightId = math.floor(styleAndWeight / 2)
	local fontWeight = fontWeights[weightId] :: Enum.FontWeight

	return Font.new(family, fontWeight, style)
end

--[[
	@within Squash
]]
Squash.Ser.Array.Font = serArrayFixed(Squash.Ser.Font) -- TODO: This needs a way to be serialized still, we have nothing to serialize variable sized strings. It requires a delimiter, C-style.

--[[
	@within Squash
]]
Squash.Des.Array.Font = desArrayFixed(Squash.Des.Font, -1) --TODO: Same story

--[[
	@within Squash
]]
function Squash.Ser.NumberRange(x: NumberRange, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Ser.Int
	local bytes = bytes or 4
	return ser(x.Min, 4) .. ser(x.Max, 4)
end

--[[
	@within Squash
]]
function Squash.Des.NumberRange(y: string, des: NumberDes?, bytes: number?): NumberRange
	local des = des or Squash.Des.Int
	local bytes = bytes or 4
	return NumberRange.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[[
	@within Squash
]]
Squash.Ser.Array.NumberRange = serArrayVector(Squash.Ser.NumberRange)

--[[
	@within Squash
]]
Squash.Des.Array.NumberRange = desArrayVector(2, Squash.Des.NumberRange)

--[[
	@within Squash
]]
function Squash.Ser.OverlapParams(x: OverlapParams): string
	return string.char(
		(if x.FilterType == Enum.RaycastFilterType.Include then 1 else 0) + (if x.RespectCanCollide then 2 else 0)
	) .. Squash.Ser.Uint(2, x.MaxParts) .. x.CollisionGroup -- I wish we could use GetCollisionGroupId and restrict this to 1 or 2 bytes, but that was deprecated. --TODO: Same story
end

--[[
	@within Squash
]]
function Squash.Des.OverlapParams(y: string): OverlapParams
	local filterTypeAndRespectCanCollide = string.byte(y, 1)

	local x = OverlapParams.new()
	x.CollisionGroup = string.sub(y, 4) --TODO: Same story
	x.MaxParts = Squash.Des.Uint(string.sub(y, 2, 3), 2)
	x.RespectCanCollide = filterTypeAndRespectCanCollide >= 2
	x.FilterType = if filterTypeAndRespectCanCollide % 2 == 0
		then Enum.RaycastFilterType.Include
		else Enum.RaycastFilterType.Exclude

	return x
end

--[[
	@within Squash
]]
Squash.Ser.Array.OverlapParams = serArrayFixed(Squash.Ser.OverlapParams) --TODO: Same story

--[[
	@within Squash
]]
Squash.Des.Array.OverlapParams = desArrayFixed(Squash.Des.OverlapParams, -1) --TODO: Same story

--[[
	@within Squash
]]
function Squash.Ser.RaycastParams(x: RaycastParams): string
	return Squash.Ser.Boolean(x.FilterType == Enum.RaycastFilterType.Include, x.IgnoreWater, x.RespectCanCollide)
		.. x.CollisionGroup --TODO: Same story
end

--[[
	@within Squash
]]
function Squash.Des.RaycastParams(y: string): RaycastParams
	local isInclude, ignoreWater, respectCanCollide = Squash.Des.Boolean(string.sub(y, 1, 1))

	local x = RaycastParams.new()
	x.CollisionGroup = string.sub(y, 2) --TODO: Same story
	x.RespectCanCollide = respectCanCollide
	x.IgnoreWater = ignoreWater
	x.FilterType = if isInclude then Enum.RaycastFilterType.Include else Enum.RaycastFilterType.Exclude

	return x
end

--[[
	@within Squash
]]
Squash.Ser.Array.RaycastParams = serArrayFixed(Squash.Ser.RaycastParams) --TODO: Same story

--[[
	@within Squash
]]
Squash.Des.Array.RaycastParams = desArrayFixed(Squash.Des.RaycastParams, -1) --TODO: Same story

--[[
	@within Squash
]]
function Squash.Ser.Region3(x: Region3, ser: NumberSer?, bytes: number?): string
	local bytes = bytes or 4
	return Squash.Ser.Vector3(x.Size, ser, bytes) .. Squash.Ser.CFrame(x.CFrame, ser, bytes)
end

--[[
	@within Squash
]]
function Squash.Des.Region3(y: string, des: NumberDes?, bytes: number?): Region3
	local bytes = bytes or 4
	local x = Region3.new(Vector3.zero, Vector3.zero)
	x.Size = Squash.Des.Vector3(string.sub(y, 1, 12), des, bytes)
	x.CFrame = Squash.Des.CFrame(string.sub(y, 13, 24), des, bytes)
	return x
end

--[[
	@within Squash
]]
Squash.Ser.Array.Region3 = serArrayVector(Squash.Ser.Region3)

--[[
	@within Squash
]]
function Squash.Des.Array.Region3(y: string, des: NumberDes?, bytes: number?): { Region3 }
	local bytes = bytes or 4
	local decode = des or Squash.Des.Int
	local size = 6 + 9 * bytes

	local x = {}
	for i = 1, #y / size do
		x[i] = Squash.Des.Region3(string.sub(y, (i - 1) * size + 1, i * size), decode, bytes)
	end
	return x
end

--[[
	@within Squash
]]
function Squash.Ser.Region3int16(x: Region3int16): string
	return Squash.Ser.Vector3int16(x.Min) .. Squash.Ser.Vector3int16(x.Max)
end

--[[
	@within Squash
]]
function Squash.Des.Region3int16(y: string): Region3int16
	return Region3int16.new(Squash.Des.Vector3int16(string.sub(y, 1, 6)), Squash.Des.Vector3int16(string.sub(y, 7, 12)))
end

--[[
	@within Squash
]]
Squash.Ser.Array.Region3int16 = serArrayFixed(Squash.Ser.Region3int16)

--[[
	@within Squash
]]
Squash.Des.Array.Region3int16 = desArrayFixed(Squash.Des.Region3int16, 12)

return Squash

-- Squash.Ser.Rbx = {}
-- Squash.Des.Rbx = {}

-- local fileExtensions = {
-- 	'png',
-- 	'gif',
-- 	'jpg',
-- 	'jpeg',
-- 	'tga',
-- 	'bmp',
-- 	'fbx',
-- 	'obj',
-- 	'mp3',
-- 	'ogg',
-- 	'webm',
-- 	'wav',
-- 	'mp4',
-- 	'rbxm',
-- 	'rbxmx',
-- 	'rbxl',
-- 	'rbxlx',
-- 	'mesh',
-- 	'midi',
-- 	'txt',
-- }

-- local thumbTypes = {
-- 	'Asset',
-- 	'Avatar',
-- 	'AvatarHeadShot',
-- 	'BadgeIcon',
-- 	'BundleThumbnail',
-- 	'FontFamily',
-- 	'GameIcon',
-- 	'GamePass',
-- 	'GroupIcon',
-- 	'Outfit',
-- }

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.Ser.Rbx.Asset(id: number): string
-- 	return Squash.Ser.Uint(6, id)
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.Des.Rbx.Asset(y: string): number
-- 	return Squash.Des.Uint(6, y)
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.Ser.Rbx.AssetPath(path: string, extension: string): string
-- 	local extensionId = table.find(fileExtensions, extension)
-- 	assert(extensionId, 'Invalid extension "' .. extension .. '"')

-- 	return Squash.Ser.Uint(1, extensionId) .. path --TODO: Implement string compression and use it here
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.Des.Rbx.AssetPath(y: string): (string, string)
-- 	local extensionId = Squash.Des.Uint(1, string.sub(y, 1))
-- 	local path = string.sub(y, 2, -1) --TODO: Implement variable sized string decompression and use it here
-- 	return path, fileExtensions[extensionId]
-- end

-- --[[
-- rbxasset
-- 	rbxasset://<relative_file_path>
-- 		relative_file_path: <string/string.string>.<extension>

-- rbxthumb
-- 	rbxthumb://type=<type>&id=<id>&w=<width>&h=<height>[&filters=circular]
-- 		type: Asset, Avatar, AvatarHeadShot, BadgeIcon, BundleThumbnail, FontFamily, GameIcon, GamePass, GroupIcon, Outfit
-- 		id: <number>
-- 		width: <number>
-- 		height: <number>
-- 		filters: circular

-- rbxhttp
-- 	rbxhttp://<relative_url_path>
-- 		relative_url_path: <string>

-- 		rbxhttp://Thumbs/Avatar.ashx?x=100&y=100&format=png

-- https/http
-- 	This goes on for a very long time, so

-- 	http://www.roblox.com/<string>
-- 	https://www.roblox.com/<string>
-- ]]

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.Ser.Rbx.Thumb(thumbType: string, id: number, width: number, height: number, filters: string?): string
-- 	local thumbTypeId = table.find(thumbTypes, thumbType)
-- 	assert(thumbTypeId, 'Invalid thumb type "' .. thumbType .. '"')

-- 	return table.concat {
-- 		string.char(2 * thumbTypeId + if filters == 'circular' then 1 else 0),
-- 		Squash.Ser.Uint(5, id),
-- 		Squash.Ser.Uint(2, width),
-- 		Squash.Ser.Uint(2, height),
-- 	}
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.Des.Rbx.Thumb(y: string): (string, number, number, number, string?)
-- 	local thumbTypeIdAndFilters = Squash.Des.Uint(1, string.sub(y, 1))
-- 	local thumbType = thumbTypes[math.floor(thumbTypeIdAndFilters / 2)]
-- 	local filters = thumbTypeIdAndFilters % 2 == 1 and 'circular' or nil

-- 	local id = Squash.Des.Uint(5, string.sub(y, 2, 6))
-- 	local width = Squash.Des.Uint(2, string.sub(y, 7, 8))
-- 	local height = Squash.Des.Uint(2, string.sub(y, 9, 10))

-- 	return thumbType, id, width, height, filters
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.Ser.Rbx.Http(path: string, posx: number, posy: number, format: string): string
-- 	local formatId = table.find(fileExtensions, format)
-- 	assert(formatId, 'Invalid format "' .. format .. '"')

-- 	return table.concat {
-- 		Squash.Ser.Uint(1, formatId),
-- 		Squash.Ser.Uint(2, posx),
-- 		Squash.Ser.Uint(2, posy),
-- 		path,
-- 	}
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.Des.Rbx.Http(y: string): (string, number, number, string)
-- 	local formatId = Squash.Des.Uint(1, string.sub(y, 1))
-- 	local posx = Squash.Des.Uint(2, string.sub(y, 2, 3))
-- 	local posy = Squash.Des.Uint(2, string.sub(y, 4, 5))
-- 	local path = string.sub(y, 6, -1)
-- 	local format = fileExtensions[formatId]
-- 	return path, posx, posy, format
-- end

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
