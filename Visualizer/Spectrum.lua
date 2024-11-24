--\\ Audio Spectrum Handler

local container = script.Parent:WaitForChild("Container")
local Bar = container.Bar
Bar.Parent = nil

local smooth = false

local AudioPlayer = script.Parent:WaitForChild("AudioPlayer")
AudioPlayer:Play()

local Config = script.Configuration

local audio = Config.Audio

local SmoothBool = Config.Smooth

local markers = Config.Markers
local startfrequency = Config.startFreq
local endfrequency = Config.endFreq

for freq = startfrequency.Value, endfrequency.Value, (endfrequency.Value - startfrequency.Value) / markers.Value do
	local bar = Bar:Clone()
	bar.LayoutOrder = freq
	bar.Name = tostring(freq)
	bar.Parent = container
end
local function easeInOut(t)
	return 0.5 * (1 - math.cos(math.pi * t))
end

--\\ Updater

local rs = game:GetService("RunService")
rs.RenderStepped:Connect(function(dt)
	if smooth then
		local spectrum = AudioPlayer.AudioAnalyzer:GetSpectrum()
		for _, bar in pairs(container:GetChildren()) do
			if bar:IsA("Frame") then
				local scale = (spectrum[bar.LayoutOrder] or 0) / .0125 * (math.ceil((spectrum[bar.LayoutOrder] or 0)%1/100) + math.floor((spectrum[bar.LayoutOrder] or 0)%1/50))
				local start = UDim2.fromScale(0, bar.Size.Y.Scale)
				local i = (bar.LayoutOrder - startfrequency.Value) / (endfrequency.Value-startfrequency.Value)

				local speed = 1
				bar.BackgroundColor3 = Color3.fromHSV(0.736389,(0.5 + 0.5 * math.max(math.sin((tick() * speed) - i),math.sin((tick() * speed) +i))), 1)
				local transitionValue
				if transitionValue == 0 then
					transitionValue = 1
				else
					transitionValue = 0.5 + 0.5 * math.max(-math.sin((tick() * speed) - i), -math.sin((tick() * speed) + i))
				end
				bar.UIStroke.Color = Color3.fromHSV(0.736389, transitionValue, 1)

				local easeFactor = easeInOut(dt * 10)
				bar.Size = (Bar.Size + start):Lerp(Bar.Size + UDim2.fromScale(0, scale), easeFactor)
			end
		end
	else
		local spectrum = AudioPlayer.AudioAnalyzer:GetSpectrum()
		for _, bar in pairs(container:GetChildren()) do
			if bar:IsA("Frame") then
				local scale = (spectrum[bar.LayoutOrder] or 0) / .0125 * (math.ceil((spectrum[bar.LayoutOrder] or 0)%1/100) + math.floor((spectrum[bar.LayoutOrder] or 0)%1/50))
				local start = UDim2.fromScale(0, bar.Size.Y.Scale)
				local i = (bar.LayoutOrder - startfrequency.Value) / (endfrequency.Value-startfrequency.Value)

				local speed = 1

				bar.BackgroundColor3 = Color3.fromHSV(0.736389,(0.5 + 0.5 * math.max(math.sin((tick() * speed) - i),math.sin((tick() * speed) +i))), 1)
				local transitionValue
				if transitionValue == 0 then
					transitionValue = 1
				else
					transitionValue = 0.5 + 0.5 * math.max(-math.sin((tick() * speed) - i), -math.sin((tick() * speed) + i))
				end
				bar.UIStroke.Color = Color3.fromHSV(0.736389,transitionValue, 1)
				--(tick()*.4-i)%1 <- Old colour change system
				bar.Size = (Bar.Size+ start):Lerp(Bar.Size + UDim2.fromScale(0,scale),math.min(1,dt*10))
			end
		end
	end
end)

--\\ Variable Updater

markers.Changed:Connect(function()
	AudioPlayer:Stop()
	for _,i in container:GetChildren() do
		if i:IsA("Frame") then i:Destroy() end
	end
	for freq = startfrequency.Value, endfrequency.Value, (endfrequency.Value - startfrequency.Value) / markers.Value do
		local bar = Bar:Clone()
		bar.LayoutOrder = freq
		bar.Name = tostring(freq)
		bar.Parent = container
	end
	AudioPlayer:Play()
end)

audio.Changed:Connect(function()
	AudioPlayer:Stop()
	AudioPlayer.AssetId = "rbxassetid://"..audio.Value
	AudioPlayer.TimePosition = 0
	AudioPlayer:Play()
end)

SmoothBool.Changed:Connect(function()
	smooth = SmoothBool.Value
end)
