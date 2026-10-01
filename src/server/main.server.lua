--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Economy = require(ReplicatedStorage.Shared.Economy)
local rng = Random.new()

local arena = Instance.new("Folder")
arena.Name = "CrystalRushArena"
arena.Parent = workspace

local function part(name: string, size: Vector3, position: Vector3, color: Color3): Part
	local value = Instance.new("Part")
	value.Name = name
	value.Size = size
	value.Position = position
	value.Color = color
	value.Anchored = true
	value.TopSurface = Enum.SurfaceType.Smooth
	value.BottomSurface = Enum.SurfaceType.Smooth
	value.Parent = arena
	return value
end

part("Floor", Vector3.new(100, 1, 100), Vector3.new(0, -0.5, 0), Color3.fromRGB(55, 60, 70))
local deposit =
	part("Deposit", Vector3.new(16, 1, 12), Vector3.new(0, 0.5, 35), Color3.fromRGB(50, 220, 100))
local upgrade = part(
	"SpeedUpgrade",
	Vector3.new(12, 1, 12),
	Vector3.new(20, 0.5, 35),
	Color3.fromRGB(50, 140, 255)
)
local spawn = Instance.new("SpawnLocation")
spawn.Name = "PlayerSpawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, 0.5, 25)
spawn.Anchored = true
spawn.Neutral = true
spawn.Parent = arena

local function playerFromHit(hit: BasePart): Player?
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return nil
	end
	return Players:GetPlayerFromCharacter(character)
end

local function updateSpeed(player: Player)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local level = player:GetAttribute("SpeedLevel") :: number
		humanoid.WalkSpeed = Config.BaseWalkSpeed + level * Config.SpeedPerLevel
	end
end

local function setupPlayer(player: Player)
	player:SetAttribute("Carried", 0)
	player:SetAttribute("Coins", 0)
	player:SetAttribute("SpeedLevel", 0)
	player:SetAttribute("RoundTime", Config.RoundSeconds)
	player.CharacterAdded:Connect(function()
		task.defer(updateSpeed, player)
	end)
	if player.Character then
		task.defer(updateSpeed, player)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in Players:GetPlayers() do
	setupPlayer(player)
end

local function spawnCrystal(index: number)
	local crystal = part(
		"Crystal" .. index,
		Vector3.new(2, 3, 2),
		Vector3.new(rng:NextNumber(-40, 40), 2, rng:NextNumber(-35, 25)),
		Color3.fromRGB(160, 80, 255)
	)
	crystal.Material = Enum.Material.Neon
	crystal.CanCollide = false
	local available = true
	crystal.Touched:Connect(function(hit)
		if not available then
			return
		end
		local player = playerFromHit(hit)
		if not player then
			return
		end
		local carried = player:GetAttribute("Carried") :: number
		if carried >= Config.CarryCapacity then
			return
		end
		available = false
		player:SetAttribute("Carried", carried + 1)
		crystal.Transparency = 1
		crystal.CanTouch = false
		task.delay(Config.CrystalRespawnSeconds, function()
			crystal.Position = Vector3.new(rng:NextNumber(-40, 40), 2, rng:NextNumber(-35, 25))
			crystal.Transparency = 0
			crystal.CanTouch = true
			available = true
		end)
	end)
end

for index = 1, 18 do
	spawnCrystal(index)
end

local depositDebounce: { [Player]: boolean } = {}
deposit.Touched:Connect(function(hit)
	local player = playerFromHit(hit)
	if not player or depositDebounce[player] then
		return
	end
	depositDebounce[player] = true
	local carried = player:GetAttribute("Carried") :: number
	if carried > 0 then
		local coins = player:GetAttribute("Coins") :: number
		local newCoins, newCarried = Economy.deposit(coins, carried, Config.CrystalValue)
		player:SetAttribute("Carried", newCarried)
		player:SetAttribute("Coins", newCoins)
	end
	task.delay(0.75, function()
		depositDebounce[player] = nil
	end)
end)

local upgradeDebounce: { [Player]: boolean } = {}
upgrade.Touched:Connect(function(hit)
	local player = playerFromHit(hit)
	if not player or upgradeDebounce[player] then
		return
	end
	upgradeDebounce[player] = true
	local coins = player:GetAttribute("Coins") :: number
	local level = player:GetAttribute("SpeedLevel") :: number
	local newCoins, newLevel, bought =
		Economy.tryBuySpeed(coins, level, Config.UpgradeCost, Config.MaxSpeedLevel)
	if bought then
		player:SetAttribute("Coins", newCoins)
		player:SetAttribute("SpeedLevel", newLevel)
		updateSpeed(player)
	end
	task.delay(0.75, function()
		upgradeDebounce[player] = nil
	end)
end)

task.spawn(function()
	while true do
		for remaining = Config.RoundSeconds, 0, -1 do
			for _, player in Players:GetPlayers() do
				player:SetAttribute("RoundTime", remaining)
			end
			task.wait(1)
		end
	end
end)
