local config = require("shared.config")
local lib = require("shared.lib")
local etypes = require("shared.etypes")
local loc = localization.localize

if config.shieldsDontAffectShields then
	etypes.redefineItem("lootplot.s0:doomed_shield", "dsh.dd:doomed_shield", {
		name = loc("Doomed Shield"),
		image = "doomed_shield",
		rarity = lp.rarities.RARE,
		triggers = { "PULSE" },

		activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} on items.\nGives {lootplot:DOOMED_LIGHT_COLOR}+1 Doomed{/lootplot:DOOMED_LIGHT_COLOR} to doomed-items.\nDoesn't affect shields."),

		unlockAfterWins = 3,

		basePrice = 7,
		baseMaxActivations = 4,
		doomCount = 10,

		shape = lp.targets.KingShape(1),

		target = {
			type = "ITEM",
			filter = function(selfEnt, ppos, targetEnt)
				return (lp.hasTrigger(targetEnt, "PULSE") or targetEnt.doomCount) and not lib.hasTag(targetEnt, lib.tags.SHIELD)
			end,
			activate = function(selfEnt, ppos, targetEnt)
				if targetEnt.doomCount then
					targetEnt.doomCount = targetEnt.doomCount + 1
				end
				lp.tryTriggerEntity("PULSE", targetEnt)
			end
		},

		lootplotTags = { lib.tags.SHIELD }
	})

	etypes.redefineItem("lootplot.s0:wooden_shield", "dsh.dd:wooden_shield", {
		name = loc("Wooden Shield"),
		image = "wooden_shield",
		rarity = lp.rarities.RARE,
		triggers = { "PULSE" },

		activateDescription = loc("{lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} items.\nDoesn't affect shields."),

		basePrice = 12,
		baseMaxActivations = 4,

		shape = lp.targets.KingShape(1),

		target = {
			type = "ITEM",
			filter = function(selfEnt, ppos, targetEnt)
				return lp.hasTrigger(targetEnt, "PULSE") and not lib.hasTag(targetEnt, lib.tags.SHIELD)
			end,
			activate = function(selfEnt, ppos, targetEnt)
				lp.tryTriggerEntity("PULSE", targetEnt)
			end
		},
		lootplotTags = { lib.tags.SHIELD }
	})

	etypes.redefineItem("lootplot.s0:mini_wooden_shield", "dsh.dd:mini_wooden_shield", {
		name = loc("Mini Wooden Shield"),
		image = "mini_wooden_shield",
		rarity = lp.rarities.UNCOMMON,
		triggers = {"PULSE"},

		activateDescription = loc("50% chance to {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} each item.\nDoesn't affect shields."),

		basePrice = 3,
		baseMaxActivations = 5,

		shape = lp.targets.KingShape(1),

		target = {
			type = "ITEM",
			filter = function(selfEnt, ppos, targetEnt)
				return lp.hasTrigger(targetEnt, "PULSE") and not lib.hasTag(targetEnt, lib.tags.SHIELD)
			end,
			activate = function(selfEnt, ppos, targetEnt)
				if lp.SEED:randomMisc() < 0.5 then
					lp.tryTriggerEntity("PULSE", targetEnt)
				end
			end
		},
		lootplotTags = { lib.tags.SHIELD }
	})

	etypes.redefineItem("lootplot.s0:level_shield", "dsh.dd:level_shield", {
		name = loc("Level Shield"),
		image = "level_shield",
		rarity = lp.rarities.UNCOMMON,
		triggers = {"PULSE"},

		activateDescription = loc("{lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} items.\nDoesn't affect shields."),

		basePrice = 9,
		baseMaxActivations = 6,

		shape = lp.targets.KingShape(1),

		target = {
			type = "ITEM",
			filter = function(selfEnt, ppos, targetEnt)
				return lp.hasTrigger(targetEnt, "PULSE") and not lib.hasTag(targetEnt, lib.tags.SHIELD)
			end,
			activate = function(selfEnt, ppos, targetEnt)
				lp.tryTriggerEntity("PULSE", targetEnt)
			end
		},
		lootplotTags = { lib.tags.SHIELD }
	})

	etypes.redefineItem("lootplot.s0:interdimensional_shield", "dsh.dd:interdimensional_shield", {
		name = loc("Interdimensional Shield"),
		image = "interdimensional_shield",
		triggers = { "PULSE" },

		activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} on items.\nIf {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} is negative, triggers 3 times instead of 1.\nDoesn't affect shields."),

		rarity = lp.rarities.RARE,

		basePrice = 12,
		baseMaxActivations = 2,

		shape = lp.targets.KingShape(1),

		target = {
			type = "ITEM",
			filter = function(selfEnt, ppos, targetEnt)
				return lp.hasTrigger(targetEnt, "PULSE") and not lib.hasTag(targetEnt, lib.tags.SHIELD)
			end,
			activate = function(selfEnt, ppos, targetEnt)
				lp.tryTriggerEntity("PULSE", targetEnt)
				if lp.getPointsBonus(selfEnt) < 0 then
					lp.tryTriggerEntity("PULSE", targetEnt)
					lp.tryTriggerEntity("PULSE", targetEnt)
				end
			end
		},
		lootplotTags = { lib.tags.SHIELD }
	})
end