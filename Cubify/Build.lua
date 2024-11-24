--\\ Variables
local UIS = game:GetService("UserInputService")
local rS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Ts = game:GetService("TweenService")

local Blocks = RS:FindFirstChild("Blocks")
local Events = RS:FindFirstChild("Events")
local Sound = RS:FindFirstChild("Sound")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Character = Player.Character or Player.CharacterAdded:Wait()

local lM = nil
local lT = tick()
local holo = nil
local Dholo = nil

local Rotating = false

local MouseFunctionStates = {"None","Build","Destroy"}
local MouseFunction = "None"
local mCount = 0

local BlockTypes = {"Block","Wedge", "Inner edge wedge"}
local BlockType = "Block"
local BlockDescription = {CFrame = CFrame.new(), rotation = 0, tilt = 0}

local rayDepth = 250

--\\ Functions

rS.Heartbeat:Connect(function(dT)
	if lM ~= Mouse.Hit then
		lM = Mouse.Hit
		if MouseFunction == "Build" then
			local unitRay = workspace.CurrentCamera:ScreenPointToRay(Mouse.X,Mouse.Y)
			local Params = RaycastParams.new()
			Params.FilterDescendantsInstances = {workspace.Blocks:GetChildren()}
			Params.FilterType = Enum.RaycastFilterType.Include
			local extendedRay = workspace:Raycast(unitRay.Origin, unitRay.Direction * rayDepth,Params)
			if extendedRay then
				local Position = extendedRay.Position + (extendedRay.Normal * 0.01)
				Position = Vector3.new(
					math.floor((Position.X + 2.5) / 4) * 4,
					math.floor((Position.Y + 2.5) / 4) * 4,
					math.floor((Position.Z + 2.5) / 4) * 4
				)
				if holo and holo.Position == Position and lT == tick() then return elseif holo then holo:Destroy() end
				lT = tick()
				local Block: Part = Blocks:FindFirstChild(BlockType):Clone()
				local Outline = Instance.new("SelectionBox")
				Outline.Adornee = Block
				Block.Position = Position
				Block:SetAttribute("Owner", Player.Name)
				Block.CanCollide, Block.CanQuery = false, false
				Outline.Color3 = Color3.fromRGB(120, 192, 255)
				Outline.Transparency = 0.4
				Outline.LineThickness = .1
				Outline.Parent = Block
				Block.Parent = workspace.Temp
				BlockDescription.CFrame = Block.CFrame
				holo = Block
			elseif not extendedRay and holo then
				holo:Destroy()
				holo = nil
			end
		elseif MouseFunction == "Destroy" then
			local unitRay = workspace.CurrentCamera:ScreenPointToRay(Mouse.X,Mouse.Y)
			local Params = RaycastParams.new()
			Params.FilterDescendantsInstances = {workspace.Blocks:GetChildren()}
			Params.FilterType = Enum.RaycastFilterType.Include
			local extendedRay = workspace:Raycast(unitRay.Origin, unitRay.Direction * rayDepth,Params)
			if extendedRay then
				if Dholo == extendedRay.Instance then return elseif Dholo and Dholo ~= extendedRay then Dholo:FindFirstChild("DestroyBox"):Destroy() Dholo = nil end
				local hit = extendedRay.Instance
				Dholo = hit
				local Outline = Instance.new("SelectionBox")
				Outline.Name = "DestroyBox"
				Outline.Color3 = Color3.fromRGB(150,0,0)
				Outline.LineThickness = 0.1
				Outline.Transparency = 0.4
				Outline.Adornee = hit
				Outline.Parent = hit
			end
		end
	end
end)

Mouse.Button1Up:Connect(function()
	if MouseFunction == "Build" then
		local unitRay = workspace.CurrentCamera:ScreenPointToRay(Mouse.X,Mouse.Y)
		local Params = RaycastParams.new()
		Params.FilterDescendantsInstances = {workspace.Blocks:GetChildren()}
		Params.FilterType = Enum.RaycastFilterType.Include
		local extendedRay = workspace:Raycast(unitRay.Origin, unitRay.Direction * rayDepth,Params)
		if extendedRay then
			local tI = TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
			local Tween = Ts:Create(extendedRay.Instance,tI,{Size = Vector3.new(4,4,4)})
			Tween:Play()
			local offsetPosition = extendedRay.Position + (extendedRay.Normal * 0.01)
			local SFX = Sound.Place:Clone()
			SFX.Parent = game.SoundService
			SFX:Destroy()
			Events.Place:FireServer(offsetPosition, BlockType, BlockDescription)
		end
	elseif MouseFunction == "Destroy" then
		local unitRay = workspace.CurrentCamera:ScreenPointToRay(Mouse.X,Mouse.Y)
		local Params = RaycastParams.new()
		Params.FilterDescendantsInstances = {workspace.Blocks:GetChildren()}
		Params.FilterType = Enum.RaycastFilterType.Include
		local extendedRay = workspace:Raycast(unitRay.Origin, unitRay.Direction * rayDepth,Params)
		if extendedRay then
			local tI = TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.In)
			local Tween = Ts:Create(extendedRay.Instance,tI,{Size = Vector3.new(0,0,0)})
			Tween:Play()
			local SFX = Sound:FindFirstChild("Destroy"):Clone()
			SFX.Parent = game.SoundService
			SFX:Destroy()
			Tween.Completed:Connect(function(pbs)
				if pbs == Enum.PlaybackState.Completed then
					Events:FindFirstChild("Destroy"):FireServer(extendedRay.Instance)
				end
			end)
		end
	end
end)

UIS.InputBegan:Connect(function(i,t)
	if t then return end
	if i.KeyCode == Enum.KeyCode.Q then
		if holo then holo:Destroy() end
		if Dholo then Dholo.DestroyBox:Destroy() Dholo = nil end
		if mCount < 3 then
			mCount+=1
		else
			mCount = 1
		end
		MouseFunction = MouseFunctionStates[mCount]
		print(MouseFunction)
	elseif i.KeyCode == Enum.KeyCode.R then
		if holo and not Rotating then
			Rotating = true
			local rot = math.rad(90)
			local newCF = holo.CFrame * CFrame.Angles(0,rot,0)
			local tween = Ts:Create(holo,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{CFrame = newCF})
			tween:Play()
			
			BlockDescription.rotation += rot
			BlockDescription.CFrame = newCF
			Rotating = false
		end	
	elseif i.KeyCode == Enum.KeyCode.T then
		if holo and not Rotating then
			Rotating = true
			local tilt = math.rad(90)
			local newCF = holo.CFrame *CFrame.Angles(tilt,0,0)
			local tween = Ts:Create(holo,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{CFrame = newCF})
			tween:Play()
			
			BlockDescription.tilt = tilt
			BlockDescription.CFrame = newCF
			Rotating = false
		end
	end
end)
