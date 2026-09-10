local lib = require("shared.lib")
local config = require("shared.config")
local worldgen = require("shared.worldgen")
local reroll = require("shared.reroll")
local loc = localization.localize

if not config.mallBall then return end

local function spawnWalls(cpos, team, difficulty)
	for y = -3, 3 do
		for x = -3, 3 do
			if x == -3 or y == -3 or x == 3 or y == 3 then
				local ppos = cpos:move(x, y)
				if ppos then
					if lp.SEED:randomWorldGen() > difficulty / 2 then
						lp.forceSpawnSlot(ppos, server.entities["auto_stone_slot"], team)
					else
						lp.forceSpawnSlot(ppos, server.entities["stone_slot"], team)
					end
				end
			end
		end
	end
end

local function spawnShops(cpos, team, difficulty)
	for y = -2, 2 do
		for x = -2, 2 do
			if x ~= 0 or y ~= 0 then
				local ppos = cpos:move(x, y)
				if ppos then
					local shop
					if math.abs(x) == math.abs(y) and math.abs(x) == 2 then
						shop = lp.forceSpawnSlot(ppos, server.entities["food_shop_slot"], team)
					else
						shop = lp.forceSpawnSlot(ppos, server.entities["shop_slot"], team)
					end
					lp.removeTrigger(shop, "PULSE")
				end
			end
		end
	end
end

local function spawnBottomRow(cpos, team, difficulty)
	lp.forceSpawnSlot(cpos:move(-3, 4), server.entities["pulse_button_slot"], team)
	lp.forceSpawnSlot(cpos:move(-2, 4), server.entities["slot"], team)
	if difficulty >= 2 then
		lp.forceSpawnSlot(cpos:move(-1, 4), server.entities["dirt_slot"], team)
		lp.forceSpawnSlot(cpos:move(1, 4), server.entities["dirt_slot"], team)
	elseif difficulty == 1 then
		lp.forceSpawnSlot(cpos:move(-1, 4), server.entities["gravel_slot"], team)
		local nullSlot = lp.forceSpawnSlot(cpos:move(0, 4), server.entities["null_slot"], team)
		nullSlot.doomCount = 10
		lp.forceSpawnSlot(cpos:move(1, 4), server.entities["gravel_slot"], team)
	else
		lp.forceSpawnSlot(cpos:move(-1, 4), server.entities["slot"], team)
		lp.forceSpawnSlot(cpos:move(0, 4), server.entities["null_slot"], team)
		lp.forceSpawnSlot(cpos:move(1, 4), server.entities["slot"], team)
	end
	lp.forceSpawnSlot(cpos:move(2, 4), server.entities["slot"], team)
	lp.forceSpawnSlot(cpos:move(3, 4), server.entities["next_level_button_slot"], team)
end

local COST_TEXT = localization.newInterpolator("{lootplot:MONEY_COLOR}{wavy amp=0.5 k=0.5}{outline}Cost: $%{cost}")
local CANT_AFFORD_TEXT = localization.newInterpolator("{c r=0.87 g=0 b=0}{wavy amp=0.5 k=0.5}{outline}Cost: $%{cost}")
local FREE_TEXT = localization.newInterpolator("{c r=0.5 g=1 b=0.4}{wavy amp=0.5 k=0.5}{outline}Get: $%{cost}")
lp.defineSlot("dsh.cc:mall_reroll_button", {
	name = loc("Mall Reroll Button"),
	description = loc("Click to trigger {wavy}{lootplot:TRIGGER_COLOR}REROLL{/lootplot:TRIGGER_COLOR} for the whole plot!"),

	baseMoneyGenerated = -5,

	rarity = lp.rarities.UNIQUE,

	onDraw = function(ent, x, y, rot, sx,sy)
		local cost = -(ent.moneyGenerated or 0)
		local moneh = lp.getMoney(ent) or 0
		local costTxt
		if cost > 0 then
			if moneh >= cost then
				costTxt = COST_TEXT({
					cost = cost
				})
			else
				costTxt = CANT_AFFORD_TEXT({
					cost = cost
				})
			end
		else
			costTxt = FREE_TEXT({
				cost = -cost
			})
		end
		local font = love.graphics.getFont()
		local limit = 0xffff
		text.printRichCentered(costTxt, font, x, y - 16, limit, "left", rot, sx,sy)
	end,

	lootplotProperties = {
		modifiers = {
			moneyGenerated = function(ent)
				return -5 * (ent.activationCount or 0)
			end
		}
	},

	image = "reroll_button_up",
	activateAnimation = {
		activate = "reroll_button_hold",
		idle = "reroll_button_up",
		duration = 0.1
	},
	baseMaxActivations = 100,
	triggers = {},
	buttonSlot = true,
	onActivate = function(ent)
		local ppos = lp.getPos(ent)
		if ppos then
			reroll.rerollPlot(ppos:getPlot())
		end
	end
})

local RICH_DESC = loc("Start with a huge shop and expensive rerolls. Original idea by {lootplot:BORING_COLOR}Voltgojjj{/lootplot:BORING_COLOR}.")
lp.defineItem("dsh.cc:mall_ball", {
	name = loc("Mall Ball"),
	image = "mall_ball",
	canItemFloat = true,
	triggers = { "PULSE" },
	description = loc("Start with a huge shop and expensive rerolls. Original idea by Voltgojjj."),
	rarity = lp.rarities.UNIQUE,
	onActivateOnce = function(ent)
		local ppos = lp.getPos(ent)
		local team = ent.lootplotTeam
		local _, dInfo = lp.getDifficulty()
		local difficulty = dInfo.difficulty

		lp.setMoney(ent, 10)
		lp.setAttribute("NUMBER_OF_ROUNDS", ent, 6)
		ent.description = RICH_DESC
		spawnWalls(ppos, team, difficulty)
		spawnShops(ppos, team, difficulty)
		spawnBottomRow(ppos, team, difficulty)

		worldgen.spawnDoomClock(ent, 0, -4)
		worldgen.clearFogInCircle(ppos, team, 6)

		local newPos = ppos:move(0, 4)
		ppos:clear(ent.layer)
		newPos:set(ent)
		lp.forceSpawnSlot(ppos, server.entities["mall_reroll_button"], team)
	end
})

lp.defineWinRecipient("dsh.cc:mall_ball")
lp.worldgen.STARTING_ITEMS:add("dsh.cc:mall_ball")