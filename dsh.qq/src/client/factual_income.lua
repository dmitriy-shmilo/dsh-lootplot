-- lootplot.targets\shared\util.lua
local function checkFilter(targeterEnt, compTable, ppos, val)
	if compTable.filter then
		return compTable.filter(targeterEnt, ppos, val)
	end
	return true
end

-- lootplot.targets\shared\util.lua
local function canTarget(targeterEnt, ppos)
	local target = targeterEnt.target
	local targetType = target.type
	local ok,val = lp.tryConvert(ppos, targetType)
	if target.type then
		if ok then
			return checkFilter(targeterEnt, target, ppos, val)
		end
		return false
	else
		return checkFilter(targeterEnt, target, ppos, nil)
	end
end

local factualIncomeSpecials = {
	["lootplot.s0:golden_dagger"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		return #targets * 2
	end,
	["lootplot.s0:golden_knuckles"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		return #targets
	end,
	["lootplot.s0:furnace"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		return #targets
	end,
	["lootplot.s0:tooth_necklace"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		return #targets * 4
	end,
	["lootplot.s0:golden_chestplate"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		return #targets
	end,
	["lootplot.s0:bomb"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		return #targets
	end,
	["lootplot.s0:odins_axe"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		return #targets * 0.5
	end,
	["lootplot.s0:golden_curse_helmet"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		return #targets
	end,
	["lootplot.s0:interest_slot"] = function(ent)
		local money = lp.getMoney(ent) or 0
		local interest = math.floor(money / 10)
		return math.min(interest, 3)
	end,
	["lootplot.s0:golden_magnet"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		if not targets or #targets == 0 then return 0 end
		local cheapest = targets[1].price or 0
		for i = 2, #targets do
			if targets[i].price < cheapest then
				cheapest = targets[i].price
			end
		end
		return cheapest
	end,
	["lootplot.s0:golden_scissors"] = function(ent)
		local targets = lp.targets.getConvertedTargets(ent)
		return #targets * 2
	end,
	["lootplot.s0:coins_and_emerald"] = function(ent)
		return -1
	end,
}

return function()
	umg.answer("dsh.qq:factualIncome", function(ent)
		local special = factualIncomeSpecials[ent:type()]
		if not special then return 0 end
		return special(ent) or 0
	end)
end