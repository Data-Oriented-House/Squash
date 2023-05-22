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
function Squash.Ser.u8(x: number): string
	return string.char(
		math.floor(x * 256 ^ -0) % 256
	)
end

--[[
	@within Squash
]]
function Squash.Des.u8(y: string): number
	return string.byte(y)
end

--[[
	@within Squash
]]
function Squash.Ser.u16(x: number): string
	return string.char(
		math.floor(x * 256 ^ -0) % 256,
		math.floor(x * 256 ^ -1) % 256
	)
end

--[[
	@within Squash
]]
function Squash.Des.u16(y: string): number
	return string.byte(y, 1) * 256 ^ 0
		+ string.byte(y, 2) * 256 ^ 1
end

--[[
	@within Squash
]]
function Squash.Ser.u32(x: number): string
	return string.char(
		math.floor(x * 256 ^ -0) % 256,
		math.floor(x * 256 ^ -1) % 256,
		math.floor(x * 256 ^ -2) % 256,
		math.floor(x * 256 ^ -3) % 256
	)
end

--[[
	@within Squash
]]
function Squash.Des.u32(y: string): number
	return string.byte(y, 1) * 256 ^ 0
		+ string.byte(y, 2) * 256 ^ 1
		+ string.byte(y, 3) * 256 ^ 2
		+ string.byte(y, 4) * 256 ^ 3
end

--[[
	@within Squash
]]
function Squash.Ser.u64(x: number): string
	return string.char(
		math.floor(x * 256 ^ -0) % 256,
		math.floor(x * 256 ^ -1) % 256,
		math.floor(x * 256 ^ -2) % 256,
		math.floor(x * 256 ^ -3) % 256,
		math.floor(x * 256 ^ -4) % 256,
		math.floor(x * 256 ^ -5) % 256,
		math.floor(x * 256 ^ -6) % 256,
		math.floor(x * 256 ^ -7) % 256
	)
end

--[[
	@within Squash
]]
function Squash.Des.u64(y: string): number
	return string.byte(y, 1) * 256 ^ 0
		+ string.byte(y, 2) * 256 ^ 1
		+ string.byte(y, 3) * 256 ^ 2
		+ string.byte(y, 4) * 256 ^ 3
		+ string.byte(y, 5) * 256 ^ 4
		+ string.byte(y, 6) * 256 ^ 5
		+ string.byte(y, 7) * 256 ^ 6
		+ string.byte(y, 8) * 256 ^ 7
end

--[[
	@within Squash
]]
function Squash.Ser.i8(x: number): string
	local sx = if x < 0 then 2^8 + x else x

	return Squash.Ser.u8(sx)
end

--[[
	@within Squash
]]
function Squash.Des.i8(y: string): number
	local x = Squash.Des.u8(y)

	return if x > 2^7 - 1 then x - 2^8 else x
end

--[[
	@within Squash
]]
function Squash.Ser.i16(x: number): string
	local sx = if x < 0 then 2^16 + x else x

	return Squash.Ser.u16(sx)
end

--[[
	@within Squash
]]
function Squash.Des.i16(y: string): number
	local x = Squash.Des.u16(y)
	
	return if x > 2^15 - 1 then x - 2^16 else x
end

--[[
	@within Squash
]]
function Squash.Ser.i32(x: number): string
	local sx = if x < 0 then 2^32 + x else x

	return Squash.Ser.u32(sx)
end

--[[
	@within Squash
]]
function Squash.Des.i32(y: string): number
	local x = Squash.Des.u32(y)
	
	return if x > 2^31 - 1 then x - 2^32 else x
end

--[[
	@within Squash
]]
function Squash.Ser.i64(x: number): string
	local sx = if x < 0 then 2^64 + x else x

	return Squash.Ser.u64(sx)
end

--[[
	@within Squash
]]
function Squash.Des.i64(y: string): number
	local x = Squash.Des.u64(y)
	
	return if x > 2^63 - 1 then x - 2^64 else x
end

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

return Squash
