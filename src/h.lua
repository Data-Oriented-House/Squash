-- local PseudoDataStores = {}

-- local DataStore = {}

-- function DataStore.Set(name: string, key: string, value: any)
-- 	local dataStore = PseudoDataStores[name]
-- 	if not dataStore then
-- 		dataStore = {}
-- 		PseudoDataStores[name] = dataStore
-- 	end

-- 	dataStore[key] = value
-- end

-- function DataStore.Get(name: string, key: string): any?
-- 	local dataStore = PseudoDataStores[name]
-- 	if not dataStore then
-- 		return nil
-- 	end

-- 	return dataStore[key]
-- end

-- ------------------- Test1

-- DataStore.Set("Name", "Key", "Hello world!")

-- ------------------- Test2

-- local Players = game:GetService("Players")

-- Players.PlayerAdded:Connect(function(player)

-- end)

-- Players.PlayerRemoving:Connect(function(player)
--     local dataStore = DataStore.Get("Player", player.UserId)
-- 	print(dataStore)
-- end)