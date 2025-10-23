local Squash = require("../src")

local function get(byte: number)
	if byte == 1 then
		return Squash.i8()
	elseif byte == 2 then
		return Squash.i16()
	elseif byte == 3 then
		return Squash.i24()
	elseif byte == 4 then
		return Squash.i32()
	elseif byte == 5 then
		return Squash.i40()
	elseif byte == 6 then
		return Squash.i48()
	elseif byte == 7 then
		return Squash.i56()
	else
		return Squash.i64()
	end
end

local RANGE = 10

for b = 1, 8 do
	local serdes = get(b)
	local c = Squash.cursor()

	local BOUNDARY = 2^(b * 8 - 1)
	local MAX = 2^(b * 8)

	for i = -BOUNDARY - RANGE, -BOUNDARY + RANGE do
		local j = ((i - BOUNDARY) % MAX) - BOUNDARY

		serdes.ser(c, i)
		local v = serdes.des(c)
		if j ~= v then
			print(`[SquashTest Integer] {b} | {j} ~= {v}`)
		end
	end

	for i = BOUNDARY - RANGE, BOUNDARY + RANGE do
		local j = ((i - BOUNDARY) % MAX) - BOUNDARY

		serdes.ser(c, i)
		local v = serdes.des(c)
		if j ~= v then
			print(`[SquashTest Integer] {b} | {j} ~= {v}`)
		end
	end

	for i = 0 - RANGE, 0 + RANGE do
		local j = ((i - BOUNDARY) % MAX) - BOUNDARY

		serdes.ser(c, i)
		local v = serdes.des(c)
		if j ~= v then
			print(`[SquashTest Integer] {b} | {j} ~= {v}`)
		end
	end
end