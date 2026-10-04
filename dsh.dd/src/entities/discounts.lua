local config = require("shared.config")
local etypes = require("shared.etypes")
local loc = localization.localize

if not config.modestDiscounts then return end

etypes.redefineItem("lootplot.s0:pineapple_ring", "dsh.dd:pineapple_ring", {
	name = loc("Pineapple Ring"),
	image = "pineapple_ring",
	basePrice = 14,
	grubMoneyCap = 20,
	canItemFloat = true,
	activateDescription = loc("Make all target items {lootplot:MONEY_COLOR}$2{/lootplot:MONEY_COLOR} cheaper. Won't reduce price below zero."),

	baseMaxActivations = 10,

	sticky = true,

	listen = {
		type = "ITEM",
		trigger = "BUY",
	},
	target = {
		type = "ITEM",
		activate = function(selfEnt, ppos, targetEnt)
			local price = targetEnt.price
			if price <= 0 then return end
			if price == 1 then
				lp.modifierBuff(targetEnt, "price", -1) 
				return
			end
			lp.modifierBuff(targetEnt, "price", -2, selfEnt)
		end,
	},

	shape = lp.targets.KingShape(1),

	rarity = lp.rarities.RARE,
})

local PRICE_CAP = 6
etypes.redefineItem("lootplot.s0:6_cent_ticket", "dsh.dd:6_cent_ticket", {
	name = loc("6 Cent Ticket"),
	image = "6_cent_ticket",
	basePrice = 2,
	grubMoneyCap = GRUB_MONEY_CAP,
	canItemFloat = true,

	activateDescription = loc("Limit all target item prices to {lootplot:MONEY_COLOR}$%{priceCap}.", {
		priceCap = PRICE_CAP,
	}),

	baseMaxActivations = 5,
	sticky = true,

	triggers = { "REROLL", "PULSE" },
	target = {
		type = "ITEM",
		filter = function(selfEnt, ppos, targetEnt)
			local price = targetEnt.price
			return price and price > PRICE_CAP
		end,
		activate = function(selfEnt, ppos, targetEnt)
			local price = targetEnt.price
			if price and price > PRICE_CAP then
				local delta = targetEnt.price - PRICE_CAP
				lp.modifierBuff(targetEnt, "price", -delta, selfEnt)
			end
		end,
	},

	shape = lp.targets.DownShape(3),

	rarity = lp.rarities.UNCOMMON,
})

etypes.redefineItem("lootplot.s0:0_cent_ticket", "dsh.dd:0_cent_ticket", {
	name = loc("0 Cent Ticket"),
	image = "0_cent_ticket",
	triggers = { "PULSE", "REROLL" },

	activateDescription = loc("Reduces item prices by {lootplot:MONEY_COLOR}$3{/lootplot:MONEY_COLOR}."),

	basePrice = 6,
	grubMoneyCap = GRUB_MONEY_CAP,
	canItemFloat = true,
	sticky = true,
	rarity = lp.rarities.RARE,

	shape = lp.targets.DownShape(1),
	baseMaxActivations = 5,

	target = {
		type = "ITEM",
		activate = function(selfEnt, ppos, targetEnt)
			local price = targetEnt.price
			if price then
				lp.modifierBuff(targetEnt, "price", -3, selfEnt)
			end
		end
	},
})


etypes.redefineItem("lootplot.s0:3_cent_ticket", "dsh.dd:3_cent_ticket", {
	name = loc("3 Cent Ticket"),
	listen = {
		type = "ITEM",
		trigger = "BUY",
	},

	basePrice = 12,
	grubMoneyCap = GRUB_MONEY_CAP,
	baseMoneyGenerated = 6,
	canItemFloat = true,
	sticky = true,
	baseMaxActivations = 5,

	rarity = lp.rarities.LEGENDARY,

	shape = lp.targets.KingShape(3),
})