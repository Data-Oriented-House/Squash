---
sidebar_position: 2
---

# Why Squash?

Squash has come into existence to solve a common problem many developers end up facing. Imagine you are making a custom character controller and need to send updates to the server multiple times a second. If you don't play your cards right, you could end up sending an intolerable amount of data over the network *per player*. This is bad because it takes a lot of bandwidth to send and receive data over the network. Now imagine making a save / load system, depending on the amount of information you need to save and load, you can end up making the player wait a long time to save and load their data. This is bad because it reduces player retention rates, and lowers the overall quality of the player experience.

## Why Inconsistent Naming Convention?

Squash lowercases some of its type names, and PascalCases others. Why? Because it was designed to work with the `typeof` function. For every supported type, you can safely do `Squash[typeof(variable)].ser(variable)` and `Squash[typeof(variable)].des(variable)`. This enables automation of serialization and deserialization, which is useful for automating saving and loading data.