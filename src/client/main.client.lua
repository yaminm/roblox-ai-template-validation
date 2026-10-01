--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage.Shared.Config)

local gui = Instance.new("ScreenGui")
gui.Name = "CrystalRushHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Name = "Status"
label.Size = UDim2.fromOffset(460, 56)
label.Position = UDim2.fromOffset(24, 24)
label.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
label.BackgroundTransparency = 0.15
label.TextColor3 = Color3.new(1, 1, 1)
label.TextSize = 20
label.Font = Enum.Font.GothamBold
label.Parent = gui

local function render()
	label.Text = string.format(
		"Crystals %d/%d   Coins %d   Speed +%d   Time %ds",
		player:GetAttribute("Carried") or 0,
		Config.CarryCapacity,
		player:GetAttribute("Coins") or 0,
		player:GetAttribute("SpeedLevel") or 0,
		player:GetAttribute("RoundTime") or 0
	)
end

for _, attribute in { "Carried", "Coins", "SpeedLevel", "RoundTime" } do
	player:GetAttributeChangedSignal(attribute):Connect(render)
end
render()
