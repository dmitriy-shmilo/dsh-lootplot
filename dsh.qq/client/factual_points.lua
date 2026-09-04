local factualPointSpecials = {
	["lootplot.s0:dagger"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		return #targets * 90
	end
}

return function()
	umg.answer("dsh.qq:factualPoints", function(ent)
		local special = factualPointSpecials[ent:type()]
		if not special then return 0 end
		return special(ent) or 0
	end)
end