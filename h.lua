local function add(x, y, base)
	local z = {}
	local n = math.max(#x, #y)
	local carry = 0
	local i = 1
	while i <= n or carry > 0 do
		local xi = i <= #x and x[i] or 0
		local yi = i <= #y and y[i] or 0
		local zi = carry + xi + yi
		table.insert(z, zi % base)
		carry = math.floor(zi / base)
		i = i + 1
	end
	return z
end

local function multiplyByNumber(num, arr, base)
	if num < 0 then
		return nil
	end
	if num == 0 then
		return { 0 }
	end

	local result = {}
	local power = arr
	while num > 0 do
		if num % 2 == 1 then
			result = add(result, power, base)
		end
		num = math.floor(num / 2)
		power = add(power, power, base)
	end

	return result
end

local function decodeInput(input, inAlph)
	local arr = {}
	for i = #input, 1, -1 do
		local digit = string.sub(input, i, i)
		local n = string.find(inAlph, digit)
		if n then
			table.insert(arr, n - 1)
		end
	end
	return arr
end

function BaseConvert(input, inAlph, outAlph)
	local toBase = #outAlph
	if toBase == 1 then
		return
	end
	local fromBase = #inAlph

	inAlph = "\0" .. inAlph
	outAlph = "\0" .. outAlph

	local digits = decodeInput(input, inAlph)
	if #digits == 0 then
		return nil
	end

	local outArray = {}
	local power = { 1 }
	for _, digit in ipairs(digits) do
		outArray = add(outArray, multiplyByNumber(digit, power, toBase), toBase)
		power = multiplyByNumber(fromBase, power, toBase)
	end

	local out = {}
	for i = #outArray, 1, -1 do
		table.insert(out, string.sub(outAlph, outArray[i] + 1, outArray[i] + 1))
	end
	return table.concat(out)
end

-- convertToBase converts a list of numbers from one base to another

local lowercase = "abcdefghijklmnopqrstuvwxyz"
local uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local digits = "0123456789"
local ascii =
	" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ"

for i = 1, 255 do
	print(i, tostring(i), string.char(i), BaseConvert(tostring(i), digits, ascii))
end
