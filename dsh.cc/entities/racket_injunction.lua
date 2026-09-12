local lib = require("shared.lib")
local config = require("shared.config")
local loc = localization.localize
local interp = localization.newInterpolator

if not config.tennisBall then return end

lp.defineItem("dsh.cc:racket_injunction", {
	name = loc("Racket Injunction"),
	description = loc("All earned points are multiplied by {c r=0.6 g=0.576 b=1}credit score{/c}. Purchase items from the racket shops in order to increase credit score for the current round. This injunction is always active."),
	image = "dsh_racket_injunction",
	canItemFloat = true,
	isCurse = true,
	rarity = lp.rarities.UNIQUE,
	isInvincible = function(ent)
		return true
	end,
	lootplotTags = { lib.tags.INJUNCTION_CURSE }
})

lp.defineItem("dsh.cc:bonus_racket_injunction", {
	name = loc("Bonus Racket Injunction"),
	description = loc("Absolute {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} value can not exceed your current {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR}. Debt annuls bonus altogether. This injunction is always active."),
	image = "dsh_bonus_racket_injunction",
	canItemFloat = true,
	isCurse = true,
	rarity = lp.rarities.UNIQUE,
	isInvincible = function(ent)
		return true
	end,
	lootplotTags = { lib.tags.INJUNCTION_CURSE }
})

lp.defineItem("dsh.cc:mult_racket_injunction", {
	name = loc("Mult Racket Injunction"),
	description = loc("Absolute {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} value can not exceed your current {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR}. Debt annuls mult altogether. This injunction is always active."),
	image = "dsh_mult_racket_injunction",
	canItemFloat = true,
	isCurse = true,
	rarity = lp.rarities.UNIQUE,
	isInvincible = function(ent)
		return true
	end,
	lootplotTags = { lib.tags.INJUNCTION_CURSE }
})