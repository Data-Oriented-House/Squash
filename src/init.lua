--!strict

local CharEmpty = ''
local CharZero = '0'
local AsciiOne = string.byte('1')

local function StringBAnd(String1 : string, String2 : string) : string
	local Length = math.max(#String1, #String2)
	local String3 = table.create(Length, 0)

	for i in String3 do
		String3[i] = (string.byte(String1, i) == AsciiOne and string.byte(String2, i) == AsciiOne) and 1 or 0
	end

	for i = Length, 1, -1 do
		if String3[i] ~= 0 then break end
		String3[i] = nil
	end

	return #String3 == 0 and CharZero or table.concat(String3, CharEmpty)
end

local function StringBOr(String1 : string, String2 : string) : string
	local Length = math.max(#String1, #String2)
	local String3 = table.create(Length, 0)

	for i in String3 do
		String3[i] = (string.byte(String1, i) == AsciiOne or string.byte(String2, i) == AsciiOne) and 1 or 0
	end

	for i = Length, 1, -1 do
		if String3[i] ~= 0 then break end
		String3[i] = nil
	end

	return #String3 == 0 and CharZero or table.concat(String3, CharEmpty)
end

local function StringBXOr(String1 : string, String2 : string) : string
	local Length = math.max(#String1, #String2)
	local String3 = table.create(Length, 0)

	for i in String3 do
		String3[i] = string.byte(String1, i) == string.byte(String2, i) and 0 or 1
	end

	for i = #String3, 1, -1 do
		if String3[i] ~= 0 then break end
		String3[i] = nil
	end

	return #String3 == 0 and CharZero or table.concat(String3, CharEmpty)
end

local function StringPlace(Place : number) : string
	local String = table.create(Place, 0)

	String[Place] = 1

	return #String == 0 and CharZero or table.concat(String, CharEmpty)
end

--[=[
	@class Stew

	Stew is the package itself. Here you can mess with worlds and types.
]=]
local Stew = {}

--[=[
	@within Stew
	@private
	@type Signature string

	Signatures are used to represent bitsets of components.
]=]
export type Signature = string

--[=[
	@within Stew
	@type Name any

	A name is a unique identifier used as a key to access components of entities.
]=]
export type Name = any

--[=[
	@within Stew
	@type Component any

	A component is user-defined data that is accessed by an entity. It is defined through the Component.Build function. It is created through the Component.Create function.
]=]
export type Component = any

--[=[
	@within Stew
	@type Entity<E> E

	An entity is a unique identifier used to access components by their names. It is created through the Entity.Create function. The entity's components can be accessed by Component.Get or Component.GetAll.
]=]
export type Entity<E> = E

--[=[
	@within Stew
	@interface Collection
	.[Entity] true

	A set of entities containing specific components.
]=]
export type Collection = {
	[Entity<any>] : true;
}

--[=[
	@within Stew
	@private
	@interface EntityData
	.Signature Signature
	.Components { [Name]: Component }

	Information about an entity's components.
]=]
export type EntityData = {
	Signature  : Signature;
	Components : { [Name] : Component };
}

--[=[
	@within Stew
	@interface ComponentArgs<E, N, C, D>
	.Constructor <T...>(Entity: Entity<E>, Name: N, T...) -> C
	.Destructor <T...>(Entity: Entity<E>, Name: N, T...) -> D

	Optional arguments to build a component with the Component.Build function.
]=]
export type ComponentArgs<E, N, C, D> = {
	Constructor : (<T...>(Entity : Entity<E>, Name : N, T...) -> C)?;
	Destructor  : (<T...>(Entity : Entity<E>, Name : N, T...) -> D)?;
}

--[=[
	@within Stew
	@private
	@interface ComponentData<E, N, C, D>
	.Constructor <T...>(Entity: Entity<E>, Name: N, T...) -> C
	.Destructor <T...>(Entity: Entity<E>, Name: N, T...) -> D
	.Signature Signature

	Information about a component.
]=]
export type ComponentData<E, N, C, D> = {
	Constructor : <T...>(Entity : Entity<E>, Name : N, T...) -> C;
	Destructor  : <T...>(Entity : Entity<E>, Name : N, T...) -> D;
	Signature   : Signature;
}

--[=[
	@within Stew
	@interface WorldArgs
	.Component?.Build ((Name: Name, ComponentData: ComponentData) -> ())?
	.Component?.Create ((Entity: Entity, Name: Name, Component: Component) -> ())?
	.Component?.Delete ((Entity: Entity, Name: Name, Deleted: any) -> ())?
	.Entity?.Create ((Entity: Entity) -> ())?
	.Entity?.Delete ((Entity: Entity) -> ())?

	Optional arguments to build a component with the Component.Build function. Everything is optional, including the On table.
]=]
export type WorldArgs = {
	Component : {
		Build  : (<E, N, C, D>(Name : N, ComponentData : ComponentData<E, N, C, D>) -> ())?;
		Create : (<E, N, C>(Entity : Entity<E>, Name : N, Component: C) -> ())?;
		Delete : (<E, N, D>(Entity : Entity<E>, Name : N, Deleted: D) -> ())?;
	}?;

	Entity : {
		Create : (<E>(Entity: Entity<E>) -> ())?;
		Delete : (<E>(Entity: Entity<E>) -> ())?;
	}?;
}

--[=[
	@within Stew
	@interface World
	.Collection.Get (Names: { Name }) -> Collection
	.Collection.GetFirst (Names: { Name }) -> Entity<any>
	.Component.Build (Name: Name, ComponentArgs: ComponentArgs?) -> ()
	.Component.Create (Entity: Entity, Name: Name, ...any) -> Component?
	.Component.Delete (Entity: Entity, Name: Name, ...any) -> any?
	.Component.GetAll (Entity: Entity) -> { [Name]: Component }
	.Component.Get (Entity: Entity, Name: Name) -> Component?
	.Entity.Create () -> Entity
	.Entity.Delete (Entity: Entity) -> ()
	.Entity.Register (Entity: Entity) -> ()

	._NextPlace number
	._NameToData { [Name]: ComponentData }
	._EntityToData { [Entity]: EntityData }
	._SignatureToCollection { [Signature]: Collection }
	._Component.Build (Name : Name, ComponentData : ComponentData) -> ()
	._Component.Create (Entity: Entity, Name: Name, Component: Component) -> ()
	._Component.Delete (Entity: Entity, Name: Name, Deleted: any) -> ()
	._Entity.Create (Entity: Entity) -> ()
	._Entity.Delete (Entity: Entity) -> ()
]=]
type WorldCollection = {
	Get      : (Names : { Name }) -> Collection;
	GetFirst : (Names : { Name }) -> Entity<any>;
}

type WorldComponent = {
	Build  : <E, N, C, D>(Name : N, ComponentArgs : ComponentArgs<E, N, C, D>?) -> ();
	Create : <E, N, C, T...>(Entity : Entity<E>, Name : N, T...) -> C?;
	Delete : <E, N, D, T...>(Entity : Entity<E>, Name : N, T...) -> D?;
	GetAll : <E>(Entity : Entity<E>) -> { [Name] : Component };
	Get    : <E, N, C>(Entity : Entity<E>, Name : N) -> C?;
}

type WorldEntity = {
	Create   : () -> Entity<any>;
	Delete   : <E>(Entity : Entity<E>) -> ();
	Register : <E>(Entity : Entity<E>) -> ();
}

export type World = {
	_NextPlace : number;

	_NameToData            : { [Name] : ComponentData<any, Name, Component, any> };
	_EntityToData          : { [Entity<any>] : EntityData };
	_SignatureToCollection : { [Signature] : Collection };

	_Component : {
		Build  : <E, N, C, D>(Name : N, ComponentData : ComponentData<E, N, C, D>) -> ();
		Create : <E, N, C>(Entity : Entity<any>, Name : N, Component: C) -> ();
		Delete : <E, N, D>(Entity : Entity<E>, Name : N, Deleted: D) -> ();
	};

	_Entity : {
		Create : <E>(Entity: Entity<E>) -> ();
		Delete : <E>(Entity: Entity<E>) -> ();
	};

	Collection : WorldCollection;
	Component : WorldComponent;
	Entity : WorldEntity;
}

local function GetCollection(World: World, Signature : Signature) : Collection
	local FoundCollection = World._SignatureToCollection[Signature]
	if FoundCollection then return FoundCollection end

	local Collection = {} :: Collection
	World._SignatureToCollection[Signature] = Collection

	local UniversalCollection = World._SignatureToCollection[CharZero]
	for Entity in UniversalCollection do
		local EntityData = World._EntityToData[Entity]
		if StringBAnd(Signature, EntityData.Signature) == Signature then
			Collection[Entity] = true
		end
	end

	return Collection
end

local function DefaultConstructor() : true
	return true
end

local function DefaultDestructor()
end

local function DefaultOn()
end

local DefaultEntityData = {
	Components = {};
}

--[=[
	@class World

	Has methods for dealing with worlds.
]=]
Stew.World = {}

--[=[
	@within World
	@function Create
	@param WorldArgs WorldArgs?
	@return World

	Creates a new world, and for convenience creates all methods that pass a world as the first argument in it, too
]=]
function Stew.World.Create(WorldArgs: WorldArgs?) : World
	local WorldComponent = if WorldArgs then WorldArgs.Component else nil
	local WorldEntity = if WorldArgs then WorldArgs.Entity else nil

	local World = {
		_NextPlace = 1;
		_NameToData = {};
		_EntityToData = {};

		_SignatureToCollection = {
			[CharZero] = {};
		};

		_Component = {
			Build  = if WorldComponent then WorldComponent.Build  else DefaultOn;
			Create = if WorldComponent then WorldComponent.Create else DefaultOn;
			Delete = if WorldComponent then WorldComponent.Delete else DefaultOn;
		};

		_Entity = {
			Create = if WorldEntity then WorldEntity.Create else DefaultOn;
			Delete = if WorldEntity then WorldEntity.Delete else DefaultOn;
		};
	} :: World

	--[=[
		@class Collection
		Contains methods for dealing with collections.
	]=]
	World.Collection = {} :: WorldCollection

	--[=[
		@within Collection
		@function Get
		@tag Read Only
		@error Component Not Built -- A component with the given name is not built.

		@param Names {Name} -- An array of component names.
		@return Collection -- Returns a collection of all entities that have all the components specified.

		Used to get all entities with certain components. This is useful for implementing systems.
		It is a reference rather than a copy, so it is read-only and automatically updates when entities are created or deleted.

		```lua
		local World = Stew.World.Create()

		World.Component.Build("Starving")

		World.Component.Build("Health", {
			Constructor = function(Entity : Stew.Entity<any>, Name : string)
				return {
					Current = 100;
					Max = 100;
				}
			end;
		})

		local Hurting : Stew.Collection = World.Collection.Get{"Health", "Starving"}

		RunService.Heartbeat:Connect(function(DeltaTime : number)
			for Entity in Hurting do
				local Health = Stew.Component.Get(Entity, "Health")
				Health.Current -= DeltaTime
			end
		end)
		```
	]=]
	function World.Collection.Get(Names : { Name }) : Collection
		local Signature = CharZero

		for _, Name in Names do
			local Data = World._NameToData[Name]
			assert(Data, "Attempting to get collection of non-existant " .. tostring(Name) .. " component")

			Signature = StringBOr(Signature, Data.Signature)
		end

		return GetCollection(World, Signature)
	end

	--[=[
		@within Collection
		@function GetFirst
		@error Component Not Built -- A component with the given name is not built.

		@param Names {Name} -- An array of component names.
		@return Entity? -- Returns the first entity found in a collection.

		This is useful for systems involving components that only exist in isolation. Order is not guaranteed because this is a set.

		```lua
		local World = Stew.World.Create()

		World.Component.Build("Selected", {
			Constructor = function(Entity : any, Name : string)
				return {
					Position = Vector3.new();
					Rotation = 0;
				}
			end;
		})

		local Part : Part = Instance.new("Part")
		World.Component.Create(Part, "Selected")
		```
		```lua
		local World = require(Path.To.World)

		local Part : Part = World.Collection.GetFirst{"Selected"}
		print(Part)
		```
	]=]
	function World.Collection.GetFirst(Names : { Name }) : Entity<any>?
		return next(World.Collection.Get(Names))
	end

	--[=[
		@class Component

		Contains methods for dealing with components.
	]=]
	World.Component = {} :: WorldComponent

	--[=[
		@within Component
		@function Build
		@error Component Built Twice -- A component with the given name has already been built.

		@param Name Name -- The name of the component.
		@param ComponentArgs ComponentArgs? -- The arguments to build the component

		Sets up an internal constructor and destructor for a component. This is used to create and destroy components. If arguments are not provided, an empty table will be used instead.

		Both the constructor and destructor are optional and can be omitted. If no constructor is specified, a default constructor that returns true is used. If no destructor is specified, a default destructor that does nothing is used.

		```lua
		local World = Stew.World.Create()

		World.Component.Build("Poisoned")

		World.Component.Build("Health", {
			Constructor = function(Entity : any, Name : string, Max : number)
				return {
					Current = Max;
					Max = Max;
				}
			end;
		})

		World.Component.Build("Model", {
			Constructor = function(Entity : any, Name : string, Model : Model, NewName : string)
				local NewModel = Model:Clone()
				NewModel.Name = NewName
				return NewModel
			end;

			Destructor = function(Entity : any, Name : string)
				Stew.Component.Get(Entity, Name) :Destroy()
			end;
		})
		```
	]=]
	-- Builds a component, this must be called before any components of this type can be created
	function World.Component.Build<E, N, C, D>(Name : N, ComponentArgs : ComponentArgs<E, N, C, D>?)
		assert(not World._NameToData[Name], "Attempting to build component " .. tostring(Name) .. " twice")

		local ComponentArgs = (ComponentArgs or {}) :: ComponentArgs<E, N, C, D>

		local ComponentData = {
			Signature = StringPlace(World._NextPlace);
			Constructor = ComponentArgs.Constructor or DefaultConstructor;
			Destructor = ComponentArgs.Destructor or DefaultDestructor;
		} :: ComponentData<E, N, C, D>

		World._NameToData[Name] = ComponentData
		World._NextPlace += 1

		World._Component.Build(Name, ComponentData)
	end

	--[=[
		@within Component
		@function Create
		@error Component Not Built -- A component with the given name is not built.

		@param Entity Entity -- The entity that accesses this component.
		@param Name Name -- The name of the component to be created.
		@param ... any -- Any additional arguments.
		@return Component? -- The component that was created.

		Creates a unique component associated with the entity and returns it. Automatically registers the entity if it hasn't been registered yet.

		If the constructor returns void or nil, the component will not be created.

		```lua
		local World = Stew.World.Create()

		World.Component.Build("Model", {
			Constructor = function(Entity : any, Name : string, Model : Model, Allow : boolean)
				if not Allow then return end
				return Model:Clone()
			end;
		})

		local LocalPlayer : Player = Players.LocalPlayer
		print(World.Component.Get(LocalPlayer, "Model")) --> nil

		World.Component.Create(LocalPlayer, "Model", workspace.CoolModel, false)
		print(World.Component.Get(LocalPlayer, "Model")) --> nil

		World.Component.Create(LocalPlayer, "Model", workspace.CoolModel, true)
		print(World.Component.Get(LocalPlayer, "Model")) --> CoolModel
		```
	]=]
	function World.Component.Create<E, N, C, T...>(Entity : Entity<E>, Name : N, ...: T...) : C?
		local ComponentData = World._NameToData[Name]
		assert(ComponentData, "Attempting to create instance of non-existant " .. tostring(Name) .. " component")

		local EntityData = World._EntityToData[Entity]
		if not EntityData then
			World.Entity.Register(Entity)
			EntityData = World._EntityToData[Entity]
		end

		if EntityData.Components[Name] then return nil end
		local Component = ComponentData.Constructor(Entity, Name, ...)
		if Component == nil then return Component end

		EntityData.Components[Name] = Component

		local Signature = StringBOr(EntityData.Signature, ComponentData.Signature)
		EntityData.Signature = Signature

		for CollectionSignature, Collection in World._SignatureToCollection do
			if Collection[Entity] or StringBAnd(CollectionSignature, Signature) ~= CollectionSignature then continue end
			Collection[Entity] = true
		end

		World._Component.Create(Entity, Name, Component)

		return Component
	end

	--[=[
		@within Component
		@function Delete
		@error Component Not Built -- A component with the given name is not built.

		@param Entity Entity -- The entity to delete the component from.
		@param Name Name -- The name of the component to be deleted.
		@param ... ...any -- Any additional arguments.

		Deletes the component associated with the passed entity.

		If the destructor returns a truthy value, the component will not be deleted.

		```lua
		local World = Stew.World.Create()

		World.Component.Build("Model", {
			Constructor = function(Entity : any, Name : string, Model : Model)
				return Model:Clone()
			end;

			Destructor = function(Entity : any, Name : string, Allow : boolean)
				if not Allow then return true end
				Stew.Component.Get(Entity, Name) :Destroy()
			end;
		})

		local Part : Part = Instance.new("Part")

		World.Component.Create(Part, "Model", workspace.CoolModel)
		print(Stew.Component.Get(Part, "Model")) --> CoolModel

		Stew.Component.Delete(Part, "Model", false)
		print(Stew.Component.Get(Part, "Model")) --> CoolModel

		Stew.Component.Delete(Part, "Model", true)
		print(Stew.Component.Get(Part, "Model")) --> nil
		```
	]=]
	-- Deletes and disassociates a component from the entity, returns whatever the destructor returns
	function World.Component.Delete<E, N, D, T...>(Entity : Entity<E>, Name : N, ... : T...) : D?
		local ComponentData = World._NameToData[Name]
		assert(ComponentData, "Attempting to delete instance of non-existant " .. tostring(Name) .. " component")

		local EntityData = World._EntityToData[Entity]
		if not EntityData then return end
		if not EntityData.Components[Name] then return end

		local Deleted = ComponentData.Destructor(Entity, Name, ...)
		if Deleted ~= nil then return Deleted end

		EntityData.Components[Name] = nil
		EntityData.Signature = StringBXOr(EntityData.Signature, ComponentData.Signature)

		for CollectionSignature, Collection in World._SignatureToCollection do
			if not Collection[Entity] or StringBAnd(ComponentData.Signature, CollectionSignature) ~= ComponentData.Signature then continue end
			Collection[Entity] = nil
		end

		World._Component.Delete(Entity, Name, EntityData.Components[Name])

		return nil
	end

	--[=[
		@within Component
		@function Get

		@param Entity Entity
		@param Name Name
		@return Component?

		Gets a component from an entity.

		```lua
		local World = Stew.World.Create()

		World.Component.Build("Grid", {
			Constructor = function(Entity : any, Name : string, Properties: { Dimensions : Vector2; Default : number; })
				return {
					Cells = table.create(Properties.Dimensions.X * Properties.Dimensions.Y, Properties.Default);
				}
			end;
		})

		local GridId = 1

		local Grid1 = Stew.Component.Get(GridId, "Grid")
		print(Grid1) --> nil

		World.Component.Create(GridId, "Grid", Vector2.new(10, 10))

		local Grid2 = Stew.Component.Get(GridId, "Grid")
		print(Grid2) --> CoolModel
		```
	]=]
	function World.Component.Get<E, N, C>(Entity : Entity<E>, Name : N) : C?
		return ((World._EntityToData[Entity] or DefaultEntityData) :: typeof(DefaultEntityData)).Components[Name]
	end

	--[=[
		@within Component
		@function GetAll

		@param Entity Entity
		@return { [Name] : Component }

		Returns a table of all an entity's components in the form of a dictionary. This dictionary is cloned to prevent tampering.

		```lua
		local World = Stew.World.Create()

		World.Component.Build("Red")
		World.Component.Build("Green")
		World.Component.Build("Blue", {
			Constructor = function(Entity : any, Name : string, Value : number)
				return Value
			end;
		})

		local Entity = World.Entity.Create()

		World.Component.Create(Entity, "Red")
		World.Component.Create(Entity, "Green")
		World.Component.Create(Entity, "Blue", 5)

		for Name: string, Component: any in Stew.Component.GetAll(Entity) do
			print(Name, Component) --[[
				Red true
				Green true
				Blue 5
			]]
		end
		```
	]=]
	function World.Component.GetAll<E>(Entity : Entity<E>) : { [Name] : Component }
		return (World._EntityToData[Entity] or DefaultEntityData).Components
	end

	--[=[
		@class Entity

		Contains methods for dealing with entities.
	]=]
	World.Entity = {} :: WorldEntity

	--[=[
		@within Entity
		@function Register
		@error Entity Registered Twice -- An entity cannot be registered twice without first being deleted.

		@param Entity any

		Register an entity with the world. This is done automatically when creating a component.

		```lua
		local World = Stew.World.Create()

		-- They all work! :D
		World.Entity.Register(5)
		World.Entity.Register("Hi")
		World.Entity.Register({ Cool = true })
		World.Entity.Register(newproxy())
		World.Entity.Register(Instance.new("Part"))
		-- No entity left behind!
		```
	]=]
	function World.Entity.Register<E>(Entity: Entity<E>)
		assert(not World._EntityToData[Entity], "Attempting to register entity twice")

		World._EntityToData[Entity] = {
			Signature = CharZero;
			Components = {};
		}

		GetCollection(World, CharZero)[Entity] = true

		World._Entity.Create(Entity)
	end

	--[=[
		@within Entity
		@function Create
		@return Entity

		Creates, registers, and returns an entity. Uses `newproxy` internally, so these entities cannot be sent over the network.

		```lua
		local World = Stew.World.Create()

		local Entity1 : any = World.Entity.Create()
		print(Entity1) --> userdata
		```
	]=]
	function World.Entity.Create() : Entity<any>
		local Entity = newproxy() :: Entity<any>
		World.Entity.Register(Entity)
		return Entity
	end

	--[=[
		@within Entity
		@function Delete

		@param Entity Entity

		Deletes all components associated with an entity and removes it from all internal storage.

		The entity must be registered again to be used, though this is done automatically when creating components.

		```lua
		local World = Stew.World.Create()

		local States = {
			Happy = 1;
			Sad = 2;
		}

		World.Component.Build(States.Happy)
		World.Component.Build(States.Sad)

		local Entity : any = Stew.Entity.Create()
		World.Component.Create(Entity, States.Happy)
		World.Component.Create(Entity, States.Sad)
		print(Stew.Component.GetAll(Entity)) --> { [1] = true, [2] = true }

		Stew.Entity.Delete(Entity)
		print(Stew.Component.GetAll(Entity)) --> {}
		```
	]=]
	function World.Entity.Delete<E>(Entity : Entity<E>)
		local EntityData = World._EntityToData[Entity]
		if not EntityData then return end

		for Name in EntityData.Components do
			World.Component.Delete(Entity, Name)
		end

		GetCollection(World, CharZero)[Entity] = nil
		World._EntityToData[Entity] = nil

		World._Entity.Delete(Entity)
	end

	return World
end

return Stew