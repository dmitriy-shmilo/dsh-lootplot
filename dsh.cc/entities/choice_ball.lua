local lib = require("shared.lib")
local config = require("shared.config")
local worldgen = require("shared.worldgen")
local loc = localization.localize
local interp = localization.newInterpolator

if not config.choiceBall then return end

lp.defineTrigger("CHOOSE", "Choose")
local mallState = {
	choicesLeft = 2,
	cpos = nil,
	playerTeam = ""
}

local function resetArea(plot)
	plot:foreachSlot(function(ent)
		if ent:type() == "dsh.cc:choice_offer_slot" then
			local ppos = lp.getPos(ent)
			local item = lp.slotToItem(ent)
			if item then item:delete() end
			ent:delete()

			for y = -1, 1 do
				for x = -1, 1 do
					local fogPos = ppos:move(x, y)
					if fogPos then
						plot:setFogRevealed(fogPos, ent.lootplotTeam, false)
					end
				end
			end
		end
	end)

	if mallState.cpos then
		worldgen.clearFogInCircle(mallState.cpos, mallState.playerTeam, 6)
	end
end

local BUY_FREE_BUTTON = {
	action = function(ent, _clientId)
		local itemEnt = lp.slotToItem(ent)
		mallState.choicesLeft = mallState.choicesLeft - 1
		if server then
			local ppos = lp.getPos(ent)
			if ppos then
				local nullSlotType = server.entities["null_slot"]
				local slotEnt = lp.forceSpawnSlot(ppos, nullSlotType, ent.lootplotTeam)
				if slotEnt then
					slotEnt.doomCount = 1
				end
			end

			if mallState.choicesLeft <= 0 then
				local plot = ppos:getPlot()
				resetArea(plot)
			end
		else
			if itemEnt then
				scheduling.nextTick(function()
					if umg.exists(itemEnt) then
						lp.selectItem(itemEnt, true)
					end
				end)
			end
		end
	end,
	canDisplay = alwaysTrue,
	canClick = alwaysTrue,
	text = loc("Choose"),
	color = objects.Color(0.39,0.66,0.24),
}

local CHOICE_SLOT_DESC = interp("Choose an item. You have %{choicesLeft} choices left.")

lp.defineSlot("dsh.cc:choice_offer_slot", {
	name = loc("Offering Slot"),
	image = "cloud_slot",
	description = function(ent) return CHOICE_SLOT_DESC(mallState) end,
	remainingChoices = 2,
	baseMaxActivations = 100,
	dontPropagateTriggerToItem = true,
	triggers = { "CHOOSE" },
	isItemListenBlocked = true,

	itemLock = true,

	canPlayerAccessItemInSlot = function(slotEnt)
		return not slotEnt.itemLock
	end,

	onDraw = function(ent)
		if mallState.choicesLeft == 1 then
			ent.color = objects.Color.RED
		end
	end,
	actionButtons = {
		BUY_FREE_BUTTON
	},
	reduceChoices = function(ent)
		ent.remainingChoices = ent.remainingChoices - 1
		if ent.remainingChoices == 1 then
			ent.color = objects.Color.RED
		end
		if ent.remainingChoices <= 0 then
			local item = lp.slotToItem(ent)
			if item then item:delete() end
			ent:delete()
		end
	end,
	onActivate = function(ent)
		ent.remainingChoices = ent.remainingChoices - 1
		if ent.remainingChoices == 1 then
			ent.color = objects.Color.RED
		end
		if ent.remainingChoices <= 0 then
			local item = lp.slotToItem(ent)
			if item then item:delete() end
			ent:delete()
		end
	end
})

local function spawnChoices(cpos, team)
	local itemGenerator = lp.newItemGenerator({
		filter = function(item, weight)
			local etype = server.entities[item]
			local isUnlocked = lp.metaprogression.isEntityTypeUnlocked(etype)
			if not isUnlocked then return false end
			if lib.hasTag(item, lib.tags.FOOD) then return false end

			return etype.rarity == lp.rarities.COMMON 
			or etype.rarity == lp.rarities.UNCOMMON
			or etype.rarity == lp.rarities.RARE
		end
	})

	local entries = itemGenerator:getEntries()
	entries = objects.Array(entries)
		:map(function (itemTypeId)
			return server.entities[itemTypeId]
		end)
	entries:sortInPlace(function(a, b)
		return a.rarity.rarityWeight > b.rarity.rarityWeight
	end)
	local root = math.ceil(math.sqrt(#entries + 1))
	local cursor = cpos:move(-3, -4)
	local motions = {
		cursor.right,
		cursor.down,
		cursor.left,
		cursor.up
	}
	local motionIdx = 0
	local stepCount = #entries
	local extent = 6
	local itemIndex = 1

	while stepCount > 0 do
		if motionIdx == 0 or motionIdx == 2 then
			extent = extent + 1
		end
		local leg = math.min(extent, stepCount)
		stepCount = stepCount - leg
		while leg > 0 do 
			local slot = lp.forceSpawnSlot(cursor, server.entities["choice_offer_slot"], team)
			local item = lp.forceSpawnItem(cursor, entries[itemIndex], team)
			itemIndex = itemIndex + 1

			cursor = motions[motionIdx + 1](cursor)
			leg = leg - 1
		end
		motionIdx = (motionIdx + 1) % #motions
	end
end

local function spawnShops(cpos, team, difficulty)
	lp.forceSpawnSlot(cpos:move(-3, -1), server.entities["food_shop_slot"], team)
	lp.forceSpawnSlot(cpos:move(-3, 1), server.entities["food_shop_slot"], team)

	if difficulty < 2 then
		lp.forceSpawnSlot(cpos:move(-3, 0), server.entities["food_shop_slot"], team)
	end

	if difficulty < 1 then
		lp.forceSpawnSlot(cpos:move(-2, 1), server.entities["shop_slot"], team)
		lp.forceSpawnSlot(cpos:move(-2, -1), server.entities["shop_slot"], team)
	end
end

local function spawnSlots(cpos, team, difficulty)
	lp.forceSpawnSlot(cpos:move(3, -1), server.entities["slot"], team)
	if difficulty > 1 then
		lp.forceSpawnSlot(cpos:move(3, 1), server.entities["dirt_slot"], team)
	elseif difficulty == 1 then
		lp.forceSpawnSlot(cpos:move(3, 1), server.entities["gravel_slot"], team)
		lp.forceSpawnSlot(cpos:move(3, 0), server.entities["null_slot"], team)
	else
		lp.forceSpawnSlot(cpos:move(3, 1), server.entities["slot"], team)
		lp.forceSpawnSlot(cpos:move(3, 0), server.entities["null_slot"], team)
	end
end

local function spawnButtons(cpos, team)
	lp.forceSpawnSlot(cpos:move(-2, -3), server.entities["reroll_button_slot"], team)
	lp.forceSpawnSlot(cpos:move(0, -3), server.entities["pulse_button_slot"], team)
	lp.forceSpawnSlot(cpos:move(2, -3), server.entities["next_level_button_slot"], team)
end

local RICH_DESC = loc("Start with two items of your choice. Original idea by {lootplot:BORING_COLOR}sysem fan{/lootplot:BORING_COLOR}.")
lp.defineItem("dsh.cc:choice_ball", {
	name = loc("Choice Ball"),
	image = "choice_ball",
	canItemFloat = true,
	triggers = { "PULSE" },
	description = loc("Start with two items of your choice. Original idea by sysem fan."),
	rarity = lp.rarities.UNIQUE,
	onActivateOnce = function(ent)
		local ppos = lp.getPos(ent)
		local team = ent.lootplotTeam
		local _, dInfo = lp.getDifficulty()
		local difficulty = dInfo.difficulty

		mallState.cpos = ppos
		mallState.playerTeam = team

		lp.setMoney(ent, 10)
		lp.setAttribute("NUMBER_OF_ROUNDS", ent, 6)

		ent.description = RICH_DESC

		worldgen.spawnDoomClock(ent, 0, -2)
		worldgen.clearFogInCircle(ppos, team, 6)
		spawnChoices(ppos, team)
		spawnShops(ppos, team, difficulty)
		spawnSlots(ppos, team, difficulty)
		spawnButtons(ppos, team)
	end
})

lp.defineWinRecipient("dsh.cc:choice_ball")
lp.worldgen.STARTING_ITEMS:add("dsh.cc:choice_ball")