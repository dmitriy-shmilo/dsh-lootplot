local _ = require("shared.reroll")

server.on("dsh.qq:toggleRerollSlotLock", function(_sender, isLock)
	print("toggleRerollSlotLock", isLock)
	local run = lp.singleplayer.getRun()
	if not run then return end
	local plot = run:getPlot()
	if not plot then return end
	plot:foreachSlot(function(ent, ppos)
		if ent:type() == "lootplot.s0:reroll_slot" then
			ent.rerollLock = isLock
			sync.syncComponent(ent, "rerollLock")
		end
	end)
end)