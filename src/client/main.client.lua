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
label.AnchorPoint = Vector2.new(0.5, 1)
label.Size = UDim2.new(1, -48, 0, 56)
label.Position = UDim2.new(0.5, 0, 1, -24)
label.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
label.BackgroundTransparency = 0.15
label.TextColor3 = Color3.new(1, 1, 1)
label.TextSize = 20
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(460, 56)
sizeConstraint.Parent = label

local textConstraint = Instance.new("UITextSizeConstraint")
textConstraint.MaxTextSize = 20
textConstraint.Parent = label

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
