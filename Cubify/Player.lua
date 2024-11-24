-- Server script
local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")

local DS = DSS:GetDataStore("Studio")

local function SaveData(Player: Player)
	print("Saving Data for " .. Player.Name)
	local PlrStats = Player:FindFirstChild("PlayerStats")
	if not PlrStats then return end

	local success, err = pcall(function()
		DS:UpdateAsync(Player.UserId, function(oldData)
			oldData = oldData or { Perm = {}, Cubes = 500 }
			oldData.Perm[game.PlaceId] = PlrStats.Perm.Value
			oldData.Cubes = PlrStats:FindFirstChild("Cubes").Value
			return oldData
		end)
	end)

	if success then
		print("Data saved successfully.")
	else
		warn("Error saving data: " .. tostring(err))
	end
end

local function LoadData(Player: Player)
	local success, data = pcall(function()
		return DS:GetAsync(Player.UserId)
	end)

	if not success then
		warn("Error loading data for " .. Player.Name)
		return
	end
	data = data or { Perm = {}, Cubes = 500 }
	
	local PlrStats = Player:FindFirstChild("PlayerStats")
	
	if not PlrStats then return end
	
	PlrStats.Perm.Value = data.Perm[game.PlaceId] or "Visitor"
	PlrStats.Cubes.Value = data.Cubes
end

Players.PlayerAdded:Connect(function(Player)
	local PlrStats = Instance.new("Folder")
	PlrStats.Name = "PlayerStats"
	PlrStats.Parent = Player

	local Perm = Instance.new("StringValue")
	Perm.Name = "Perm"
	Perm.Parent = PlrStats

	local Cubes = Instance.new("IntValue")
	Cubes.Name = "Cubes"
	Cubes.Parent = PlrStats

	-- Load data when the player joins
	LoadData(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
	SaveData(Player)
end)

game:BindToClose(function()
	local players = Players:GetPlayers()
	local saveThreads = {}

	for _, player in ipairs(players) do
		local thread = coroutine.create(function()
			SaveData(player)
		end)
		coroutine.resume(thread)
		table.insert(saveThreads, thread)
	end
	
	for _, thread in ipairs(saveThreads) do
		local success, err = coroutine.status(thread) == "dead" or nil,nil
		if not success then
			warn("Error saving data for a player during BindToClose: " .. tostring(err))
		end
	end
end)
