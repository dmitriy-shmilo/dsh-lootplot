local lib = require("shared.lib")
local config = require("shared.config")
local worldgen = require("shared.worldgen")
local reroll = require("shared.reroll")
local loc = localization.localize
local interp = localization.newInterpolator

if not config.tennisBall then return end

local DEFAULT_CREDIT_SCORE = 0.1

lp.defineAttribute("CREDIT_SCORE", 0.1)
lp.defineAttribute("MIN_CREDIT_SCORE", 0.1)
lp.defineAttribute("MAX_CREDIT_SCORE", 1.0)

local function spawnSlots(cpos, team, difficulty)
	worldgen.forceSpawnSlotsAround(cpos:move(4, 1), server.entities["slot"], 3, 3, team)
end

local function spawnButtons(cpos, team, difficulty)
	lp.forceSpawnSlot(cpos:move(-1, -2), server.entities["reroll_button_slot"], team)
	lp.forceSpawnSlot(cpos:move(0, -2), server.entities["racket_pulse_button_slot"], team)
	lp.forceSpawnSlot(cpos:move(1, -2), server.entities["next_level_button_slot"], team)
end

local function spawnShops(cpos, team, difficulty)
	-- if difficulty == 2 then
	-- 	worldgen.forceSpawnSlotsAround(cpos:move(-4, 0), server.entities["racket_shop_slot"], 1, 1, team)
	-- 	worldgen.forceSpawnSlotsAround(cpos:move(-3, 2), server.entities["racket_food_shop_slot"], 1, 2, team)
	-- elseif difficulty == 1 then
	-- 	worldgen.forceSpawnSlotsAround(cpos:move(-4, 0), server.entities["racket_shop_slot"], 2, 1, team)
	-- 	worldgen.forceSpawnSlotsAround(cpos:move(-3, 2), server.entities["racket_food_shop_slot"], 1, 2, team)
	-- else
		worldgen.forceSpawnSlotsAround(cpos:move(-4, 0), server.entities["racket_shop_slot"], 3, 1, team)
		worldgen.forceSpawnSlotsAround(cpos:move(-3, 2), server.entities["racket_food_shop_slot"], 1, 2, team)
	-- end
end

local function spawnCurses(cpos, team, difficulty)
	if difficulty < 1 then
		lp.forceSpawnItem(cpos:move(0, 1), server.entities["dsh.cc:racket_injunction"], team)
	elseif difficulty == 1 then
		lp.forceSpawnItem(cpos:move(1, 1), server.entities["dsh.cc:racket_injunction"], team)
		lp.forceSpawnItem(cpos:move(-1, 1), server.entities["dsh.cc:mult_racket_injunction"], team)
	else
		lp.forceSpawnItem(cpos:move(1, 1), server.entities["dsh.cc:bonus_racket_injunction"], team)
		lp.forceSpawnItem(cpos:move(0, 2), server.entities["dsh.cc:racket_injunction"], team)
		lp.forceSpawnItem(cpos:move(-1, 1), server.entities["dsh.cc:mult_racket_injunction"], team)
	end
end

local function adjustConditions(starter, difficulty)
	starter.activationCount = 0
	if difficulty >= 2 then
		lp.setAttribute("MIN_CREDIT_SCORE", starter, 0.0)
		lp.setAttribute("CREDIT_SCORE", starter, 0.0)
		lp.setTriggers(starter, { "LEVEL_UP", "UNLOCK" })
		starter.baseMoneyGenerated = 20
	elseif difficulty == 1 then
		lp.setAttribute("MIN_CREDIT_SCORE", starter, 0.1)
		lp.setAttribute("CREDIT_SCORE", starter, 0.1)
		lp.setTriggers(starter, { "ROTATE", "LEVEL_UP" })
		starter.baseMoneyGenerated = 30
	else
		lp.setAttribute("MIN_CREDIT_SCORE", starter, 0.2)
		lp.setAttribute("CREDIT_SCORE", starter, 0.2)
		lp.setTriggers(starter, { "ROTATE", "UNLOCK" })
		starter.baseMoneyGenerated = 40
	end
end

local RICH_DESC = loc("Purchase items to increase your {c r=0.6 g=0.576 b=1}credit score{/c}. Original idea by {lootplot:BORING_COLOR}ZeroFractal{/lootplot:BORING_COLOR}.")
local MULT_DESC = interp("Reduces {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} by %{mult} (half of your {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR}).")
lp.defineItem("dsh.cc:racket_ball", {
	name = loc("Tennis Ball"),
	image = "dsh_tennis_ball",
	canItemFloat = true,
	triggers = { "PULSE" },
	activateDescription = function(ent)
		local mult = math.floor((lp.getMoney(ent) or 0) / 2)
		if mult <= 0 then return "" end
		return MULT_DESC({
			mult = mult
		})
	end,
	description = loc("Purchase items to increase your credit score. Original idea by ZeroFractal."),
	rarity = lp.rarities.UNIQUE,
	baseMaxActivations = 4,
	onActivate = function(ent)
		local mult = math.floor((lp.getMoney(ent) or 0) / 2)
		lp.addPointsMult(ent, mult)
	end,
	onActivateOnce = function(ent)
		local ppos = lp.getPos(ent)
		local team = ent.lootplotTeam
		local _, dInfo = lp.getDifficulty()
		local difficulty = dInfo.difficulty
		ent.description = RICH_DESC

		adjustConditions(ent, difficulty)

		lp.setMoney(ent, 10)
		lp.setAttribute("NUMBER_OF_ROUNDS", ent, 6)

		spawnSlots(ppos, team, difficulty)
		spawnShops(ppos, team, difficulty)
		spawnButtons(ppos, team, difficulty)
		spawnCurses(ppos, team, difficulty)

		worldgen.spawnDoomClock(ent, 0, -4)
		worldgen.clearFogInCircle(ppos, team, 6)
	end
})

lp.defineWinRecipient("dsh.cc:racket_ball")
lp.worldgen.STARTING_ITEMS:add("dsh.cc:racket_ball")