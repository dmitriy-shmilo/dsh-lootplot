local config = require("shared.config")
local etypes = require("shared.etypes")
local loc = localization.localize

if not config.nobleMarble then return end

local function rotateRandomly(ent)
	local rot = lp.SEED:randomMisc(0,3)
	if rot ~= 0 then
		lp.rotateItem(ent, rot)
	end
end

etypes.redefineItem("lootplot.s0:golden_urn", "dsh.dd:golden_urn", {
	name = loc("Golden Urn"),
	image = "golden_urn",
	rarity = lp.rarities.EPIC,
	init = rotateRandomly,

	basePrice = 14,

	listen = {
		type = "ITEM",
		trigger = "BUFF"
	},
	shape = lp.targets.UpShape(3),

	baseMaxActivations = 3,
	baseMoneyGenerated = 1,
})



etypes.redefineItem("lootplot.s0:pink_urn", "dsh.dd:pink_urn", {
	name = loc("Pink Urn"),
	image = "pink_urn",
	rarity = lp.rarities.RARE,
	init = rotateRandomly,

	activateDescription = loc("Give {lootplot:LIFE_COLOR}+1 life{/lootplot:LIFE_COLOR} to the buffed item"),

	basePrice = 12,

	listen = {
		type = "ITEM",
		trigger = "BUFF",

		filter = function(selfEnt, ppos, targEnt)
			return true
		end,
		activate = function(selfEnt, ppos, targEnt)
			targEnt.lives = (targEnt.lives or 0) + 1
		end
	},

	shape = lp.targets.UpShape(3),

	baseMaxActivations = 3,
	basePointsGenerated = 120,
})

etypes.redefineItem("lootplot.s0:red_urn", "dsh.dd:red_urn", {
	name = loc("Red Urn"),
	image = "red_urn",
	rarity = lp.rarities.RARE,
	init = rotateRandomly,

	basePrice = 11,

	listen = {
		type = "ITEM",
		trigger = "BUFF",
	},

	shape = lp.targets.UpShape(3),

	baseMaxActivations = 3,
	baseMultGenerated = 2,
})

etypes.redefineItem("lootplot.s0:marble_chest", "dsh.dd:marble_chest", {
	name = loc("Marble Chest"),
	image = "marble_chest",
	description = loc("{wavy}{lootplot:INFO_COLOR}HINT:{/lootplot:INFO_COLOR}{/wavy} When this item's stats are increased, {lootplot:TRIGGER_COLOR}Buff{/lootplot:TRIGGER_COLOR} is triggered"),

	triggers = {"BUFF", "UNLOCK"},

	rarity = lp.rarities.RARE,

	basePrice = 11,

	baseMaxActivations = 2,
	baseMoneyGenerated = 1,
	basePointsGenerated = 30,
})

