local lib = require("shared.lib")
local config = require("shared.config")

if config.sturdyLocks or config.lessSpace then
	lib.hooks.addBeforeCallback(lp.unlocks, "forceSpawnLockedSlot", function(ppos, slot, item)
		local rnd = lp.SEED:randomMisc()
		if config.sturdyLocks and rnd <= 0.25 then
			local doubleLock = lp.forceSpawnSlot(ppos, server.entities["double_locked_slot"])
			doubleLock.targetSlot = slot
			doubleLock.targetItem = item

			return false, doubleLock
		end

		if config.lessSpace and rnd > 0.25 and rnd <= 0.33 then
			local stoneSlot = lp.forceSpawnSlot(ppos, server.entities["stone_slot"])
			for y = -1, 1 do
				for x = -1, 1 do
					if x ~= 0 and y ~= 0 then
						local rnd = lp.SEED:randomMisc()
						if rnd <= 0.33 then
							local ppos = ppos:move(x, y)
							if ppos then
								lp.trySpawnSlot(ppos, server.entities["stone_slot"])
							end
						end
					end
				end
			end
			return false, stoneSlot
		end
		return true
	end)
end