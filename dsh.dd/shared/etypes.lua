local etypes = {
}

local replacedSlots = {
}

local replacedItems = {
}

function etypes.redefineItem(id, newId, definition)
	replacedItems[id] = newId
	lp.defineItem(newId, definition)
end

function etypes.redefineSlot(id, newId, definition)
	replacedSlots[id] = newId
	lp.defineSlot(newId, definition)
end

function etypes.getRedefinedItemId(id)
	return replacedItems[id]
end

function etypes.getRedefinedSlotId(id)
	return replacedSlots[id]
end

return etypes