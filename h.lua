-- local function add(x, y, base)
-- 	local z = {}

-- 	local i = 1
-- 	local carry = 0
-- 	local n = math.max(#x, #y)
-- 	while i <= n or carry > 0 do
-- 		local xi = i <= #x and x[i] or 0
-- 		local yi = i <= #y and y[i] or 0
-- 		local zi = carry + xi + yi

-- 		table.insert(z, zi % base)
-- 		carry = math.floor(zi / base)
-- 		i += 1
-- 	end

-- 	return z
-- end

-- local function multiplyByNumber(num, arr, base)
-- 	if num < 0 then
-- 		return nil
-- 	end

-- 	if num == 0 then
-- 		return { 0 }
-- 	end

-- 	local result = {}

-- 	local power = arr
-- 	while num > 0 do
-- 		if num % 2 == 1 then
-- 			result = add(result, power, base)
-- 		end

-- 		num = math.floor(num / 2)
-- 		power = add(power, power, base)
-- 	end

-- 	return result
-- end

-- local function decodeInput(input, inAlph)
-- 	local arr = {}

-- 	for i = #input, 1, -1 do
-- 		local digit = string.sub(input, i, i)
-- 		local n = string.find(inAlph, digit)
-- 		if n then
-- 			table.insert(arr, n - 1)
-- 		end
-- 	end

-- 	return arr
-- end

-- function BaseConvert(input, inAlph, outAlph)
-- 	inAlph = '\0' .. inAlph
-- 	outAlph = '\0' .. outAlph

-- 	local toBase = #outAlph
-- 	if toBase == 2 then
-- 		return
-- 	end

-- 	local digits = decodeInput(input, inAlph)
-- 	if #digits == 0 then
-- 		return nil
-- 	end

-- 	local fromBase = #inAlph

-- 	local outArray = {}
-- 	local power = { 1 }
-- 	for _, digit in ipairs(digits) do
-- 		outArray = add(outArray, multiplyByNumber(digit, power, toBase), toBase)
-- 		power = multiplyByNumber(fromBase, power, toBase)
-- 	end

-- 	local out = {}

-- 	for i = #outArray, 1, -1 do
-- 		table.insert(out, string.sub(outAlph, outArray[i] + 1, outArray[i] + 1))
-- 	end

-- 	return table.concat(out)
-- end

local function BaseConvert(input: string, inAlphabet: string, outAlphabet: string): string
    inAlphabet = '\0' .. inAlphabet
	outAlphabet = '\0' .. outAlphabet

    local sourceDigits = {}
    local targetDigits = {}
    local inputDigits = {}

    for i = 1, #inAlphabet do
        sourceDigits[string.byte(inAlphabet, i)] = i - 1
    end

    for i = 1, #outAlphabet do
        targetDigits[i - 1] = string.byte(outAlphabet, i)
    end

    for i = 1, #input do
        table.insert(inputDigits, sourceDigits[string.byte(input, i)])
    end

	local output = {}
	local sourceBase = #inAlphabet
    local targetBase = #outAlphabet
	local carry, value

    while #inputDigits > 0 do
        carry = 0

        for i = 1, #inputDigits do
            value = inputDigits[i] + carry * sourceBase
            inputDigits[i] = math.floor(value / targetBase)
            carry = value % targetBase
        end

        while #inputDigits > 0 and inputDigits[1] == 0 do
            table.remove(inputDigits, 1)
        end

        table.insert(output, 1, string.char(targetDigits[carry]))
    end

    return table.concat(output)
end

-- -- convertToBase converts a list of numbers from one base to another

local lowercase = "abcdefghijklmnopqrstuvwxyz"
local uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local digits = "0123456789"

local utf8Characters = {}
for i = 1, 255 do
	utf8Characters[i] = string.char(i)
end
local UTF8 = table.concat(utf8Characters)

print(BaseConvert("helloworld", lowercase, UTF8))
print(BaseConvert(BaseConvert("helloworld", lowercase, UTF8), UTF8, lowercase))