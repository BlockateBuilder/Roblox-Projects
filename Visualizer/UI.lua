local UIS = game:GetService("UserInputService")

local UI = script.Parent
local MarkersTB = UI.Markers
local AudioTB = UI.Audio
local SmoothB = UI.Smooth
MarkersTB.Text = UI.Parent.Spectrum.Configuration.Markers.Value
AudioTB.Text = UI.Parent.Spectrum.Configuration.Audio.Value

UIS.InputBegan:Connect(function(i,t)
	if i.KeyCode == Enum.KeyCode.M then
		script.Parent.Visible = not script.Parent.Visible
	end
end)

MarkersTB.FocusLost:Connect(function(ep) if not ep then return end; if not tonumber(MarkersTB.Text) then
		MarkersTB.Text = UI.Parent.Spectrum.Configuration.Markers.Value return 
	end
	UI.Parent.Spectrum.Configuration.Markers.Value = tonumber(MarkersTB.Text)
end)

AudioTB.FocusLost:Connect(function(ep) if not ep then return end; if not tonumber(AudioTB.Text) then
		AudioTB.Text = UI.Parent.Spectrum.Configuration.Markers.Value return 
	end
	UI.Parent.Spectrum.Configuration.Audio.Value = tonumber(AudioTB.Text)
end)

SmoothB.MouseButton1Click:Connect(function()
	UI.Parent.Spectrum.Configuration.Smooth.Value = not UI.Parent.Spectrum.Configuration.Smooth.Value
	SmoothB.Text = UI.Parent.Spectrum.Configuration.Smooth.Value and "Smooth" or "Sharp"
end)
