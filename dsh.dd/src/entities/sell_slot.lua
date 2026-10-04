local config = require("shared.config")
local etypes = require("shared.etypes")
local lib = require("shared.lib")
local loc = localization.localize

if not config.seasonSale then return end

etypes.redefineSlot("lootplot.s0:sell_slot", "dsh.dd:sell_slot", {
	image = "sell_slot",
	name = loc("Sell slot"),
	activateDescription = loc("Sets item price to zero, and earns half of it as {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR}.\nThen, destroys the item."),

	triggers = { "PULSE" },

	dontPropagateTriggerToItem = true,
	isItemListenBlocked = true,

	baseMaxActivations = 500,

	rarity = lp.rarities.UNCOMMON,

	canActivate = function(slotEnt)
		local itemEnt = lp.slotToItem(slotEnt)
		return itemEnt
	end,

	onActivate = function(slotEnt)
		local itemEnt = lp.slotToItem(slotEnt)
		if not itemEnt then
			return
		end

		local price = (itemEnt.price or 0)
		lp.modifierBuff(itemEnt, "price", -price, slotEnt)
		lp.addMoney(itemEnt, price / 2)
		lp.destroy(itemEnt)
	end
})