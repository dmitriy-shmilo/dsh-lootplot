local config = require("shared.config")
local etypes = require("shared.etypes")
local lib = require("shared.lib")
local loc = localization.localize

if not config.edibleBomb then return end

etypes.redefineItem("lootplot.s0:bomb", "dsh.dd:bomb", {
	name = loc("Bomb"),
	image = "bomb",
	activateDescription = loc("Destroy slots.\nEarn {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} for every slot destroyed."),

	rarity = lp.rarities.RARE,
	foodItem = true,
	lootplotTags = { lib.tags.FOOD },

	basePrice = 2,
	baseMaxActivations = 1,

	shape = lp.targets.KingShape(1),

	target = {
		type = "SLOT",
		activate = function(selfEnt, ppos, targetEnt)
			lp.addMoney(selfEnt, 1)
			lp.destroy(targetEnt)
		end
	}
})