return function()
	umg.answer("dsh.qq:factualTotalActivations", function(ent)
		if ent.foodItem then
			return 0, 1
		end
		return ent.maxActivations or 0, -1
	end)

	umg.answer("dsh.qq:factualRemainingActivations", function(ent)
		if ent.foodItem then
			return 0, 1
		end
		local total = ent.maxActivations or 0
		local used = ent.activationCount or 0
		return math.max(0, total - used), -1
	end)
end