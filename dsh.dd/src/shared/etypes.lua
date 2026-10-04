local etypes = {
}

local replacedSlots = {
}

local originalSlots = {
}

local replacedItems = {
}

local originalItems = {
}

function etypes.redefineItem(id, newId, definition)
	replacedItems[id] = newId
	originalItems[newId] = id
	lp.defineItem(newId, definition)
end

function etypes.redefineSlot(id, newId, definition)
	replacedSlots[id] = newId
	originalSlots[newId] = id
	lp.defineSlot(newId, definition)
end

function etypes.getRedefinedItemId(id)
	return replacedItems[id]
end

function etypes.getRedefinedSlotId(id)
	return replacedSlots[id]
end

function etypes.getOriginalItemId(id)
	return originalItems[id]
end

function etypes.getOriginalSlotId(id)
	return originalSlots[id]
end

return etypes