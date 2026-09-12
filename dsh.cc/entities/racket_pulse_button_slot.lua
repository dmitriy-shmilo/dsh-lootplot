local lib = require("shared.lib")
local config = require("shared.config")
local loc = localization.localize
local interp = localization.newInterpolator

if not config.tennisBall then return end

local function pulseFilter(ppos, ent)
	local plot = ppos:getPlot()
	local team = ent.lootplotTeam
	if team then
		if plot:isFogRevealed(ppos, team) then
			local slotEnt = lp.posToSlot(ppos)
			local itemEnt = lp.posToItem(ppos)
			if slotEnt and (lp.hasTrigger(slotEnt, "PULSE")) then
				return true
			end
			if itemEnt and lp.hasTrigger(itemEnt, "PULSE") then
				return true
			end
		end
	else
		return false
	end
end

local function resetPlot(ppos)
	local plot = ppos:getPlot()
	lp.queue(ppos, function()
		plot:foreachLayerEntry(function(e, _ppos, layer)
			lp.resetEntity(e)
		end)
	end)
end


local function isInfinity(x)
	local isNan = x ~= x
	local isInf = (x == math.huge)
	return isNan or isInf
end


local function hasRequiredPoints(ent)
	local requiredPoints = lp.getRequiredPoints(ent)
	local points = lp.getPoints(ent)
	if (points >= requiredPoints) or isInfinity(points) then
		return true
	end
	return false
end


local function hasLost(e)
	local numberOfRounds = lp.getNumberOfRounds(e)
	local round = lp.getRound(e)

	if (round > numberOfRounds) and (not hasRequiredPoints(e)) then
		return true
	end
end


local function deleteAllButtonSlots(plot)
	plot:foreachSlot(function(ent, ppos)
		if ent.buttonSlot then
			ent:delete()
		end
	end)
end


local function loseGame(ent, plot)
	lp.loseGame(plot, ent.lootplotTeam)
	deleteAllButtonSlots(plot)
end


local function buttonOnDraw(ent)
	if not lp.canActivateEntity(ent) then
		ent.opacity = 0.3
	else
		ent.opacity = 1
	end
end

local function getMoneyPerRound()
	local _, dInfo = lp.getDifficulty()
	local difficulty = dInfo.difficulty

	if difficulty < 1 then
		return 10
	end

	if difficulty == 1 then
		return 8
	end

	return 6
end

local INCOME = getMoneyPerRound()
local AFTER_ACTIVATION = interp("(Afterwards earns {lootplot:MONEY_COLOR}$%{money}{/lootplot:MONEY_COLOR} and resets {c r=0.6 g=0.576 b=1}credit score{/c} to %{score})")
lp.defineSlot("dsh.cc:racket_pulse_button_slot", {
	image = "dsh_racket_pulse_button_slot",

	name = loc("Racket Pulse Button"),
	description = loc("Click to {wavy}{lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR}{/wavy} all items/slots, and go to the next round! Will reset your credit score."),
	activateDescription = function(ent)
		return AFTER_ACTIVATION({
			money = INCOME,
			score = lp.getAttribute("MIN_CREDIT_SCORE", ent)
		})
	end,

	onDraw = buttonOnDraw,

	baseMaxActivations = 3,

	triggers = {},
	buttonSlot = true,
	rarity = lp.rarities.UNIQUE,

	canActivate = function(ent)
		local round = lp.getRound(ent)
		local numOfRounds = lp.getNumberOfRounds(ent)
		if round <= numOfRounds then
			return true
		end
		return false
	end,

	onActivate = function(ent)
		local ppos=lp.getPos(ent)
		if ppos then
			local plot = ppos:getPlot()
			resetPlot(ppos)

			lp.queueWithEntity(ent, function(e)
				lp.addMoney(e, INCOME)
				lp.setPointsMult(e, 1)
				lp.setPointsBonus(e, 0)

				local round = lp.getAttribute("ROUND", e)
				local newRound = round + 1
				lp.setRound(e, newRound)

				if hasLost(e) then
					loseGame(e, plot)
				end


				lp.setAttribute("CREDIT_SCORE", e, lp.getAttribute("MIN_CREDIT_SCORE", e))
			end)

			lp.Bufferer()
				:all(plot)
				:to("SLOT_OR_ITEM")
				:filter(pulseFilter)
				:execute(function(ppos1, slotEnt)
					lp.resetCombo(slotEnt)
					lp.tryTriggerSlotThenItem("PULSE", ppos1)
				end)

			resetPlot(ppos)
		end
	end,
})

