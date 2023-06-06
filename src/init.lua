--!strict

--[[
	@class Squash

	Provides a set of functions for serializing and deserializing data in both single and array forms.
]]
local Squash = {}

-- Duplication Reducers --

type NumberSer = typeof(Squash.int.ser)
type NumberDes = typeof(Squash.int.des)

local function bytesAssert(bytes: number)
	if bytes ~= math.floor(bytes) or bytes < 1 or bytes > 8 then
		error 'bytes must be 1, 2, 3, 4, 5, 6, 7, or 8'
	end
end

local function floatAssert(bytes: number)
	if bytes ~= 4 and bytes ~= 8 then
		error(`Expected 4 or 8 bytes. Invalid number of bytes for floating point: {bytes}`)
	end
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

local function serArrayFixed<T>(ser: (T) -> string)
	return function(x: { T }): string
		local y = {}
		for i, v in x do
			y[i] = ser(v)
		end
		return table.concat(y)
	end
end

local function desArrayFixed<T>(des: (string) -> T, bytes: number)
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

local function serArrayVector<T>(serializer: (vector: T, ser: NumberSer, bytes: number?) -> string)
	return function(x: { T }, ser: NumberSer?, bytes: number?): string
		local bytes = bytes or 4
		local encoding = ser or Squash.int.ser

		local y = {}
		for i, v in x do
			y[i] = serializer(v, encoding, bytes)
		end
		return table.concat(y)
	end
end

local function desArrayVector<T>(
	deserializer: (y: string, des: NumberDes?, bytes: number?) -> T,
	elements: number,
	offsetBytes: number
)
	return function(y: string, des: NumberDes?, bytes: number?): { T }
		local bytes = bytes or 4
		local decoding = des or Squash.int.des

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

local function serArrayVectorNoCoding<T>(serializer: (vector: T, bytes: number?) -> string)
	return function(x: { T }, bytes: number?): string
		local bytes = bytes or 4

		local y = {}
		for i, v in x do
			y[i] = serializer(v, bytes)
		end
		return table.concat(y)
	end
end

local function desArrayVectorNoCoding<T>(
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

local function serAngle(x: number): string
	return Squash.uint.ser(2, (x + math.pi) % (2 * math.pi) * 65535)
end

local function desAngle(y: string): number
	return Squash.uint.des(y, 2) / 65535 - math.pi
end

local function getBitSize(x: number): number
	return math.ceil(math.log(x, 2 ^ 1))
end

local function getByteSize(x: number): number
	return math.ceil(math.log(x, 2 ^ 8))
end

local function getItemData<T>(array: { T }): { items: { T }, bits: number, bytes: number }
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

-- Actual API --

--[[
	@class bool
]]
Squash.bool = {}

--[[
	@within bool
]]
function Squash.bool.ser(
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
	@within bool
]]
function Squash.bool.des(y: string): (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean)
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
	@within bool
--]]
function Squash.bool.serarr(x: { boolean }): string
	local y = {}
	for i = 1, math.ceil(#x / 8) do
		y[i] = Squash.bool.ser(x[i + 0], x[i + 1], x[i + 2], x[i + 3], x[i + 4], x[i + 5], x[i + 6], x[i + 7])
	end
	return table.concat(y)
end

--[[
	@within bool
--]]
function Squash.bool.desarr(y: string): { boolean }
	local x = {}
	for i = 1, #y do
		local j = 8 * i
		x[j - 7], x[j - 6], x[j - 5], x[j - 4], x[j - 3], x[j - 2], x[j - 1], x[j] =
			Squash.bool.des(string.sub(y, i, i))
	end
	return x
end

--[[
	@class uint
]]
Squash.uint = {}

--[[
	@within uint
]]
function Squash.uint.ser(
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
	@within uint
]]
function Squash.uint.des(y: string, bytes: number?): number
	local bytes = bytes or 4
	bytesAssert(bytes)

	local sum = 0
	for i = 1, bytes do
		sum += string.byte(y, i) * 256 ^ (i - 1)
	end
	return sum
end

--[[
	@within uint
--]]
Squash.uint.serarr = serArrayNumber(Squash.uint.ser)

--[[
	@within uint
--]]
Squash.uint.desarr = desArrayNumber(Squash.uint.des)

--[[
	@class int
]]
Squash.int = {}

--[[
	@within int
]]
function Squash.int.ser(x: number, bytes: number?): string
	local bytes = bytes or 4
	bytesAssert(bytes)

	local sx = if x < 0 then x + 256 ^ bytes else x
	return Squash.uint.ser(bytes, sx)
end

--[[
	@within int
]]
function Squash.int.des(y: string, bytes: number?): number
	local bytes = bytes or 4
	bytesAssert(bytes)

	local x = Squash.uint.des(y, bytes)
	return if x > 0.5 * 256 ^ bytes - 1 then x - 256 ^ bytes else x
end

--[[
	@within int
--]]
Squash.int.serarr = serArrayNumber(Squash.int.ser)

--[[
	@within int
--]]
Squash.int.desarr = desArrayNumber(Squash.int.des)

--[[
	@class float
]]
Squash.float = {}

--[[
	@within float
]]
function Squash.float.ser(x: number, bytes: number?): string
	local bytes = bytes or 4
	floatAssert(bytes)
	return string.pack(if bytes == 4 then 'f' else 'd', x)
end

--[[
	@within float
]]
function Squash.float.des(y: string, bytes: number?): number
	local bytes = bytes or 4
	floatAssert(bytes)
	return string.unpack(if bytes == 4 then 'f' else 'd', y)
end

--[[
	@within float
--]]
Squash.float.serarr = serArrayNumber(Squash.float.ser)

--[[
	@within float
--]]
Squash.float.desarr = desArrayNumber(Squash.float.des)

--[[
	@class vector2
]]
Squash.vector2 = {}

--[[
	@within vector2
]]
function Squash.vector2.ser(x: Vector2, ser: NumberSer?, bytes: number?): string
	local bytes = bytes or 4
	local encoding = ser or Squash.int.ser
	return encoding(bytes, x.X) .. encoding(bytes, x.Y)
end

--[[
	@within vector2
]]
function Squash.vector2.des(y: string, des: NumberDes?, bytes: number?): Vector2
	local bytes = bytes or 4
	local decoding = des or Squash.int.des
	return Vector2.new(decoding(string.sub(y, 1, bytes), bytes), decoding(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[[
	@within vector2
--]]
Squash.vector2.serarr = serArrayVector(Squash.vector2.ser)

--[[
	@within vector2
--]]
Squash.vector2.desarr = desArrayVector(Squash.vector2.des, 2, 0)

--[[
	@class vector3
]]
Squash.vector3 = {}

--[[
	@within vector3
]]
function Squash.vector3.ser(x: Vector3, ser: NumberSer?, bytes: number?): string
	local bytes = bytes or 4
	local encoding = ser or Squash.int.ser
	return encoding(bytes, x.X) .. encoding(bytes, x.Y) .. encoding(bytes, x.Z)
end

--[[
	@within vector3
]]
function Squash.vector3.des(y: string, des: NumberDes?, bytes: number?): Vector3
	local bytes = bytes or 4
	local decoding = des or Squash.int.des
	return Vector3.new(
		decoding(string.sub(y, 1, bytes), bytes),
		decoding(string.sub(y, bytes + 1, 2 * bytes), bytes),
		decoding(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes)
	)
end

--[[
	@within vector3
--]]
Squash.vector3.serarr = serArrayVector(Squash.vector3.ser)

--[[
	@within vector3
--]]
Squash.vector3.desarr = desArrayVector(Squash.vector3.des, 3, 0)

--[[
	@class vector2int16
]]
Squash.vector2int16 = {}

--[[
	@within vector2int16
]]
function Squash.vector2int16.ser(x: Vector2int16)
	return Squash.int.ser(2, x.X) .. Squash.int.ser(2, x.Y)
end

--[[
	@within vector2int16
]]
function Squash.vector2int16.des(y: string): Vector2int16
	return Vector2int16.new(Squash.int.des(string.sub(y, 1, 2), 2), Squash.int.des(string.sub(y, 3, 4), 2))
end

--[[
	@within vector2int16
]]
Squash.vector2int16.serarr = serArrayFixed(Squash.vector2int16.ser)

--[[
	@within vector2int16
]]
Squash.vector2int16.desarr = desArrayFixed(Squash.vector2int16.des, 4)

--[[
	@class vector3int16
]]
Squash.vector3int16 = {}

--[[
	@within vector3int16
]]
function Squash.vector3int16.ser(x: Vector3int16)
	return Squash.int.ser(2, x.X) .. Squash.int.ser(2, x.Y) .. Squash.int.ser(2, x.Z)
end

--[[
	@within vector3int16
]]
function Squash.vector3int16.des(y: string): Vector3int16
	return Vector3int16.new(
		Squash.int.des(string.sub(y, 1, 2), 2),
		Squash.int.des(string.sub(y, 3, 4), 2),
		Squash.int.des(string.sub(y, 5, 6), 2)
	)
end

--[[
	@within vector3int16
]]
Squash.vector3int16.serarr = serArrayFixed(Squash.vector3int16.ser)

--[[
	@within vector3int16
]]
Squash.vector3int16.desarr = desArrayFixed(Squash.vector3int16.des, 6)

--[[
	@class cframe
]]
Squash.cframe = {}

--[[
	@within cframe
]]
function Squash.cframe.ser(x: CFrame, ser: NumberSer?, posBytes: number?): string
	local posBytes = posBytes or 4
	local encoding = ser or Squash.int.ser

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
	@within cframe
]]
function Squash.cframe.des(y: string, des: NumberDes?, posBytes: number?): CFrame
	local posBytes = posBytes or 4
	local decoding = des or Squash.int.des

	local rx = desAngle(string.sub(y, 1, 2))
	local ry = desAngle(string.sub(y, 3, 4))
	local rz = desAngle(string.sub(y, 5, 6))

	local px = decoding(string.sub(y, 7, 7 + posBytes - 1), posBytes)
	local py = decoding(string.sub(y, 7 + posBytes, 7 + 2 * posBytes - 1), posBytes)
	local pz = decoding(string.sub(y, 7 + 2 * posBytes, 7 + 3 * posBytes - 1), posBytes)

	return CFrame.Angles(rx, ry, rz) + Vector3.new(px, py, pz)
end

--[[
	@within cframe
]]
Squash.cframe.serarr = serArrayVector(Squash.cframe.ser)

--[[
	@within cframe
]]
function Squash.cframe.desarr(posBytes: number, y: string, des: NumberDes?): { CFrame }
	local decoding = des or Squash.int.des
	local bytes = 7 + 3 * posBytes

	local x = {}
	for i = 1, #y / bytes do
		local a = bytes * (i - 1) + 1
		local b = bytes * i
		x[i] = Squash.cframe.des(string.sub(y, a, b), decoding, posBytes)
	end
	return x
end

--[[
	@class enum
]]
Squash.enum = {}

--[[
	@within enum
]]
function Squash.enum.ser(enum: Enum): string
	local enumData = enumItemData[enum]
	local enumId = table.find(enumData.items, enum) :: number
	return Squash.uint.ser(enumId, enumData.bytes)
end

--[[
	@within enum
]]
function Squash.enum.des(y: string): Enum
	local enumId = Squash.uint.des(y, enumData.bytes)
	return enumData.items[enumId]
end

--[[
	@class enumitem
]]
Squash.enumitem = {}

--[[
	@within enumitem
]]
function Squash.enumitem.ser(enumItem: EnumItem): string
	local enumData = enumItemData[enumItem.EnumType]
	local enumItemId = table.find(enumData.items, enumItem) :: number
	return Squash.uint.ser(enumItemId, enumData.bytes)
end

--[[
	@within enumitem
]]
function Squash.enumitem.des(y: string, enum: Enum): EnumItem
	local enumData = enumItemData[enum]
	local enumItemId = Squash.uint.des(y, enumData.bytes)
	return enumData.items[enumItemId]
end

--[[
	@class axes
]]
Squash.axes = {}

--[[
	@within axes
]]
function Squash.axes.ser(x: Axes)
	return Squash.bool.ser(x.X, x.Y, x.Z) .. Squash.bool.ser(x.Top, x.Bottom, x.Left, x.Right, x.Back, x.Front)
end

--[[
	@within axes
]]
function Squash.axes.des(y: string): Axes
	local axes = Axes.new()
	axes.X, axes.Y, axes.Z = Squash.bool.des(string.sub(y, 1))
	axes.Top, axes.Bottom, axes.Left, axes.Right, axes.Back, axes.Front = Squash.bool.des(string.sub(y, 2))
	return axes
end

--[[
	@within axes
--]]
Squash.axes.serarr = serArrayFixed(Squash.axes.ser)

--[[
	@within axes
--]]
Squash.axes.desarr = desArrayFixed(Squash.axes.des, 8)

--[[
	@class brickcolor
]]
Squash.brickcolor = {}

--[[
	@within brickcolor
]]
function Squash.brickcolor.ser(x: BrickColor): string
	return Squash.uint.ser(x.Number, 2)
end

--[[
	@within brickcolor
]]
function Squash.brickcolor.des(y: string): BrickColor
	return BrickColor.new(Squash.uint.des(y, 2))
end

--[[
	@within brickcolor
]]
Squash.brickcolor.serarr = serArrayFixed(Squash.brickcolor.ser)

--[[
	@within brickcolor
]]
Squash.brickcolor.desarr = desArrayFixed(Squash.brickcolor.des, 2)

--[[
	@class color3
]]
Squash.color3 = {}

--[[
	@within color3
]]
function Squash.color3.ser(x: Color3): string
	return string.char(x.R * 255, x.G * 255, x.B * 255)
end

--[[
	@within color3
]]
function Squash.color3.des(y: string): Color3
	return Color3.fromRGB(string.byte(y, 1), string.byte(y, 2), string.byte(y, 3))
end

--[[
	@within color3
]]
Squash.color3.serarr = serArrayFixed(Squash.color3.ser)

--[[
	@within color3
]]
Squash.color3.desarr = desArrayFixed(Squash.color3.des, 3)

--[[
	@class catalogsearchparams
]]
Squash.catalogsearchparams = {}

--[[
	@within catalogsearchparams
]]
function Squash.catalogsearchparams.ser(x: CatalogSearchParams): string
	local assetIndices = {}
	for i, v in x.AssetTypes do
		assetIndices[i] = table.find(enumItemData[Enum.AssetType].items, v) :: number
	end

	local bundleIndices = {}
	for i, v in x.BundleTypes do
		bundleIndices[i] = table.find(enumItemData[Enum.BundleType].items, v) :: number
	end

	return Squash.bool.ser(x.IncludeOffSale)
		.. Squash.uint.ser(x.MinPrice, 4)
		.. Squash.uint.ser(x.MaxPrice, 4)
		.. Squash.enumitem.ser(x.SalesTypeFilter)
		.. Squash.enumitem.ser(x.CategoryFilter)
		.. Squash.enumitem.ser(x.SortAggregation)
		.. Squash.enumitem.ser(x.SortType)
		.. packBits(assetIndices, enumItemData[Enum.AssetType].bits)
		.. packBits(bundleIndices, enumItemData[Enum.BundleType].bits)
		.. x.Keyword -- TODO: Squash.ser.String(x.Keyword)
		.. '\0'
		.. x.Creator -- TODO: Squash.ser.String(x.Creator)
end

local function desEnumItem<T>(y: string, offset: number, enum: T & Enum): (number, T & EnumItem)
	local enumData = enumItemData[enum]
	local enumItemId = Squash.uint.des(string.sub(y, offset, offset + enumData.bytes - 1), enumData.bytes)
	return offset + enumData.bytes, enumData.items[enumItemId]
end

--[[
	@within catalogsearchparams
]]
function Squash.catalogsearchparams.des(y: string): CatalogSearchParams
	local x = CatalogSearchParams.new()
	x.IncludeOffSale = Squash.bool.des(string.sub(y, 1, 1))
	x.MinPrice = Squash.uint.des(string.sub(y, 2, 5), 4)
	x.MaxPrice = Squash.uint.des(string.sub(y, 6, 9), 4)

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
	@within catalogsearchparams
]]
Squash.catalogsearchparams.serarr = serArrayFixed(Squash.catalogsearchparams.ser)

--[[
	@within catalogsearchparams
]]
Squash.catalogsearchparams.desarr = desArrayFixed(Squash.catalogsearchparams.des, -1) --TODO: same story

--[[
	@class datetime
]]
Squash.datetime = {}

local dateTimeOffset = 17_987_443_200

--[[
	@within datetime
]]
function Squash.datetime.ser(x: DateTime): string
	return Squash.uint.ser(5, x.UnixTimestamp + dateTimeOffset)
end

--[[
	@within datetime
]]
function Squash.datetime.des(y: string): DateTime
	return DateTime.fromUnixTimestamp(Squash.uint.des(y, 5) - dateTimeOffset)
end

--[[
	@within datetime
]]
Squash.datetime.serarr = serArrayFixed(Squash.datetime.ser)

--[[
	@within datetime
]]
Squash.datetime.desarr = desArrayFixed(Squash.datetime.des, 5)

--[[
	@class dockwidgetpluginguiinfo
]]
Squash.dockwidgetpluginguiinfo = {}

--[[
	@within dockwidgetpluginguiinfo
]]
function Squash.dockwidgetpluginguiinfo.ser(x: DockWidgetPluginGuiInfo): string
	return Squash.bool.ser(x.InitialEnabled, x.InitialEnabledShouldOverrideRestore)
		.. Squash.int.ser(2, x.floatingXSize)
		.. Squash.int.ser(2, x.floatingYSize)
		.. Squash.int.ser(2, x.MinWidth)
		.. Squash.int.ser(2, x.MinHeight)
end

--[[
	@within dockwidgetpluginguiinfo
]]
function Squash.dockwidgetpluginguiinfo.des(y: string): DockWidgetPluginGuiInfo
	local x = DockWidgetPluginGuiInfo.new()
	x.InitialEnabled, x.InitialEnabledShouldOverrideRestore = Squash.bool.des(string.sub(y, 1, 1))
	x.floatingXSize = Squash.int.des(string.sub(y, 2, 3), 2)
	x.floatingYSize = Squash.int.des(string.sub(y, 4, 5), 2)
	x.MinWidth = Squash.int.des(string.sub(y, 6, 7), 2)
	x.MinHeight = Squash.int.des(string.sub(y, 8, 9), 2)
	return x
end

--[[
	@within dockwidgetpluginguiinfo
]]
Squash.dockwidgetpluginguiinfo.serarr = serArrayFixed(Squash.dockwidgetpluginguiinfo.ser)

--[[
	@within dockwidgetpluginguiinfo
]]
Squash.dockwidgetpluginguiinfo.desarr = desArrayFixed(Squash.dockwidgetpluginguiinfo.des, 9)

--[[
	@class colorsequencekeypoint
]]
Squash.colorsequencekeypoint = {}

--[[
	@within colorsequencekeypoint
]]
function Squash.colorsequencekeypoint.ser(x: ColorSequenceKeypoint): string
	return string.char(x.Time * 255) .. Squash.color3.ser(x.Value)
end

--[[
	@within colorsequencekeypoint
]]
function Squash.colorsequencekeypoint.des(y: string): ColorSequenceKeypoint
	return ColorSequenceKeypoint.new(string.byte(y, 1) / 255, Squash.color3.des(string.sub(y, 2, 4)))
end

--[[
	@within colorsequencekeypoint
]]
Squash.colorsequencekeypoint.serarr = serArrayFixed(Squash.colorsequencekeypoint.ser)

--[[
	@within colorsequencekeypoint
]]
Squash.colorsequencekeypoint.desarr = desArrayFixed(Squash.colorsequencekeypoint.des, 4)

--[[
	@class colorsequence
]]
Squash.colorsequence = {}

--[[
	@within colorsequence
]]
function Squash.colorsequence.ser(x: ColorSequence): string
	return Squash.colorsequencekeypoint.serarr(x.Keypoints)
end

--[[
	@within colorsequence
]]
function Squash.colorsequence.des(y: string): ColorSequence
	return ColorSequence.new(Squash.colorsequencekeypoint.desarr(y))
end

--[[
	@within colorsequence
]]
Squash.colorsequence.serarr = serArrayVector(Squash.colorsequence.ser) -- TODO: Same story

--[[
	@within colorsequence
]]
Squash.colorsequence.desarr = desArrayFixed(Squash.colorsequence.des, 4) -- TODO: Same story

--[[
	@class faces
]]
Squash.faces = {}

--[[
	@within faces
]]
function Squash.faces.ser(x: Faces): string
	return Squash.bool.ser(x.Top, x.Bottom, x.Left, x.Right, x.Back, x.Front) --This marty, is how we squash 6 booleans into 1 byte
end

--[[
	@within faces
]]
function Squash.faces.des(y: string): Faces
	local faces = Faces.new()
	faces.Top, faces.Bottom, faces.Left, faces.Right, faces.Back, faces.Front = Squash.bool.des(y)
	return faces
end

--[[
	@within faces
]]
Squash.faces.serarr = serArrayFixed(Squash.faces.ser)

--[[
	@within faces
]]
Squash.faces.desarr = desArrayFixed(Squash.faces.des, 1)

--[[
	@class floatcurvekey
]]
Squash.floatcurvekey = {}

--[[
	@within floatcurvekey
]]
function Squash.floatcurvekey.ser(x: FloatCurveKey, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.float.ser :: NumberSer
	local bytes = bytes or 4

	return Squash.enumitem.ser(x.Interpolation)
		.. ser(x.Time, bytes)
		.. ser(x.Value, bytes)
		.. ser(x.LeftTangent, bytes)
		.. ser(x.RightTangent, bytes)
end

--[[
	@within floatcurvekey
]]
function Squash.floatcurvekey.des(y: string, des: NumberDes?, bytes: number?): FloatCurveKey
	local des = des or Squash.float.des :: NumberDes
	local bytes = bytes or 4

	local offset = enumItemData[Enum.KeyInterpolationMode].bytes
	local x = FloatCurveKey.new(
		des(string.sub(y, offset + 1, offset + bytes), bytes),
		des(string.sub(y, offset + bytes + 1, offset + 2 * bytes), bytes),
		Squash.enumitem.des(string.sub(y, 1, offset), Enum.KeyInterpolationMode) :: Enum.KeyInterpolationMode
	)
	offset += 2 * bytes
	x.LeftTangent = des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes
	x.RightTangent = des(string.sub(y, offset + 1, offset + bytes), bytes)
	return x
end

--[[
	@within floatcurvekey
]]
Squash.floatcurvekey.serarr = serArrayVector(Squash.floatcurvekey.ser) --TODO: same story

--[[
	@within floatcurvekey
]]
Squash.floatcurvekey.desarr = desArrayVector(Squash.floatcurvekey.des, 4, enumItemData[Enum.KeyInterpolationMode].bytes) --TODO: same story

--[[
	@class font
]]
Squash.font = {}

--[[
	@within font
]]
function Squash.font.ser(x: Font): string
	local family = string.match(x.Family, '(.+)%..+$')
	if not family then
		error 'Font Family must be a Roblox font'
	end

	return Squash.enumitem.ser(x.Style) .. Squash.enumitem.ser(x.Weight) .. family -- TODO: This needs a way to be serialized still
end

--[[
	@within font
]]
function Squash.font.des(y: string): Font
	local a, b = 1, enumItemData[Enum.FontStyle].bytes
	local style = Squash.enumitem.des(string.sub(y, a, b), Enum.FontStyle) :: Enum.FontStyle
	a += b
	b += enumItemData[Enum.FontWeight].bytes
	local fontWeight = Squash.enumitem.des(string.sub(y, a, b), Enum.FontWeight) :: Enum.FontWeight
	local family = string.sub(y, b + 1) -- TODO: This needs a way to be serialized still
	return Font.new(family, fontWeight, style)
end

--[[
	@within font
]]
Squash.font.serarr = serArrayFixed(Squash.font.ser) -- TODO: This needs a way to be serialized still, we have nothing to serialize variable sized strings. It requires a delimiter, C-style.

--[[
	@within font
]]
Squash.font.desarr = desArrayFixed(Squash.font.des, -1) --TODO: Same story

--[[
	@class numberrange
]]
Squash.numberrange = {}

--[[
	@within numberrange
]]
function Squash.numberrange.ser(x: NumberRange, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.int.ser
	local bytes = bytes or 4
	return ser(x.Min, bytes) .. ser(x.Max, bytes)
end

--[[
	@within numberrange
]]
function Squash.numberrange.des(y: string, des: NumberDes?, bytes: number?): NumberRange
	local des = des or Squash.int.des
	local bytes = bytes or 4
	return NumberRange.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[[
	@within numberrange
]]
Squash.numberrange.serarr = serArrayVector(Squash.numberrange.ser)

--[[
	@within numberrange
]]
Squash.numberrange.desarr = desArrayVector(Squash.numberrange.des, 2, 0)

--[[
	@class numbersequencekeypoint
]]
Squash.numbersequencekeypoint = {}

--[[
	@within numbersequencekeypoint
]]
function Squash.numbersequencekeypoint.ser(x: NumberSequenceKeypoint, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.float.ser :: NumberSer
	local bytes = bytes or 4
	return ser(x.Time, bytes) .. ser(x.Value, bytes) .. ser(x.Envelope, bytes)
end

--[[
	@within numbersequencekeypoint
]]
function Squash.numbersequencekeypoint.des(y: string, des: NumberDes?, bytes: number?): NumberSequenceKeypoint
	local des = des or Squash.float.des :: NumberDes
	local bytes = bytes or 4
	return NumberSequenceKeypoint.new(
		des(string.sub(y, 1, bytes), bytes),
		des(string.sub(y, bytes + 1, 2 * bytes), bytes),
		des(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes)
	)
end

--[[
	@within numbersequencekeypoint
]]
Squash.numbersequencekeypoint.serarr = serArrayVector(Squash.numbersequencekeypoint.ser)

--[[
	@within numbersequencekeypoint
]]
Squash.numbersequencekeypoint.desarr = desArrayVector(Squash.numbersequencekeypoint.des, 3, 0)

--[[
	@class numbersequence
]]
Squash.numbersequence = {}

--[[
	@within numbersequence
]]
function Squash.numbersequence.ser(x: NumberSequence, ser: NumberSer?, bytes: number?): string
	return Squash.numbersequencekeypoint.serarr(x.Keypoints, ser, bytes)
end

--[[
	@within numbersequence
]]
function Squash.numbersequence.des(y: string, des: NumberDes?, bytes: number?): NumberSequence
	return NumberSequence.new(Squash.numbersequencekeypoint.desarr(y, des, bytes))
end

--[[
	@within numbersequence
]]
Squash.numbersequence.serarr = serArrayVector(Squash.numbersequence.ser) --TODO: Same story

--[[
	@within numbersequence
]]
Squash.numbersequence.desarr = desArrayVector(Squash.numbersequence.des, -1, -1) --TODO: Same story, delimited arrays

--[[
	@class overlapparams
]]
Squash.overlapparams = {}

--[[
	@within overlapparams
]]
function Squash.overlapparams.ser(x: OverlapParams): string
	return string.char(
		(if x.FilterType == Enum.RaycastFilterType.Include then 1 else 0) + (if x.RespectCanCollide then 2 else 0)
	) .. Squash.uint.ser(2, x.MaxParts) .. x.CollisionGroup -- I wish we could use GetCollisionGroupId and restrict this to 1 or 2 bytes, but that was deprecated. --TODO: Same story
end

--[[
	@within overlapparams
]]
function Squash.overlapparams.des(y: string): OverlapParams
	local filterTypeAndRespectCanCollide = string.byte(y, 1)

	local x = OverlapParams.new()
	x.CollisionGroup = string.sub(y, 4) --TODO: Same story
	x.MaxParts = Squash.uint.des(string.sub(y, 2, 3), 2)
	x.RespectCanCollide = filterTypeAndRespectCanCollide >= 2
	x.FilterType = if filterTypeAndRespectCanCollide % 2 == 1
		then Enum.RaycastFilterType.Include
		else Enum.RaycastFilterType.Exclude

	return x
end

--[[
	@within overlapparams
]]
Squash.overlapparams.serarr = serArrayFixed(Squash.overlapparams.ser) --TODO: Same story

--[[
	@within overlapparams
]]
Squash.overlapparams.desarr = desArrayFixed(Squash.overlapparams.des, -1) --TODO: Same story

--[[
	@class raycastparams
]]
Squash.raycastparams = {}

--[[
	@within raycastparams
]]
function Squash.raycastparams.ser(x: RaycastParams): string
	return Squash.bool.ser(x.FilterType == Enum.RaycastFilterType.Include, x.IgnoreWater, x.RespectCanCollide)
		.. x.CollisionGroup --TODO: Same story
end

--[[
	@within raycastparams
]]
function Squash.raycastparams.des(y: string): RaycastParams
	local isInclude, ignoreWater, respectCanCollide = Squash.bool.des(string.sub(y, 1, 1))

	local x = RaycastParams.new()
	x.CollisionGroup = string.sub(y, 2) --TODO: Same story
	x.RespectCanCollide = respectCanCollide
	x.IgnoreWater = ignoreWater
	x.FilterType = if isInclude then Enum.RaycastFilterType.Include else Enum.RaycastFilterType.Exclude

	return x
end

--[[
	@within raycastparams
]]
Squash.raycastparams.serarr = serArrayFixed(Squash.raycastparams.ser) --TODO: Same story

--[[
	@within raycastparams
]]
Squash.raycastparams.desarr = desArrayFixed(Squash.raycastparams.des, -1) --TODO: Same story

--[[
	@class pathwaypoint
]]
Squash.pathwaypoint = {}

--[[
	@within pathwaypoint
]]
function Squash.pathwaypoint.ser(x: PathWaypoint, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.int.ser
	local bytes = bytes or 4

	return Squash.enumitem.ser(x.Action) .. Squash.vector3.ser(x.Position, ser, bytes)
end

--[[
	@within pathwaypoint
]]
function Squash.pathwaypoint.des(y: string, des: NumberDes?, bytes: number?): PathWaypoint
	local des = des or Squash.int.des
	local bytes = bytes or 4

	local offset, action = 1, nil
	offset, action = desEnumItem(y, offset, Enum.PathWaypointAction)
	return PathWaypoint.new(Squash.vector3.des(string.sub(y, offset + 1), des, bytes), action)
end

--[[
	@within pathwaypoint
]]
Squash.pathwaypoint.serarr = serArrayVector(Squash.pathwaypoint.ser)

--[[
	@within pathwaypoint
]]
Squash.pathwaypoint.desarr = desArrayVector(Squash.pathwaypoint.des, 3, enumItemData[Enum.PathWaypointAction].bytes)

--[[
	@class physicalproperties
]]
Squash.physicalproperties = {}

--[[
	@within physicalproperties
]]
function Squash.physicalproperties.ser(x: PhysicalProperties, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.int.ser
	local bytes = bytes or 4
	return ser(x.Density, bytes)
		.. ser(x.Friction, bytes)
		.. ser(x.Elasticity, bytes)
		.. ser(x.FrictionWeight, bytes)
		.. ser(x.ElasticityWeight, bytes)
end

--[[
	@within physicalproperties
]]
function Squash.physicalproperties.des(y: string, des: NumberDes?, bytes: number?): PhysicalProperties
	local des = des or Squash.int.des
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
	@within physicalproperties
]]
Squash.physicalproperties.serarr = serArrayVector(Squash.physicalproperties.ser)

--[[
	@within physicalproperties
]]
Squash.physicalproperties.desarr = desArrayVector(Squash.physicalproperties.des, 5, 0)

--[[
	@class ray
]]
Squash.ray = {}

--[[
	@within ray
]]
function Squash.ray.ser(x: Ray, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.int.ser
	local bytes = bytes or 4
	return Squash.vector3.ser(x.Origin, ser, bytes) .. Squash.vector3.ser(x.Direction, ser, bytes)
end

--[[
	@within ray
]]
function Squash.ray.des(y: string, des: NumberDes?, bytes: number?): Ray
	local des = des or Squash.int.des
	local bytes = bytes or 4
	return Ray.new(
		Squash.vector3.des(string.sub(y, 1, bytes), des, bytes),
		Squash.vector3.des(string.sub(y, bytes + 1, 2 * bytes), des, bytes)
	)
end

--[[
	@within ray
]]
Squash.ray.serarr = serArrayVector(Squash.ray.ser)

--[[
	@within ray
]]
Squash.ray.desarr = desArrayVector(Squash.ray.des, 2, 0)

--[[
	@class raycastresult
]]
Squash.raycastresult = {}

--[[
	@within raycastresult
]]
function Squash.raycastresult.ser(x: RaycastResult, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.int.ser
	local bytes = bytes or 4
	return Squash.enumitem.ser(x.Material)
		.. Squash.uint.ser(x.Distance, bytes)
		.. Squash.vector3.ser(x.Position, ser, bytes)
		.. Squash.vector3.ser(x.Normal, ser, bytes)
end

--[[
	@within raycastresult
]]
function Squash.raycastresult.des(
	y: string,
	des: NumberDes?,
	bytes: number?
): { Material: Enum.Material, Distance: number, Position: Vector3, Normal: Vector3 }
	local des = des or Squash.int.des
	local bytes = bytes or 4

	local offset, material = 0, nil
	offset, material = desEnumItem(y, offset, Enum.Material)

	local distance = Squash.uint.des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes

	local position = Squash.vector3.des(string.sub(y, offset + 1, offset + bytes), des, bytes)
	offset += bytes

	local normal = Squash.vector3.des(string.sub(y, offset + 1, offset + bytes), des, bytes)

	return {
		Material = material :: Enum.Material,
		Distance = distance,
		Position = position,
		Normal = normal,
	}
end

--[[
	@within raycastresult
]]
Squash.raycastresult.serarr = serArrayFixed(Squash.raycastresult.ser) --TODO: Same story

--[[
	@within raycastresult
]]
Squash.raycastresult.desarr = desArrayVector(Squash.raycastresult.des, 7, enumItemData[Enum.Material].bytes) --TODO: Same story

--[[
	@class rect
]]
Squash.rect = {}

--[[
	@within rect
]]
function Squash.rect.ser(x: Rect, bytes: number?)
	local bytes = bytes or 4
	return Squash.uint.ser(x.Min.X, bytes)
		.. Squash.uint.ser(x.Min.Y, bytes)
		.. Squash.uint.ser(x.Max.X, bytes)
		.. Squash.uint.ser(x.Max.Y, bytes)
end

--[[
	@within rect
]]
function Squash.rect.des(y: string, bytes: number?): Rect
	local bytes = bytes or 4
	return Rect.new(
		Squash.uint.des(string.sub(y, 1, bytes), bytes),
		Squash.uint.des(string.sub(y, bytes + 1, 2 * bytes), bytes),
		Squash.uint.des(string.sub(y, 2 * bytes + 1, 3 * bytes), bytes),
		Squash.uint.des(string.sub(y, 3 * bytes + 1, 4 * bytes), bytes)
	)
end

--[[
	@within rect
]]
Squash.rect.serarr = serArrayVectorNoCoding(Squash.rect.ser) --HGHINOGFEID ior

--[[
	@within rect
]]
Squash.rect.desarr = desArrayVectorNoCoding(Squash.rect.des, 4, 0)

--[[
	@class region3
]]
Squash.region3 = {}

--[[
	@within region3
]]
function Squash.region3.ser(x: Region3, ser: NumberSer?, bytes: number?): string
	local bytes = bytes or 4
	return Squash.vector3.ser(x.Size, ser, bytes) .. Squash.cframe.ser(x.CFrame, ser, bytes)
end

--[[
	@within region3
]]
function Squash.region3.des(y: string, des: NumberDes?, bytes: number?): Region3
	local bytes = bytes or 4
	local x = Region3.new(Vector3.zero, Vector3.zero)
	x.Size = Squash.vector3.des(string.sub(y, 1, 12), des, bytes)
	x.CFrame = Squash.cframe.des(string.sub(y, 13, 24), des, bytes)
	return x
end

--[[
	@within region3
]]
Squash.region3.serarr = serArrayVector(Squash.region3.ser)

--[[
	@within region3
]]
Squash.region3.desarr = desArrayVector(Squash.region3.desarr, 9, 6)

--[[
	@class region3int16
]]
Squash.region3int16 = {}

--[[
	@within region3int16
]]
function Squash.region3int16.ser(x: Region3int16): string
	return Squash.vector3int16.ser(x.Min) .. Squash.vector3int16.ser(x.Max)
end

--[[
	@within region3int16
]]
function Squash.region3int16.des(y: string): Region3int16
	return Region3int16.new(Squash.vector3int16.des(string.sub(y, 1, 6)), Squash.vector3int16.des(string.sub(y, 7, 12)))
end

--[[
	@within region3int16
]]
Squash.region3int16.serarr = serArrayFixed(Squash.region3int16.ser)

--[[
	@within region3int16
]]
Squash.region3int16.desarr = desArrayFixed(Squash.region3int16.des, 12)

--[[
	@class tweeninfo
]]
Squash.tweeninfo = {}

--[[
	@within tweeninfo
]]
function Squash.tweeninfo.ser(x: TweenInfo, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.float.ser :: NumberSer
	local bytes = bytes or 4
	return Squash.bool.ser(x.Reverses)
		.. Squash.enumitem.ser(x.EasingStyle)
		.. Squash.enumitem.ser(x.EasingDirection)
		.. Squash.int.ser(x.RepeatCount, bytes)
		.. ser(x.Time, bytes)
		.. ser(x.DelayTime, bytes)
end

--[[
	@within tweeninfo
]]
function Squash.tweeninfo.des(y: string, des: NumberDes?, bytes: number?): TweenInfo
	local des = des or Squash.float.des :: NumberDes
	local bytes = bytes or 4

	local offset = 0
	local reverses = Squash.bool.des(string.sub(y, offset + 1, offset + 1))
	offset += 1

	local easingStyle
	offset, easingStyle = desEnumItem(y, offset, Enum.EasingStyle)

	local easingDirection
	offset, easingDirection = desEnumItem(y, offset, Enum.EasingDirection)

	local repeatCount = Squash.int.des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes

	local tweenTime = des(string.sub(y, offset + 1, offset + bytes), bytes)
	offset += bytes

	local delayTime = des(string.sub(y, offset + 1, offset + bytes), bytes)

	return TweenInfo.new(tweenTime, easingStyle, easingDirection, repeatCount, reverses, delayTime)
end

--[[
	@within tweeninfo
]]
Squash.tweeninfo.serarr = serArrayVector(Squash.tweeninfo.ser)

--[[
	@within tweeninfo
]]
Squash.tweeninfo.desarr = desArrayVector(
	Squash.tweeninfo.des,
	3,
	1 + enumItemData[Enum.EasingStyle].bytes + enumItemData[Enum.EasingDirection].bytes
) --TODO: Same story

--[[
	@class udim
]]
Squash.udim = {}

--[[
	@within udim
]]
function Squash.udim.ser(x: UDim, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.int.ser
	local bytes = bytes or 4
	return ser(x.Scale, bytes) .. ser(x.Offset, bytes)
end

--[[
	@within udim
]]
function Squash.udim.des(y: string, des: NumberDes?, bytes: number?): UDim
	local des = des or Squash.int.des
	local bytes = bytes or 4
	return UDim.new(des(string.sub(y, 1, bytes), bytes), des(string.sub(y, bytes + 1, 2 * bytes), bytes))
end

--[[
	@within udim
]]
Squash.udim.serarr = serArrayVector(Squash.udim.ser)

--[[
	@within udim
]]
Squash.udim.desarr = desArrayVector(Squash.udim.des, 2, 0)

--[[
	@class udim2
]]
Squash.udim2 = {}

--[[
	@within udim2
]]
function Squash.udim2.ser(x: UDim2, ser: NumberSer?, bytes: number?): string
	local ser = ser or Squash.int.ser
	local bytes = bytes or 4
	return Squash.udim.ser(x.X, ser, bytes) .. Squash.udim.ser(x.Y, ser, bytes)
end

--[[
	@within udim2
]]
function Squash.udim2.des(y: string, des: NumberDes?, bytes: number?): UDim2
	local des = des or Squash.int.des
	local bytes = bytes or 4
	return UDim2.new(
		Squash.udim.des(string.sub(y, 1, 2 * bytes), des, bytes),
		Squash.udim.des(string.sub(y, 2 * bytes + 1, 4 * bytes), des, bytes)
	)
end

--[[
	@within udim2
]]
Squash.udim2.serarr = serArrayVector(Squash.udim2.ser)

--[[
	@within udim2
]]
Squash.udim2.desarr = desArrayVector(Squash.udim2.des, 4, 0)

return Squash

-- Squash.ser.Rbx = {}
-- Squash.des.Rbx = {}

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
-- function Squash.ser.Rbx.Asset(id: number): string
-- 	return Squash.uint.ser(6, id)
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.des.Rbx.Asset(y: string): number
-- 	return Squash.uint.des(6, y)
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.ser.Rbx.AssetPath(path: string, extension: string): string
-- 	local extensionId = table.find(fileExtensions, extension)
-- 	assert(extensionId, 'Invalid extension "' .. extension .. '"')

-- 	return Squash.uint.ser(1, extensionId) .. path --TODO: Implement string compression and use it here
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.des.Rbx.AssetPath(y: string): (string, string)
-- 	local extensionId = Squash.uint.des(1, string.sub(y, 1))
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
-- function Squash.ser.Rbx.Thumb(thumbType: string, id: number, width: number, height: number, filters: string?): string
-- 	local thumbTypeId = table.find(thumbTypes, thumbType)
-- 	assert(thumbTypeId, 'Invalid thumb type "' .. thumbType .. '"')

-- 	return table.concat {
-- 		string.char(2 * thumbTypeId + if filters == 'circular' then 1 else 0),
-- 		Squash.uint.ser(5, id),
-- 		Squash.uint.ser(2, width),
-- 		Squash.uint.ser(2, height),
-- 	}
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.des.Rbx.Thumb(y: string): (string, number, number, number, string?)
-- 	local thumbTypeIdAndFilters = Squash.uint.des(1, string.sub(y, 1))
-- 	local thumbType = thumbTypes[math.floor(thumbTypeIdAndFilters / 2)]
-- 	local filters = thumbTypeIdAndFilters % 2 == 1 and 'circular' or nil

-- 	local id = Squash.uint.des(5, string.sub(y, 2, 6))
-- 	local width = Squash.uint.des(2, string.sub(y, 7, 8))
-- 	local height = Squash.uint.des(2, string.sub(y, 9, 10))

-- 	return thumbType, id, width, height, filters
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.ser.Rbx.Http(path: string, posx: number, posy: number, format: string): string
-- 	local formatId = table.find(fileExtensions, format)
-- 	assert(formatId, 'Invalid format "' .. format .. '"')

-- 	return table.concat {
-- 		Squash.uint.ser(1, formatId),
-- 		Squash.uint.ser(2, posx),
-- 		Squash.uint.ser(2, posy),
-- 		path,
-- 	}
-- end

-- --[[
-- 	@within Squash
-- ]]
-- function Squash.des.Rbx.Http(y: string): (string, number, number, string)
-- 	local formatId = Squash.uint.des(1, string.sub(y, 1))
-- 	local posx = Squash.uint.des(2, string.sub(y, 2, 3))
-- 	local posy = Squash.uint.des(2, string.sub(y, 4, 5))
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
-- function Squash.ser.StringCased(
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
-- function Squash.des.StringCased(
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

-- local function printarray(arr: { number })
-- 	return "[" .. table.concat(arr, ", ") .. "]"
-- end

-- local function test(name: string, size: number, x: number | { number })
-- 	local y = Squash.ser[name](size, x)
-- 	local z = Squash.des[name](size, y)
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
