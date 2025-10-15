---
sidebar_position: 3
---

# Advanced Techniques

## Custom Serializers
For the performance-concerned, Squash exposes the `Squash.tryrealloc(cursor: Cursor, bytes: number)` method to make implementing custom serializers a breeze. These custom serializers can be used in conjunction with other serializers like the `table`, `record`, `map`, `array`, and `tuple` serializers. For example, if you have thousands of enemies represented by simple data, you may wish to serialize them all in one go without the overhead of the array.

```lua
local Squash = require(...)

local T = Squash.T
local rec = Squash.record
local arr = Squash.array
local i3 = Squash.i24()
local u2 = Squash.u16()

local Serializers = {}
```

The below example implementation wastes a few bytes at the end of each array to redundantly record a length that can be stored only once. The type could be changed to `{ { x: number, z: number, id: number } }` but that comes with a performance overhead because of so many table creations when deserializing.
```lua
Serializers.enemies = rec {
	x = T(arr(i3, u2)),
	z = T(arr(i3, u2)),
	id = T(arr(u2, u2))
}

do
	local c = Squash.cursor()
	Serializers.enemies.ser(c, {
		x = {-1000, 2, 3, 4},
		z = {4, 5, 6, 7},
		id = {10, 11, 12, 13},
	})
	Squash.print(c)
	local b = Squash.tobuffer(c)

	local c = Squash.frombuffer(b)
	local data = Serializers.enemies.des(c)
	for i = 1, #data.x do
		print(`x: {data.x[i]}, z: {data.z[i]}, id: {data.id[i]}`)
	end
	--[[
		Look, it uses 38 bytes, 4 more extra!

		Pos: 38 / 40
		Buf: { 10 0 11 0 12 0 13 0 4 0 24 252 255 2 0 0 3 0 0 4 0 0 4 0 4 0 0 5 0 0 6 0 0 7 0 0 4 0 0 0 }
																									^
		x: -1000, z: 4, id: 10
		x: 2, z: 5, id: 11
		x: 3, z: 6, id: 12
		x: 4, z: 7, id: 13
	]]
end
```

The below implementation has less overhead and defines a custom format to only store the length once. It can serialize into the `{ { x: number, z: number, id: number } }` format, but then deserialize straight into the `{ x: { number }, z: { number }, id: { number } }` format.
```lua
local getbuf = Squash.getbuf
local getpos = Squash.getpos
local setpos = Squash.setpos
local tryrealloc = Squash.tryrealloc

Serializers.enemiesManually = {
	ser = function(cursor, data)
		local n = #data.x

		tryrealloc(cursor, 8 * n)
		local buf = getbuf(cursor)

		local p = getpos(buf)
		for i = 1, n do
			local x, z, id = data.x[i], data.z[i], data.id[i]

			x = math.abs(x) * 2 + if x < 0 then 1 else 0
			buffer.writeu8(buf, p, x)
			p += 1
			buffer.writeu16(buf, p, x // 256)
			p += 2

			z = math.abs(z) * 2 + if z < 0 then 1 else 0
			buffer.writeu8(buf, p, z)
			p += 1
			buffer.writeu16(buf, p, z // 256)
			p += 2

			buffer.writeu16(buf, p, id)
			p += 2
		end

		buffer.writeu16(buf, p, n)
		p += 2

		setpos(buf, p)
	end,

	des = function(cursor)
		local buf = getbuf(cursor)
		local p = getpos(buf)

		p -= 2
		local n = buffer.readu16(buf, p)

		local data = {
			x = table.create(n),
			z = table.create(n),
			id = table.create(n),
		}
		for i = n, 1, -1 do
			p -= 2
			local id = buffer.readu16(buf, p)

			p -= 2
			local z2 = buffer.readu16(buf, p) * 256
			p -= 1
			local z1 = buffer.readu8(buf, p)
			local z = (z2 + z1) // 2 * if z1 % 2 == 0 then 1 else -1

			p -= 2
			local x2 = buffer.readu16(buf, p) * 256
			p -= 1
			local x1 = buffer.readu8(buf, p)
			local x = (x2 + x1) // 2 * if x1 % 2 == 0 then 1 else -1

			data.x[i], data.z[i], data.id[i] = x, z, id
		end

		setpos(buf, p)

		return data
	end,
} :: SerDes<{ x: { number }, z: { number }, id: { number } }>

do
	local c = Squash.cursor()
	Serializers.enemiesManually.ser(c, {
		x = {-1000, 2, 3, 4},
		z = {4, 5, 6, 7},
		id = {10, 11, 12, 13},
	})
	Squash.print(c)
	local b = Squash.tobuffer(c)

	local c = Squash.frombuffer(b)
	local data = Serializers.enemiesManually.des(c)
	for i = 1, #data.x do
		print(`x: {data.x[i]}, z: {data.z[i]}, id: {data.id[i]}`)
	end
	--[[
		Only 34 bytes, perfection!

		Pos: 34 / 40
		Buf: { 209 7 0 8 0 0 10 0 4 0 0 10 0 0 11 0 6 0 0 12 0 0 12 0 8 0 0 14 0 0 13 0 4 0 0 0 0 0 0 0 }
																							^
		x: -1000, z: 4, id: 10
		x: 2, z: 5, id: 11
		x: 3, z: 6, id: 12
		x: 4, z: 7, id: 13
	]]
end
```