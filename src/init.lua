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
	return string.char(math.fmod(math.floor(x * 256 ^ -0), 256))
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
	return string.char(math.fmod(math.floor(x * 256 ^ -0), 256), math.fmod(math.floor(x * 256 ^ -1), 256))
end

--[[
	@within Squash
]]
function Squash.Des.Uint16(y: string): number
	return string.byte(y, 1) * 256 ^ 0 + string.byte(y, 2) * 256 ^ 1
end

--[[
	@within Squash
]]
function Squash.Ser.Uint32(x: number): string
	return string.char(
		math.fmod(math.floor(x * 256 ^ -0), 256),
		math.fmod(math.floor(x * 256 ^ -1), 256),
		math.fmod(math.floor(x * 256 ^ -2), 256),
		math.fmod(math.floor(x * 256 ^ -3), 256)
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
		math.fmod(math.floor(x * 256 ^ -0), 256),
		math.fmod(math.floor(x * 256 ^ -1), 256),
		math.fmod(math.floor(x * 256 ^ -2), 256),
		math.fmod(math.floor(x * 256 ^ -3), 256),
		math.fmod(math.floor(x * 256 ^ -4), 256),
		math.fmod(math.floor(x * 256 ^ -5), 256),
		math.fmod(math.floor(x * 256 ^ -6), 256),
		math.fmod(math.floor(x * 256 ^ -7), 256)
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

return Squash
