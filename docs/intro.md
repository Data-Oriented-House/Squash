# What Is SerDes?

Serdes is a common abbreviation used for **Serialization Deserialization**.

## Why SerDes?

**SerDes** is a way to minimize latency and save space by reducing the size of data. **It is to give the player a better experience.**

### Minimizing Latency

In the world of distributed systems, we often need to send data over the network and receive it on the other end. The time it takes for data to be sent across networks is proportional to how large it is. The smaller data is, the less time it takes to send it over networks. The less time it takes to send data over networks, the less latency we have. The less latency we have, the better the player experience.

### Saving Space

In the world of persistent data storage, we often need to store data across servers in data banks (such as DataStores). The amount of space data takes up on disks is proportional to how large it is. The smaller data is, the less space it takes up on disks. The less space data takes up on disks, the more data we can store and the less time it takes to save or load it. The more data we can store and the less time it takes to access it, the better the player experience.

## When SerDes?

**SerDes** is used when we need to send data over the network or store it in data banks. Common use cases include:
- Animations
- Movement
- Physics
- Saving / Loading

## How To SerDes In Roblox?

### Strings Are The Key

The only two arbitrarily-sized datatypes in Luau are the `string` datatype and the `table` datatype. Tables can only be composed of primitive datatypes or other tables, therefore if we need more control over the data we need to serialize, we need to use strings. With strings, we have access to individual characters, which in Lua are single-byte values. **Strings enable byte-level control of our data.**

### When To Serialize

Strings are great for serializing data, but we need to know when to serialize. We should serialize when we need to send data over the network or store it in data banks. However, the size of a string when sent over the network has some overhead compared to raw data. **We should only serialize when the data we are serializing is large enough to warrant the overhead.** *TODO: Investigate how Roblox handles this and write about it.*