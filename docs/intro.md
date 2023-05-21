---
sidebar_position: 1
---

# Introduction

<!-- ![Stew Logo](/SoupWhiteBlack.png) -->

Stew is a minimalistic data-oriented entity-component module. It is designed to be used in conjunction with the Roblox Studio game engine. It was designed to be smaller than competitors, efficient, non-restrictive, and easy to use.

## Some Notes
Stew is a very templated piece of software regarding data formats, allowing for things most others won't. This extends Stew's usefulness well beyond ECS, as can also easily implement things like Finite State Machines. The internals of Stew are volatile and expected to change, potentially rapidly.

### Style
Though Stew uses PascalCase, semicolon delimiters, and spaces between colons all around, please feel no pressure to use these conventions in your own code. It also experiments with using tables as namespaces, which does lead to nested tables with the benefit of less duplication and language supported organization. Funnily enough, the nested namespaces begin reading like plain english!

### No Dependencies; Self Contained
Stew commits to not depending on resources outside of its own ecosystem, this leads to interesting design consequences. In place of events where you may connect and listen for things to happen, Stew provides defineable callbacks that can execute arbitrary code at any of these stages. This allows any user to use their own event implementation such as Sleitnick's Signal or Roblox's BindableEvent. It even allows the freedom to debug the entirety of all stew operations, and potentially build tooling to beautifly view Stew internals at runtime.

### Respecting The User
Unlike many OSS projects today, Stew respects your intelligence, needs, and desires, trusting you with how you want to use it. It wants to be integratable into any pre-existing codebase. As a consequence of this, it provides a different set of tools compared to other ECS-like projects. The implementation is aimed to be as generic as possible, allowing you maximum flexibility over data representation, logic execution, implementation details, etc.

This is why private fields are prefixed with `_` rather than being kept local to the module; if you know what you are doing, you may have at the internals as you please.

An example of tooling differences is instead of offering a way to define systems in a scheduler that query certain components, Stew returns references to collections of entities with the specified components, allowing you to iterate or copy these collections as necessary. This is under the motivation that systems are user-defined logic that operate on intersections of entities, that may run on pre-existing scheduling systems, so Stew provides a way to get intersections of entities and nothing more.