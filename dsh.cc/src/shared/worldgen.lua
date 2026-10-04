local worldgen = {
}

function worldgen.clearSlotsInCircle(ppos, radius)
	local searchRad = math.ceil(radius)
	local rsq = radius * radius

	for y = -searchRad, searchRad do
		for x = -searchRad, searchRad do
			local newPPos = ppos:move(x, y)

			if newPPos then
				local sq = x * x + y * y
				if sq <= rsq then
					local slot = lp.posToSlot(newPPos)
					if slot then
						newPPos:clear(slot.layer)
						slot:delete()
					end
				end
			end
		end
	end
end

function worldgen.clearFogInCircle(ppos, team, radius)
	local searchRad = math.ceil(radius)
	local plot = ppos:getPlot()
	local rsq = radius * radius

	for y = -searchRad, searchRad do
		for x = -searchRad, searchRad do
			local newPPos = ppos:move(x, y)

			if newPPos then
				local sq = x * x + y * y
				if sq <= rsq then
					plot:setFogRevealed(newPPos, team, true)
				end
			end
		end
	end
end

function worldgen.spawnDoomClock(ent, dx,dy)
	dx = dx or 0
	dy = dy or 0

	local plot = lp.getPos(ent):getPlot()
	local team = assert(ent.lootplotTeam)
	local ppos = assert(lp.getPos(ent)
		:move(dx, dy)
	)

	local dclock = server.entities.doom_clock()
	dclock._plotX, dclock._plotY = ppos:getCoords()
	plot:set(dclock._plotX, dclock._plotY, dclock)
	local wppos = plot:getPPos(dclock._plotX, dclock._plotY)
	dclock.x, dclock.y, dclock.dimension = wppos:getWorldPos()
	worldgen.clearFogInCircle(ppos, team, 1)
end

function worldgen.forceSpawnSlotsAround(ppos, slotType, w, h, lootplotTeam, transform)
	assert(server, "Can only be called on server-side")
	for dx = math.floor(-w / 2 + 0.5), math.floor(w / 2 + 0.5) - 1 do
		for dy = math.floor(-h / 2 + 0.5), math.floor(h / 2 + 0.5) - 1 do
			local p2 = ppos:move(dx,dy)
			if p2 then
				local slotEnt = lp.forceSpawnSlot(p2, slotType, lootplotTeam)
				if not slotEnt then
					umg.log.error("SPAWN: Couldnt spawn slot at pos: ", ppos)
				elseif transform then
					transform(slotEnt)
				end
			end
		end
	end
end

return worldgen