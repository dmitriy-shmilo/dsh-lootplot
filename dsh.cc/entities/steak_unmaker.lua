local lib = require("shared.lib")
local config = require("shared.config")
local loc = localization.localize

if not config.steakUnmaker then return end

local activateInstantly = umg.group("activateInstantly", "item")

local function tryActivateInstantly(ent)
	local slotEnt = lp.itemToSlot(ent)
	if slotEnt and (not lp.canSlotPropagateTriggerToItem(slotEnt)) then
		return
	end
	local ppos = lp.getPos(ent)
	local plot = ppos and ppos:getPlot()
	if plot and lp.canActivateEntity(ent) then
		lp.wait(ppos, 0.15)
		lp.tryActivateEntity(ent)
		lp.wait(ppos, 0.15)
	end
end

local function activateAllFood()
	for _, ent in ipairs(activateInstantly) do
		tryActivateInstantly(ent)
	end
end

local ACTIVATE_FOOD_BUTTON = {
	text = loc("Activate All Food"),
	action = function(selfEnt)
		if server then
			activateAllFood()
		end
	end
}

lp.defineItem("dsh.cc:steak_unmaker", {
	name = loc("Steak Unmaker"),
	image = "steak_unmaker",
	description = loc("Activates all possible food."),
	baseMaxActivations = 1,
	rarity = lp.rarities.RARE,
	actionButtons = {
		ACTIVATE_FOOD_BUTTON
	}
})