local config = require("shared.config")
local etypes = require("shared.etypes")
local lib = require("shared.lib")
local loc = localization.localize
local interp = localization.newInterpolator

if not config.softRocks then return end

etypes.redefineItem("lootplot.s0:gear", "dsh.dd:gear", {
	name = loc("Gear"),
	image = "gear",
	activateDescription = loc("Rotates items"),

	shape = lp.targets.KingShape(1),

	triggers = {"ROTATE", "DESTROY"},

	lives = 25,
	rarity = lp.rarities.RARE,

	basePrice = 10,
	baseMaxActivations = 4,

	target = {
		type = "ITEM",
		activate = function(selfEnt, ppos, targetEnt)
			lp.rotateItem(targetEnt, 1)
		end,
	}
})

etypes.redefineItem("lootplot.s0:bone", "dsh.dd:bone", {
	name = loc("Bone"),
	image = "bone",
	description = loc("(Hint: Put this item in a sell-slot!)"),

	triggers = { "DESTROY" },

	basePrice = 0,
	basePointsGenerated = 50,

	lives = 15,
	rarity = lp.rarities.UNCOMMON,
})

local function redefineRock(id, name, etype)
	etype.image = etype.image or id
	etype.name = loc(name)

	etype.baseMaxActivations = etype.baseMaxActivations or 8
	etype.basePrice = etype.basePrice or 7

	etype.lootplotTags = {lib.tags.ROCKS}

	etype.unlockAfterWins = 3

	if not etype.listen then
		etype.triggers = etype.triggers or { "DESTROY" }
	end

	return etypes.redefineItem("lootplot.s0:" .. id, "dsh.dd:" .. id, etype)
end

do
	local HALF_BONUS_DESC = loc("Halves the current {lootplot:BONUS_COLOR}Bonus")

	local function halfBonus(ent)
		local bonus = lp.getPointsBonus(ent) or 0
		lp.setPointsBonus(ent, bonus/2)
	end

	redefineRock("jagged_rock", "Jagged Rock", {
		triggers = { "DESTROY", "PULSE" },

		activateDescription = HALF_BONUS_DESC,
		onActivate = halfBonus,

		rarity = lp.rarities.RARE,

		basePointsGenerated = 60,

		lives = 50
	})

	redefineRock("alienrock", "Alienrock", {
		triggers = { "DESTROY", "REROLL" },

		activateDescription = HALF_BONUS_DESC,
		onActivate = halfBonus,

		rarity = lp.rarities.RARE,

		basePointsGenerated = 60,

		lives = 50
	})

	do
		local PTS_BUFF = 5
		redefineRock("sapphire", "Sapphire", {
			triggers = { "DESTROY", "PULSE" },

			activateDescription = loc("If {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is negative, gains +%{buff} points", {
				buff = PTS_BUFF,
			}),

			onActivate = function(ent)
				local bonus = lp.getPointsBonus(ent)
				if bonus < 0 then
					lp.modifierBuff(ent, "pointsGenerated", PTS_BUFF, ent)
				end
			end,

			basePrice = 8,
			basePointsGenerated = 30,
			baseMaxActivations = 6,

			lives = 30,

			rarity = lp.rarities.RARE,
		})
	end
end

redefineRock("ice_cube", "Ice Cube", {
	triggers = { "DESTROY" },
	rarity = lp.rarities.RARE,

	baseBonusGenerated = 15,

	lives = 10
})

redefineRock("orange_rock", "Orange Rock", {
	triggers = { "DESTROY", "ROTATE" },
	rarity = lp.rarities.RARE,

	basePointsGenerated = 60,
	baseMoneyGenerated = 0.5,

	lives = 25
})


local GOLDEN_ROCK_DESC = interp("Earn multiplier equal to the 10% of the current balance {lootplot:MONEY_COLOR}($%{balance}){/lootplot:MONEY_COLOR}")
redefineRock("golden_rock", "Golden Rocks", {
	triggers = { "ROTATE", "DESTROY" },

	rarity = lp.rarities.RARE,

	description = function(ent)
		return GOLDEN_ROCK_DESC({
			balance = math.floor(lp.getMoney(ent) or 0)
		})
	end,

	lootplotProperties = {
		modifiers = {
			multGenerated = function(ent)
				return (lp.getMoney(ent) or 0) * 0.1
			end
		}
	},

	lives = 30,
})

redefineRock("tombstone", "Tombstone", {
	triggers = { "DESTROY", "UNLOCK" },

	activateDescription = loc("{lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} items 3 times."),

	rarity = lp.rarities.EPIC,

	basePointsGenerated = 100,
	basePrice = 12,

	shape = lp.targets.KingShape(1),
	target = {
		type = "ITEM",
		filter = function(selfEnt, ppos, targetEnt)
			return lp.hasTrigger(targetEnt, "PULSE")
		end,
		activate = function(selfEnt, ppos, targetEnt)
			lp.tryTriggerEntity("PULSE", targetEnt)

			lp.queueWithEntity(targetEnt, function(e)
				lp.tryTriggerEntity("PULSE", e)
			end)
			lp.wait(ppos, 0.2)

			lp.queueWithEntity(targetEnt, function(e)
				lp.tryTriggerEntity("PULSE", e)
			end)
			lp.wait(ppos, 0.2)
		end
	},

	lives = 30,
})

redefineRock("dark_rock", "Dark Rock", {
	triggers = { "DESTROY", "PULSE" },

	activateDescription = loc("Destroys items"),

	rarity = lp.rarities.EPIC,

	basePointsGenerated = 200,
	basePrice = 12,
	baseMaxActivations = 6,

	shape = lp.targets.KingShape(1),
	target = {
		type = "ITEM",
		activate = function(selfEnt, ppos, targetEnt)
			lp.destroy(targetEnt)
		end
	},

	lives = 50,
})

redefineRock("red_tomb", "Red Tomb", {
	triggers = { "DESTROY", "LEVEL_UP" },
	rarity = lp.rarities.RARE,

	activateDescription = loc("Gives items {lootplot:POINTS_MULT_COLOR}+0.5 multiplier{/lootplot:POINTS_MULT_COLOR}"),

	shape = lp.targets.RookShape(1),
	target = {
		type = "ITEM",
		activate = function(selfEnt, ppos, targEnt)
			lp.modifierBuff(targEnt, "multGenerated", 0.5)
		end
	},

	lives = 40
})

redefineRock("green_tomb", "Green Tomb", {
	triggers = { "DESTROY", "LEVEL_UP" },
	rarity = lp.rarities.RARE,

	activateDescription = loc("Gives items {lootplot:POINTS_COLOR}+6 points{/lootplot:POINTS_COLOR}"),

	shape = lp.targets.RookShape(1),
	target = {
		type = "ITEM",
		activate = function(selfEnt, ppos, targEnt)
			lp.modifierBuff(targEnt, "pointsGenerated", 6)
		end
	},

	lives = 40
})