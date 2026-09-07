local config = require("shared.config")
local lib = require("shared.lib")
local etypes = require("shared.etypes")
local loc = localization.localize

if not config.starsDontAffectFood then return end

local function shuffleTargetShapes(selfEnt)
	local targets = lp.targets.getTargets(selfEnt)
	if not targets then
		return
	end

	local itemEntities = {}
	local itemEntShapes = {}

	for _, ppos in ipairs(targets) do
		local itemEnt = lp.posToItem(ppos)
		if itemEnt then
			itemEntities[#itemEntities+1] = itemEnt
			itemEntShapes[#itemEntities] = itemEnt.shape
		end
	end

	-- Shuffle shapes
	itemEntShapes = shuffled(itemEntShapes)

	-- Assign shapes
	for i, itemEnt in ipairs(itemEntities) do
		if itemEnt.shape ~= itemEntShapes[i] then
			lp.targets.setShape(itemEnt, itemEntShapes[i])
		end
	end
end

etypes.redefineItem("lootplot.s0:star_card", "dsh.dd:star_card", {
	name = loc("Star Card"),
	image = "star_card",
	activateDescription = loc("Shuffle {lootplot.targets:COLOR}target-shapes{/lootplot.targets:COLOR} between items. Doesn't affect food."),
	rarity = lp.rarities.EPIC,
	shape = lp.targets.VerticalShape(1),
	triggers = { "PULSE" },
	baseMaxActivations = 1,
	basePrice = 10,
	unlockAfterWins = 2,
	target = {
		type = "ITEM",
		target = function(ent, ppos, targEnt)
			return targEnt.target and targEnt.shape and not lib.hasTag(targEnt, lib.tags.FOOD)
		end
	},
	onActivate = shuffleTargetShapes
})

etypes.redefineItem("lootplot.s0:star", "dsh.dd:star", {
	name = loc("Star"),
	image = "star",
	foodItem = true,
	activateDescription = loc("Shuffle {lootplot.targets:COLOR}target-shapes{/lootplot.targets:COLOR} between items. Doesn't affect food."),
	rarity = lp.rarities.EPIC,
	shape = lp.targets.VerticalShape(1),
	triggers = { "PULSE" },
	baseMaxActivations = 1,
	basePrice = 11,
	unlockAfterWins = 2,
	target = {
		type = "ITEM",
		target = function(ent, ppos, targEnt)
			return targEnt.target and targEnt.shape and not lib.hasTag(targEnt, lib.tags.FOOD)
		end
	},
	onActivate = shuffleTargetShapes
})