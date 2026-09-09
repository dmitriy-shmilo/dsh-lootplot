local lib = require("shared.lib")
local config = require("shared.config")
local loc = localization.localize

if not config.royalSlot then return end

lp.defineSlot("dsh.cc:royal_slot", {
	name = loc("Royal Slot"),
	image = "royal_slot",
	description = loc("Will not hold plebean %{rarity} items or below.", {
		rarity = lp.rarities.RARE.displayString
	}),
	rarity = lp.rarities.COMMON,
	triggers = { "PULSE" },
	canAddItemToSlot = function(slotEnt, itemEnt)
		if itemEnt.rarity then
			if itemEnt.rarity == lp.rarities.UNIQUE then return true end

			local minWeight = lp.rarities.getWeight(lp.rarities.EPIC)
			local itemWeight = lp.rarities.getWeight(itemEnt.rarity)
			return itemWeight <= minWeight
		end
		return true
	end
})

lp.defineItem("dsh.cc:royal_flask", {
	name = loc("Royal Flask"),
	image = "royal_flask",
	description = loc("Spawns royal slots, which will not hold items of %{rarity} or below.", {
		rarity = lp.rarities.RARE.displayString
	}),
	foodItem = true,
	basePrice = 6,
	rarity = lp.rarities.UNCOMMON,
	target = {
		type = "NO_SLOT",
		filter = function (selfEnt, ppos)
			local itemEnt = lp.posToItem(ppos)
			if itemEnt and lp.curses.isCurse(itemEnt) then
				return false
			end
			return true
		end,
		activate = function (selfEnt, ppos)
			local etype = server.entities["royal_slot"]
			lp.trySpawnSlot(ppos, etype, selfEnt.lootplotTeam)
		end
	},
	shape = lp.targets.BishopShape(3),
})

lp.defineItem("dsh.cc:other_basilisks_eye", {
	name = loc("The Other Basilisk's Eye"),
	image = "other_basilisks_eye",
	activateDescription = loc("Set rarity of items/slots to %{EPIC}", {
		EPIC = lp.rarities.EPIC.displayString
	}),

	unlockAfterWins = 1,

	triggers = { "PULSE" },

	baseMaxActivations = 1,
	basePointsGenerated = -10,
	basePrice = 7,

	shape = lp.targets.BishopShape(1),
	target = {
		type = "ITEM_OR_SLOT",
		filter = function(selfEnt, ppos, targetEnt)
			return targetEnt.rarity ~= lp.rarities.EPIC
		end,
		activate = function(selfEnt, ppos, targetEnt)
			targetEnt.rarity = lp.rarities.EPIC
			sync.syncComponent(targetEnt, "rarity")
		end,
	},

	rarity = lp.rarities.RARE,
})