-- Server Script
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local TS = game:GetService("TweenService")

local Events = RS:FindFirstChild("Events")
local Blocks = RS:FindFirstChild("Blocks")

local Perms = {
	["Visitor"] = 0;
	["Builder"] = 1;
	["Admin"] = 2;
	["Owner"] = 3
}

Events.Place.OnServerEvent:Connect(function(Player, Position, BlockType, BlockDescription)
	Position = Vector3.new(
		math.floor((Position.X + 2) / 4) * 4,
		math.floor((Position.Y + 2) / 4) * 4,
		math.floor((Position.Z + 2) / 4) * 4
	)
	for _, v in workspace.Blocks:GetChildren() do
		if v.Position == Position then
			return
		end
	end

	local Block = Blocks:FindFirstChild(BlockType):Clone()
	Block.Size = Vector3.new(0,0,0)
	Block.Position = Position
	--Block.CFrame = CFrame.new(Position,BlockDescription.CFrame.LookVector)
	Block:SetAttribute("Owner", Player.Name)
	Block.Parent = workspace.Blocks
	TS:Create(Block,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size = Vector3.new(4,4,4)}):Play()
end)

Events:FindFirstChild("Destroy").OnServerEvent:Connect(function(p,Block)
	Block:Destroy()
end)

Events.Input.OnServerEvent:Connect(function(p,input)
	print(input)
end)
