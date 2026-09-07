local config = require("shared.config")
local etypes = require("shared.etypes")
local loc = localization.localize

if not config.stickyConsistency then return end

etypes.redefineItem("lootplot.s0:triple_dice", "dsh.dd:triple_dice", {
	name = loc("Triple Dice"),
	image = "triple_dice",
	triggers = { "REROLL" },

	rarity = lp.rarities.UNCOMMON,

	sticky = true,
	basePrice = 8,
	baseMaxActivations = 6,
	baseMoneyGenerated = 2,

	grubMoneyCap = 20
})