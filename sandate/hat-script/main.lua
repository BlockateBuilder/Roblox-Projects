local rS = game:GetService("RunService")
local TS = game:GetService("TweenService")

local Hat = script.Parent
local Character = Hat.Parent
local hrp = Character.HumanoidRootPart

local angle = 0

local Info = {}

local anims = {
	["Size"] = {
		["Info"] = {
			["Tween"] = nil;
			["Keyframe"] = 1;
		}
	}
}

local function WaitForTween(name,v)
	if anims[name].Info.Playing then
		anims[name].Info.Tween.Completed:Connect(function()
			local tween: Tween = anims[name].Info.Tween
			tween:Destroy()
			anims[name].Info[v].Tween = nil
			anims.Size.Info[v].Playing = false
		end)
	end
end

local EasingStyles = {
	["Linear"] = Enum.EasingStyle.Linear;
	["Sine"] = Enum.EasingStyle.Sine;
	["Back"] = Enum.EasingStyle.Back;
	["Quad"] = Enum.EasingStyle.Quad;
	["Quart"] = Enum.EasingStyle.Quart;
	["Quint"] = Enum.EasingStyle.Quint;
	["Bounce"] = Enum.EasingStyle.Bounce;
	["Elastic"] = Enum.EasingStyle.Elastic;
	["Exponential"] = Enum.EasingStyle.Exponential;
	["Circular"] = Enum.EasingStyle.Circular;
	["Cubic"] = Enum.EasingStyle.Cubic;
}

local EasingDirections = {
	["In"] = Enum.EasingDirection.In;
	["Out"] = Enum.EasingDirection.Out;
	["InOut"] = Enum.EasingDirection.InOut
}

rS.Stepped:Connect(function(dT)
	for _,v in Hat:GetChildren() do
		if v:IsA("BasePart") and v:FindFirstChildOfClass("Configuration") then
			local Config = v:FindFirstChildOfClass("Configuration")
			if v:FindFirstChildOfClass("Configuration").hrpCenter.Value then
				Center = hrp.Position
			elseif v:FindFirstChildOfClass("Configuration"):FindFirstChild("Center") then
				Center = v:FindFirstChildOfClass("Configuration").Center.Value.Position
			else
				Center = Hat.PrimaryPart.Position
			end
			v.AssemblyAngularVelocity = Vector3.new(0,0,0)
			v.AssemblyLinearVelocity = Vector3.new(0,0,0)
			if not Info[v] then
				Info[v] = {
					Radius = (v.Position - Center).Magnitude
				}
			end
			local Radius = Info[v].Radius
			local speed = Config.SpinSpeed.Value
			if Config.LockOrientation.Value then
				local angle = angle + speed * dT
				local x = Config.Spin.X.Value and Center.X + math.cos(angle) * Radius or Center.X
				local y = Config.Spin.Y.Value and Center.Y + math.sin(angle) * Radius or Center.Y
				local z = Config.Spin.Z.Value and Center.Z + math.cos(angle) * Radius or Center.Z
				v.Position = Vector3.new(x, y, z)
			end
			if Config:FindFirstChild("Anims") then
				if Config.Anims:FindFirstChild("Size") then
					coroutine.wrap(function()
					local SizeAnim: Folder = Config.Anims.Size
					local Keyframes= SizeAnim:GetChildren()
					local TotalTime = 0
					if not anims.Size.Info[v] then
						anims.Size.Info[v] = {
							["Playing"] = false,
							["Tween"] = nil,
							["Keyframe"] = 1
						}
					end
					if not anims.Size.Info[v].Playing then
						local Keyframe = Keyframes[anims.Size.Info[v].Keyframe]
						anims.Size.Info[v].Keyframe = anims.Size.Info[v].Keyframe == #Keyframes and 1 or anims.Size.Info[v].Keyframe+1
						local EasingStyle = Keyframe:FindFirstChild("EasingStyle") and EasingStyles[Keyframe.EasingStyle.Value] or Enum.EasingStyle.Linear
						local EasingDirection = Keyframe:FindFirstChild("EasingDirection") and EasingDirections[Keyframe.EasingDirection.Value] or Enum.EasingDirection.InOut
						local repeatCount = Keyframe:FindFirstChild("RepeatCount") and Keyframe.RepeatCount.Value or 0
						local Reverses = Keyframe:FindFirstChild("Reverses") and Keyframe.Reverses.Value or false
						local X = Keyframe.X.Value
						local Y = Keyframe.Y.Value
						local Z = Keyframe.Z.Value
						local Time = Keyframe.Time.Value
						anims.Size.Info[v].Tween = TS:Create(v,TweenInfo.new(Time-TotalTime,EasingStyle,EasingDirection,repeatCount,Reverses),{Size = Vector3.new(X,Y,Z)})
						anims.Size.Info[v].Playing = true
						anims.Size.Info[v].Tween:Play()
						coroutine.wrap(function(a,b)
							WaitForTween(a,b)
						end)("Size",v)
						TotalTime += Time
						end
					end)()
				end
			end
		end
	end
end)
