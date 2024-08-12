--- @class Squash

--- @interface Cursor
--- @within Squash
--- .Buf buffer
--- .Pos number
--- An import of the Redblox Buffit Cursor type for better cross-library interaction

--- @interface SerDes
--- @within Squash
--- .ser (Cursor, T...) -> ()
--- .des (Cursor) -> T...

--- @function print
--- @within Squash
--- @param cursor Cursor
--- Pretty prints a Cursor record.

--- @function cursor
--- @within Squash
--- @param size number?
--- @param position number?
--- @return Cursor

--- @function frombuffer
--- @within Squash
--- @param buf buffer
--- @return Cursor

--- @function tobuffer
--- @within Squash
--- @param cursor Cursor
--- @return buffer

--- @function T
--- @within Squash
--- @param x SerDes<T>
--- @return T

--- @function boolean
--- @within Squash
--- @return { ser: (Cursor, boolean, boolean?, boolean?, boolean?, boolean?, boolean?, boolean?, boolean?) -> (), des: (Cursor) -> (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean) }

-- --- @class uint

--- @function uint
--- @within Squash
--- @param bytes number
--- @return SerDes<number>
--- Accuracy diminishes using 7 or 8 bytes.

-- --- @class int

--- @function int
--- @within Squash
--- @param bytes number
--- @return SerDes<number>
--- Accuracy diminishes using 7 or 8 bytes.

-- --- @class number

--- @function number
--- @within Squash
--- @param bytes number
--- @return SerDes<number>
--- Only supports 4 or 8 bytes.

--[=[
    @class string
    This namespace may be called like a function to return a string serdes, or it may be accessed like a table to use the string content.
]=]

--[=[
    @function convert
    @param str string
    @param inAlphabet string
    @param outAlphabet string
    @return string
    @within string
    Converts a string, treated as a number in base `inAlphabet`, to a number in base `toAlphabet`.
]=]

--[=[
    @function alphabet
    @param source string
    @return string
    @within string
    Returns the smallest sorted alphabet from a source string.
]=]

--- @prop binary string
--- @within string
--- The alphabet `'01'`.

--- @prop octal string
--- @within string
--- The alphabet `'01234567'`.

--- @prop decimal string
--- @within string
--- The alphabet `'0123456789'`.

--- @prop duodecimal string
--- @within string
--- The alphabet `'0123456789AB'`.

--- @prop hexadecimal string
--- @within string
--- The alphabet `'0123456789ABCDEF'`.

--- @prop utf8 string
--- @within string
--- The alphabet of all 256 possible characters.

--- @prop lower string
--- @within string
--- The alphabet `'abcdefghijklmnopqrstuvwxyz'`.

--- @prop upper string
--- @within string
--- The alphabet `'ABCDEFGHIJKLMNOPQRSTUVWXYZ'`.

--- @prop letters string
--- @within string
--- The alphabet `lower .. upper`.

--- @prop punctuation string
--- @within string
--- The alphabet `' .,?!:;\'"-_'`.

--- @prop english string
--- @within string
--- The alphabet `letters .. punctuation`.

--- @prop filepath string
--- @within string
--- The alphabet `letters .. ':/'`.

--- @prop datastore string
--- @within string
--- The alphabet of every character that doesn't get expanded when JSON encoding.

--- @function string
--- @within Squash
--- @param length number?
--- @return SerDes<string>

-- --- @class buffer

--- @function buffer
--- @within Squash
--- @param length number?
--- @return SerDes<buffer>

-- --- @class vlq

--- @function vlq
--- @within Squash
--- @return SerDes<number>

-- --- @class opt

--- @function opt
--- @within Squash
--- @param serdes SerDes<T>
--- @return SerDes<T?>

-- --- @class array

--- @function array
--- @within Squash
--- @param serdes SerDes<T>
--- @param length number?
--- @return SerDes<{T}>

-- --- @class tuple

--- @function tuple
--- @within Squash
--- @param ... T...
--- @return SerDes<T...>

-- --- @class record

--- @function record
--- @within Squash
--- @param schema T
--- @return SerDes<T>

-- --- @class map

--- @function map
--- @within Squash
--- @param keySerDes SerDes<K>
--- @param valueSerDes SerDes<V>
--- @return SerDes<{[K]: V}>

-- --- @class literal

--- @function literal
--- @within Squash
--- @param literals ... any
--- @return SerDes<any>

-- --- @class table

--[=[
    @function table
    @within Squash
    @param schema { [string]: SerDes<any> }
    @return SerDes<any>
    Serializes tables given a schema mapping types to serializers.
    If a type is not defined in the schema, it will be ignored when serializing tables.
    **This is an expensive and heavy serializer compared to Record, Map, and Array.**
    **It is highly recommended that you do not use this for tables you know the type of already.**
]=]

-- --- @class Axes

--- @function Axes
--- @within Squash
--- @return SerDes<Axes>

-- --- @class BrickColor

--- @function BrickColor
--- @within Squash
--- @return SerDes<BrickColor>

-- --- @class EnumItem

--- @function EnumItem
--- @within Squash
--- @param enum Enum
--- @return SerDes<EnumItem>

-- --- @class CatalogueSearchParams

--- @function CatalogueSearchParams
--- @within Squash
--- @return SerDes<CatalogSearchParams>

-- --- @class CFrame

--- @function CFrame
--- @within Squash
--- @param positionSerDes SerDes<number>
--- @return SerDes<CFrame>

-- --- @class Color3

--- @function Color3
--- @within Squash
--- @return SerDes<Color3>

-- --- @class ColorSequenceKeypoint

--- @function ColorSequenceKeypoint
--- @within Squash
--- @return SerDes<ColorSequenceKeypoint>

-- --- @class ColorSequence

--- @function ColorSequence
--- @within Squash
--- @return SerDes<ColorSequence>

-- --- @class DateTime

--- @function DateTime
--- @within Squash
--- @return SerDes<DateTime>

-- --- @class Faces

--- @function Faces
--- @within Squash
--- @return SerDes<Faces>

-- --- @class FloatCurveKey

--- @function FloatCurveKey
--- @within Squash
--- @return SerDes<FloatCurveKey>

-- --- @class Font

--- @function Font
--- @within Squash
--- @return SerDes<Font>

-- --- @class NumberRange

--- @function NumberRange
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<NumberRange>

-- --- @class NumberSequenceKeypoint

--- @function NumberSequenceKeypoint
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<NumberSequenceKeypoint>

-- --- @class NumberSequence

--- @function NumberSequence
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<NumberSequence>

-- --- @class OverlapParams

--- @function OverlapParams
--- @within Squash
--- @return SerDes<OverlapParams>

-- --- @class RaycastParams

--- @function RaycastParams
--- @within Squash
--- @return SerDes<RaycastParams>

-- --- @class Vector3

--- @function Vector3
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<Vector3>

-- --- @class PathWaypoint

--- @function PathWaypoint
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<PathWaypoint>

-- --- @class PhysicalProperties

--- @function PhysicalProperties
--- @within Squash
--- @return SerDes<PhysicalProperties>

-- --- @class Ray

--- @function Ray
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<Ray>

-- --- @class RaycastResult

--- @interface SquashRaycastResult
--- .Distance number,
--- .Position Vector3
--- .Normal Vector3
--- .Material Enum.Material
--- @within Squash

--- @function RaycastResult
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<SquashRaycastResult>
--- Returns a `SquashRaycastResult` because Roblox does not allow instantiating RaycastResults.

-- --- @class Vector2

--- @function Vector2
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<Vector2>

-- --- @class Rect

--- @function Rect
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<Rect>

-- --- @class Region3

--- @function Region3
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<Region3>

-- --- @class Region3int16

--- @function Region3int16
--- @within Squash
--- @return SerDes<Region3int16>

-- --- @class RotationCurveKey

--- @function RotationCurveKey
--- @within Squash
--- @param positionSerDes SerDes<number>
--- @return SerDes<RotationCurveKey>

-- --- @class TweenInfo

--- @function TweenInfo
--- @within Squash
--- @return SerDes<TweenInfo>

-- --- @class UDim

--- @function UDim
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<UDim>

-- --- @class UDim2

--- @function UDim2
--- @within Squash
--- @param serdes SerDes<number>
--- @return SerDes<UDim2>

-- --- @class Vector2int16

--- @function Vector2int16
--- @within Squash
--- @return SerDes<Vector2int16>

-- --- @class Vector3int16

--- @function Vector3int16
--- @within Squash
--- @return SerDes<Vector3int16>