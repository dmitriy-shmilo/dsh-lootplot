local lib = require("shared.lib")
local config = require("shared.config")
local loc = localization.localize
local interp = localization.newInterpolator

if not config.eraser then return end

local ACTIVATE_TEXT = loc("Erase for $10")
local ACTIVATE_BROKE_TEXT = loc("Needs $10 to activate")

local ERASE_BUTTON = {
	text = function(selfEnt)
		local mon = lp.getMoney(selfEnt) or 0
		if mon < 10 then
			return ACTIVATE_BROKE_TEXT
		end
		return ACTIVATE_TEXT
	end,
	action = function(selfEnt)
		if server then
			selfEnt.activationCount = 0
			local mon = lp.getMoney(selfEnt) or 0
			if mon < 10 then
				return
			end

			lp.setMoney(selfEnt, mon - 10)
			local targets = lp.targets.getConvertedTargets(selfEnt)
			for a, target in ipairs(targets) do
				local ppos = lp.getPos(target)
				ppos:clear(target.layer)
				target:delete()
			end
		end
	end
}

lp.defineItem("dsh.cc:eraser", {
	name = loc("Eraser"),
	image = "eraser",
	description = loc("Erases an item or slot from the board. Has an activation button. Always costs $10 to activate. Doesn't work on curses. Original idea by {lootplot:BORING_COLOR}d:sys{/lootplot:BORING_COLOR}."),
	baseMaxActivations = 20,
	rarity = lp.rarities.EPIC,
	canItemFloat = true,
	target = {
		type = "ITEM_OR_SLOT",
		filter = function (selfEnt, ppos)
			local itemEnt = lp.posToItem(ppos)
			if itemEnt and lp.curses.isCurse(itemEnt) then
				return false
			end
			return true
		end,
		activate = function (selfEnt, ppos)
			
		end
	},
	shape = lp.targets.UpShape(1),
	actionButtons = {
		ERASE_BUTTON
	}
})