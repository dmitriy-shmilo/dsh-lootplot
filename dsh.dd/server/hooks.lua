local lib = require("shared.lib")
local etypes = require("shared.etypes")

local function forceSpawnItem(ppos, type, team, spawnMidair)
	local newType = etypes.getRedefinedItemId(type:getTypename())
	if newType then
		lp.forceSpawnItem(ppos, server.entities[newType], team, spawnMidair)
		return false
	end

	return true
end

local function trySpawnItem(ppos, type, team, spawnMidair)
	local newType = etypes.getRedefinedItemId(type:getTypename())
	if newType then
		lp.trySpawnItem(ppos, server.entities[newType], team, spawnMidair)
		return false
	end

	return true
end

lib.hooks.addBeforeCallback(lp, "forceSpawnItem", forceSpawnItem)
lib.hooks.addBeforeCallback(lp, "trySpawnItem", trySpawnItem)
