local config = require("shared.config")
local lib = require("shared.lib")
local etypes = require("shared.etypes")
local loc = localization.localize

if not config.mildNacho then return end

etypes.redefineItem("lootplot.s0:nacho", "dsh.dd:nacho", {
	name = loc("Nacho"),
	image = "nacho",
	activateDescription = loc("Destroys target items. Copies item's base stats to the slot underneath."),
	rarity = lp.rarities.LEGENDARY,

	foodItem = true,
	baseMaxActivations = 1,
	unlockAfterWins = 2,
	basePrice = 18,
	shape = lp.targets.UpShape(1),
	lootplotTags = { lib.tags.ORGANIC },

	target = {
		type = "ITEM",
		filter = function (selfEnt, ppos, targetEnt)
			return lp.posToSlot(ppos)
		end,
		activate = function(selfEnt, ppos, targetEnt)
			local slotEnt = lp.itemToSlot(targetEnt)
			if not slotEnt then return end
			local pts = targetEnt.basePointsGenerated or 0
			local money = targetEnt.baseMoneyGenerated or 0
			local mult = targetEnt.baseMultGenerated or 0
			local bonus = targetEnt.baseBonusGenerated or 0
			if pts ~= 0 then
				lp.modifierBuff(slotEnt, "pointsGenerated", pts, selfEnt)
			end
			if money ~= 0 then
				lp.modifierBuff(slotEnt, "moneyGenerated", money, selfEnt)
			end
			if mult ~= 0 then
				lp.modifierBuff(slotEnt, "multGenerated", mult, selfEnt)
			end
			if bonus ~= 0 then
				lp.modifierBuff(slotEnt, "bonusGenerated", bonus, selfEnt)
			end
			lp.destroy(targetEnt)
		end
	}
})
