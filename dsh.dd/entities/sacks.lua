local config = require("shared.config")
local lib = require("shared.lib")
local etypes = require("shared.etypes")
local loc = localization.localize
local interp = localization.newInterpolator

local BIG_SACK_RARITY = lp.rarities.UNCOMMON
if config.rareSacks then
	BIG_SACK_RARITY = lp.rarities.RARE
end

local EPIC_SACK_RARITY = lp.rarities.UNCOMMON
if config.rareSacks then
	EPIC_SACK_RARITY = lp.rarities.RARE
end

local HORIZONTAL_SACK_SHAPE = lp.targets.UnionShape(
	lp.targets.HorizontalShape(1),
	lp.targets.ON_SHAPE
)

local VERTICAL_SACK_SHAPE = lp.targets.UnionShape(
	lp.targets.VerticalShape(1),
	lp.targets.ON_SHAPE
)

local BIG_SACK_SHAPE = lp.targets.UnionShape(
	lp.targets.KingShape(1),
	lp.targets.ON_SHAPE
)

local function canSpawnCloudSlot(selfEnt, ppos)
	local itemEnt = lp.posToItem(ppos)
	local slotEnt = lp.posToSlot(ppos)
	local slotOK = (not slotEnt)
	local itemOK = (not itemEnt) or (itemEnt == selfEnt)
	return slotOK and itemOK
end

local function trySpawnCloudWithItem(ppos, ent, gen, transform)
	if not ppos then
		return
	end
	local itemId = gen(ent)
	if not itemId then
		return
	end
	local itemEtype = server.entities[itemId]
	local success = lp.trySpawnSlot(ppos, server.entities.cloud_slot, ent.lootplotTeam)
	if success then
		local item = lp.forceSpawnItem(ppos, itemEtype, ent.lootplotTeam)
		if item and transform then
			transform(item, ppos)
		end
	end
end

local function defaultWeightAdjuster(etype)
	local r = etype.rarity
	if not r then return 0 end
	if r == lp.rarities.COMMON then
		return 3
	end
	if r == lp.rarities.UNCOMMON then
		return 2
	end
	if r == lp.rarities.RARE then
		return 1
	end
	if r == lp.rarities.EPIC then
		return 0.333
	end
	if r == lp.rarities.LEGENDARY then
		return 0.02
	end
	return 0
end

local function locRarity(txt, t)
	local args = {
		COMMON = lp.rarities.COMMON.displayString,
		UNCOMMON = lp.rarities.UNCOMMON.displayString,
		RARE = lp.rarities.RARE.displayString,
		EPIC = lp.rarities.EPIC.displayString,
		LEGENDARY = lp.rarities.LEGENDARY.displayString,
	}
	if t then
		for k,v in pairs(t) do
			args[k] = v
		end
	end
	return localization.localize(txt, args)
end

local function createItemGenerator(filter)
	local itemGenerator
	local function generateItem()
		itemGenerator = itemGenerator or lp.newItemGenerator({
			filter = function(item, weight)
				local etype = server.entities[item]
				local isUnlocked = lp.metaprogression.isEntityTypeUnlocked(etype)
				if not isUnlocked then return false end
				if etypes.getRedefinedItemId(item) then
					return false
				end
				return filter(item, etype)
			end,
			adjustWeights = function(item, currentWeight)
				local etype = server.entities[item]
				return defaultWeightAdjuster(etype)
			end
		})
		if itemGenerator:isEmpty() then
			return lp.FALLBACK_NULL_ITEM
		end
		return itemGenerator:query()
	end
	return generateItem
end

local function defineSack(id, definition)
	if config.edibleSacks then
		definition.foodItem = true
	end
	definition.activateInstantly = true
	definition.canItemFloat = true
	definition.lootplotTags = { lib.tags.TREASURE }
	definition.target = {
		type = "NO_SLOT",
		filter = function(selfEnt, ppos)
			local item = lp.posToItem(ppos)
			return (not item) or item == selfEnt
		end
	}
	definition.canActivate = function(selfEnt)
		return (not lp.itemToSlot(selfEnt))
	end
	definition.onPostActivate = function(ent)
		lp.destroy(ent)
	end
	etypes.redefineItem("lootplot.s0:" .. id, "dsh.dd:" .. id, definition)
end

-- ----------------
-- item definitions
-- ----------------

local uncommonSackGenerator = createItemGenerator(function(id, etype)
	return etype.rarity == lp.rarities.UNCOMMON
		and not etype.foodItem
end)
defineSack("sack_uncommon", {
	name = loc("Uncommon Sack"),
	image = "sack_uncommon",
	activateDescription = locRarity("Spawns %{UNCOMMON} items to choose from.\nMust be placed in the air!"),

	basePrice = 5,
	rarity = lp.rarities.COMMON,
	shape = HORIZONTAL_SACK_SHAPE,

	onActivate = function(selfEnt)
		local targs = lp.targets.getTargets(selfEnt) or {}
		for _,ppos in ipairs(targs) do
			if canSpawnCloudSlot(selfEnt, ppos) then
				trySpawnCloudWithItem(ppos, selfEnt, uncommonSackGenerator)
			end
		end
	end
})

local rareSackGenerator = createItemGenerator(function(id, etype)
	return etype.rarity == lp.rarities.RARE
		and not etype.foodItem
end)
defineSack("sack_rare", {
	name = loc("Rare Sack"),
	image = "sack_rare",
	activateDescription = locRarity("Spawns %{RARE} items to choose from.\nMust be placed in the air!"),

	basePrice = 11,
	unlockAfterWins = 2,
	rarity = lp.rarities.COMMON,
	shape = HORIZONTAL_SACK_SHAPE,

	onActivate = function(selfEnt)
		local targs = lp.targets.getTargets(selfEnt) or {}
		for _,ppos in ipairs(targs) do
			if canSpawnCloudSlot(selfEnt, ppos) then
				trySpawnCloudWithItem(ppos, selfEnt, rareSackGenerator)
			end
		end
	end
})

defineSack("sack_rare_big", {
	name = loc("BIG Rare Sack"),
	image = "sack_rare_big",
	activateDescription = locRarity("Spawns %{RARE} items to choose from.\nMust be placed in the air!"),

	basePrice = 13,
	unlockAfterWins = 2,
	rarity = BIG_SACK_RARITY,
	shape = BIG_SACK_SHAPE,

	onActivate = function(selfEnt)
		local targs = lp.targets.getTargets(selfEnt) or {}
		for _,ppos in ipairs(targs) do
			if canSpawnCloudSlot(selfEnt, ppos) then
				trySpawnCloudWithItem(ppos, selfEnt, rareSackGenerator)
			end
		end
	end
})


local foodSackGenerator = createItemGenerator(function(id, etype)
	return etype.rarity ~= lp.rarities.COMMON
		and etype.foodItem
end)
defineSack("sack_food", {
	name = loc("Food Sack"),
	image = "sack_food",
	activateDescription = locRarity("Spawns food items to choose from.\nMust be placed in the air!"),

	basePrice = 5,
	rarity = lp.rarities.COMMON,
	shape = VERTICAL_SACK_SHAPE,

	onActivate = function(selfEnt)
		local targs = lp.targets.getTargets(selfEnt) or {}
		for _,ppos in ipairs(targs) do
			if canSpawnCloudSlot(selfEnt, ppos) then
				trySpawnCloudWithItem(ppos, selfEnt, foodSackGenerator)
			end
		end
	end
})

defineSack("sack_food_big", {
	name = loc("BIG Food Sack"),
	image = "sack_food_big",
	activateDescription = locRarity("Spawns food items to choose from.\nMust be placed in the air!"),

	basePrice = 8,
	rarity = BIG_SACK_RARITY,
	shape = BIG_SACK_SHAPE,

	canActivate = function(selfEnt)
		return (not lp.itemToSlot(selfEnt))
	end,
	onActivate = function(selfEnt)
		local targs = lp.targets.getTargets(selfEnt) or {}
		for _,ppos in ipairs(targs) do
			if canSpawnCloudSlot(selfEnt, ppos) then
				trySpawnCloudWithItem(ppos, selfEnt, foodSackGenerator, transform)
			end
		end
	end,
	onPostActivate = function(ent)
		lp.destroy(ent)
	end,
})


local epicSackGenerator = createItemGenerator(function(id, etype)
	return etype.rarity == lp.rarities.EPIC
		and not etype.foodItem
end)
defineSack("sack_epic", {
	name = loc("Epic Sack"),
	image = "sack_epic",
	activateDescription = locRarity("Spawns %{EPIC} items to choose from.\nMust be placed in the air!"),

	basePrice = 16,
	rarity = EPIC_SACK_RARITY,
	shape = HORIZONTAL_SACK_SHAPE,

	canActivate = function(selfEnt)
		return (not lp.itemToSlot(selfEnt))
	end,
	onActivate = function(selfEnt)
		local targs = lp.targets.getTargets(selfEnt) or {}
		for _,ppos in ipairs(targs) do
			if canSpawnCloudSlot(selfEnt, ppos) then
				trySpawnCloudWithItem(ppos, selfEnt, epicSackGenerator, transform)
			end
		end
	end,
	onPostActivate = function(ent)
		lp.destroy(ent)
	end,
})


local darkSackGenerator = createItemGenerator(function(id, etype)
	if etype.rarity ~= lp.rarities.RARE
		and etype.rarity ~= lp.rarities.RARE then
		return false
	end

	if not lib.hasTag(etype, lib.tags.ROCKS)
		or not lib.hasTag(etype, lib.tags.DESTRUCTIVE) then
		return false
	end
	return etypes.getRedefinedItemId(id) == nil
end)
defineSack("sack_dark", {
	name = loc("Epic Sack"),
	image = "sack_dark",
	activateDescription = loc("Spawns destructive items to choose from.\nMust be placed in the air!"),

	basePrice = 10,
	rarity = lp.rarities.UNCOMMON,
	shape = VERTICAL_SACK_SHAPE,

	onActivate = function(selfEnt)
		local targs = lp.targets.getTargets(selfEnt) or {}
		for _,ppos in ipairs(targs) do
			if canSpawnCloudSlot(selfEnt, ppos) then
				trySpawnCloudWithItem(ppos, selfEnt, darkSackGenerator)
			end
		end
	end
})

local GRUB_MONEY_CAP = 20
local function grubTransform(item)
	item.grubMoneyCap = GRUB_MONEY_CAP
end
defineSack("sack_grubby", {
	name = loc("Grubby Sack"),
	image = "sack_grubby",
	activateDescription = loc("Spawns {lootplot:GRUB_COLOR_LIGHT}GRUB-%{n}{/lootplot:GRUB_COLOR_LIGHT} items to choose from.\nMust be placed in the air!", {
		n = 20
	}),
	grubMoneyCap = GRUB_MONEY_CAP,
	basePrice = 2,
	rarity = lp.rarities.UNCOMMON,
	shape = HORIZONTAL_SACK_SHAPE,

	onActivate = function(selfEnt)
		local targs = lp.targets.getTargets(selfEnt) or {}
		for _,ppos in ipairs(targs) do
			if canSpawnCloudSlot(selfEnt, ppos) then
				trySpawnCloudWithItem(ppos, selfEnt, rareSackGenerator, grubTransform)
			end
		end
	end
})