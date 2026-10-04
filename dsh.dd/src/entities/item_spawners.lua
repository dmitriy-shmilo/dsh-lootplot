local config = require("shared.config")
local etypes = require("shared.etypes")
local loc = localization.localize

if not config.stickyConsistency then return end

etypes.redefineItem("lootplot.s0:fish_skeleton", "dsh.dd:fish_skeleton", {
	name = loc("Fish Skeleton"),
	image = "fish_skeleton",
	triggers = { "PULSE" },
	activateDescription = loc("Spawn free %{UNCOMMON} items on {lootplot:INFO_COLOR}dirt-slots.", {
		UNCOMMON = lp.rarities.UNCOMMON.displayString
	}),

	unlockAfterWins = 2,

	basePrice = 8,
	baseBonusGenerated = 4,
	sticky = true,

	shape = lp.targets.HorizontalShape(2),
	target = {
		type = "SLOT_NO_ITEM",
		filter = function(selfEnt, ppos, slotEnt)
			return slotEnt:type() == "lootplot.s0:dirt_slot"
		end,
		activate = function(selfEnt, ppos, slotEnt)
			local itemEType = lp.rarities.randomItemOfRarity(lp.rarities.UNCOMMON)
			if itemEType then
				lp.trySpawnItem(ppos, itemEType, selfEnt.lootplotTeam)
			end
		end
	},

	rarity = lp.rarities.RARE,
})

etypes.redefineItem("lootplot.s0:toolbelt", "dsh.dd:toolbelt", {
	name = loc("Toolbelt"),
	image = "toolbelt",
	triggers = { "PULSE" },

	activateDescription = loc("Spawns random %{RARE} items, and gives them {lootplot:GRUB_COLOR_LIGHT}GRUB-%{grubCap}", {
		grubCap = GRUB_MONEY_CAP,
		RARE = lp.rarities.RARE.displayString
	}),

	rarity = lp.rarities.RARE,
	basePrice = 8,
	baseMoneyGenerated = -14,
	sticky = true,

	shape = lp.targets.DownShape(2),
	target = {
		type = "SLOT_NO_ITEM",
		activate = function(selfEnt, ppos, slotEnt)
			local r = lp.SEED:randomMisc()
			local itemEType
			if r < 0.15 then
				itemEType = lp.rarities.randomItemOfRarity(lp.rarities.EPIC)
			else
				itemEType = lp.rarities.randomItemOfRarity(lp.rarities.RARE)
			end

			local item = itemEType and lp.trySpawnItem(ppos, itemEType, selfEnt.lootplotTeam)
			if item then
				item.grubMoneyCap = GRUB_MONEY_CAP
			end
		end
	},
})


etypes.redefineItem("lootplot.s0:pandoras_box", "dsh.dd:pandoras_box", {
	name = loc("Pandora's Box"),
	image = "pandoras_box",
	triggers = { "PULSE" },
	activateDescription = loc("Spawn %{RARE} items.", {
		RARE = lp.rarities.RARE.displayString
	}),

	unlockAfterWins = 4,

	rarity = lp.rarities.EPIC,

	shape = lp.targets.RookShape(1),
	doomCount = 1,

	basePrice = 9,
	baseMaxActivations = 1,
	sticky = true,

	target = {
		type = "SLOT_NO_ITEM",
		activate = function(selfEnt, ppos, targetEnt)
			local etype = lp.rarities.randomItemOfRarity(lp.rarities.RARE)
			if etype then
				lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
			end
		end
	}
})