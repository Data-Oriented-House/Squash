---
sidebar_position: 3
---

# Common Patterns

As Stew's usage grows, patterns to achieve common tasks make themselves apparent and will find themselves here. These are by no means strict guidelines on how to use Stew.

## Deferred Execution

Sometimes you may find yourself needing to execute code *after* the constructor or other callback fires. To do this, and to not do more than you have to, you can use `task.defer` to execute code the frame after it was called.

```lua
local World = Stew.World.Create()

World.Component.Build("MyComponent", {
	Constructor = function(Entity, Name)
		print("Before")

		task.defer(function()
			print("After")
		end)

		return true
	end;
})
```

## Modularity + Event Decoupling

More often than not you will want to separate code execution from where it is being called, so you do not couple unrelated or modular code. Stew provides component-level and world-level ways to achieve this, both along the same lines and very simple. Since arbitrary code can be executed whenever a component is constructed, events of your choice can be fired.

This also ties well into using Module Scripts when defining Worlds or Components, since you can easily define extra data alongside everything else and encourage more flexible data accessing. It pairs well with the idea of registries, modules of purely constant data.

This particular example uses Sleitnick's Signal implementation.
```lua
local Module = {}

Module.Signals = {
	Built = Signal.new();
	Created = Signal.new();
}

Module.World = Stew.World.Create {
	Component = {
		Build = function(Name, ComponentData)
			Module.Signals.Built:Fire(Name, ComponentData.Signature)
		end;

		Create = function(Entity, Name, Component)
			Module.Signal.Created:Fire(Entity, Name, Component)
		end;
	};
}

return Module
```
```lua
local World = require(Path.To.Module).World

local Module = {}

Module.Signals = {
	Created = Signal.new();
	Deleted = Signal.new();
}

World.Component.Build("MyComponent", {
	Constructor = function(Entity : Player, Name : string, Arg1 : number, Arg2 : number) : number
		local Component = Arg1 + Arg2

		task.defer(function()
			Module.Signals.Created:Fire(Entity, Name, Component)
		end)

		return Component
	end;

	Destructor = function(Entity : Player, Name : string)
		Module.Signals.Deleted:Fire(Entity, Name)
	end;
})

return Module
```