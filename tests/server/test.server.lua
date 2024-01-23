local RunService = game:GetService("RunService")
local fire = game.ReplicatedStorage.Fire :: RemoteEvent
local stop = game.ReplicatedStorage.Stop :: RemoteEvent
local start = game.ReplicatedStorage.Start :: RemoteEvent

local inputs = {
	baseline = {
		['()'] = {},
		['({})'] = {{}},
	},

	nils = {
		['(nil)'] = {nil},
		['(nil, nil)'] = {nil, nil},
		['(nil, nil, nil)'] = {nil, nil, nil},
		['(nil, nil, nil, nil)'] = {nil, nil, nil, nil},
		['(nil, nil, nil, nil, nil)'] = {nil, nil, nil, nil, nil},
		['(nil, nil, nil, nil, nil, nil)'] = {nil, nil, nil, nil, nil, nil},
		['(nil, nil, nil, nil, nil, nil, nil)'] = {nil, nil, nil, nil, nil, nil, nil},
		['(nil, nil, nil, nil, nil, nil, nil, nil)'] = {nil, nil, nil, nil, nil, nil, nil, nil},

		['({nil})'] = {{nil}},
		['({nil, nil})'] = {{nil, nil}},
		['({nil, nil, nil})'] = {{nil, nil, nil}},
		['({nil, nil, nil, nil})'] = {{nil, nil, nil, nil}},
		['({nil, nil, nil, nil, nil})'] = {{nil, nil, nil, nil, nil}},
		['({nil, nil, nil, nil, nil, nil})'] = {{nil, nil, nil, nil, nil, nil}},
		['({nil, nil, nil, nil, nil, nil, nil})'] = {{nil, nil, nil, nil, nil, nil, nil}},
		['({nil, nil, nil, nil, nil, nil, nil, nil})'] = {{nil, nil, nil, nil, nil, nil, nil, nil}},
	},

	numbers = {
		['(0)'] = {0},
		['(18375)'] = {18375},
		['(-18375)'] = {-18375},
		['(0, 0)'] = {0, 0},
		['(0, 0, 0)'] = {0, 0, 0},
		['(0, 0, 0, 0)'] = {0, 0, 0, 0},
		['(0, 0, 0, 0, 0)'] = {0, 0, 0, 0, 0},
		['(0, 0, 0, 0, 0, 0)'] = {0, 0, 0, 0, 0, 0},
		['(0, 0, 0, 0, 0, 0, 0)'] = {0, 0, 0, 0, 0, 0, 0},
		['(0, 0, 0, 0, 0, 0, 0, 0)'] = {0, 0, 0, 0, 0, 0, 0, 0},
		['(0, 0, 0, 0, 0, 0, 0, 0, 0)'] = {0, 0, 0, 0, 0, 0, 0, 0, 0},

		['({0})'] = {{0}},
		['({0, 0})'] = {{0, 0}},
		['({0, 0, 0})'] = {{0, 0, 0}},
		['({0, 0, 0, 0})'] = {{0, 0, 0, 0}},
		['({0, 0, 0, 0, 0})'] = {{0, 0, 0, 0, 0}},
		['({0, 0, 0, 0, 0, 0})'] = {{0, 0, 0, 0, 0, 0}},
		['({0, 0, 0, 0, 0, 0, 0})'] = {{0, 0, 0, 0, 0, 0, 0}},
		['({0, 0, 0, 0, 0, 0, 0, 0})'] = {{0, 0, 0, 0, 0, 0, 0, 0}},
		['({0, 0, 0, 0, 0, 0, 0, 0, 0})'] = {{0, 0, 0, 0, 0, 0, 0, 0, 0}},
	},

	booleans = {
		['(true)'] = {true},
		['(false)'] = {false},
		['(true, false)'] = {true, false},
		['(true, false, true)'] = {true, false, true},
		['(true, false, true, false)'] = {true, false, true, false},
		['(true, false, true, false, true)'] = {true, false, true, false, true},
		['(true, false, true, false, true, false)'] = {true, false, true, false, true, false},
		['(true, false, true, false, true, false, true)'] = {true, false, true, false, true, false, true},
		['(true, false, true, false, true, false, true, false)'] = {true, false, true, false, true, false, true, false},

		['({true})'] = {{true}},
		['({true, false})'] = {{true, false}},
		['({true, false, true})'] = {{true, false, true}},
		['({true, false, true, false})'] = {{true, false, true, false}},
		['({true, false, true, false, true})'] = {{true, false, true, false, true}},
		['({true, false, true, false, true, false})'] = {{true, false, true, false, true, false}},
		['({true, false, true, false, true, false, true})'] = {{true, false, true, false, true, false, true}},
		['({true, false, true, false, true, false, true, false})'] = {{true, false, true, false, true, false, true, false}},
	},

	emptystrings = {
		["('')"] = {''},
		["('', '')"] = {'', ''},
		["('', '', '')"] = {'', '', ''},
		["('', '', '', '')"] = {'', '', '', ''},
		["('', '', '', '', '')"] = {'', '', '', '', ''},
		["('', '', '', '', '', '')"] = {'', '', '', '', '', ''},
		["('', '', '', '', '', '', '')"] = {'', '', '', '', '', '', ''},
		["('', '', '', '', '', '', '', '')"] = {'', '', '', '', '', '', '', ''},
		["('', '', '', '', '', '', '', '', '')"] = {'', '', '', '', '', '', '', '', ''},

		["({''})"] = {{''}},
		["({'', ''})"] = {{'', ''}},
		["({'', '', ''})"] = {{'', '', ''}},
		["({'', '', '', ''})"] = {{'', '', '', ''}},
		["({'', '', '', '', ''})"] = {{'', '', '', '', ''}},
		["({'', '', '', '', '', ''})"] = {{'', '', '', '', '', ''}},
		["({'', '', '', '', '', '', ''})"] = {{'', '', '', '', '', '', ''}},
		["({'', '', '', '', '', '', '', ''})"] = {{'', '', '', '', '', '', '', ''}},
		["({'', '', '', '', '', '', '', '', ''})"] = {{'', '', '', '', '', '', '', '', ''}},
	},

	singlestrings = {
		["(string.char(255))"] = {string.char(255)},
		["('A')"] = {"A"},
		["('0')"] = {"0"},
		["('\0')"] = {"\0"},
		["('a')"] = {"a"}, -- I"ll grab my mouse
		["('aa')"] = {"aa"},
		["('aaa')"] = {"aaa"},
		["('aaaa')"] = {"aaaa"},  -- Maximum Size of a Vector2int16
		["('aaaaa')"] = {"aaaaa"},
		["('aaaaaa')"] = {"aaaaaa"}, -- Maximum Size of a Vector3int16
		["('aaaaaaa')"] = {"aaaaaaa"},
		["('aaaaaaaa')"] = {"aaaaaaaa"}, -- Maximum Size of a Number
		["('aaaaaaaaa')"] = {"aaaaaaaaa"},
		["('aaaaaaaaaa')"] = {"aaaaaaaaaa"},
		["('aaaaaaaaaaa')"] = {"aaaaaaaaaaa"},
		["('aaaaaaaaaaaa')"] = {"aaaaaaaaaaaa"},
		["('aaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaa"}, -- Maximum Size of a Vector2
		["('aaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaa"}, -- Maximum Size of a Vector3
		["('aaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
		["('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"] = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}, -- Maximum Size of a CFrame
	},

	manystrings = {
		["(\0, \0)"] = {"\0", "\0"},
		["(\0, \0, \0)"] = {"\0", "\0", "\0"},
		["(\0, \0, \0, \0)"] = {"\0", "\0", "\0", "\0"},
		["(\0, \0, \0, \0, \0)"] = {"\0", "\0", "\0", "\0", "\0"},
		["(\0, \0, \0, \0, \0, \0)"] = {"\0", "\0", "\0", "\0", "\0", "\0"},
		["(\0, \0, \0, \0, \0, \0, \0)"] = {"\0", "\0", "\0", "\0", "\0", "\0", "\0"},
		["(\0, \0, \0, \0, \0, \0, \0, \0)"] = {"\0", "\0", "\0", "\0", "\0", "\0", "\0", "\0"},

		["({'\0', '\0'})"] = {{'\0', '\0'}},
		["({'\0', '\0', '\0'})"] = {{'\0', '\0', '\0'}},
		["({'\0', '\0', '\0', '\0'})"] = {{'\0', '\0', '\0', '\0'}},
		["({'\0', '\0', '\0', '\0', '\0'})"] = {{'\0', '\0', '\0', '\0', '\0'}},
		["({'\0', '\0', '\0', '\0', '\0', '\0'})"] = {{'\0', '\0', '\0', '\0', '\0', '\0'}},
		["({'\0', '\0', '\0', '\0', '\0', '\0', '\0'})"] = {{'\0', '\0', '\0', '\0', '\0', '\0', '\0'}},
		["({'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0'})"] = {{'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0'}},
	},

	vector2int16s = {
		['(Vector2int16.new(-1, 3))'] = {Vector2int16.new(-1, 3)},
		['(Vector2int16.new(1, -3))'] = {Vector2int16.new(1, -3)},
		['(Vector2int16.new(-1, -3))'] = {Vector2int16.new(-1, -3)},
		['(Vector2int16.new(1, 3))'] = {Vector2int16.new(1, 3)},
		['(Vector2int16.new(-1, 3), Vector2int16.new(-1, 3))'] = {Vector2int16.new(-1, 3), Vector2int16.new(-1, 3)},
		['(Vector2int16.new(-1, 3), Vector2int16.new(-1, 3), Vector2int16.new(-1, 3))'] = {Vector2int16.new(-1, 3), Vector2int16.new(-1, 3), Vector2int16.new(-1, 3)},

		['({Vector2int16.new(-1, 3)})'] = {{Vector2int16.new(-1, 3)}},
		['({Vector2int16.new(-1, 3), Vector2int16.new(-1, 3)})'] = {{Vector2int16.new(-1, 3), Vector2int16.new(-1, 3)}},
		['({Vector2int16.new(-1, 3), Vector2int16.new(-1, 3), Vector2int16.new(-1, 3)})'] = {{Vector2int16.new(-1, 3), Vector2int16.new(-1, 3), Vector2int16.new(-1, 3)}},
	},

	vector2s = {
		['(Vector2.zero)'] = {Vector2.zero},
		['(Vector2.one)'] = {Vector2.one},
		['(Vector2.new(1, 2))'] = {Vector2.new(1, 2)},
		['(Vector2.new(1, -2))'] = {Vector2.new(1, -2)},
		['(Vector2.new(-1, 2.5))'] = {Vector2.new(-1, 2.5)},
		['(Vector2.new(-1, -2.73))'] = {Vector2.new(-1, -2.73)},
		['(Vector2.new(1, 2), Vector2.new(1, 2))'] = {Vector2.new(1, 2), Vector2.new(1, 2)},
		['(Vector2.new(1, 2), Vector2.new(1, 2), Vector2.new(1, 2))'] = {Vector2.new(1, 2), Vector2.new(1, 2), Vector2.new(1, 2)},

		['({Vector2.new(1, 2)})'] = {{Vector2.new(1, 2)}},
		['({Vector2.new(1, 2), Vector2.new(1, 2)})'] = {{Vector2.new(1, 2), Vector2.new(1, 2)}},
		['({Vector2.new(1, 2), Vector2.new(1, 2), Vector2.new(1, 2)})'] = {{Vector2.new(1, 2), Vector2.new(1, 2), Vector2.new(1, 2)}},
	},

	vector3int16s = {
		['(Vector3int16.new(-1, 3, -5))'] = {Vector3int16.new(-1, 3, -5)},
		['(Vector3int16.new(1, -3, 5))'] = {Vector3int16.new(1, -3, 5)},
		['(Vector3int16.new(-1, -3, -5))'] = {Vector3int16.new(-1, -3, -5)},
		['(Vector3int16.new(1, 3, 5))'] = {Vector3int16.new(1, 3, 5)},
		['(Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5))'] = {Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5)},
		['(Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5))'] = {Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5)},

		['({Vector3int16.new(-1, 3, -5)})'] = {{Vector3int16.new(-1, 3, -5)}},
		['({Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5)})'] = {{Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5)}},
		['({Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5)})'] = {{Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5)}},
	},

	vector3s = {
		['(Vector3.zero)'] = {Vector3.zero},
		['(Vector3.one)'] = {Vector3.one},
		['(Vector3.new())'] = {Vector3.new()},
		['(Vector3.new(1, 2, 3))'] = {Vector3.new(1, 2, 3)},
		['(Vector3.new(1, -2, 3))'] = {Vector3.new(1, -2, 3)},
		['(Vector3.new(-1, 2.5, -3.27))'] = {Vector3.new(-1, 2.5, -3.27)},
		['(Vector3.new(1, 2, 3), Vector3.new(1, 2, 3))'] = {Vector3.new(1, 2, 3), Vector3.new(1, 2, 3)},
		['(Vector3.new(1, 2, 3), Vector3.new(1, 2, 3), Vector3.new(1, 2, 3))'] = {Vector3.new(1, 2, 3), Vector3.new(1, 2, 3), Vector3.new(1, 2, 3)},

		['({Vector3.new(1, 2, 3)})'] = {{Vector3.new(1, 2, 3)}},
		['({Vector3.new(1, 2, 3), Vector3.new(1, 2, 3)})'] = {{Vector3.new(1, 2, 3), Vector3.new(1, 2, 3)}},
		['({Vector3.new(1, 2, 3), Vector3.new(1, 2, 3), Vector3.new(1, 2, 3)})'] = {{Vector3.new(1, 2, 3), Vector3.new(1, 2, 3), Vector3.new(1, 2, 3)}},
	},

	cframes = {
		['(CFrame.identity)'] = {CFrame.identity},
		['(CFrame.new())'] = {CFrame.new()},
		['(CFrame.new(1, 2, 3))'] = {CFrame.new(1, 2, 3)},
		['(CFrame.new(1, -2, 3))'] = {CFrame.new(1, -2, 3)},
		['(CFrame.new(-1, 2.5, -3.27))'] = {CFrame.new(-1, 2.5, -3.27)},
		['(CFrame.fromEulerAnglesYXZ(1, 2, 3))'] = {CFrame.fromEulerAnglesYXZ(1, 2, 3)},
		['(CFrame.fromEulerAnglesYXZ(1, -2, 3))'] = {CFrame.fromEulerAnglesYXZ(1, -2, 3)},
		['(CFrame.fromEulerAnglesYXZ(-1, 2.5, -3.27))'] = {CFrame.fromEulerAnglesYXZ(-1, 2.5, -3.27)},
		['(CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3))'] = {CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3)},
		['(CFrame.fromEulerAnglesYXZ(1, -2, 3) + Vector3.new(-1, 2, 3))'] = {CFrame.fromEulerAnglesYXZ(1, -2, 3) + Vector3.new(-1, 2, 3)},
		['(CFrame.fromEulerAnglesYXZ(-1, 2.5, -3.27) + Vector3.new(-1, -2, -3))'] = {CFrame.fromEulerAnglesYXZ(-1, 2.5, -3.27) + Vector3.new(-1, -2, -3)},
		['(CFrame.new(), CFrame.new())'] = {CFrame.new(), CFrame.new()},
		['(CFrame.new(), CFrame.new(), CFrame.new())'] = {CFrame.new(), CFrame.new(), CFrame.new()},
		['(CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3))'] = {CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3)},
		['(CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3))'] = {CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3)},
		['(CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3))'] = {CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3)},
		['(CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3))'] = {CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3)},

		['({CFrame.identity})'] = {{CFrame.identity}},
		['({CFrame.fromEulerAnglesYXZ(1, 2, 3)})'] = {{CFrame.fromEulerAnglesYXZ(1, 2, 3)}},
		['({CFrame.identity, CFrame.identity})'] = {{CFrame.identity, CFrame.identity}},
		['({CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3)})'] = {{CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3)}},
		['({CFrame.identity, CFrame.identity, CFrame.identity})'] = {{CFrame.identity, CFrame.identity, CFrame.identity}},
		['({CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3)})'] = {{CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3)}},
	},
}

local output = {}

for groupName, group in inputs do
	local groupdata = {}
	output[groupName] = groupdata

	for inputName, input in group do
		local connection = RunService.Heartbeat:Connect(function()
			fire:FireAllClients(table.unpack(input))
		end)
		start:FireAllClients()

		local _, data = stop.OnServerEvent:Wait()
		connection:Disconnect()

		groupdata[inputName] = string.split(data, ',')
		print(output)
	end
end