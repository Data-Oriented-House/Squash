---
sidebar_position: 4
---

# Packet Format And Insights

Strings are great for serializing data, but we need to know when to serialize. Certain kinds of data is cheaper to send over the network than others. This page is *very* technical, as it introduces the raw binary format remotes use internally and discusses the overhead of each type of data. If you are looking for a more high-level overview of the topic, check out the [Why SerDes?](/docs/intro) or [How To SerDes?](/docs/how) pages.

## How Are Packets Sent And Recieved?

Roblox remotes sends its data in the form of [*packets*](https://en.wikipedia.org/wiki/Network_packet). Every roblox packet is packed densely with data to reduce their size. Every byte is important and has meaning. To verify this information for yourself, source code and instructions on the hooking process are provided in [this ZIP folder](/PacketViewerSource.zip).

### Variable Length Quantities

Many of the values packets use can scale in size drastically, but still need to be kept as small as possible. There is a common format or strategy for doing this called [*Variable Length Quantities*](https://en.wikipedia.org/wiki/Variable-length_quantity) that only use as much space as they need to represent a number. This is used for the length of strings, the number of arguments in a remote call, and the number of remotes in a session. It is labeled with the acronym **VLQ** in parenthesis since it takes the place of a size. We know these are VLQs and not just regular numbers because we have tested them with numbers that are too big to fit in their initial size and looked at the binary; they scale in size as the number grows.

### The Enigmas

Even after literal days of looking at the binary, we still can't quite figure out some of the meanings behind some of the bytes. We have appropriately called these bytes "Enigmas". Over time these enigma bytes have been reduced, but they aren't quite gone yet. If you would like to help identify these bytes, you may download the packet viewer, run the tests you need to, and make a pull request improving [Squash's documentation](https://github.com/Data-Oriented-House/Squash)!

## Packet Structure

| Packet Type 0×83 (byte) | Packet Data 1 | Packet Data 2 | ... | Packet Delimiter 0×00 (byte) |
|-|-|-|-|-|

Every packet of **Packet Type 0×83** ends with a **Packet Delimiter 0×00** (null) byte, but not all packet types do this.

### Single Remote Optimization Strategy

When multiple packet datas are sent within a short enough time period using the same remote, they are merged into a single packet in the format above. This is why the packet delimiter is important; it says when to stop reading the packet. This is a strategy used to reduce packet overhead, such as the packet type, delimiter, and header necessary due to internet protocols.

It is a strategy to use only one remote and funnel all data through it, appending all packet datas into a single packet. This is why we recommend using a single remote for all data, and not using multiple remotes for different kinds of data.

## Packet Data Types

### Client To Server

#### Remote Event

Packet Subtype 0×0701 (2 bytes) | Remote Id (3 bytes) | Enigma 0×000b (2 bytes) | Client To Server Id 0×70 (byte) | User Information (5 bytes) | Argument Count (byte) | Data 1 | Data 2 | ... |
|-|-|-|-|-|-|-|-|-|

When creating remotes in studio before starting a session, each remote gets an incrementing **Remote Id** starting from an unpredictable number. This number is 3 bytes long. When creating remotes in a session, each remote gets a **Remote Id** that increments at different rates, and starts from a different value.

We are unsure of the format of the User Information, or what it actually contains. We hypothesize that it contains the player's UserId, but we have not been able to verify this.

The maximum **Argument Count** is 255 because the argument count is a single byte. This happens to also align with the maximum number of arguments a function can have in Luau.

There is no difference in size when firing remotes with different ids, or in short, the number of remotes does not affect bandwidth per packet.

#### Remote Function

Packet Subtype 0×0701 (2 bytes) | Remote Id (3 bytes) | Enigma 0×000b (2 bytes) | Client To Server Id 0×7b (byte) | Call Count (VLQ) | User Information (5 bytes) | Argument Count (byte) | Data 1 | Data 2 | ... |
|-|-|-|-|-|-|-|-|-|-|

The **Call Count** is the number of times the remote function has been invoked since the start of the session. It increments by 2 every invocation, and is sent both ways from the `Server -> Client -> Server` or `Client -> Server -> Client`. We hypothesize that this is used to prevent duplicate packets from being processed, to prevent packets from being processed out of order, or to know if a packet was dropped.

### Server To Client

#### Remote Event

Packet Subtype 0×0701 (2 bytes) | Remote Id (3 bytes) | Enigma 0×000b (2 bytes) | Server To Client Id 0×6f (byte) | Argument Count (byte) | Data 1 | Data 2 | ... |
|-|-|-|-|-|-|-|-|

#### Remote Function

<!-- 07 01 7c c1 04 00 0b 79 06 00 -->

Packet Subtype 0×0701 (2 bytes) | Remote Id (3 bytes) | Enigma 0×000b (2 bytes) | Server To Client Id 0×79 (byte) | Call Count (VLQ) | Argument Count (byte) | Data 1 | Data 2 | ... |
|-|-|-|-|-|-|-|-|-|

## Data

Below are the different ways types of data are formatted in memory when packed into remotes.

### Void (Just Remote Overhead)

#### Server -> Client

##### Remote Events

Created | Remote Name | Packet Type | Packet Subtype | Remote Id | Enigma | Server To Client Id | Argument Count | Packet Delimiter |
|-|-|-|-|-|-|-|-|-|
Before | "A" | 0×83 | 0×0701 | 0×7f6d11 | 0×000b | 0×6f | 0×00 | 0×00
Before | "B" | 0×83 | 0×0701 | 0×7d6d11 | 0×000b | 0×6f | 0×00 | 0×00
Before | "C" | 0×83 | 0×0701 | 0×7e6d11 | 0×000b | 0×6f | 0×00 | 0×00
After | "D" | 0×83 | 0×0701 | 0×430d19 | 0×000b | 0×6f | 0×00 | 0×00
After | "E" | 0×83 | 0×0701 | 0×470d19 | 0×000b | 0×6f | 0×00 | 0×00
After | "F" | 0×83 | 0×0701 | 0×4a0d19 | 0×000b | 0×6f | 0×00 | 0×00

##### Remote Functions

Created | Remote Name | Packet Type | Packet Subtype | Remote Id | Enigma | Server To Client Id | Call Count | Argument Count | Packet Delimiter |
|-|-|-|-|-|-|-|-|-|-|
Before | "A" | 0×83 | 0×0701 | 0×9ef104 | 0×000b | 0×79 | 0×02 | 0×00 | 0×00
Before | "B" | 0×83 | 0×0701 | 0×9ff104 | 0×000b | 0×79 | 0×02 | 0×00 | 0×00
Before | "C" | 0×83 | 0×0701 | 0×a0f104 | 0×000b | 0×79 | 0×02 | 0×00 | 0×00
After | "D" | 0×83 | 0×0701 | 0×27f506 | 0×000b | 0×79 | 0×02 | 0×00 | 0×00
After | "E" | 0×83 | 0×0701 | 0×2bf506 | 0×000b | 0×79 | 0×02 | 0×00 | 0×00
After | "F" | 0×83 | 0×0701 | 0×2ef506 | 0×000b | 0×79 | 0×02 | 0×00 | 0×00

#### Client -> Server

##### Remote Events

Created | Remote Name | Packet Type | Packet Subtype | Remote Id | Enigma | Client To Server Id | User Information | Argument Count | Packet Delimiter |
|-|-|-|-|-|-|-|-|-|-|
Before | "A" | 0×83 | 0×0701 | 0×6d9109 | 0×000b | 70 | 0×0159890a00 | 0×00 | 0×00
Before | "B" | 0×83 | 0×0701 | 0×6b9109 | 0×000b | 70 | 0×0159890a00 | 0×00 | 0×00
Before | "C" | 0×83 | 0×0701 | 0×6c9109 | 0×000b | 70 | 0×0159890a00 | 0×00 | 0×00
After | "D" | 0×83 | 0×0701 | 0×67960b | 0×000b | 70 | 0×0159890a00 | 0×00 | 0×00
After | "E" | 0×83 | 0×0701 | 0×6b960b | 0×000b | 70 | 0×0159890a00 | 0×00 | 0×00
After | "F" | 0×83 | 0×0701 | 0×6e960b | 0×000b | 70 | 0×0159890a00 | 0×00 | 0×00

##### Remote Functions

Created | Remote Name | Packet Type | Packet Subtype | Remote Id | Enigma | Client To Server Id | Call Count | User Information | Argument Count | Packet Delimiter |
|-|-|-|-|-|-|-|-|-|-|-|
Before | "A" | 0×83 | 0×0701 | 0×d9be07 | 0×000b | 0×7b | 0×02 | 0×01c5b60800 | 0×00 | 0×00
Before | "B" | 0×83 | 0×0701 | 0×dabe07 | 0×000b | 0×7b | 0×02 | 0×01c5b60800 | 0×00 | 0×00
Before | "C" | 0×83 | 0×0701 | 0×dbbe07 | 0×000b | 0×7b | 0×02 | 0×01c5b60800 | 0×00 | 0×00
After | "D" | 0×83 | 0×0701 | 0×6fc309 | 0×000b | 0×7b | 0×02 | 0×01c5b60800 | 0×00 | 0×00
After | "E" | 0×83 | 0×0701 | 0×73c309 | 0×000b | 0×7b | 0×02 | 0×01c5b60800 | 0×00 | 0×00
After | "F" | 0×83 | 0×0701 | 0×76c309 | 0×000b | 0×7b | 0×02 | 0×01c5b60800 | 0×00 | 0×00

### Nil

| Type 0×01 (byte) |
|-|

`(nil)`

| 1 |
|-|
| 0×01 |

### Booleans

| Type 0×09 (byte) | Value (byte) |
|-|-|

`(true)`

| 9 | true |
|-|-|
| 0×09 | 0×01 |

`(false)`

| 9 | false |
|-|-|
| 0×09 | 0×00 |

`(true, true)`

| 9 | true | 9 | true |
|-|-|-|-|
| 0×09 | 0×01 | 0×09| 0×01 |

### Numbers (Double, F64)

| Type 0×0c (byte) | Value (8 bytes) |
|-|-|

`(-5)`

| 12 | -5 |
|-|-|
| 0×0c | 0×c014000000000000 |

`(5)`

| 12 | 5 |
|-|-|
| 0×0c | 0×4014000000000000 |

`(0, 0)`

| 12 | 0 | 12 | 0 |
|-|-|-|-|
| 0×0c | 0×0000000000000000 | 0×0c | 0×0000000000000000 |

### Strings

| Type 0×02 (byte) | Length (VLQ) | Value (Length bytes) |
|-|-|-|

`("Hello World!")`

| 2 | 12 | 'H' | 'e' | 'l' | 'l' | 'o' | ' ' | 'W' | 'o' | 'r' | 'l' | 'd' | '!' |
|---|----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| 0×02 | 0×0c | 0×48 | 0×65 | 0×6c | 0×6c | 0×6f | 0×20 | 0×57 | 0×6f | 0×72 | 0×6c | 0×64 | 0×21 |

`("swous", "bibbity")`

| 2 | 5 | 's' | 'w' | 'o' | 'u' | 's' | 2 | 7 | 'b' | 'i' | 'b' | 'b' | 'i' | 't' | 'y' |
|---|---|-----|-----|-----|-----|-----|---|---|-----|-----|-----|-----|-----|-----|-----|
| 0×02 | 0×05 | 0×73 | 0×77 | 0×6f | 0×75 | 0×73 | 0×02 | 0×07 | 0×62 | 0×69 | 0×62 | 0×62 | 0×69 | 0×74 | 0×79 |

### Vector2int16s

| Type 0×18 (byte) | X (2 bytes) | Y (2 bytes) |
|-|-|-|

`(Vector2int16.new())`

| 24 | 0 | 0 |
|-|-|-|
| 0×18 | 0×0000 | 0×0000 |

`(Vector2int16.new(-5, 7))`

| 24 | -5 | 7 |
|-|-|-|
| 0×18 | 0xfffb | 0×0007 |

### Vector2s

| Type 0×15 (byte) | X (4 bytes) | Y (4 bytes) |
|-|-|-|

`(Vector2.zero)` or `(Vector2.new())`

| 21 | 0 | 0 |
|-|-|-|
| 0×15 | 0×00000000 | 0×00000000 |

`(Vector2.new(5, -1))`

| 21 | 5 | -1 |
|-|-|-|
| 0×15 | 0×40a00000 | 0×bf800000 |

### Vector3int16s

| Type 0×19 (byte) | X (2 bytes) | Y (2 bytes) | Z (2 bytes) |
|-|-|-|-|

`(Vector3int16.new())`

| 25 | 0 | 0 | 0 |
|-|-|-|-|
| 0×19 | 0×0000 | 0×0000 | 0×0000 |

`(Vector3int16.new(-5, 7, 9))`

| 25 | -5 | 7 | 9 |
|-|-|-|-|
| 0×19 | 0xfffb | 0×0007 | 0×0009 |

### Vector3s

| Type 0×16 (byte) | X (4 bytes) | Y (4 bytes) | Z (4 bytes) |
|-|-|-|-|

`(Vector3.zero)` or `(Vector3.new())`

| 22 | 0 | 0 | 0 |
|-|-|-|-|
| 0×16 | 0×00000000 | 0×00000000 | 0×00000000 |

`(Vector3.new(59.2, -1.101, 9.3))`

| 22 | 59.2 | -1.101 | 9.3 |
|-|-|-|-|
| 0×16 | 0x426ccccd | 0xbf8ced91 | 0x4114cccd

### CFrames

#### General Case

In the general case, CFrames have some arbitrary rotation that is not clean multiples of 90 degrees. This means that the rotation will not or cannot be enumerated, and therefore must be sent entirely. We do not understand the rotation format, but it is 6 bytes long, so forgive the elusive formatting we use. If you would like to help us figure out the rotation format, you may download the packet viewer, run the tests you need to, and make a pull request improving [Squash's documentation](https://github.com/Data-Oriented-House/Squash)!

| Type 0×1b (byte) | X (4 bytes) | Y (4 bytes) | Z (4 bytes) | Id 0×00 (byte) | Rotation (6 bytes) |
|-|-|-|-|-|-|

<!-- 1b 00 00 00 00 00 00 00 00 00 00 00 00 00 54 00 93 91 a6 cc -->

`(CFrame.fromEulerAnglesYXZ(5, -1, 9))`

| 27 | 0 | 0 | 0 | 0 | 5, -1, 9 |
|-|-|-|-|-|-|
| 0×1b | 0×00000000 | 0×00000000 | 0×00000000 | 0×00 | 0×54009391a6cc |

<!-- 1b bf 80 00 00 40 00 00 00 c0 75 58 10 00 6f 42 7b 6d aa 6a -->

`(CFrame.fromEulerAnglesYXZ(-1, 2, 3) + Vector3.new(-1, 2, -3))`

| 27 | -1 | 2 | -3 | 0 | -1, 2, 3 |
|-|-|-|-|-|-|
| 0×1b | 0×bf800000 | 0×40000000 | 0×c0400000 | 0×00 | 0×1c1d16b1de9e |

#### Special Case

In the special case, CFrames have rotations that are clean multiples of 90 degrees. This means that the rotation can be enumerated, and so only the enum is sent, and the rotation is reconstructed on the other side.

| Type 0×1b (byte) | X (4 bytes) | Y (4 bytes) | Z (4 bytes) | Id (byte) |
|-|-|-|-|-|

<!-- 1b 00 00 00 00 00 00 00 00 00 00 00 00 02 -->

`(CFrame.identity)` or `(CFrame.new())`

| 27 | 0 | 0 | 0 | 2 |
|-|-|-|-|-|
| 0×1b | 0×00000000 | 0×00000000 | 0×00000000 | 0×02 |

<!-- 1b 44 6a 80 00 00 00 00 00 c0 00 00 00 02 -->

`(CFrame.new(938, 0, -2))` or `(CFrame.identity + Vector3.new(938, 0, -2))`

| 27 | 938 | 0 | -2 | 2 |
|-|-|-|-|-|
| 0×1b | 0×446a80 | 0×00000000 | 0×c0000000 | 0×02 |

Below are all of the different axis-angle representation of the rotation matrices that map to each rotation id. We do not know why there are holes in the Ids but have verified through exhaustive testing that these are the only Ids.

| Id | Angle | X | Y | Z |
|-|-|-|-|-|
| 0×02 | 0 | 0 | 0 | 0 |
| 0×03 | π/2 | 1 | 0 | 0 |
| 0×05 | π | 1 | 0 | 0 |
| 0×06 | π/2 | -1 | 0 | 0 |
| 0×07 | π | 1/√2 | 1/√2 | 0 |
| 0×09 | 2π/3 | 1/√3 | 1/√3 | 1/√3 |
| 0×0a | π/2 | 0 | 0 | 1 |
| 0×0c | 2π/3 | -1/√3 | -1/√3 | 1/√3 |
| 0×0d | 2π/3 | -1/√3 | -1/√3 | -1/√3 |
| 0×0e | π/2 | 0 | -1 | 0 |
| 0×10 | 2π/3 | 1/√3 | -1/√3 | 1/√3 |
| 0×11 | π | 1/√2 | 0 | 1/√2 |
| 0×14 | π | 0 | 1 | 0 |
| 0×15 | π | 0 | 1/√2 | 1/√2 |
| 0×17 | π | 0 | 0 | 1 |
| 0×18 | π | 0 | -1/√2 | 1/√2 |
| 0×19 | π/2 | 0 | 0 | -1 |
| 0×1b | 2π/3 | 1/√3 | -1/√3 | -1/√3 |
| 0×1c | π | -1/√2 | 1/√2 | 0 |
| 0×1e | 2π/3 | -1/√3 | 1/√3 | -1/√3 |
| 0×1f | 2π/3 | 1/√3 | 1/√3 | -1/√3 |
| 0×20 | π/2 | 0 | 1 | 0 |
| 0×22 | 2π/3 | -1/√3 | 1/√3 | 1/√3 |
| 0×23 | π | -1/√2 | 0 | 1/√2 |


<!-- The above table is a key-value map of numbers to Angle-Axis rotations. Below is the rotation matrix representation of these values. -->

<!-- | Id | X | Y | Z | | Id | X | Y | Z | | Id | X | Y | Z | | Id | X | Y | Z |
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
|      | 1 | 0 | 0 | |      | 1 | 0 | 0 | |       | 1 | 0 | 0 | |      | 1 | 0 | 0 |
| 0×02 | 0 | 1 | 0 | | 0×03 | 0 | 0 | -1 | | 0×05 | 0 | 0 | 1 | | 0×06 | 0 | -1 | 0 |
|      | 0 | 0 | 1 | |      | 0 | 1 | 0 | |       | 0 | -1 | 0 | |     | 0 | 0 | -1 |
|
|      | -1 | 0 | 0 | |      | 0 | 0 | 1 | |       | 0 | 1 | 0 | |      | 0 | 0 | -1 |
| 0×07 | 0 | -1 | 0 | | 0×09 | 0 | -1 | 0 | | 0×0a | 1 | 0 | 0 | | 0×0c | -1 | 0 | 0 |
|      | 0 | 0 | -1 | |      | 0 | 0 | 1 | |       | 0 | 0 | 1 | |      | 0 | 0 | 1 |
|
|      | 0 | 0 | 1 | |      | 0 | 1 | 0 | |       | 0 | 0 | -1 | |     | 0 | -1 | 0 |
| 0×0d | 0 | 1 | 0 | | 0×0e | 0 | 0 | -1 | | 0×10 | 0 | 1 | 0 | | 0×11 | 0 | 0 | 1 |
|      | 1 | 0 | 0 | |      | 0 | 0 | 1 | |       | -1 | 0 | 0 | |     | 0 | 1 | 0 |
|
|      | 0 | 0 | 1 | |      | 0 | -1 | 0 | |      | 0 | 0 | 1 | |      | 0 | 1 | 0 |
| 0×14 | 0 | 1 | 0 | | 0×15 | 0 | 0 | 1 | | 0×17 | 0 | -1 | 0 | | 0×18 | 0 | 0 | -1 |
|      | -1 | 0 | 0 | |     | 0 | 0 | 1 | |       | 0 | 0 | -1 | |     | 1 | 0 | 0 |
|
|      | 0 | 0 | 1 | |      | 0 | -1 | 0 | |      | 0 | 0 | -1 | |     | 0 | -1 | 0 |
| 0×19 | 0 | 1 | 0 | | 0×1b | 0 | 0 | -1 | | 0×1c | 0 | 0 | 1 | | 0×1e | 0 | 1 | 0 |
|      | 1 | 0 | 0 | |      | 0 | 0 | 1 | |       | 0 | -1 | 0 | |     | 0 | 0 | -1 |
|
|      | 0 | 0 | 1 | |      | 0 | 0 | -1 | |      | 0 | -1 | 0 | |     | 0 | 0 | 1 |
| 0×1f | 0 | 1 | 0 | | 0×20 | 0 | 0 | 1 | | 0×22 | 0 | 0 | -1 | | 0×23 | 0 | -1 | 0 |
|      | -1 | 0 | 0 | |     | 0 | 1 | 0 | |       | 0 | 0 | 1 | |      | 1 | 0 | 0 | -->

### Tables

Tables are separated into two types: Arrays and Dictionaries. This is because internally they use different types. This allows them to optimize how they read each case, at the cost of less flexibility of what the table can contain. Arrays may only have numerical indices, and must be contiguous. If you send an array with a hole, it will stop reading at the first hole. Dictionaries may only have string indices, and don't have an internal order; holes don't exist in dictionaries. Using any other kind of key will result in an error.

#### Arrays

| Type 0×1e (byte) | Element Count (VLQ) | Element 1 | Element 2 | ... |
|-|-|-|-|-|

`({})`

| 30 | 0 |
|-|-|
| 0×1e | 0×00 |

`({true})`

| 30 | 1 | 9 | true |
|-|-|-|-|
| 0×1e | 0×01 | 0×09 | 0×01 |

`({[1] = true, [3] = false})`

The array is cut off at the first nil value.

| 30 | 1 | 9 | true |
|-|-|-|-|
| 0×1e | 0×01 | 0×09 | 0×01 |

`({"sofa is ", 8})`

| 30 | 2 | 2 | 8 | 's' | 'o' | 'f' | 'a' | ' ' | 'i' | 's' | ' ' | 12 | 8 |
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
| 0×1e | 0×02 | 0×02 | 0×08 | 0×73 | 0×6f | 0×66 | 0×61 | 0×20 | 0×69 | 0×73 | 0×20 | 0×0c | 0×4020000000000000 |

#### Dictionaries

| Type 0×1f (byte) | Pair Count (VLQ) | Key 1 | Value 1 | Key 2 | Value 2 | ... |
|-|-|-|-|-|-|-|

<!-- 1f 01 05 73 77 6f 72 64 09 01 -->

`({sword = true})`

| 31 | 1 | 5 | 's' | 'w' | 'o' | 'r' | 'd' | 9 | true |
|-|-|-|-|-|-|-|-|-|-|
| 0×1f | 0×01 | 0×05 | 0×73 | 0×77 | 0×6f | 0×72 | 0×64 | 0×09 | 0×01 |

<!-- 1f 02 07 73 74 61 6d 69 6e 61 02 04 68 69 67 68 06 68 65 61 6c 74 68 0c 40 54 86 66 66 66 66 66 -->

`({stamina = "high", ["health"] = 82.1})`

| 31 | 2 | 7 | 's' | 't' | 'a' | 'm' | 'i' | 'n' | 'a' | 2 | 4 | 'h' | 'e' | 'a' | 'l' | 't' | 'h' | 6 | 'h' | 'e' | 'a' | 'l' | 't' | 'h' | 12 | 82.1 |
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
| 0×1f | 0×02 | 0×07 | 0×73 | 0×74 | 0×61 | 0×6d | 0×69 | 0×6e | 0×61 | 0×02 | 0×04 | 0×68 | 0×65 | 0×61 | 0×6c | 0×74 | 0×68 | 0×06 | 0×68 | 0×65 | 0×61 | 0×6c | 0×74 | 0×68 | 0×0c | 0×4054866666666666 |