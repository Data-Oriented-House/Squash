---
sidebar_position: 1
---

# What Is SerDes?

Serdes is a common abbreviation used for **Serialization Deserialization**.

## Why SerDes?

**SerDes** is a way to minimize latency and save space by reducing the size of data. **It is to give the player a better experience.**

### Minimizing Latency

In the world of distributed systems, we often need to send data over the network and receive it on the other end. The time that takes is proportional to how large the data is. The smaller the data, the less time it takes and the less latency we have, resulting in a better player experience.

### Saving Space

In the world of persistent data storage, we often need to store data across servers in data banks, such as Roblox DataStores. The amount of space that takes up on disks is proportional to how large the data is. Smaller data means less required storage space, which means we can store more data and take less time to save and load it.

## When SerDes?

**SerDes** is used whenever we need to compress data in a way that we can fully retrieve the original version of it, such as when we need to send data over the network or store it in data banks. Common use cases include:
- Animations
- Movement
- Physics
- Saving / Loading

## How To SerDes In Roblox?

### Strings Are The Key

The only two arbitrarily-sized datatypes in Luau are the `string` datatype and the `table` datatype. Tables can only be composed of primitive datatypes or other tables, therefore if we need more control over the data we need to serialize, we need to use strings. With strings, we have access to individual characters, which in Lua are single-byte values. **Strings enable byte-level control of our data.**

### When And What To Serialize

Strings are great for serializing data, but we need to know when to serialize. We should serialize when we need to send data over the network or store it in data banks. However, certain kinds of data is cheaper to send over the network than others. Below are empirically measured throughputs of different kinds of types, lengths, and amounts. This is the code on the server:
```lua
local remote = game.ReplicatedStorage.RemoteEvent
while task.wait() do
	remote:FireAllClients(Value)
end
```

The results are measured from the client's Network Stats window. These are useful results for anyone in any context looking to evaluate what is expensive to send over a remote:

| Value | Bandwidth (KB/s) | Notes | Conclusions |
|-|-|-|-|
| noise | 0.16 | Noise from environment | Roblox is constantly sending data in the background |
| `()` | 0.85 | Testing if remote event has a cost | Yes |
| `(nil)` | 0.91 | Testing if nil is the same as void | No. |
| `(true)`, `(false)`, `('')` | 0.97 | Testing if value changes cost | No. Only serialize 2 or more booleans for optimal results |
| `('\0')`, `('a')`, `('0')` | 1.03 | Testing if value changes cost | No. Past this point, it is better to serialize to strings |
| `('aa')`, `('', '')` | 1.09 |
| `(true, false)`, `(false, true)`, `({true})` | 1.10 | Testing if bitpacked. Testing if order changes cost | No. No |
| `('aaa')`, `(Vector2int16.new(-32768, 9274))` | 1.16 |
| `(true, true, true)`, `('aaaa')`, `('a', 'a')`, `({true, true})`, `('', '', '')` | 1.22 | Empty string cost measured | Empty string cost averages 0.12 KB/s. Separating arguments is costly!
| `('aaaaa')`, `(Vector3int16.new(-32768, 9274, 32767))` | 1.28 |
| `(true, true, true, true)` | 1.34 |
| `('aaaaaa')` | 1.35 |
| `(Vector2.zero), (Vector2.one)`, `(Vector2.new(-32768, 32767))` | 1.40 | Testing if value changes cost | No |
| `('aaaaaaa')`, `('a', 'a', 'a')`, `(0)`, `(-96495734574.4864)` | 1.41 | Testing if value changes cost | No |
| `(true, true, true, true, true)`, `('aaaaaaaa')` | 1.47 | Character cost measured | Character cost averages 0.07 KB/s |
| `(true, true, true, true, true, true)`, `('a', 'a', 'a', 'a')` | 1.60 |
| `(Vector3.zero)`, `(Vector3.one)`, `(Vector3.new(-2402.39, 938403, 2057492.4953))` | 1.66 | Testing if value changes cost | No |
| `(true, true, true, true, true, true, true)`, `(CFrame.identity)`, `(CFrame.new() + Vector3.new(938, 0, 0))` | 1.73 | | The CFrame's position is always sent |
| `('a', 'a', 'a', 'a', 'a')` | 1.79 | Cost measured | String cost averages 0.19 KB/s |
| `(true, true, true, true, true, true, true, true)` | 1.86 | Cost measured | Boolean cost averages 0.13 KB/s |
| `(0, 0)` | 1.98 |
| `((CFrame.fromEulerAngles(9, 2, -5.3))`, `(CFrame.fromEulerAngles(9, 2, -5.3) + Vector3.new(938, 0, 0))` | 2.10 | Investigating if position and rotation are sent separately | The rotation is sent separately, and only if it needs to be sent |
| `(0, 0, 0)` | 2.54 | Dang |
| `(0, 0, 0, 0)` | 3.10 | Cost measured | Number cost averages 0.56 KB/s. Numbers are expensive! Sad |

Main takeaways:
- Arguments have overhead! Avoid separating arguments if possible!
- Numbers are expensive! Avoid sending numbers! ***Even CFrames can be cheaper.***
- Booleans are cheap! Don't serialize a single boolean. Serialize 2 or more booleans at a time!
- Strings are cheap! Serialize to strings!
- Nil takes up space!!! Don't send nils for no reason!!!!!!!!