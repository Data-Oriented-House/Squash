---
sidebar_position: 1
---

# What is Squash?

Squash is a very large library that can efficiently and intelligently serialize and compress your data with little effort. **SerDes** or **Serde** is a common abbreviation used for **Serialization / Deserialization**. It is a way to translate data into raw bytes and back again.

In the world of distributed systems, we often need to send data over the network and receive it on the other end. The time that takes is proportional to how large the data is. The smaller the data, the less time it takes and the less bandwidth we use, resulting in a better player experience with lower pings.

Similarly in the world of persistent data storage, we often need to store data across servers in data banks such as: Roblox DataStores, [MySQL](https://www.mysql.com), [MongoDB](https://www.mongodb.com), and [Firebase Database](https://firebase.google.com/docs/database/). The amount of space that takes up on disks is proportional to how large the data is and how much money is spent hosting it. Smaller data means less required storage space and less money, which means we can store more data for cheaper while taking less time to save and load it.

**SerDes** is used whenever we need to compress data losslessly, in a way that can be fully recovered, such as when we need to send data over the network or store it in data banks. Common use cases include:
- Animations
- Movement
- Physics
- Saving / Loading

The only three arbitrarily-sized datatypes in Luau are the `string`, `buffer`, and `table` datatypes. Tables can only be composed of primitive datatypes or other tables, and strings have both performance and memory overheads. Therefore if we need more control over the data we need to serialize, we should use buffers. With buffers, we have access to individual byte manipulation.

## Cursor & Alternatives

There exist a few common alternatives that aim to do the same which can be compared [here on Cursor's documentation](https://data-oriented-house.github.io/Cursor/docs/intro/#alternatives). These alternatives are not as comprehensive as Squash and may be harder to use. If you like Squash but are uncomfortable with its size or performance, consider [Cursor](https://data-oriented-house.github.io/Cursor/) as it's the backbone of this project.

[![Squash vs. Cursor](/SquashVsCursor.webp)](https://data-oriented-house.github.io/Cursor/)