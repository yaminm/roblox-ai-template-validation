--!strict
-- Execute this module's contents through Studio MCP, never by editing Script.Source.
-- Client steps move the character; server steps read authoritative results.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
type Config = typeof(require(game.ReplicatedStorage.Shared.Config))

return function(Config: Config)
	local Acceptance = {}

	local function player(): Player
		local value = if RunService:IsClient() then Players.LocalPlayer else Players:GetPlayers()[1]
		assert(value, "playtest needs one player")
		return value
	end

	local function arena(): Folder
		return workspace:WaitForChild("CrystalRushArena", 5) :: Folder
	end

	local function character(): Model
		local value = player().Character
		assert(value, "character missing")
		return value
	end

	local function humanoid(): Humanoid
		return character():FindFirstChildOfClass("Humanoid") :: Humanoid
	end

	local function moveTo(target: BasePart)
		assert(RunService:IsClient(), "movement must run on the actual client")
		-- Start nearby to keep the test bounded despite the randomized arena.
		-- Humanoid movement and engine Touched events exercise the real game handlers.
		character():PivotTo(CFrame.new(target.Position + Vector3.new(-4, 3, 0)))
		humanoid():MoveTo(target.Position)
		task.wait(1.25)
		humanoid():MoveTo(character():GetPivot().Position)
		humanoid():Move(Vector3.zero)
	end

	local function crystal(): Part
		local chosen: Part? = nil
		local bestDistance = -1
		for _, item in arena():GetChildren() do
			if item:IsA("Part") and item.Name:match("^Crystal%d+$") and item.CanTouch then
				local distance = math.huge
				for _, neighbor in arena():GetChildren() do
					if
						neighbor ~= item
						and neighbor:IsA("Part")
						and neighbor.Name:match("^Crystal%d+$")
					then
						distance = math.min(distance, (neighbor.Position - item.Position).Magnitude)
					end
				end
				if distance > bestDistance then
					chosen = item
					bestDistance = distance
				end
			end
		end
		assert(chosen, "no available crystal")
		return chosen
	end

	function Acceptance.snapshot(): string
		local value = player()
		local gui = value:FindFirstChild("PlayerGui")
		local hud = gui and gui:FindFirstChild("CrystalRushHUD")
		local status = hud and hud:FindFirstChild("Status") :: TextLabel?
		return HttpService:JSONEncode({
			attributes = value:GetAttributes(),
			walkSpeed = humanoid().WalkSpeed,
			health = humanoid().Health,
			position = tostring(character():GetPivot().Position),
			hud = status and status.Text,
		})
	end

	function Acceptance.expectServer(carried: number, coins: number, level: number): string
		assert(RunService:IsServer(), "check authoritative server state")
		local value = player()
		assert(value:GetAttribute("Carried") == carried, "unexpected carried count")
		assert(value:GetAttribute("Coins") == coins, "unexpected coin balance")
		assert(value:GetAttribute("SpeedLevel") == level, "unexpected speed level")
		assert(
			humanoid().WalkSpeed == Config.BaseWalkSpeed + level * Config.SpeedPerLevel,
			"wrong speed"
		)
		local remaining = value:GetAttribute("RoundTime") :: number
		assert(
			remaining >= 0 and remaining <= Config.RoundSeconds and remaining % 1 == 0,
			"invalid timer"
		)
		return Acceptance.snapshot()
	end

	function Acceptance.checkHUD(): string
		assert(RunService:IsClient(), "inspect the actual client HUD")
		local value = player()
		local status = value
			:WaitForChild("PlayerGui")
			:WaitForChild("CrystalRushHUD")
			:WaitForChild("Status") :: TextLabel
		local expected = string.format(
			"Crystals %d/%d   Coins %d   Speed +%d   Time %ds",
			value:GetAttribute("Carried") :: number,
			Config.CarryCapacity,
			value:GetAttribute("Coins") :: number,
			value:GetAttribute("SpeedLevel") :: number,
			value:GetAttribute("RoundTime") :: number
		)
		assert(status.Text == expected, "HUD disagrees with replicated state")
		assert(status.TextFits, "HUD text clipped")
		local viewport = workspace.CurrentCamera :: Camera
		assert(
			status.AbsolutePosition.Y > viewport.ViewportSize.Y / 2,
			"HUD overlaps default chat area"
		)
		assert(status.AbsolutePosition.X >= 0, "HUD left edge outside viewport")
		assert(
			status.AbsolutePosition.X + status.AbsoluteSize.X <= viewport.ViewportSize.X,
			"HUD right edge outside viewport"
		)
		return HttpService:JSONEncode({
			text = status.Text,
			fits = status.TextFits,
			position = tostring(status.AbsolutePosition),
			size = tostring(status.AbsoluteSize),
			viewport = tostring(viewport.ViewportSize),
		})
	end

	function Acceptance.beginRoundProbe(): string
		assert(RunService:IsServer(), "observe server timer")
		assert(not workspace:FindFirstChild("HarnessRuntimeProbe"), "remove previous probe first")
		local probe = Instance.new("Folder")
		probe.Name = "HarnessRuntimeProbe"
		probe.Parent = workspace
		local value = player()
		local previous = value:GetAttribute("RoundTime") :: number
		probe:SetAttribute("InitialTime", previous)
		probe:SetAttribute("Ticked", false)
		probe:SetAttribute("SawZero", false)
		probe:SetAttribute("Restarted", false)
		local connection = value:GetAttributeChangedSignal("RoundTime"):Connect(function()
			local current = value:GetAttribute("RoundTime") :: number
			if current < previous then
				probe:SetAttribute("Ticked", true)
			end
			if current == 0 then
				probe:SetAttribute("SawZero", true)
			end
			if previous == 0 and current == Config.RoundSeconds then
				probe:SetAttribute("Restarted", true)
			end
			previous = current
		end)
		probe.Destroying:Once(function()
			connection:Disconnect()
		end)
		return HttpService:JSONEncode(probe:GetAttributes())
	end

	function Acceptance.finishRoundProbe(): string
		local probe = workspace:FindFirstChild("HarnessRuntimeProbe")
		assert(probe, "round observer missing")
		assert(probe:GetAttribute("Ticked"), "timer did not count down")
		assert(probe:GetAttribute("SawZero"), "round has not reached zero yet")
		assert(probe:GetAttribute("Restarted"), "round did not restart at configured duration")
		local result = HttpService:JSONEncode(probe:GetAttributes())
		probe:Destroy()
		return result
	end

	function Acceptance.respawnCharacter(): string
		assert(RunService:IsServer(), "respawn from server")
		local old = character()
		humanoid().Health = 0
		local deadline = os.clock() + Players.RespawnTime + 5
		repeat
			task.wait(0.1)
		until (player().Character ~= old and player().Character ~= nil) or os.clock() > deadline
		assert(player().Character ~= old, "character failed to respawn")
		local newHumanoid = character():WaitForChild("Humanoid", 5) :: Humanoid
		task.wait(0.25)
		local level = player():GetAttribute("SpeedLevel") :: number
		assert(newHumanoid.Health > 0, "respawned character is dead")
		assert(
			newHumanoid.WalkSpeed == Config.BaseWalkSpeed + level * Config.SpeedPerLevel,
			"respawn lost speed"
		)
		return Acceptance.snapshot()
	end

	function Acceptance.collect(count: number): string
		local collected = {}
		for _ = 1, count do
			local target = crystal()
			local before = player():GetAttribute("Carried") :: number
			moveTo(target)
			assert(
				player():GetAttribute("Carried") == before + 1,
				"touch did not collect exactly one crystal"
			)
			assert(
				target.Transparency == 1 and not target.CanTouch,
				"collected crystal still available"
			)
			assert(not target.CanCollide, "collected crystal is an invisible obstacle")
			table.insert(collected, target.Name)
		end
		return HttpService:JSONEncode({
			collected = collected,
			state = HttpService:JSONDecode(Acceptance.snapshot()),
		})
	end

	function Acceptance.visitPad(name: string): string
		assert(name == "Deposit" or name == "SpeedUpgrade", "unknown pad")
		moveTo(arena():FindFirstChild(name) :: Part)
		return Acceptance.snapshot()
	end

	function Acceptance.checkCapacity(): string
		assert(player():GetAttribute("Carried") == Config.CarryCapacity, "fill inventory first")
		local target = crystal()
		moveTo(target)
		assert(player():GetAttribute("Carried") == Config.CarryCapacity, "capacity exceeded")
		assert(target.CanTouch and target.Transparency == 0, "full inventory consumed crystal")
		return Acceptance.snapshot()
	end

	function Acceptance.checkRespawn(name: string): string
		local target = arena():FindFirstChild(name) :: Part
		-- Park outside both the crystal spawn range and the economy pads.
		character():PivotTo(CFrame.new(-45, 3, 35))
		local deadline = os.clock() + Config.CrystalRespawnSeconds + 2
		repeat
			task.wait(0.1)
		until (target.Transparency == 0 and target.CanTouch) or os.clock() > deadline
		assert(target.Transparency == 0 and target.CanTouch, "crystal failed to respawn")
		assert(not target.CanCollide, "respawned crystal blocks movement")
		return HttpService:JSONEncode({
			crystal = name,
			available = true,
			state = HttpService:JSONDecode(Acceptance.snapshot()),
		})
	end

	return Acceptance
end
