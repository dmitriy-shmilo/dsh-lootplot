local lib = require("shared.lib")
local config = require("shared.config")
local worldgen = require("shared.worldgen")
local loc = localization.localize

if not config.colorfulLoaves then return end

lp.defineItem("dsh.cc:purple_loaf", {
	name = loc("Purple Loaf"),
	activateDescription = loc("Spawns a purple shop slot, which dooms sold items."),
	image = "dsh_purple_loaf",
	canItemFloat = true,
	basePrice = 7,
	rarity = lp.rarities.RARE,
	foodItem = true,
	lootplotTags = { lib.tags.FOOD },
	baseMaxActivations = 1,
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
			local etype = server.entities["lootplot.s0:purple_shop_slot"]
			lp.trySpawnSlot(ppos, etype, selfEnt.lootplotTeam)
		end
	},
	shape = lp.targets.ON_SHAPE
})

lp.defineItem("dsh.cc:green_loaf", {
	name = loc("Green Loaf"),
	activateDescription = loc("Spawns an emerald shop slot, which gives sold items a reroll trigger."),
	image = "dsh_green_loaf",
	canItemFloat = true,
	basePrice = 10,
	rarity = lp.rarities.RARE,
	foodItem = true,
	lootplotTags = { lib.tags.FOOD },
	baseMaxActivations = 1,
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
			local etype = server.entities["lootplot.s0:emerald_shop_slot"]
			lp.trySpawnSlot(ppos, etype, selfEnt.lootplotTeam)
		end
	},
	shape = lp.targets.ON_SHAPE
})

lp.defineItem("dsh.cc:pinkish_loaf", {
	name = loc("Pinkish Loaf"),
	activateDescription = loc("Spawns a pink shop slot, which adds lives to the sold items."),
	image = "dsh_pinkish_loaf",
	canItemFloat = true,
	basePrice = 10,
	rarity = lp.rarities.RARE,
	foodItem = true,
	lootplotTags = { lib.tags.FOOD },
	baseMaxActivations = 1,
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
			local etype = server.entities["lootplot.s0:pink_shop_slot"]
			lp.trySpawnSlot(ppos, etype, selfEnt.lootplotTeam)
		end
	},
	shape = lp.targets.ON_SHAPE
})