---
sidebar_position: 2
---

# Why Squash?

Squash has come into existence to solve a common problem many developers end up facing. Imagine you are making a custom character controller and need to send updates to the server multiple times a second. If you don't play your cards right, you could end up sending an intolerable amount of data over the network *per player*. This is bad because it takes a lot of bandwidth to send and receive data over the network. Now imagine making a save / load system, depending on the amount of information you need to save and load, you can end up making the player wait a long time to save and load their data. This is bad because it reduces player retention rates, and lowers the overall quality of the player experience.

## Pragmatic Naming

Squash has carefully designed its naming scheme to practically support automating serialization. This is achieved by supporting `Squash[typeof(x)]().ser(y)`. Aside from the few compound types that require extra information, such as vectors, this pattern can be used to quickly read data and serialize it.