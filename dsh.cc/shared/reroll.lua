local reroll = {
}

local function hasRerollTrigger(ent)
	for _,t in ipairs(ent.triggers)do
		if t == "REROLL" then
			return true
		end
	end
	return false
end

local function shouldReroll(ppos)
	local slot = lp.posToSlot(ppos)
	if slot and hasRerollTrigger(slot) then
		return true
	end
	local item = lp.posToItem(ppos)
	if item and hasRerollTrigger(item) then
		return true
	end
end

function reroll.rerollPlot(plot)
	lp.Bufferer()
		:all(plot)
		:filter(shouldReroll)
		:withDelay(0.05)
		:to("SLOT_OR_ITEM")
		:execute(function(ppos, ent)
			lp.resetCombo(ent)
			lp.tryTriggerSlotThenItem("REROLL", ppos)
		end)
end

return reroll