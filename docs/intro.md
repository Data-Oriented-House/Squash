---
sidebar_position: 1
---

# What Is SerDes?

SerDes is a common abbreviation used for **Serialization Deserialization**.

## Why SerDes?

**SerDes** is a way to minimize bandwidth and save space by reducing the size of data. **It is to give the player a better experience.**

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

### Buffers Are The Key

The only three arbitrarily-sized datatypes in Luau are the `string`, `buffer`, and `table` datatypes. Tables can only be composed of primitive datatypes or other tables, and strings have both performance and memory overheads. Therefore if we need more control over the data we need to serialize, we should use buffers. With buffers, we have access to individual byte manipulation.
