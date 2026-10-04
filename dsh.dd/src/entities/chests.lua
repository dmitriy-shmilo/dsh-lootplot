local config = require("shared.config")
local etypes = require("shared.etypes")
local loc = localization.localize

if not config.brittleChests then return end

etypes.redefineItem("lootplot.s0:chest_gold_small", "dsh.dd:chest_gold_small", {
	name = loc("Small Golden Chest"),
	image = "chest_gold_small",
	baseMoneyGenerated = 10,
	basePrice = 4,
	rarity = lp.rarities.RARE,
	baseMaxActivations = 1,
	doomCount = 1
})

etypes.redefineItem("lootplot.s0:chest_gold_big", "dsh.dd:chest_gold_big", {
	name = loc("Big Golden Chest"),
	image = "chest_gold_big",
	baseMoneyGenerated = 25,
	basePrice = 10,
	rarity = lp.rarities.EPIC,
	baseMaxActivations = 1,
	doomCount = 1
})