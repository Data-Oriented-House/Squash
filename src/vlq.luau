local function tovlq(x: number)
	local x0 = x // 128 ^ 0 % 128
	local x1 = x // 128 ^ 1 % 128
	local x2 = x // 128 ^ 2 % 128
	local x3 = x // 128 ^ 3 % 128
	local x4 = x // 128 ^ 4 % 128
	local x5 = x // 128 ^ 5 % 128
	local x6 = x // 128 ^ 6 % 128
	local x7 = x // 128 ^ 7 % 128

	if x7 ~= 0 then
		return x0 * 256 ^ 0 + x1 * 256 ^ 1 + x2 * 256 ^ 2 + x3 * 256 ^ 3 + x4 * 256 ^ 4 + x5 * 256 ^ 5 + x6 * 256 ^ 6 + (x7 + 128) * 256 ^ 7,
			8
	elseif x6 ~= 0 then
		return x0 * 256 ^ 0 + x1 * 256 ^ 1 + x2 * 256 ^ 2 + x3 * 256 ^ 3 + x4 * 256 ^ 4 + x5 * 256 ^ 5 + (x6 + 128) * 256 ^ 6, 7
	elseif x5 ~= 0 then
		return x0 * 256 ^ 0 + x1 * 256 ^ 1 + x2 * 256 ^ 2 + x3 * 256 ^ 3 + x4 * 256 ^ 4 + (x5 + 128) * 256 ^ 5, 6
	elseif x4 ~= 0 then
		return x0 * 256 ^ 0 + x1 * 256 ^ 1 + x2 * 256 ^ 2 + x3 * 256 ^ 3 + (x4 + 128) * 256 ^ 4, 5
	elseif x3 ~= 0 then
		return x0 * 256 ^ 0 + x1 * 256 ^ 1 + x2 * 256 ^ 2 + (x3 + 128) * 256 ^ 3, 4
	elseif x2 ~= 0 then
		return x0 * 256 ^ 0 + x1 * 256 ^ 1 + (x2 + 128) * 256 ^ 2, 3
	elseif x1 ~= 0 then
		return x0 * 256 ^ 0 + (x1 + 128) * 256, 2
	else
		return x0 + 128, 1
	end
end

local function fromvlq(y: buffer)
	local x = 0
	for i = 0, 7 do
		local b = buffer.readu8(y, i)
		if b >= 128 then
			return x + (b - 128) * 128 ^ i, i
		end
		x += b * 128 ^ i
	end
	error(`Not a valid vlq: {x} = {buffer.tostring(y)}`)
end

local function serstring(x: string)
	local vlq, len = tovlq(#x)
	local buf = buffer.create(len + #x)
	if len <= 1 then
		buffer.writeu8(buf, 0, vlq)
	elseif len == 2 then
		buffer.writeu16(buf, 0, vlq)
	elseif len == 3 then
		buffer.writeu8(buf, 0, vlq)
		buffer.writeu16(buf, 1, vlq // 256)
	elseif len == 4 then
		buffer.writeu32(buf, 0, vlq)
	elseif len == 5 then
		buffer.writeu8(buf, 0, vlq)
		buffer.writeu32(buf, 1, vlq // 256)
	elseif len == 6 then
		buffer.writeu16(buf, 0, vlq)
		buffer.writeu32(buf, 2, vlq // 256 ^ 2)
	elseif len == 7 then
		buffer.writeu8(buf, 0, vlq)
		buffer.writeu16(buf, 1, vlq // 256)
		buffer.writeu32(buf, 3, vlq // 256 ^ 3)
	elseif len == 8 then
		buffer.writeu32(buf, 0, vlq)
		buffer.writeu32(buf, 4, vlq // 256 ^ 4)
	end
	buffer.copy(buf, len, buffer.fromstring(x), 0)
	return buf
end

local function desstring(y: buffer)
	local len, bytes = fromvlq(y)
	local out = buffer.create(len)
	buffer.copy(out, 0, y, bytes + 1, len)
	return buffer.tostring(out)
end

local buf = serstring(string.rep('a', 128 - 0))
print(buffer.len(buf), fromvlq(buf))
print(desstring(buf))
