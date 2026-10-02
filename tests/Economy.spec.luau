local Economy = require("../src/shared/Economy")

local coins, carried = Economy.deposit(5, 3, 10)
assert(coins == 35 and carried == 0, "deposit converts all carried crystals")

local remainder, level, bought = Economy.tryBuySpeed(30, 0, 30, 3)
assert(remainder == 0 and level == 1 and bought, "valid purchase succeeds")

local unchangedCoins, unchangedLevel, rejected = Economy.tryBuySpeed(29, 0, 30, 3)
assert(
	unchangedCoins == 29 and unchangedLevel == 0 and not rejected,
	"insufficient funds are rejected"
)

local cappedCoins, cappedLevel, capped = Economy.tryBuySpeed(100, 3, 30, 3)
assert(cappedCoins == 100 and cappedLevel == 3 and not capped, "maximum level is enforced")

print("Economy tests passed")
