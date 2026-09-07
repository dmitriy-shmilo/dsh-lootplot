local function patchForceSpawns()
	local forceSpawnSlot = lp.forceSpawnSlot

	lp.forceSpawnSlot = function(ppos, slotEType, team)
		local plot = ppos:getPlot()
		local width, height = plot:getDimensions()
		local x, y = plot:indexToCoords(ppos:getSlotIndex())
		
		x = x % width
		y = y % height

		ppos = plot:getPPos(x, y)

		return forceSpawnSlot(ppos, slotEType, team)
	end

	local forceSpawnItem = lp.forceSpawnItem

	lp.forceSpawnItem = function(ppos, itemEType, team, spawnMidair)
		local plot = ppos:getPlot()
		local width, height = plot:getDimensions()
		local x, y = plot:indexToCoords(ppos:getSlotIndex())

		x = x % width
		y = y % height

		ppos = plot:getPPos(x, y)

		return forceSpawnItem(ppos, itemEType, team, spawnMidair)
	end
end

local function patchLayerAccessors()
	lp.posToItem = function(ppos)
		local plot = ppos:getPlot()
		local x, y = plot:indexToCoords(ppos:getSlotIndex())
		if not plot:isInBounds(x, y) then
			return nil
		end

		return plot:get("item", x, y)
	end

	lp.posToSlot = function(ppos)
		local plot = ppos:getPlot()
		local x, y = plot:indexToCoords(ppos:getSlotIndex())
		if not plot:isInBounds(x, y) then
			return nil
		end

		return plot:get("slot", x, y)
	end
end

local function patch()
	if lp.dshPatched then return end
	lp.dshPatched = true

	patchForceSpawns()
	patchLayerAccessors()
end

return patch