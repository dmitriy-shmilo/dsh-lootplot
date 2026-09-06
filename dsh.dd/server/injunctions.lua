local lib = require("shared.lib")
local config = require("shared.config")

local function trySpawnSlot(ppos, slotEType, team)
	local item = lp.posToItem(ppos)
	if lib.hasTag(item, lib.tags.INJUNCTION_CURSE) then return false end
	return true
end

local function forceSpawnSlot(ppos, slotEType, team)
	local item = lp.posToItem(ppos)
	if lib.hasTag(item, lib.tags.INJUNCTION_CURSE) then
		local doomCount = 5
		local oldSlot = lp.posToSlot(ppos)
		if oldSlot and oldSlot.doomCount and oldSlot.doomCount < doomCount then
			doomCount = oldSlot.doomCount
		end

		if slotEType.itemSpawner or slotEType.itemReroller then
			local slot = lp.forceSpawnSlot(ppos, server.entities["null_slot"], team)
			if slot then
				slot.doomCount = doomCount
			end
			return false
		end
	end
	return true
end

if config.stableInjunctions then
	lib.hooks.addBeforeCallback(lp, "forceSpawnSlot", forceSpawnSlot)
	lib.hooks.addBeforeCallback(lp, "trySpawnSlot", trySpawnSlot)
end