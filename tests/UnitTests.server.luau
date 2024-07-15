local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Squash = require(ReplicatedStorage.Squash)

local function assert_equal(actual, expected, message)
    if actual ~= expected then
        warn(message .. ": expected " .. tostring(expected) .. " --> " .. tostring(actual))
    end
end

local function test_alloci_and_popi()
    local test_cases = {
        {push = Squash.int(1).ser, pop = Squash.int(1).des, value = -128},
        {push = Squash.int(2).ser, pop = Squash.int(2).des, value = -32768},
        {push = Squash.int(3).ser, pop = Squash.int(3).des, value = -8388608},
        {push = Squash.int(4).ser, pop = Squash.int(4).des, value = -2147483648},
        {push = Squash.int(5).ser, pop = Squash.int(5).des, value = -549755813888},
        {push = Squash.int(6).ser, pop = Squash.int(6).des, value = -140737488355328},
        {push = Squash.int(7).ser, pop = Squash.int(7).des, value = -36028797018963968},
        {push = Squash.int(8).ser, pop = Squash.int(8).des, value = -9223372036854775808},
    }

    for i, test_case in ipairs(test_cases) do
        local cursor = Squash.cursor()
        test_case.push(cursor, test_case.value)
        local result = test_case.pop(cursor)
        assert_equal(result, test_case.value, "Serialization and deserialization of int " .. i .. " failed")
    end
end

local function test_allocu_and_popu()
    local test_cases = {
        {push = Squash.uint(1).ser, pop = Squash.uint(1).des, value = 255},
        {push = Squash.uint(2).ser, pop = Squash.uint(2).des, value = 65535},
        {push = Squash.uint(3).ser, pop = Squash.uint(3).des, value = 16777215},
        {push = Squash.uint(4).ser, pop = Squash.uint(4).des, value = 4294967295},
        {push = Squash.uint(5).ser, pop = Squash.uint(5).des, value = 1099511627775},
        {push = Squash.uint(6).ser, pop = Squash.uint(6).des, value = 281474976710655},
        {push = Squash.uint(7).ser, pop = Squash.uint(7).des, value = 72057594037927935},
        {push = Squash.uint(8).ser, pop = Squash.uint(8).des, value = 18446744073709551615},
    }

    for i, test_case in ipairs(test_cases) do
        local cursor = Squash.cursor()
        test_case.push(cursor, test_case.value)
        local result = test_case.pop(cursor)
        assert_equal(result, test_case.value, "Serialization and deserialization of uint " .. i .. " failed")
    end
end

local function test_number()
    local test_cases = {
        {push = Squash.number(4).ser, pop = Squash.number(4).des, value = 3.14},
        {push = Squash.number(8).ser, pop = Squash.number(8).des, value = 2.718281828459045},
    }

    for i, test_case in ipairs(test_cases) do
        local cursor = Squash.cursor()
        test_case.push(cursor, test_case.value)
        local result = test_case.pop(cursor)
        assert_equal(result, test_case.value, "Serialization and deserialization of number " .. i .. " failed")
    end
end

local function test_allocvlq_and_popvlq()
    local test_cases = {
        {push = Squash.vlq().ser, pop = Squash.vlq().des, value = 255},
        {push = Squash.vlq().ser, pop = Squash.vlq().des, value = 65535},
        {push = Squash.vlq().ser, pop = Squash.vlq().des, value = 16777215},
        {push = Squash.vlq().ser, pop = Squash.vlq().des, value = 4294967295},
        {push = Squash.vlq().ser, pop = Squash.vlq().des, value = 1099511627775},
        {push = Squash.vlq().ser, pop = Squash.vlq().des, value = 281474976710655},
        {push = Squash.vlq().ser, pop = Squash.vlq().des, value = 72057594037927935},
        {push = Squash.vlq().ser, pop = Squash.vlq().des, value = 18446744073709551615},
    }

    for i, test_case in ipairs(test_cases) do
        local cursor = Squash.cursor()
        test_case.push(cursor, test_case.value)
        local result = test_case.pop(cursor)
        assert_equal(result, test_case.value, "Serialization and deserialization of vlq failed")
    end
end

local function test_string()
    local cursor = Squash.cursor()
    local value = "Hello, World!"
    Squash.string().ser(cursor, value)
    local result = Squash.string().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of string failed")
end

local function test_bool()
    local value = { true, false, true, false, true, false, true, false }
    local cursor = Squash.cursor()
    Squash.boolean().ser(cursor, table.unpack(value))
    local result = {Squash.boolean().des(cursor)}
    for i = 1, 8 do
        assert_equal(result[i], value[i], "Serialization and deserialization of boolean failed")
    end
end

local function test_buffer()
    local cursor = Squash.cursor()
    local value = buffer.create(8)
    buffer.writeu32(value, 0, 12345678)
    Squash.buffer().ser(cursor, value)
    local result = Squash.buffer().des(cursor)
    assert_equal(buffer.readu32(result, 0), 12345678, "Serialization and deserialization of buffer failed")
end

local function test_axes()
    local cursor = Squash.cursor()
    local value = Axes.new(Enum.Axis.X, Enum.Axis.Y)
    Squash.Axes().ser(cursor, value)
    local result = Squash.Axes().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of axes failed")
end

local function test_brickcolor()
    local cursor = Squash.cursor()
    local value = BrickColor.new("Bright red")
    Squash.BrickColor().ser(cursor, value)
    local result = Squash.BrickColor().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of BrickColor failed")
end

local function test_cframe()
    local cursor = Squash.cursor()
    local value = CFrame.new(1, 2, 3)
    Squash.CFrame(Squash.number(4)).ser(cursor, value)
    local result = Squash.CFrame(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of CFrame failed")
end

local function test_color3()
    local cursor = Squash.cursor()
    local value = Color3.new(1, 0, 0)
    Squash.Color3().ser(cursor, value)
    local result = Squash.Color3().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of Color3 failed")
end

local function test_colorsequence()
    local cursor = Squash.cursor()
    local value = ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 1, 0))
    Squash.ColorSequence().ser(cursor, value)
    local result = Squash.ColorSequence().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of ColorSequence failed")
end

local function test_datetime()
    local cursor = Squash.cursor()
    local value = DateTime.now()
    Squash.DateTime().ser(cursor, value)
    local result = Squash.DateTime().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of DateTime failed")
end

local function test_faces()
    local cursor = Squash.cursor()
    local value = Faces.new(Enum.NormalId.Front, Enum.NormalId.Top)
    Squash.Faces().ser(cursor, value)
    local result = Squash.Faces().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of Faces failed")
end

local function test_floatcurvekey()
    local cursor = Squash.cursor()
    local value = FloatCurveKey.new(1, 0.5, Enum.KeyInterpolationMode.Linear)
    Squash.FloatCurveKey().ser(cursor, value)
    local result = Squash.FloatCurveKey().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of FloatCurveKey failed")
end

local function test_font()
    local cursor = Squash.cursor()
    local value = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Bold, Enum.FontStyle.Italic)
    Squash.Font().ser(cursor, value)
    local result = Squash.Font().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of Font failed")
end

local function test_numberrange()
    local cursor = Squash.cursor()
    local value = NumberRange.new(1, 2)
    Squash.NumberRange(Squash.number(4)).ser(cursor, value)
    local result = Squash.NumberRange(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of NumberRange failed")
end

local function test_numbersequence()
    local cursor = Squash.cursor()
    local value = NumberSequence.new {NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }
    Squash.NumberSequence(Squash.number(4)).ser(cursor, value)
    local result = Squash.NumberSequence(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of NumberSequence failed")
end

local function test_ray()
    local cursor = Squash.cursor()
    local value = Ray.new(Vector3.new(0, 0, 0), Vector3.new(1, 0, 0))
    Squash.Ray(Squash.number(4)).ser(cursor, value)
    local result = Squash.Ray(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of Ray failed")
end

local function test_region3()
    local cursor = Squash.cursor()
    local value = Region3.new(Vector3.new(0, 0, 0), Vector3.new(1, 1, 1))
    Squash.Region3(Squash.number(4)).ser(cursor, value)
    local result = Squash.Region3(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of Region3 failed")
end

local function test_region3int16()
    local cursor = Squash.cursor()
    local value = Region3int16.new(Vector3int16.new(0, 0, 0), Vector3int16.new(1, 1, 1))
    Squash.Region3int16().ser(cursor, value)
    local result = Squash.Region3int16().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of Region3int16 failed")
end

local function test_rotationcurvekey()
    local cursor = Squash.cursor()
    local value = RotationCurveKey.new(1, CFrame.new(0, 0, 0), Enum.KeyInterpolationMode.Linear)
    Squash.RotationCurveKey(Squash.number(4)).ser(cursor, value)
    local result = Squash.RotationCurveKey(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of RotationCurveKey failed")
end

local function test_tweeninfo()
    local cursor = Squash.cursor()
    local value = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
    Squash.TweenInfo().ser(cursor, value)
    local result = Squash.TweenInfo().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of TweenInfo failed")
end

local function test_udim()
    local cursor = Squash.cursor()
    local value = UDim.new(1, 2)
    Squash.UDim(Squash.number(4)).ser(cursor, value)
    local result = Squash.UDim(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of UDim failed")
end

local function test_udim2()
    local cursor = Squash.cursor()
    local value = UDim2.new(1, 2, 3, 4)
    Squash.UDim2(Squash.number(4)).ser(cursor, value)
    local result = Squash.UDim2(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of UDim2 failed")
end

local function test_vector2()
    local cursor = Squash.cursor()
    local value = Vector2.new(1, 2)
    Squash.Vector2(Squash.number(4)).ser(cursor, value)
    local result = Squash.Vector2(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of Vector2 failed")
end

local function test_vector2int16()
    local cursor = Squash.cursor()
    local value = Vector2int16.new(1, 2)
    Squash.Vector2int16().ser(cursor, value)
    local result = Squash.Vector2int16().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of Vector2int16 failed")
end

local function test_vector3()
    local cursor = Squash.cursor()
    local value = Vector3.new(1, 2, 3)
    Squash.Vector3(Squash.number(4)).ser(cursor, value)
    local result = Squash.Vector3(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of Vector3 failed")
end

local function test_vector3int16()
    local cursor = Squash.cursor()
    local value = Vector3int16.new(1, 2, 3)
    Squash.Vector3int16().ser(cursor, value)
    local result = Squash.Vector3int16().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of Vector3int16 failed")
end

local function test_pathwaypoint()
    local cursor = Squash.cursor()
    local value = PathWaypoint.new(Vector3.new(1, 2, 3), Enum.PathWaypointAction.Jump, "Label")
    Squash.PathWaypoint(Squash.number(4)).ser(cursor, value)
    local result = Squash.PathWaypoint(Squash.number(4)).des(cursor)
    assert_equal(result, value, "Serialization and deserialization of PathWaypoint failed")
end

local function test_physicalproperties()
    local cursor = Squash.cursor()
    local value = PhysicalProperties.new(1, 2, 0.5, 4, 5)
    Squash.PhysicalProperties().ser(cursor, value)
    local result = Squash.PhysicalProperties().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of PhysicalProperties failed")
end

local function test_raycastparams()
    local cursor = Squash.cursor()
    local value = RaycastParams.new()
    value.CollisionGroup = "Default"
    value.FilterType = Enum.RaycastFilterType.Include
    value.BruteForceAllSlow = true
    value.RespectCanCollide = true
    Squash.RaycastParams().ser(cursor, value)
    local result = Squash.RaycastParams().des(cursor)
    assert_equal(result, value, "Serialization and deserialization of RaycastParams failed")
end

local function test_raycastresult()
    local cursor = Squash.cursor()
    local value = workspace:Raycast(Vector3.new(1, 2, 3), Vector3.new(-4, -5, -6))
    assert(value, `No RaycastResult`)
    Squash.RaycastResult(Squash.number(4)).ser(cursor, value)
    local result = Squash.RaycastResult(Squash.number(4)).des(cursor)
    assert_equal(result.Distance, value.Distance, "Serialization and deserialization of RaycastResult.Distance failed")
    assert_equal(result.Instance, nil, "Serialization and deserialization of RaycastResult.Instance failed")
    assert_equal(result.Material, value.Material, "Serialization and deserialization of RaycastResult.Material failed")
    assert_equal(result.Normal, value.Normal, "Serialization and deserialization of RaycastResult.Normal failed")
    assert_equal(result.Position, value.Position, "Serialization and deserialization of RaycastResult.Position failed")
end

local function run_tests()
    test_alloci_and_popi()
    test_allocu_and_popu()
    test_allocvlq_and_popvlq()
    test_number()
    test_string()
    test_bool()
    test_buffer()
    test_axes()
    test_brickcolor()
    test_cframe()
    test_color3()
    test_colorsequence()
    test_datetime()
    test_faces()
    test_floatcurvekey()
    test_font()
    test_numberrange()
    test_numbersequence()
    test_ray()
    test_region3()
    test_region3int16()
    test_rotationcurvekey()
    test_tweeninfo()
    test_udim()
    test_udim2()
    test_vector2()
    test_vector2int16()
    test_vector3()
    test_vector3int16()
    test_pathwaypoint()
    test_physicalproperties()
    test_raycastparams()
    test_raycastresult()
    print("All tests passed!")
end

run_tests()

--* Booleans

local cursor = Squash.cursor()
Squash.boolean().ser(cursor, true)
Squash.print(cursor)
-- Pos: 1 / 8
-- Buf: { 1 0 0 0 0 0 0 0 }
--          ^
print(Squash.boolean().des(cursor))
-- true false false false false false false false

local cursor = Squash.cursor(3)
Squash.boolean().ser(cursor, true, false, true, false, true, true, false, true)
Squash.print(cursor)
--- Pos: 1 / 3
--- Buf: { 181 0 0 }
---            ^
print(Squash.boolean().des(cursor))
-- true false true false true true false true

--* Unsigned Integers

local cursor = Squash.cursor()
Squash.uint(1).ser(cursor, 243)
Squash.print(cursor)
-- Pos: 1 / 8
-- Buf: { 243 0 0 0 0 0 0 0 }
--            ^
print(Squash.uint(1).des(cursor))
-- 243

local cursor = Squash.cursor(1)
Squash.uint(1).ser(cursor, -13)
Squash.print(cursor)
-- Pos: 1 / 1
-- Buf: { 243   }
--            ^
print(Squash.uint(1).des(cursor))
-- 243

local cursor = Squash.cursor(4, 1)
Squash.uint(2).ser(cursor, 7365)
Squash.print(cursor)
-- Pos: 3 / 4
-- Buf: { 0 197 28 0 }
--                 ^
print(Squash.uint(2).des(cursor))
-- 7365

--* Signed Integers

local cursor = Squash.cursor()
Squash.int(1).ser(cursor, 127)
Squash.print(cursor)
-- Pos: 1 / 8
-- Buf: { 127 0 0 0 0 0 0 0 }
--            ^
print(Squash.int(1).des(cursor))
-- 127

local cursor = Squash.cursor()
Squash.int(1).ser(cursor, -127)
Squash.print(cursor)
-- Pos: 1 / 8
-- Buf: { 129 0 0 0 0 0 0 0 }
--            ^
print(Squash.int(1).des(cursor))
-- -127

local cursor = Squash.cursor()
Squash.int(1).ser(cursor, 128)
Squash.print(cursor)
-- Pos: 1 / 8
-- Buf: { 128 0 0 0 0 0 0 0 }
--            ^
print(Squash.int(1).des(cursor))
-- -128

local cursor = Squash.cursor()
Squash.int(1).ser(cursor, -128)
Squash.print(cursor)
-- Pos: 1 / 8
-- Buf: { 128 0 0 0 0 0 0 0 }
--            ^
print(Squash.int(1).des(cursor))
-- -128

--* Numbers

local cursor = Squash.cursor()
Squash.number(4).ser(cursor, 174302.923957475339573)
Squash.print(cursor)
-- Pos: 4 / 8
-- Buf: { 187 55 42 72 0 0 0 0 }
--                     ^
print(Squash.number(4).des(cursor))
-- 174302.921875

local cursor = Squash.cursor()
Squash.number(8).ser(cursor, -17534840302.923957475339573)
Squash.print(cursor)
-- Pos: 8 / 8
-- Buf: { 34 178 187 183 161 84 16 194   }
--                                     ^
print(Squash.number(8).des(cursor))
-- -17534840302.923958

--* VLQ

local cursor = Squash.cursor()
Squash.vlq().ser(cursor, 10)
Squash.print(cursor)
-- Pos: 1 / 8
-- Buf: { 138 0 0 0 0 0 0 0 }
--            ^
print(Squash.vlq().des(cursor))
-- 10

local cursor = Squash.cursor()
Squash.vlq().ser(cursor, 130)
Squash.print(cursor)
-- Pos: 2 / 8
-- Buf: { 129 2 0 0 0 0 0 0 }
--              ^
print(Squash.vlq().des(cursor))
-- 130

local cursor = Squash.cursor()
Squash.vlq().ser(cursor, 547359474)
Squash.print(cursor)
-- Pos: 5 / 8
-- Buf: { 130 5 0 21 114 0 0 0 }
--                       ^
print(Squash.vlq().des(cursor))
-- 547359474

--* Strings

local cursor = Squash.cursor()
Squash.string().ser(cursor, "Hello, World!")
Squash.print(cursor)
-- Pos: 14 / 18
-- Buf: { 72 101 108 108 111 44 32 87 111 114 108 100 33 141 0 0 0 0 }
--                                                           ^
print(Squash.string().des(cursor))

local cursor = Squash.cursor()
Squash.string(13).ser(cursor, "Hello, World!")
Squash.print(cursor)
-- Pos: 13 / 18
-- Buf: { 72 101 108 108 111 44 32 87 111 114 108 100 33 0 0 0 0 0 }
--                                                       ^
print(Squash.string(13).des(cursor))
-- Hello, World!

----* Base Conversion

local x = 'Hello, world!'
local alphabet = Squash.string.alphabet(x)
print(alphabet)
--  !,Hdelorw
local y = Squash.string.convert(x, alphabet, Squash.string.utf8)
print(y)
-- >q#�
print(Squash.string.convert(y, Squash.string.utf8, alphabet))
-- 'Hello, world!'

local y = Squash.string.convert('great sword', Squash.string.lower .. ' ', Squash.string.utf8)
print(y)
-- �zvFV�
print(Squash.string.convert(y, Squash.string.utf8, Squash.string.lower .. ' '))
-- 'great sword'

local y = Squash.string.convert('lowercase', Squash.string.lower, Squash.string.upper)
print(y)
-- LOWERCASE
print(Squash.string.convert(y, Squash.string.upper, Squash.string.lower))
-- lowercase

local y = Squash.string.convert('123', Squash.string.decimal, Squash.string.binary)
print(y)
-- 1111011
print(Squash.string.convert(y, Squash.string.binary, Squash.string.octal))
-- 173
print(Squash.string.convert(y, Squash.string.binary, Squash.string.decimal))
-- 123
print(Squash.string.convert(y, Squash.string.binary, Squash.string.duodecimal))
-- A3
print(Squash.string.convert(y, Squash.string.binary, Squash.string.hexadecimal))
-- 7B
print(Squash.string.convert(y, Squash.string.binary, Squash.string.utf8))
-- {

--* Arrays

local cursor = Squash.cursor()
Squash.array(Squash.number(4)).ser(cursor, {1, 2, 3, 4, 5.5, 6.6, -7.7, -8.9, 10.01})
Squash.print(cursor)
-- Pos: 37 / 40
-- Buf: { 0 0 128 63 0 0 0 64 0 0 64 64 0 0 128 64 0 0 176 64 51 51 211 64 102 102 246 192 102 102 14 193 246 40 32 65 137 0 0 0 }
--                                                                                                                         ^
print(Squash.array(Squash.number(4)).des(cursor))
-- {
--    [1] = 1,
--    [2] = 2,
--    [3] = 3,
--    [4] = 4,
--    [5] = 5.5,
--    [6] = 6.599999904632568,
--    [7] = -7.699999809265137,
--    [8] = -8.899999618530273,
--    [9] = 10.01000022888184
-- }

local arr = Squash.array
local float = Squash.number(4)
local myarr = arr(float, 8)

local cursor = Squash.cursor()
myarr.ser(cursor, {1, 2, 3, 4, 5.5, 6.6, -7.7, -8.9, 10.01})
Squash.print(cursor)
-- Pos: 32 / 40
-- Buf: { 0 0 128 63 0 0 0 64 0 0 64 64 0 0 128 64 0 0 176 64 51 51 211 64 102 102 246 192 102 102 14 193 0 0 0 0 0 0 0 0 }
--                                                                                                        ^
print(myarr.des(cursor))
-- {
--    [1] = 1,
--    [2] = 2,
--    [3] = 3,
--    [4] = 4,
--    [5] = 5.5,
--    [6] = 6.599999904632568,
--    [7] = -7.699999809265137,
--    [8] = -8.899999618530273,
-- }

--* Maps

local u = Squash.uint
local vec3 = Squash.Vector3
local vec2 = Squash.Vector2
local mymap = Squash.map(vec2(u(2)), vec3(u(3)))

local cursor = Squash.cursor()
mymap.ser(cursor, {
    [Vector2.new(1, 2)] = Vector3.new(1, 2, 3),
    [Vector2.new(4, 29)] = Vector3.new(4, 29, 33),
    [Vector2.new(72, 483)] = Vector3.new(72, 483, 555),
})
Squash.print(cursor)
-- Pos: 40 / 40
-- Buf: { 43 2 0 227 1 0 72 0 0 227 1 72 0 33 0 0 29 0 0 4 0 0 29 0 4 0 3 0 0 2 0 0 1 0 0 2 0 1 0 131   }
--                                                                                                    ^
print(mymap.des(cursor))
-- {
--    [Vector2(24346692898)] = 72, 483, 555,
--    [Vector2(243466928B0)] = 4, 29, 33,
--    [Vector2(243466928C8)] = 1, 2, 3
-- }

--* Records

local T = Squash.T
local u = Squash.uint
local vlq = Squash.vlq()
local bool = Squash.boolean()
local str = Squash.string()
local float = Squash.number(4)
local vec2 = Squash.Vector2
local arr = Squash.array
local map = Squash.map
local opt = Squash.opt
local record = Squash.record

local playerserdes = record {
    position = T(vec2(float)),
    health = T(u(1)),
    name = T(str),
    poisoned = T(bool),
    items = T(arr(record {
        count = T(vlq),
        name = T(str),
    })),
    inns = T(map(str, bool)),
    equipped = T(opt(str)),
}

local cursor = Squash.cursor()
playerserdes.ser(cursor, {
    position = Vector2.new(287.3855, -13486.3),
    health = 9,
    name = "Cedrick",
    poisoned = true,
    items = {
        { name = 'Lantern', count = 2 },
        { name = 'Waterskin', count = 1 },
        { name = 'Map', count = 4 },
    },
    inns = {
        ['The Copper Cauldron'] = true,
        Infirmary = true,
        ['His Recess'] = true,
    },
    equipped = nil,
})
Squash.print(cursor)
-- Pos: 90 / 90
-- Buf: { 0 9 1 72 105 115 32 82 101 99 101 115 115 138 1 84 104 101 32 67 111 112 112 101 114 32 67 97 117 108 100 114 111 110 147 1 73 110 102 105 114 109 97 114 121 137 131 130 76 97 110 116 101 114 110 135 129 87 97 116 101 114 115 107 105 110 137 132 77 97 112 131 131 67 101 100 114 105 99 107 135 1 51 185 82 198 88 177 143 67   }
--                                                                                                                                                                                                                                                                                                                                            ^                                                                                                                                                                                                                                                                                                                                     ^
print(playerserdes.des(cursor))
-- {
--     ["health"] = 9,
--     ["inns"] =  ▼  {
--        ["His Recess"] = true,
--        ["Infirmary"] = true,
--        ["The Copper Cauldron"] = true
--     },
--     ["items"] =  ▼  {
--        [1] =  ▼  {
--           ["count"] = 2,
--           ["name"] = "Lantern"
--        },
--        [2] =  ▼  {
--           ["count"] = 1,
--           ["name"] = "Waterskin"
--        },
--        [3] =  ▼  {
--           ["count"] = 4,
--           ["name"] = "Map"
--        }
--     },
--     ["name"] = "Cedrick",
--     ["poisoned"] = true,
--     ["position"] = 287.385498, -13486.2998
--  }

--* Tuples

local S = Squash
local T = S.T

local mytuple = S.tuple(
    T(S.Vector3(S.number(8))),
    T(S.CFrame(S.int(1))),
    T(S.BrickColor()),
    T(S.EnumItem(Enum.HumanoidStateType))
)

local cursor = S.cursor()
mytuple.ser(cursor, Vector3.new(123456789, 1, 0), CFrame.new(1, 2, 3), BrickColor.new(93), Enum.HumanoidStateType.Freefall)
Squash.print(cursor)
-- Pos: 40 / 40
-- Buf: { 0 0 0 0 0 0 0 0 0 0 0 0 0 0 240 63 0 0 0 96 52 111 157 65 1 0 0 64 64 0 0 0 64 0 0 128 63 194 0 134   }
--                                                                                                            ^
print(mytuple.des(cursor))
-- 123456792, 1, 0 1, 2, 3, 1, 0, 0, 0, 1, 0, 0, 0, 1 Medium stone grey Enum.HumanoidStateType.Freefall

--* Tables

local serdes = Squash.table {
    number = Squash.number(8),
    string = Squash.string(),
    boolean = Squash.boolean(),
    table = Squash.table {
        CFrame = Squash.CFrame(Squash.number(4)),
        Vector3 = Squash.Vector3(Squash.int(2)),
        number = Squash.vlq(),
    },
}

local cursor = Squash.cursor()
serdes.ser(cursor, {
    wow = -5.352345,
    [23846.4522] = true,
    [false] = 'Gaming!',
    ThisWontSerialize = DateTime.now(),
    [{
        CFrame.new(-24.2435, 2, 3), CFrame.new(), Vector3.new(354, -245, -23),
        [100] = Vector3.zAxis,
        [Vector3.zero] = 255,
    }] = {
        [1] = CFrame.identity,
        [2] = Vector3.zero,
        [3] = 256,
    },
})
Squash.print(cursor)
-- Pos: 131 / 135
-- Buf: { 71 97 109 105 110 103 33 135 1 0 2 240 162 175 32 205 104 21 192 0 119 111 119 131 1 1 2 208 68 216 240 156 73 215 64 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 129 0 0 0 0 0 0 0 2 130 0 130 0 0 131 0 131 3 1 0 0 64 64 0 0 0 64 176 242 193 193 1 129 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 130 0 233 255 11 255 98 1 2 131 0 129 127 0 0 0 0 0 0 0 2 1 0 0 0 0 0 2 228 0 133 3 132 0 0 0 0 }
--                                                                                                                                                                                                                                                                                                                                                                           ^
print(serdes.des(cursor))
-- {
--     ["wow"] = -5.352345,
--     [23846.4522] = true,
--     [Table(24BE4A11A98)] =  ▼  {
--         [1] = 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1,
--         [2] = 0, 0, 0,
--         [3] = 256
--     },
--     [false] = "Gaming!"
-- }