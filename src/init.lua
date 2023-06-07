--!strict

local Squash = {}

-- Duplication Reducers --

type NumberSer = (x: number, bytes: number?) -> string
type NumberDes = (y: string, bytes: number?) -> number

local bytesAssert = function(bytes: number)
	if bytes ~= math.floor(bytes) or bytes < 1 or bytes > 8 then
		error 'bytes must be 1, 2, 3, 4, 5, 6, 7, or 8'
	end
end

local floatAssert = function(bytes: number)
	if bytes ~= 4 and bytes ~= 8 then
		error(`Expected 4 or 8 bytes. Invalid number of bytes for floating point: {bytes}`)
	end
end

local serArrayNumber = function<T>(ser: (x: T, bytes: number?) -> string)
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

local desArrayNumber = function<T>(des: (y: string, bytes: number?) -> T)
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

local serArrayFixed = function<T>(ser: (T) -> string)
	return function(x: { T }): string
		local y = {}
		for i, v in x do
			y[i] = ser(v)
		end
		return table.concat(y)
	end
end

local desArrayFixed = function<T>(des: (string) -> T, bytes: number)
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

local serArrayVector = function<T>(serializer: (vector: T, ser: NumberSer, bytes: number?) -> string)
	return function(x: { T }, ser: NumberSer?, bytes: number?): string
		local bytes = bytes or 4
		local encoding = ser or Squash.Int.Ser

		local y = {}
		for i, v in x do
			y[i] = serializer(v, encoding, bytes)
		end
		return table.concat(y)
	end
end

local desArrayVector = function<T>(
	deserializer: (y: string, des: NumberDes?, bytes: number?) -> T,
	elements: number,
	offsetBytes: number
)
	return function(y: string, des: NumberDes?, bytes: number?): { T }
		local bytes = bytes or 4
		local decoding = des or Squash.Int.Des

		local size = offsetBytes + elements * bytes
		local x = {}
		for i = 1, #y / size do
			local a = size * (i - 1) + 1
			local b = size * i
			x[i] = deserializer(string.sub(y, a, b), decoding, bytes)
		end
		return x
	end
end

local serArrayVectorNoCoding = function<T>(serializer: (vector: T, bytes: number?) -> string)
	return function(x: { T }, bytes: number?): string
		local bytes = bytes or 4

		local y = {}
		for i, v in x do
			y[i] = serializer(v, bytes)
		end
		return table.concat(y)
	end
end

local desArrayVectorNoCoding = function<T>(
	deserializer: (y: string, bytes: number?) -> T,
	elements: number,
	offsetBytes: number
)
	return function(y: string, bytes: number?): { T }
		local bytes = bytes or 4

		local size = offsetBytes + elements * bytes
		local x = {}
		for i = 1, #y / size do
			local a = size * (i - 1) + 1
			local b = size * i
			x[i] = deserializer(string.sub(y, a, b), bytes)
		end
		return x
	end
end

local serAngle = function(x: number): string
	return Squash.UInt.Ser(2, (x + math.pi) % (2 * math.pi) * 65535)
end

local desAngle = function(y: string): number
	return Squash.UInt.Des(y, 2) / 65535 - math.pi
end

local getBitSize = function(x: number): number
	return math.ceil(math.log(x, 2 ^ 1))
end

local getByteSize = function(x: number): number
	return math.ceil(math.log(x, 2 ^ 8))
end

local getItemData = function<T>(array: { T }): { items: { T }, bits: number, bytes: number }
	return {
		items = array,
		bits = getBitSize(#array),
		bytes = getByteSize(#array),
	}
end

local enumData = getItemData(Enum:GetEnums())
local enumItemData = {}
for _, enum in enumData.items do
	enumItemData[enum] = getItemData(enum:GetEnumItems())
end

local packBits = function(x: { number }, bits: number): string
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

local unpackBits = function(y: string, bits: number): { number }
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

local desEnumItem = function<T>(y: string, offset: number, enum: T & Enum): (number, T & EnumItem)
	local enumData = enumItemData[enum]
	local enumItemId = Squash.UInt.Des(string.sub(y, offset, offset + enumData.bytes - 1), enumData.bytes)
	return offset + enumData.bytes, enumData.items[enumItemId]
end

-- Actual API --

--[[
	@class Bool
]]
Squash.Bool = {}

--[[
	@within Bool
]]
Squash.Bool.Ser = function(
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
	@within Bool
]]
Squash.Bool.Des = function(y: string): (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean)
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
	@within Bool
--]]
Squash.Bool.SerArr = function(x: { boolean }): string
	local y = {}
	for i = 1, math.ceil(#x / 8) do
		y[i] = Squash.Bool.Ser(x[i + 0], x[i + 1], x[i + 2], x[i + 3], x[i + 4], x[i + 5], x[i + 6], x[i + 7])
	end
	return table.concat(y)
end

--[[
	@within Bool
--]]

Squash.Bool.DesArr = function(y: string): { boolean }
	local x = {}
	for i = 1, #y do
		local j = 8 * i
		x[j - 7], x[j - 6], x[j - 5], x[j - 4], x[j - 3], x[j - 2], x[j - 1], x[j] =
			Squash.Bool.Des(string.sub(y, i, i))
	end
	return x
end

--[[
	@class UInt
]]
Squash.UInt = {}

--[[
	@within UInt
]]
Squash.UInt.Ser = function(
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
	@within UInt
]]
Squash.UInt.Des = function(y: string, bytes: number?): number
	local bytes = bytes or 4
	bytesAssert(bytes)

	local sum = 0
	for i = 1, bytes do
		sum += string.byte(y, i) * 256 ^ (i - 1)
	end
	return sum
end

--[[
	@within UInt
--]]
Squash.UInt.SerArr = serArrayNumber(Squash.UInt.Ser)

--[[
	@within UInt
--]]
Squash.UInt.DesArr = desArrayNumber(Squash.UInt.Des)

--[[
	@class Int
]]
Squash.Int = {}

--[[
	@within Int
]]
Squash.Int.Ser = function(x: number, bytes: number?): string
	local bytes = bytes or 4
	bytesAssert(bytes)

	local sx = if x < 0 then x + 256 ^ bytes else x
	return Squash.UInt.Ser(bytes, sx)
end

--[[
	@within Int
]]
Squash.Int.Des = function(y: string, bytes: number?): number
	local bytes = bytes or 4
	bytesAssert(bytes)

	local x = Squash.UInt.Des(y, bytes)
	return if x > 0.5 * 256 ^ bytes - 1 then x - 256 ^ bytes else x
end

--[[
	@within Int
--]]
Squash.Int.SerArr = serArrayNumber(Squash.Int.Ser)

--[[
	@within Int
--]]
Squash.Int.DesArr = desArrayNumber(Squash.Int.Des)

--[[
	@class Float
]]
Squash.Float = {}

--[[
	@within Float
]]
Squash.Float.Ser = function(x: number, bytes: number?): string
	local bytes = bytes or 4
	floatAssert(bytes)
	return string.pack(if bytes == 4 then 'f' else 'd', x)
end

--[[
	@within Float
]]
Squash.Float.Des = function(y: string, bytes: number?): number
	local bytes = bytes or 4
	floatAssert(bytes)
	return string.unpack(if bytes == 4 then 'f' else 'd', y)
end

--[[
	@within Float
--]]
Squash.Float.SerArr = serArrayNumber(Squash.Float.Ser)

--[[
	@within Float
--]]
Squash.Float.DesArr = desArrayNumber(Squash.Float.Des)

--[[
	@class Vector2
]]
Squash.Vector2 = {}

--[[
	@within Vector2
]]
Squash.Vector2.Ser = function(x: Vector2, ser: NumberSer?, bytes: number?): string
	local bytes = bytes or 4
	local encoding = ser or Squash.Int.Ser
	return encoding(bytes, x.X) .. encoding(bytes, x.Y)
end

--[[
	@within Vector2
]]
Squash.Vector2.Des = function(y: string, des: NumberDes?, bytes: number?): Vector2
	local bytes = bytes or 4
	local decoding = des or Squash.Int.Des
	return Vector2.new(decoding(string.sub(y, 1, bytes), bytes), decoding(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[[
	@within Vector2
--]]
Squash.Vector2.SerArr = serArrayVector(Squash.Vector2.Ser)

--[[
	@within Vector2
--]]
Squash.Vector2.DesArr = desArrayVector(Squash.Vector2.Des, 2, 0)

--[[
	@class Vector3
]]
Squash.Vector3 = {}

--[[
	@within Vector3
]]
Squash.Vector3.Ser = function(x: Vector3, ser: NumberSer?, bytes: number?): string
	local bytes = bytes or 4
	local encoding = ser or Squash.Int.Ser
	return encoding(bytes, x.X) .. encoding(bytes, x.Y) .. encoding(bytes, x.Z)
end

--[[
	@within Vector3
]]
Squash.Vector3.Des = function(y: string, des: NumberDes?, bytes: number?): Vector3
	local bytes = bytes or 4
	local decoding = des or Squash.Int.Des
	return Vector3.new(
		decoding(string.sub(y, 1, bytes), bytes),
		decoding(string.sub(y, bytes + 1, 2 * bytes), bytes),
		decoding(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes)
	)
end

--[[
	@within Vector3
--]]
Squash.Vector3.SerArr = serArrayVector(Squash.Vector3.Ser)

--[[
	@within Vector3
--]]
Squash.Vector3.DesArr = desArrayVector(Squash.Vector3.Des, 3, 0)

--[[
	@class Vector2int16
]]
Squash.Vector2int16 = {}

--[[
	@within Vector2int16
]]
Squash.Vector2int16.Ser = function(x: Vector2int16)
	return Squash.Int.Ser(2, x.X) .. Squash.Int.Ser(2, x.Y)
end

--[[
	@within Vector2int16
]]
Squash.Vector2int16.Des = function(y: string): Vector2int16
	return Vector2int16.new(Squash.Int.Des(string.sub(y, 1, 2), 2), Squash.Int.Des(string.sub(y, 3, 4), 2))
end

--[[
	@within Vector2int16
]]
Squash.Vector2int16.SerArr = serArrayFixed(Squash.Vector2int16.Ser)

--[[
	@within Vector2int16
]]
Squash.Vector2int16.DesArr = desArrayFixed(Squash.Vector2int16.Des, 4)

--[[
	@class Vector3int16
]]
Squash.Vector3int16 = {}

--[[
	@within Vector3int16
]]
Squash.Vector3int16.Ser = function(x: Vector3int16)
	return Squash.Int.Ser(2, x.X) .. Squash.Int.Ser(2, x.Y) .. Squash.Int.Ser(2, x.Z)
end

--[[
	@within Vector3int16
]]
Squash.Vector3int16.Des = function(y: string): Vector3int16
	return Vector3int16.new(
		Squash.Int.Des(string.sub(y, 1, 2), 2),
		Squash.Int.Des(string.sub(y, 3, 4), 2),
		Squash.Int.Des(string.sub(y, 5, 6), 2)
	)
end

--[[
	@within Vector3int16
]]
Squash.Vector3int16.SerArr = serArrayFixed(Squash.Vector3int16.Ser)

--[[
	@within Vector3int16
]]
Squash.Vector3int16.DesArr = desArrayFixed(Squash.Vector3int16.Des, 6)

--[[
	@class CFrame
]]
Squash.CFrame = {}

--[[
	@within CFrame
]]
Squash.CFrame.Ser = function(x: CFrame, ser: NumberSer?, posBytes: number?): string
	local posBytes = posBytes or 4
	local encoding = ser or Squash.Int.Ser

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
	@within CFrame
]]
Squash.CFrame.Des = function(y: string, des: NumberDes?, posBytes: number?): CFrame
	local posBytes = posBytes or 4
	local decoding = des or Squash.Int.Des

	local rx = desAngle(string.sub(y, 1, 2))
	local ry = desAngle(string.sub(y, 3, 4))
	local rz = desAngle(string.sub(y, 5, 6))

	local px = decoding(string.sub(y, 7, 7 + posBytes - 1), posBytes)
	local py = decoding(string.sub(y, 7 + posBytes, 7 + 2 * posBytes - 1), posBytes)
	local pz = decoding(string.sub(y, 7 + 2 * posBytes, 7 + 3 * posBytes - 1), posBytes)

	return CFrame.Angles(rx, ry, rz) + Vector3.new(px, py, pz)
end

--[[
	@within CFrame
]]
Squash.CFrame.SerArr = serArrayVector(Squash.CFrame.Ser)

--[[
	@within CFrame
]]
Squash.CFrame.DesArr = function(posBytes: number, y: string, des: NumberDes?): { CFrame }
	local decoding = des or Squash.Int.Des
	local bytes = 7 + 3 * posBytes

	local x = {}
	for i = 1, #y / bytes do
		local a = bytes * (i - 1) + 1
		local b = bytes * i
		x[i] = Squash.CFrame.Des(string.sub(y, a, b), decoding, posBytes)
	end
	return x
end

--[[
	@class Enum
]]
Squash.Enum = {}

--[[
	@within Enum
]]
Squash.Enum.Ser = function(enum: Enum): string
	local enumData = enumItemData[enum]
	local enumId = table.find(enumData.items, enum) :: number
	return Squash.UInt.Ser(enumId, enumData.bytes)
end

--[[
	@within Enum
]]
Squash.Enum.Des = function(y: string): Enum
	local enumId = Squash.UInt.Des(y, enumData.bytes)
	return enumData.items[enumId]
end

--[[
	@class EnumItem
]]
Squash.EnumItem = {}

--[[
	@within EnumItem
]]
Squash.EnumItem.Ser = function(enumItem: EnumItem): string
	local enumData = enumItemData[enumItem.EnumType]
	local enumItemId = table.find(enumData.items, enumItem) :: number
	return Squash.UInt.Ser(enumItemId, enumData.bytes)
end

--[[
	@within EnumItem
]]
Squash.EnumItem.Des = function(y: string, enum: Enum): EnumItem
	local enumData = enumItemData[enum]
	local enumItemId = Squash.UInt.Des(y, enumData.bytes)
	return enumData.items[enumItemId]
end

--[[
	@class Axes
]]
Squash.Axes = {}

--[[
	@within Axes
]]
Squash.Axes.Ser = function(x: Axes)
	return Squash.Bool.Ser(x.X, x.Y, x.Z) .. Squash.Bool.Ser(x.Top, x.Bottom, x.Left, x.Right, x.Back, x.Front)
end

--[[
	@within Axes
]]
Squash.Axes.Des = function(y: string): Axes
	local axes = Axes.new()
	axes.X, axes.Y, axes.Z = Squash.Bool.Des(string.sub(y, 1))
	axes.Top, axes.Bottom, axes.Left, axes.Right, axes.Back, axes.Front = Squash.Bool.Des(string.sub(y, 2))
	return axes
end

--[[
	@within Axes
--]]
Squash.Axes.SerArr = serArrayFixed(Squash.Axes.Ser)

--[[
	@within Axes
--]]
Squash.Axes.DesArr = desArrayFixed(Squash.Axes.Des, 8)

--[[
	@class BrickColor
]]
Squash.BrickColor = {}

--[[
	@within BrickColor
]]
Squash.BrickColor.Ser = function(x: BrickColor): string
	return Squash.UInt.Ser(x.Number, 2)
end

--[[
	@within BrickColor
]]
Squash.BrickColor.Des = function(y: string): BrickColor
	return BrickColor.new(Squash.UInt.Des(y, 2))
end

--[[
	@within BrickColor
]]
Squash.BrickColor.SerArr = serArrayFixed(Squash.BrickColor.Ser)

--[[
	@within BrickColor
]]
Squash.BrickColor.DesArr = desArrayFixed(Squash.BrickColor.Des, 2)

--[[
	@class Color3
]]
Squash.Color3 = {}

--[[
	@within Color3
]]
Squash.Color3.Ser = function(x: Color3): string
	return string.char(x.R * 255, x.G * 255, x.B * 255)
end

--[[
	@within Color3
]]
Squash.Color3.Des = function(y: string): Color3
	return Color3.fromRGB(string.byte(y, 1), string.byte(y, 2), string.byte(y, 3))
end

--[[
	@within Color3
]]
Squash.Color3.SerArr = serArrayFixed(Squash.Color3.Ser)

--[[
	@within Color3
]]
Squash.Color3.DesArr = desArrayFixed(Squash.Color3.Des, 3)

--[[
	@class CatalogSearchParams
]]
Squash.CatalogSearchParams = {}

--[[
	@within CatalogSearchParams
]]
Squash.CatalogSearchParams.Ser = function(x: CatalogSearchParams): string
	local assetIndices = {}
	for i, v in x.AssetTypes do
		assetIndices[i] = table.find(enumItemData[Enum.AssetType].items, v) :: number
	end

	local bundleIndices = {}
	for i, v in x.BundleTypes do
		bundleIndices[i] = table.find(enumItemData[Enum.BundleType].items, v) :: number
	end

	return Squash.Bool.Ser(x.IncludeOffSale)
		.. Squash.UInt.Ser(x.MinPrice, 4)
		.. Squash.UInt.Ser(x.MaxPrice, 4)
		.. Squash.EnumItem.Ser(x.SalesTypeFilter)
		.. Squash.EnumItem.Ser(x.CategoryFilter)
		.. Squash.EnumItem.Ser(x.SortAggregation)
		.. Squash.EnumItem.Ser(x.SortType)
		.. packBits(assetIndices, enumItemData[Enum.AssetType].bits)
		.. packBits(bundleIndices, enumItemData[Enum.BundleType].bits)
		.. x.Keyword -- TODO: Squash.Ser.String(x.Keyword)
		.. '\0'
		.. x.Creator -- TODO: Squash.Ser.String(x.Creator)
end

--[[
	@within CatalogSearchParams
]]
Squash.CatalogSearchParams.Des = function(y: string): CatalogSearchParams
	local x = CatalogSearchParams.new()
	x.IncludeOffSale = Squash.Bool.Des(string.sub(y, 1, 1))
	x.MinPrice = Squash.UInt.Des(string.sub(y, 2, 5), 4)
	x.MaxPrice = Squash.UInt.Des(string.sub(y, 6, 9), 4)

	local offset = 10
	offset, x.SalesTypeFilter = desEnumItem(y, offset, Enum.SalesTypeFilter)
	offset, x.CategoryFilter = desEnumItem(y, offset, Enum.CatalogCategoryFilter)
	offset, x.SortAggregation = desEnumItem(y, offset, Enum.CatalogSortAggregation)
	offset, x.SortType = desEnumItem(y, offset, Enum.CatalogSortType)

	local assetTypeData = enumItemData[Enum.AssetType]
	for i, v in unpackBits(string.sub(y, offset, offset + assetTypeData.bytes - 1), assetTypeData.bits) do
		x.AssetTypes[i] = assetTypeData[v]
	end
	offset += assetTypeData.bytes

	local bundleTypeData = enumItemData[Enum.BundleType]
	for i, v in unpackBits(string.sub(y, offset, offset + bundleTypeData.bytes - 1), bundleTypeData.bits) do
		x.BundleTypes[i] = bundleTypeData[v]
	end
	offset += bundleTypeData.bytes

	local keywordEnd = string.find(y, '\0')
	x.Keyword = string.sub(y, offset, keywordEnd - 1)
	x.Creator = string.sub(y, keywordEnd + 1)
	return x
end

--[[
	@within CatalogSearchParams
]]
Squash.CatalogSearchParams.SerArr = serArrayFixed(Squash.CatalogSearchParams.Ser)

--[[
	@within CatalogSearchParams
]]
Squash.CatalogSearchParams.DesArr = desArrayFixed(Squash.CatalogSearchParams.Des, -1) --TODO: same story

--[[
	@class DateTime
]]
Squash.DateTime = {}

local dateTimeOffset = 17_987_443_200

--[[
	@within DateTime
]]
Squash.DateTime.Ser = function(x: DateTime): string
	return Squash.UInt.Ser(5, x.UnixTimestamp + dateTimeOffset)
end

--[[
	@within DateTime
]]
Squash.DateTime.Des = function(y: string): DateTime
	return DateTime.fromUnixTimestamp(Squash.UInt.Des(y, 5) - dateTimeOffset)
end

--[[
	@within DateTime
]]
Squash.DateTime.SerArr = serArrayFixed(Squash.DateTime.Ser)

--[[
	@within DateTime
]]
Squash.DateTime.DesArr = desArrayFixed(Squash.DateTime.Des, 5)

--[[
	@class DockWidgetPluginGuiInfo
]]
Squash.DockWidgetPluginGuiInfo = {}

--[[
	@within DockWidgetPluginGuiInfo
]]
Squash.DockWidgetPluginGuiInfo.Ser = function(x: DockWidgetPluginGuiInfo): string
	return Squash.Bool.Ser(x.InitialEnabled, x.InitialEnabledShouldOverrideRestore)
		.. Squash.Int.Ser(2, x.FloatingXSize)
		.. Squash.Int.Ser(2, x.FloatingYSize)
		.. Squash.Int.Ser(2, x.MinWidth)
		.. Squash.Int.Ser(2, x.MinHeight)
end

--[[
	@within DockWidgetPluginGuiInfo
]]
Squash.DockWidgetPluginGuiInfo.Des = function(y: string): DockWidgetPluginGuiInfo
	local x = DockWidgetPluginGuiInfo.new()
	x.InitialEnabled, x.InitialEnabledShouldOverrideRestore = Squash.Bool.Des(string.sub(y, 1, 1))
	x.FloatingXSize = Squash.Int.Des(string.sub(y, 2, 3), 2)
	x.FloatingYSize = Squash.Int.Des(string.sub(y, 4, 5), 2)
	x.MinWidth = Squash.Int.Des(string.sub(y, 6, 7), 2)
	x.MinHeight = Squash.Int.Des(string.sub(y, 8, 9), 2)
	return x
end

--[[
	@within DockWidgetPluginGuiInfo
]]
Squash.DockWidgetPluginGuiInfo.SerArr = serArrayFixed(Squash.DockWidgetPluginGuiInfo.Ser)

--[[
	@within DockWidgetPluginGuiInfo
]]
Squash.DockWidgetPluginGuiInfo.DesArr = desArrayFixed(Squash.DockWidgetPluginGuiInfo.Des, 9)

--[[
	@class ColorSequenceKeypoint
]]
Squash.ColorSequenceKeypoint = {}

--[[
	@within ColorSequenceKeypoint
]]
Squash.ColorSequenceKeypoint.Ser = function(x: ColorSequenceKeypoint): string
	return string.char(x.Time * 255) .. Squash.Color3.Ser(x.Value)
end

--[[
	@within ColorSequenceKeypoint
]]
Squash.ColorSequenceKeypoint.Des = function(y: string): ColorSequenceKeypoint
	return ColorSequenceKeypoint.new(string.byte(y, 1) / 255, Squash.Color3.Des(string.sub(y, 2, 4)))
end

--[[
	@within ColorSequenceKeypoint
]]
Squash.ColorSequenceKeypoint.SerArr = serArrayFixed(Squash.ColorSequenceKeypoint.Ser)

--[[
	@within ColorSequenceKeypoint
]]
Squash.ColorSequenceKeypoint.DesArr = desArrayFixed(Squash.ColorSequenceKeypoint.Des, 4)

--[[
	@class ColorSequence
]]
Squash.ColorSequence = {}

--[[
	@within ColorSequence
]]
Squash.ColorSequence.Ser = function(x: ColorSequence): string
	return Squash.ColorSequenceKeypoint.SerArr(x.Keypoints)
end

--[[
	@within ColorSequence
]]
Squash.ColorSequence.Des = function(y: string): ColorSequence
	return ColorSequence.new(Squash.ColorSequenceKeypoint.DesArr(y))
end

--[[
	@within ColorSequence
]]
Squash.ColorSequence.SerArr = serArrayVector(Squash.ColorSequence.Ser) -- TODO: Same story

--[[
	@within ColorSequence
]]
Squash.ColorSequence.DesArr = desArrayFixed(Squash.ColorSequence.Des, 4) -- TODO: Same story

--[[
	@class Faces
]]
Squash.Faces = {}

--[[
	@within Faces
]]
Squash.Faces.Ser = function(x: Faces): string
	return Squash.Bool.Ser(x.Top, x.Bottom, x.Left, x.Right, x.Back, x.Front)
end

--[[
	@within Faces
]]
Squash.Faces.Des = function(y: string): Faces
	local faces = Faces.new()
	faces.Top, faces.Bottom, faces.Left, faces.Right, faces.Back, faces.Front = Squash.Bool.Des(y)
	return faces
end

--[[
	@within Faces
]]
Squash.Faces.SerArr = serArrayFixed(Squash.Faces.Ser)

--[[
	@within Faces
]]
Squash.Faces.DesArr = desArrayFixed(Squash.Faces.Des, 1)

--[[
	@class FloatCurveKey
]]
Squash.FloatCurveKey = {}

--[[
	@within FloatCurveKey
]]
Squash.FloatCurveKey.Ser = function(x: FloatCurveKey, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Float.Ser :: NumberSer
	local bytes = bytes or 4

	return Squash.EnumItem.Ser(x.Interpolation)
		.. ser(x.Time, bytes)
		.. ser(x.Value, bytes)
		.. ser(x.LeftTangent, bytes)
		.. ser(x.RightTangent, bytes)
end

--[[
	@within FloatCurveKey
]]
Squash.FloatCurveKey.Des = function(y: string, des: NumberDes?, bytes: number?): FloatCurveKey
	local des = des or Squash.Float.Des :: NumberDes
	local bytes = bytes or 4

	local offset = enumItemData[Enum.KeyInterpolationMode].bytes
	local x = FloatCurveKey.new(
		des(string.sub(y, offset + 1, offset + bytes), bytes),
		des(string.sub(y, offset + bytes + 1, offset + 2 * bytes), bytes),
		Squash.EnumItem.Des(string.sub(y, 1, offset), Enum.KeyInterpolationMode) :: Enum.KeyInterpolationMode
	)
	offset += 2 * bytes
	x.LeftTangent = des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes
	x.RightTangent = des(string.sub(y, offset + 1, offset + bytes), bytes)
	return x
end

--[[
	@within FloatCurveKey
]]
Squash.FloatCurveKey.SerArr = serArrayVector(Squash.FloatCurveKey.Ser) --TODO: same story

--[[
	@within FloatCurveKey
]]
Squash.FloatCurveKey.DesArr = desArrayVector(Squash.FloatCurveKey.Des, 4, enumItemData[Enum.KeyInterpolationMode].bytes) --TODO: same story

--[[
	@class Font
]]
Squash.Font = {}

--[[
	@within Font
]]
Squash.Font.Ser = function(x: Font): string
	local family = string.match(x.Family, '(.+)%..+$')
	if not family then
		error 'Font Family must be a Roblox Font'
	end

	return Squash.EnumItem.Ser(x.Style) .. Squash.EnumItem.Ser(x.Weight) .. family -- TODO: This needs a way to be serialized still
end

--[[
	@within Font
]]
Squash.Font.Des = function(y: string): Font
	local a, b = 1, enumItemData[Enum.FontStyle].bytes
	local style = Squash.EnumItem.Des(string.sub(y, a, b), Enum.FontStyle) :: Enum.FontStyle
	a += b
	b += enumItemData[Enum.FontWeight].bytes
	local fontWeight = Squash.EnumItem.Des(string.sub(y, a, b), Enum.FontWeight) :: Enum.FontWeight
	local family = string.sub(y, b + 1) -- TODO: This needs a way to be serialized still
	return Font.new(family, fontWeight, style)
end

--[[
	@within Font
]]
Squash.Font.SerArr = serArrayFixed(Squash.Font.Ser) -- TODO: This needs a way to be serialized still, we have nothing to serialize variable sized strings. It requires a delimiter, C-style.

--[[
	@within Font
]]
Squash.Font.DesArr = desArrayFixed(Squash.Font.Des, -1) --TODO: Same story

--[[
	@class NumberRange
]]
Squash.NumberRange = {}

--[[
	@within NumberRange
]]
Squash.NumberRange.Ser = function(x: NumberRange, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Int.Ser
	local bytes = bytes or 4
	return ser(x.Min, bytes) .. ser(x.Max, bytes)
end

--[[
	@within NumberRange
]]
Squash.NumberRange.Des = function(y: string, des: NumberDes?, bytes: number?): NumberRange
	local des = des or Squash.Int.Des
	local bytes = bytes or 4
	return NumberRange.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[[
	@within NumberRange
]]
Squash.NumberRange.SerArr = serArrayVector(Squash.NumberRange.Ser)

--[[
	@within NumberRange
]]
Squash.NumberRange.DesArr = desArrayVector(Squash.NumberRange.Des, 2, 0)

--[[
	@class NumberSequenceKeypoint
]]
Squash.NumberSequenceKeypoint = {}

--[[
	@within NumberSequenceKeypoint
]]
Squash.NumberSequenceKeypoint.Ser = function(x: NumberSequenceKeypoint, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Float.Ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.Time, bytes) .. ser(x.Value, bytes) .. ser(x.Envelope, bytes)
end

--[[
	@within NumberSequenceKeypoint
]]
Squash.NumberSequenceKeypoint.Des = function(y: string, des: NumberDes?, bytes: number?): NumberSequenceKeypoint
	local des = des or Squash.Float.Des :: NumberDes
	local bytes = bytes or 4
	return NumberSequenceKeypoint.new(
		des(string.sub(y, 1, bytes), bytes),
		des(string.sub(y, bytes + 1, 2 * bytes), bytes),
		des(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes)
	)
end

--[[
	@within NumberSequenceKeypoint
]]
Squash.NumberSequenceKeypoint.SerArr = serArrayVector(Squash.NumberSequenceKeypoint.Ser)

--[[
	@within NumberSequenceKeypoint
]]
Squash.NumberSequenceKeypoint.DesArr = desArrayVector(Squash.NumberSequenceKeypoint.Des, 3, 0)

--[[
	@class NumberSequence
]]
Squash.NumberSequence = {}

--[[
	@within NumberSequence
]]
Squash.NumberSequence.Ser = function(x: NumberSequence, ser: NumberSer?, bytes: number?): string
	return Squash.NumberSequenceKeypoint.SerArr(x.Keypoints, ser, bytes)
end

--[[
	@within NumberSequence
]]
Squash.NumberSequence.Des = function(y: string, des: NumberDes?, bytes: number?): NumberSequence
	return NumberSequence.new(Squash.NumberSequenceKeypoint.DesArr(y, des, bytes))
end

--[[
	@within NumberSequence
]]
Squash.NumberSequence.SerArr = serArrayVector(Squash.NumberSequence.Ser) --TODO: Same story

--[[
	@within NumberSequence
]]
Squash.NumberSequence.DesArr = desArrayVector(Squash.NumberSequence.Des, -1, -1) --TODO: Same story, delimited arrays

--[[
	@class OverlapParams
]]
Squash.OverlapParams = {}

--[[
	@within OverlapParams
]]
Squash.OverlapParams.Ser = function(x: OverlapParams): string
	return string.char(
		(if x.FilterType == Enum.RaycastFilterType.Include then 1 else 0) + (if x.RespectCanCollide then 2 else 0)
	) .. Squash.UInt.Ser(2, x.MaxParts) .. x.CollisionGroup -- I wish we could use GetCollisionGroupId and restrict this to 1 or 2 bytes, but that was deprecated. --TODO: Same story
end

--[[
	@within OverlapParams
]]
Squash.OverlapParams.Des = function(y: string): OverlapParams
	local filterTypeAndRespectCanCollide = string.byte(y, 1)

	local x = OverlapParams.new()
	x.CollisionGroup = string.sub(y, 4) --TODO: Same story
	x.MaxParts = Squash.UInt.Des(string.sub(y, 2, 3), 2)
	x.RespectCanCollide = filterTypeAndRespectCanCollide >= 2
	x.FilterType = if filterTypeAndRespectCanCollide % 2 == 1
		then Enum.RaycastFilterType.Include
		else Enum.RaycastFilterType.Exclude

	return x
end

--[[
	@within OverlapParams
]]
Squash.OverlapParams.SerArr = serArrayFixed(Squash.OverlapParams.Ser) --TODO: Same story

--[[
	@within OverlapParams
]]
Squash.OverlapParams.DesArr = desArrayFixed(Squash.OverlapParams.Des, -1) --TODO: Same story

--[[
	@class RaycastParams
]]
Squash.RaycastParams = {}

--[[
	@within RaycastParams
]]
Squash.RaycastParams.Ser = function(x: RaycastParams): string
	return Squash.Bool.Ser(x.FilterType == Enum.RaycastFilterType.Include, x.IgnoreWater, x.RespectCanCollide)
		.. x.CollisionGroup --TODO: Same story
end

--[[
	@within RaycastParams
]]
Squash.RaycastParams.Des = function(y: string): RaycastParams
	local isInclude, ignoreWater, respectCanCollide = Squash.Bool.Des(string.sub(y, 1, 1))

	local x = RaycastParams.new()
	x.CollisionGroup = string.sub(y, 2) --TODO: Same story
	x.RespectCanCollide = respectCanCollide
	x.IgnoreWater = ignoreWater
	x.FilterType = if isInclude then Enum.RaycastFilterType.Include else Enum.RaycastFilterType.Exclude

	return x
end

--[[
	@within RaycastParams
]]
Squash.RaycastParams.SerArr = serArrayFixed(Squash.RaycastParams.Ser) --TODO: Same story

--[[
	@within RaycastParams
]]
Squash.RaycastParams.DesArr = desArrayFixed(Squash.RaycastParams.Des, -1) --TODO: Same story

--[[
	@class PathWaypoint
]]
Squash.PathWaypoint = {}

--[[
	@within PathWaypoint
]]
Squash.PathWaypoint.Ser = function(x: PathWaypoint, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Int.Ser
	local bytes = bytes or 4

	return Squash.EnumItem.Ser(x.Action) .. Squash.Vector3.Ser(x.Position, ser, bytes)
end

--[[
	@within PathWaypoint
]]
Squash.PathWaypoint.Des = function(y: string, des: NumberDes?, bytes: number?): PathWaypoint
	local des = des or Squash.Int.Des
	local bytes = bytes or 4

	local offset, action = 1, nil
	offset, action = desEnumItem(y, offset, Enum.PathWaypointAction)
	return PathWaypoint.new(Squash.Vector3.Des(string.sub(y, offset + 1), des, bytes), action)
end

--[[
	@within PathWaypoint
]]
Squash.PathWaypoint.SerArr = serArrayVector(Squash.PathWaypoint.Ser)

--[[
	@within PathWaypoint
]]
Squash.PathWaypoint.DesArr = desArrayVector(Squash.PathWaypoint.Des, 3, enumItemData[Enum.PathWaypointAction].bytes)

--[[
	@class PhysicalProperties
]]
Squash.PhysicalProperties = {}

--[[
	@within PhysicalProperties
]]
Squash.PhysicalProperties.Ser = function(x: PhysicalProperties, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Int.Ser
	local bytes = bytes or 4
	return ser(x.Density, bytes)
		.. ser(x.Friction, bytes)
		.. ser(x.Elasticity, bytes)
		.. ser(x.FrictionWeight, bytes)
		.. ser(x.ElasticityWeight, bytes)
end

--[[
	@within PhysicalProperties
]]
Squash.PhysicalProperties.Des = function(y: string, des: NumberDes?, bytes: number?): PhysicalProperties
	local des = des or Squash.Int.Des
	local bytes = bytes or 4
	return PhysicalProperties.new(
		des(string.sub(y, 1, bytes), bytes),
		des(string.sub(y, bytes + 1, 2 * bytes), bytes),
		des(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes),
		des(string.sub(y, 3 * bytes + 1, 4 * bytes), bytes),
		des(string.sub(y, 4 * bytes + 1, 5 * bytes), bytes)
	)
end

--[[
	@within PhysicalProperties
]]
Squash.PhysicalProperties.SerArr = serArrayVector(Squash.PhysicalProperties.Ser)

--[[
	@within PhysicalProperties
]]
Squash.PhysicalProperties.DesArr = desArrayVector(Squash.PhysicalProperties.Des, 5, 0)

--[[
	@class Ray
]]
Squash.Ray = {}

--[[
	@within Ray
]]
Squash.Ray.Ser = function(x: Ray, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Int.Ser
	local bytes = bytes or 4
	return Squash.Vector3.Ser(x.Origin, ser, bytes) .. Squash.Vector3.Ser(x.Direction, ser, bytes)
end

--[[
	@within Ray
]]
Squash.Ray.Des = function(y: string, des: NumberDes?, bytes: number?): Ray
	local des = des or Squash.Int.Des
	local bytes = bytes or 4
	return Ray.new(
		Squash.Vector3.Des(string.sub(y, 1, bytes), des, bytes),
		Squash.Vector3.Des(string.sub(y, bytes + 1, 2 * bytes), des, bytes)
	)
end

--[[
	@within Ray
]]
Squash.Ray.SerArr = serArrayVector(Squash.Ray.Ser)

--[[
	@within Ray
]]
Squash.Ray.DesArr = desArrayVector(Squash.Ray.Des, 2, 0)

--[[
	@class RaycastResult
]]
Squash.RaycastResult = {}

--[[
	@within RaycastResult
]]
Squash.RaycastResult.Ser = function(x: RaycastResult, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Int.Ser
	local bytes = bytes or 4
	return Squash.EnumItem.Ser(x.Material)
		.. Squash.UInt.Ser(x.Distance, bytes)
		.. Squash.Vector3.Ser(x.Position, ser, bytes)
		.. Squash.Vector3.Ser(x.Normal, ser, bytes)
end

--[[
	@within RaycastResult
]]
Squash.RaycastResult.Des = function(
	y: string,
	des: NumberDes?,
	bytes: number?
): { Material: Enum.Material, Distance: number, Position: Vector3, Normal: Vector3 }
	local des = des or Squash.Int.Des
	local bytes = bytes or 4

	local offset, material = 0, nil
	offset, material = desEnumItem(y, offset, Enum.Material)

	local distance = Squash.UInt.Des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes

	local position = Squash.Vector3.Des(string.sub(y, offset + 1, offset + bytes), des, bytes)
	offset += bytes

	local normal = Squash.Vector3.Des(string.sub(y, offset + 1, offset + bytes), des, bytes)

	return {
		Material = material :: Enum.Material,
		Distance = distance,
		Position = position,
		Normal = normal,
	}
end

--[[
	@within RaycastResult
]]
Squash.RaycastResult.SerArr = serArrayFixed(Squash.RaycastResult.Ser) --TODO: Same story

--[[
	@within RaycastResult
]]
Squash.RaycastResult.DesArr = desArrayVector(Squash.RaycastResult.Des, 7, enumItemData[Enum.Material].bytes) --TODO: Same story

--[[
	@class Rect
]]
Squash.Rect = {}

--[[
	@within Rect
]]
Squash.Rect.Ser = function(x: Rect, bytes: number?)
	local bytes = bytes or 4
	return Squash.UInt.Ser(x.Min.X, bytes)
		.. Squash.UInt.Ser(x.Min.Y, bytes)
		.. Squash.UInt.Ser(x.Max.X, bytes)
		.. Squash.UInt.Ser(x.Max.Y, bytes)
end

--[[
	@within Rect
]]
Squash.Rect.Des = function(y: string, bytes: number?): Rect
	local bytes = bytes or 4
	return Rect.new(
		Squash.UInt.Des(string.sub(y, 1, bytes), bytes),
		Squash.UInt.Des(string.sub(y, bytes + 1, 2 * bytes), bytes),
		Squash.UInt.Des(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes),
		Squash.UInt.Des(string.sub(y, 3 * bytes + 1, 4 * bytes), bytes)
	)
end

--[[
	@within Rect
]]
Squash.Rect.SerArr = serArrayVectorNoCoding(Squash.Rect.Ser) --HGHINOGFEID ior

--[[
	@within Rect
]]
Squash.Rect.DesArr = desArrayVectorNoCoding(Squash.Rect.Des, 4, 0)

--[[
	@class Region3
]]
Squash.Region3 = {}

--[[
	@within Region3
]]
Squash.Region3.Ser = function(x: Region3, ser: NumberSer?, bytes: number?): string
	local bytes = bytes or 4
	return Squash.Vector3.Ser(x.Size, ser, bytes) .. Squash.CFrame.Ser(x.CFrame, ser, bytes)
end

--[[
	@within Region3
]]
Squash.Region3.Des = function(y: string, des: NumberDes?, bytes: number?): Region3
	local bytes = bytes or 4
	local x = Region3.new(Vector3.zero, Vector3.zero)
	x.Size = Squash.Vector3.Des(string.sub(y, 1, 12), des, bytes)
	x.CFrame = Squash.CFrame.Des(string.sub(y, 13, 24), des, bytes)
	return x
end

--[[
	@within Region3
]]
Squash.Region3.SerArr = serArrayVector(Squash.Region3.Ser)

--[[
	@within Region3
]]
Squash.Region3.DesArr = desArrayVector(Squash.Region3.DesArr, 9, 6)

--[[
	@class Region3int16
]]
Squash.Region3int16 = {}

--[[
	@within Region3int16
]]
Squash.Region3int16.Ser = function(x: Region3int16): string
	return Squash.Vector3int16.Ser(x.Min) .. Squash.Vector3int16.Ser(x.Max)
end

--[[
	@within Region3int16
]]
Squash.Region3int16.Des = function(y: string): Region3int16
	return Region3int16.new(Squash.Vector3int16.Des(string.sub(y, 1, 6)), Squash.Vector3int16.Des(string.sub(y, 7, 12)))
end

--[[
	@within Region3int16
]]
Squash.Region3int16.SerArr = serArrayFixed(Squash.Region3int16.Ser)

--[[
	@within Region3int16
]]
Squash.Region3int16.DesArr = desArrayFixed(Squash.Region3int16.Des, 12)

--[[
	@class TweenInfo
]]
Squash.TweenInfo = {}

--[[
	@within TweenInfo
]]
Squash.TweenInfo.Ser = function(x: TweenInfo, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Float.Ser :: NumberSer
	local bytes = bytes or 4
	return Squash.Bool.Ser(x.Reverses)
		.. Squash.EnumItem.Ser(x.EasingStyle)
		.. Squash.EnumItem.Ser(x.EasingDirection)
		.. Squash.Int.Ser(x.RepeatCount, bytes)
		.. ser(x.Time, bytes)
		.. ser(x.DelayTime, bytes)
end

--[[
	@within TweenInfo
]]
Squash.TweenInfo.Des = function(y: string, des: NumberDes?, bytes: number?): TweenInfo
	local des = des or Squash.Float.Des :: NumberDes
	local bytes = bytes or 4

	local offset = 0
	local reverses = Squash.Bool.Des(string.sub(y, offset + 1, offset + 1))
	offset += 1

	local easingStyle
	offset, easingStyle = desEnumItem(y, offset, Enum.EasingStyle)

	local easingDirection
	offset, easingDirection = desEnumItem(y, offset, Enum.EasingDirection)

	local repeatCount = Squash.Int.Des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes

	local tweenTime = des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes

	local delayTime = des(string.sub(y, offset + 1, offset + bytes), bytes)

	return TweenInfo.new(tweenTime, easingStyle, easingDirection, repeatCount, reverses, delayTime)
end

--[[
	@within TweenInfo
]]
Squash.TweenInfo.SerArr = serArrayVector(Squash.TweenInfo.Ser)

--[[
	@within TweenInfo
]]
Squash.TweenInfo.DesArr = desArrayVector(
	Squash.TweenInfo.Des,
	3,
	1 + enumItemData[Enum.EasingStyle].bytes + enumItemData[Enum.EasingDirection].bytes
) --TODO: Same story

--[[
	@class UDim
]]
Squash.UDim = {}

--[[
	@within UDim
]]
Squash.UDim.Ser = function(x: UDim, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Int.Ser
	local bytes = bytes or 4
	return ser(x.Scale, bytes) .. ser(x.Offset, bytes)
end

--[[
	@within UDim
]]
Squash.UDim.Des = function(y: string, des: NumberDes?, bytes: number?): UDim
	local des = des or Squash.Int.Des
	local bytes = bytes or 4
	return UDim.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[[
	@within UDim
]]
Squash.UDim.SerArr = serArrayVector(Squash.UDim.Ser)

--[[
	@within UDim
]]
Squash.UDim.DesArr = desArrayVector(Squash.UDim.Des, 2, 0)

--[[
	@class UDim2
]]
Squash.UDim2 = {}

--[[
	@within UDim2
]]
Squash.UDim2.Ser = function(x: UDim2, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.Int.Ser
	local bytes = bytes or 4
	return Squash.UDim.Ser(x.X, ser, bytes) .. Squash.UDim.Ser(x.Y, ser, bytes)
end

--[[
	@within UDim2
]]
Squash.UDim2.Des = function(y: string, des: NumberDes?, bytes: number?): UDim2
	local des = des or Squash.Int.Des
	local bytes = bytes or 4
	return UDim2.new(
		Squash.UDim.Des(string.sub(y, 1, 2 * bytes), des, bytes),
		Squash.UDim.Des(string.sub(y, 2 * bytes + 1, 4 * bytes), des, bytes)
	)
end

--[[
	@within UDim2
]]
Squash.UDim2.SerArr = serArrayVector(Squash.UDim2.Ser)

--[[
	@within UDim2
]]
Squash.UDim2.DesArr = desArrayVector(Squash.UDim2.Des, 4, 0)

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
-- Squash.Ser.Rbx.Asset(id: number): string
-- 	return Squash.UInt.Ser(6, id)
-- end

-- --[[
-- 	@within Squash
-- ]]
-- Squash.Des.Rbx.Asset(y: string): number
-- 	return Squash.UInt.Des(6, y)
-- end

-- --[[
-- 	@within Squash
-- ]]
-- Squash.Ser.Rbx.AssetPath(path: string, extension: string): string
-- 	local extensionId = table.find(fileExtensions, extension)
-- 	assert(extensionId, 'Invalid extension "' .. extension .. '"')

-- 	return Squash.UInt.Ser(1, extensionId) .. path --TODO: Implement string compression and use it here
-- end

-- --[[
-- 	@within Squash
-- ]]
-- Squash.Des.Rbx.AssetPath(y: string): (string, string)
-- 	local extensionId = Squash.UInt.Des(1, string.sub(y, 1))
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
-- Squash.Ser.Rbx.Thumb(thumbType: string, id: number, width: number, height: number, filters: string?): string
-- 	local thumbTypeId = table.find(thumbTypes, thumbType)
-- 	assert(thumbTypeId, 'Invalid thumb type "' .. thumbType .. '"')

-- 	return table.concat {
-- 		string.char(2 * thumbTypeId + if filters == 'circular' then 1 else 0),
-- 		Squash.UInt.Ser(5, id),
-- 		Squash.UInt.Ser(2, width),
-- 		Squash.UInt.Ser(2, height),
-- 	}
-- end

-- --[[
-- 	@within Squash
-- ]]
-- Squash.Des.Rbx.Thumb(y: string): (string, number, number, number, string?)
-- 	local thumbTypeIdAndFilters = Squash.UInt.Des(1, string.sub(y, 1))
-- 	local thumbType = thumbTypes[math.floor(thumbTypeIdAndFilters / 2)]
-- 	local filters = thumbTypeIdAndFilters % 2 == 1 and 'circular' or nil

-- 	local id = Squash.UInt.Des(5, string.sub(y, 2, 6))
-- 	local width = Squash.UInt.Des(2, string.sub(y, 7, 8))
-- 	local height = Squash.UInt.Des(2, string.sub(y, 9, 10))

-- 	return thumbType, id, width, height, filters
-- end

-- --[[
-- 	@within Squash
-- ]]
-- Squash.Ser.Rbx.Http(path: string, posx: number, posy: number, format: string): string
-- 	local formatId = table.find(fileExtensions, format)
-- 	assert(formatId, 'Invalid format "' .. format .. '"')

-- 	return table.concat {
-- 		Squash.UInt.Ser(1, formatId),
-- 		Squash.UInt.Ser(2, posx),
-- 		Squash.UInt.Ser(2, posy),
-- 		path,
-- 	}
-- end

-- --[[
-- 	@within Squash
-- ]]
-- Squash.Des.Rbx.Http(y: string): (string, number, number, string)
-- 	local formatId = Squash.UInt.Des(1, string.sub(y, 1))
-- 	local posx = Squash.UInt.Des(2, string.sub(y, 2, 3))
-- 	local posy = Squash.UInt.Des(2, string.sub(y, 4, 5))
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
-- Squash.Ser.StringCased(
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
-- Squash.Des.StringCased(
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

-- arr Stuff

-- local printarray(arr: { number })
-- 	return "[" .. table.concat(arr, ", ") .. "]"
-- end

-- local test(name: string, size: number, x: number | { number })
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
-- 	test("Arrayuint", i, numbers)
-- end
