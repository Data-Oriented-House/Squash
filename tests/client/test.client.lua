local Stats = game:GetService('Stats')
local RunService = game:GetService("RunService")
local stop = game.ReplicatedStorage.Stop :: RemoteEvent
local start = game.ReplicatedStorage.Start :: RemoteEvent

local connection
local data = {}

local n = 100

start.OnClientEvent:Connect(function()
	-- Do some validation idk
	local i = 0
	connection = RunService.Heartbeat:Connect(function()
		if i >= n then
			connection:Disconnect()
			stop:FireServer(table.concat(data, ','))
			return
		end

		table.insert(data, Stats.DataReceiveKbps)
	end)
end)