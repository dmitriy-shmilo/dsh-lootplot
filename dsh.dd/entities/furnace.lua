local config = require("shared.config")
local etypes = require("shared.etypes")
local lib = require("shared.lib")
local loc = localization.localize

if not config.groundedFurnace then return end

lp.defineItem("dsh.dd:furnace_ash", {
	name = loc("Ash"),
	image = "dsh_furnace_ash",
	triggers = { "PULSE", "REROLL" },
	doomCount = 2,
	basePrice = 0,
	baseMaxActivations = 2,
	lootplotTags = { lib.tags.FIREPROOF },
	rarity = lp.rarities.UNIQUE
})

etypes.redefineItem("lootplot.s0:furnace", "dsh.dd:furnace", {
	name = loc("Furnace"),
	image = "furnace",
	triggers = { "REROLL", "PULSE" },

	activateDescription = loc("Destroys items. When fully destroyed, organic and destructible items turn into useless {lootplot:INFO_COLOR}Ash{/lootplot:INFO_COLOR}. Other items turn into {lootplot:INFO_COLOR}Clone-Rocks{/lootplot:INFO_COLOR}.\nEarn {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} for every item that was converted."),

	rarity = lp.rarities.EPIC,

	basePrice = 9,
	baseMaxActivations = 10,

	shape = lp.targets.KingShape(1),

	target = {
		type = "ITEM",
		filter = function(selfEnt, ppos, targetEnt)
			return (not lp.curses.isCurse(targetEnt)) and (not lib.hasTag(targetEnt, lib.tags.FIREPROOF))
		end,
		activate = function(selfEnt, ppos, targetEnt)
			local willConvert = not lp.isInvincible(targetEnt)
			lp.destroy(targetEnt)
			if not willConvert then return end

			local type = nil
			if lib.hasTag(targetEnt, lib.tags.ORGANIC) or lp.hasTrigger(targetEnt, "DESTROY") then
				type = server.entities["furnace_ash"]
			else
				type = server.entities["clone_rocks"]
			end

			if lp.forceSpawnItem(ppos, type, selfEnt.lootplotTeam) then
				lp.addMoney(selfEnt, 1)
			end
		end
	},
})