local config = require("shared.config")
local lib = require("shared.lib")

if not config.tennisBall then return end

local function hijackPointsGeneration()
	local addPointsRaw = lp.addPointsRaw
	lp.addPointsRaw = function (fromEnt, x)
		local cscore = lp.getAttribute("CREDIT_SCORE", fromEnt)
		addPointsRaw(fromEnt, x * cscore)
	end
end

local function hijackBonusGeneration()
	local addPointsBonus = lp.addPointsBonus
	lp.addPointsBonus = function(fromEnt, x)
		local money = lp.getMoney(fromEnt)
		if money <= 0 then return end
		local bonus = lp.getPointsBonus(fromEnt)
		local allowedMod = money - math.abs(bonus)
		if allowedMod <= 0 then return end
		if allowedMod >= x then
			addPointsBonus(fromEnt, x)
			return
		end
		addPointsBonus(fromEnt, allowedMod)
	end

	local setPointsBonus = lp.setPointsBonus
	lp.setPointsBonus = function(fromEnt, x)
		local money = lp.getMoney(fromEnt)
		if money <= 0 then return end
		local mod = math.min(math.abs(x), money)
		if x < 0 then
			setPointsBonus(fromEnt, -mod)
		else
			setPointsBonus(fromEnt, mod)
		end
	end
end

local function hijackMultGeneration()
	local addPointsMult = lp.addPointsMult
	lp.addPointsMult = function(fromEnt, x)
		local money = lp.getMoney(fromEnt)
		if money <= 0 then return end
		local mult = lp.getPointsMult(fromEnt)
		local allowedMod = money - math.abs(mult)
		if allowedMod <= 0 then return end
		if allowedMod >= x then
			addPointsMult(fromEnt, x)
			return
		end
		addPointsMult(fromEnt, allowedMod)
	end

	local setPointsMult = lp.setPointsMult
	lp.setPointsMult = function(fromEnt, x)
		local money = lp.getMoney(fromEnt)
		if money <= 0 then return end
		local mod = math.min(math.abs(x), money)
		if x < 0 then
			setPointsMult(fromEnt, -mod)
		else
			setPointsMult(fromEnt, mod)
		end
	end
end

local function capBonus(ent, value)
	print("capBonus", value)
	if value <= 0 then
		print("capBonus value < 0")
		lp.setPointsBonus(ent, 0)
		return
	end

	local bonus = lp.getPointsBonus(ent)
	if value < math.abs(bonus) then
		if bonus < 0 then
			print("bonus < 0, set ", -value)
			lp.setPointsBonus(ent, -value)
		else
			print("bonus > 0, set ", value)
			lp.setPointsBonus(ent, value)
		end
	end
end

local function capMult(ent, value)
	print("capMult", value)
	if value <= 0 then
		print("capMult value < 0")
		lp.setPointsMult(ent, 0)
		return
	end

	local mult = lp.getPointsMult(ent)
	if value < math.abs(mult) then
		if mult < 0 then
			print("mult < 0, set ", -value)
			lp.setPointsMult(ent, -value)
		else
			print("mult > 0, set ", value)
			lp.setPointsMult(ent, value)
		end
	end
end

local function hijackMoneyBonusGeneration()
	local setMoney = lp.setMoney
	lib.hooks.addAfterCallback(lp, "setMoney", function(ent, x)
		capBonus(ent, x)
	end)
	lib.hooks.addAfterCallback(lp, "addMoney", function(ent, x)
		capBonus(ent, lp.getMoney(ent))
	end)
	lib.hooks.addAfterCallback(lp, "subtractMoney", function(ent, x)
		capBonus(ent, lp.getMoney(ent))
	end)
end

local function hijackMoneyMultGeneration()
	local setMoney = lp.setMoney
	lib.hooks.addAfterCallback(lp, "setMoney", function(ent, x)
		capMult(ent, x)
	end)
	lib.hooks.addAfterCallback(lp, "addMoney", function(ent, x)
		capMult(ent, lp.getMoney(ent))
	end)
	lib.hooks.addAfterCallback(lp, "subtractMoney", function(ent, x)
		capMult(ent, lp.getMoney(ent))
	end)
end

local function forceSpawnRacketSlots(ppos, etype, team)
	local typename = etype:getTypename()
	if typename == "lootplot.s0:shop_slot" then
		local slot = lp.forceSpawnSlot(ppos, server.entities["dsh.cc:racket_shop_slot"], team)
		return false, slot
	end

	if typename == "lootplot.s0:food_shop_slot" then
		local slot = lp.forceSpawnSlot(ppos, server.entities["dsh.cc:racket_food_shop_slot"], team)
		return false, slot
	end

	if typename == "lootplot.s0:pulse_button_slot" then
		local slot = lp.forceSpawnSlot(ppos, server.entities["dsh.cc:racket_pulse_button_slot"], team)
		return false, slot
	end
	return true
end

local function hijackAttributes(_, etypeOrString, _)
	local typename = etypeOrString
	if type(etypeOrString) == "table" then
		typename = etypeOrString:getTypename()
	end

	if typename == "dsh.cc:racket_injunction" then
		hijackPointsGeneration()
		return
	end

	if typename == "dsh.cc:bonus_racket_injunction" then
		hijackBonusGeneration()
		hijackMoneyBonusGeneration()
		return
	end

	if typename == "dsh.cc:mult_racket_injunction" then
		hijackMultGeneration()
		hijackMoneyMultGeneration()
		return
	end
end

local function checkExistingPlot()
	local run = lp.singleplayer.getRun()
	local plot = run:getPlot()
	plot:foreachItem(function(item)
		hijackAttributes(nil, item:type())
	end)
end

umg.on("dsh.cc:runInitialized", function(item, difficulty)
	if item == "dsh.cc:racket_ball" then
		lib.hooks.addBeforeCallback(lp, "forceSpawnSlot", forceSpawnRacketSlots)
		lib.hooks.addAfterCallback(lp, "forceSpawnItem", hijackAttributes)
		checkExistingPlot()
	end
end)