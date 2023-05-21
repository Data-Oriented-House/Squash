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
function Squash.Ser.Uint8(x: number): string
	return string.char(
		math.floor(x * 256 ^ -0) % 256
	)
end

--[[
	@within Squash
]]
function Squash.Des.Uint8(y: string): number
	return string.byte(y)
end

--[[
	@within Squash
]]
function Squash.Ser.Uint16(x: number): string
	return string.char(
		math.floor(x * 256 ^ -0) % 256,
		math.floor(x * 256 ^ -1) % 256
	)
end

--[[
	@within Squash
]]
function Squash.Des.Uint16(y: string): number
	return string.byte(y, 1) * 256 ^ 0
		+ string.byte(y, 2) * 256 ^ 1
end

--[[
	@within Squash
]]
function Squash.Ser.Uint32(x: number): string
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
function Squash.Des.Uint32(y: string): number
	return string.byte(y, 1) * 256 ^ 0
		+ string.byte(y, 2) * 256 ^ 1
		+ string.byte(y, 3) * 256 ^ 2
		+ string.byte(y, 4) * 256 ^ 3
end

--[[
	@within Squash
]]
function Squash.Ser.Uint64(x: number): string
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
function Squash.Des.Uint64(y: string): number
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
function Squash.Des.Boolean(y: string): boolean
	return string.byte(y) ~= 0,
		string.byte(y, 2) ~= 0,
		string.byte(y, 3) ~= 0,
		string.byte(y, 4) ~= 0,
		string.byte(y, 5) ~= 0,
		string.byte(y, 6) ~= 0,
		string.byte(y, 7) ~= 0,
		string.byte(y, 8) ~= 0
end

return Squash
