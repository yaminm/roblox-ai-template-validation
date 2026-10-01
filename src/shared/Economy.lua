--!strict

local Economy = {}

function Economy.deposit(coins: number, carried: number, crystalValue: number): (number, number)
	assert(coins >= 0 and carried >= 0 and crystalValue >= 0, "economy values must be non-negative")
	return coins + carried * crystalValue, 0
end

function Economy.tryBuySpeed(
	coins: number,
	level: number,
	cost: number,
	maxLevel: number
): (number, number, boolean)
	if coins < cost or level >= maxLevel then
		return coins, level, false
	end
	return coins - cost, level + 1, true
end

return table.freeze(Economy)
