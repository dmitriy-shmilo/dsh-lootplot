local lib = require("shared.lib")
local config = require("shared.config")
local loc = localization.localize
local interp = localization.newInterpolator

if not config.tennisBall then return end

local drawRarityParticles
if client then
	local RARITY_PSYS
	local function tryLoadPsys()
		if RARITY_PSYS then
			return
		end

		RARITY_PSYS = love.graphics.newParticleSystem(client.atlas:getTexture())
		RARITY_PSYS:setQuads({
			client.assets.images.ball_1,
			client.assets.images.ball_1,
			client.assets.images.ball_1,
			client.assets.images.ball_2,
			client.assets.images.ball_2,
			client.assets.images.ball_3,
			client.assets.images.ball_4,
		})

		RARITY_PSYS:setEmissionRate(16)
		RARITY_PSYS:setEmissionArea("normal", 3, 1)
		RARITY_PSYS:setSpeed(10,11)
		RARITY_PSYS:setParticleLifetime(1.6,1.8)
		RARITY_PSYS:setDirection(-math.pi/2)
	end

	umg.on("@update", function(dt)
		tryLoadPsys()
		RARITY_PSYS:update(dt)
	end)

	local SIGNIFICANT_RARITIES = {
		[lp.rarities.EPIC] = true,
		[lp.rarities.LEGENDARY] = true
	}

	function drawRarityParticles(ent, x, y)
		local itemEnt = lp.slotToItem(ent)

		if itemEnt and itemEnt.rarity and RARITY_PSYS then
			local r = itemEnt.rarity
			if SIGNIFICANT_RARITIES[r] then
				local color = r.color
				love.graphics.push("all")
				love.graphics.setColor(color)
				love.graphics.draw(RARITY_PSYS, x, y)
				love.graphics.pop()
			end
		end
	end
end

local function setItemLock(ent, bool)
	ent.itemLock = bool
	sync.syncComponent(ent, "itemLock")
end

local function setRerollLock(ent, bool)
	ent.rerollLock = bool
	sync.syncComponent(ent, "rerollLock")
end

local LOCK_TEXT = loc("Lock")
local UNLOCK_TEXT = loc("Unlock")

local LOCK_REROLL_BUTTON = {
	action = function(ent, clientId)
		if server then
			setRerollLock(ent, not ent.rerollLock)
		end
	end,
	canDisplay = function(ent, clientId)
		return lp.slotToItem(ent)
	end,
	canClick = function(ent, clientId)
		return lp.slotToItem(ent)
	end,
	text = function(ent)
		if ent.rerollLock then
			return UNLOCK_TEXT
		else
			return LOCK_TEXT
		end
	end,
	color = objects.Color(0.7,0.7,0.7),
}


local BUY_TEXT = interp("BUY ($%{price})")

local function buyClient(slotEnt)
	lp.deselectItem()
	local itemEnt = lp.slotToItem(slotEnt)
	if itemEnt then
		lp.selectItem(itemEnt, true)
	end
end

local function shopButtonBuyItem(slotEnt)
	if server then
		setRerollLock(slotEnt, false)
		local itemEnt = lp.slotToItem(slotEnt)
		if itemEnt then
			lp.subtractMoney(slotEnt, itemEnt.price)
			lp.tryTriggerEntity("BUY", itemEnt)
			lp.setAttribute("CREDIT_SCORE", slotEnt, lp.getAttribute("CREDIT_SCORE", slotEnt) + 0.1)
			setItemLock(slotEnt, false)
		end
	elseif client then
		buyClient(slotEnt)
	end
end

local function canDisplayShopButton(ent, clientId)
	return ent.itemLock
end

local function canClickShopButton(ent, clientId)
	local itemEnt = lp.slotToItem(ent)
	if itemEnt and ent.itemLock then
		local money = lp.getMoney(itemEnt) or 0
		if money >= itemEnt.price then
			return true
		end
		if itemEnt.price <= 0 then
			return true
		end
	end
end

local function getShopButtonText(ent)
	local itemEnt = lp.slotToItem(ent)
	if not itemEnt then
		return ""
	end
	return BUY_TEXT(itemEnt)
end

local SHOP_BUTTON = {
	action = shopButtonBuyItem,
	canDisplay = canDisplayShopButton,
	canClick = canClickShopButton,
	text = getShopButtonText,
	color = objects.Color(0.39,0.66,0.24),
}

local TEXT_MAX_WIDTH = 200
local function printCenterWithOutline(text, x, y, rot, sx, sy, oy, kx, ky)
	local r, g, b, a = love.graphics.getColor()
	local ox = TEXT_MAX_WIDTH / 2

	love.graphics.setColor(0, 0, 0, a)
	for outY = -1, 1 do
		for outX = -1, 1 do
			if not (outX == 0 and outY == 0) then
				love.graphics.printf(text, x + outX * sx, y + outY * sy, TEXT_MAX_WIDTH, "center", rot, sx, sy, ox, oy, kx, ky)
			end
		end
	end

	love.graphics.setColor(r, g, b, a)
	love.graphics.printf(text, x, y, TEXT_MAX_WIDTH, "center", rot, sx, sy, ox, oy, kx, ky)
end


local PRICE_TEXT = interp("$%{price}")
local NEGATIVE_PRICE_COLOR = objects.Color.fromByteRGBA(3, 252, 111)
local PRICE_COLOR = objects.Color.fromByteRGBA(252, 211, 3)
local CANT_AFFORD_COLOR = objects.Color.fromByteRGBA(222, 0, 0)

local function drawItemPrice(slotEnt, itemEnt)
	if slotEnt.itemLock and itemEnt.price then
		local money = lp.getMoney(slotEnt) or 0

		if itemEnt.price <= 0 then
			love.graphics.setColor(NEGATIVE_PRICE_COLOR)
		elseif money >= itemEnt.price then
			love.graphics.setColor(PRICE_COLOR)
		else
			love.graphics.setColor(CANT_AFFORD_COLOR)
		end
		printCenterWithOutline(PRICE_TEXT(itemEnt), itemEnt.x, itemEnt.y, 0, 0.75, 0.75, 20, 0, 0)
	end
end

local function createItemGenerator(filter, weightAdjuster)
	local itemGenerator
	local function generateItem()
		itemGenerator = itemGenerator or lp.newItemGenerator({
			filter = function(item, weight)
				local etype = server.entities[item]
				local isUnlocked = lp.metaprogression.isEntityTypeUnlocked(etype)
				if not isUnlocked then return false end
				return filter(item, etype)
			end,
			adjustWeights = function(item, currentWeight)
				local etype = server.entities[item]
				return weightAdjuster(etype)
			end
		})
		if itemGenerator:isEmpty() then
			return lp.FALLBACK_NULL_ITEM
		end
		return itemGenerator:query()
	end
	return generateItem
end

local function shopWeightAdjuster(etype)
	local r = etype.rarity
	if not r then return 0 end
	if r == lp.rarities.COMMON then
		return 10
	end
	if r == lp.rarities.UNCOMMON then
		return 1
	end
	if r == lp.rarities.RARE then
		return 0.03
	end
	if r == lp.rarities.EPIC then
		return 0.02
	end
	return 0
end

local function shopItemFilter(etype)
	if lib.hasTag(etype, lib.tags.FOOD) then
		return false
	end
	return true
end

local shopItemGenerator = createItemGenerator(shopItemFilter, shopWeightAdjuster)
lp.defineSlot("dsh.cc:racket_shop_slot", {
	name = loc("Racket Shop"),
	activateDescription = loc("Spawns items to buy. Each bought item raises your {c r=0.6 g=0.576 b=1}credit score{/c} by 0.1."),
	image = "shop_slot",
	itemLock = true,
	lootplotTags = { lib.tags.SHOP_SLOT },
	triggers = { "REROLL", "PULSE" },
	baseMaxActivations = 20,
	itemReroller = shopItemGenerator,
	itemSpawner = shopItemGenerator,
	actionButtons = {
		SHOP_BUTTON,
		LOCK_REROLL_BUTTON
	},
	dontPropagateTriggerToItem = true,
	isItemListenBlocked = true,
	canActivate = function(ent)
		return (not ent.rerollLock) or (not lp.slotToItem(ent))
	end,
	canPlayerAccessItemInSlot = function(slotEnt, itemEnt)
		return not slotEnt.itemLock
	end,
	onActivate = function(slotEnt)
		setItemLock(slotEnt, true)
		setRerollLock(slotEnt, false)
	end,
	onItemDraw = function(selfEnt, itemEnt, x,y, _rot, sx,sy)
		if selfEnt.rerollLock then
			rendering.drawImage("slot_reroll_padlock", x,y, 0, sx,sy)
		end
		return drawItemPrice(selfEnt, itemEnt)
	end
})

local function foodShopWeightAdjuster(etype)
	local r = etype.rarity
	if not r then return 0 end
	if r == lp.rarities.COMMON then
		return 32
	end
	if r == lp.rarities.UNCOMMON then
		return 6
	end
	if r == lp.rarities.RARE then
		return 1
	end
	if r == lp.rarities.EPIC then
		return 0.3
	end
	if r == lp.rarities.LEGENDARY then
		return 0.04
	end
	return 0
end

local function foodShopItemFilter(etype)
	return lib.hasTag(etype, lib.tags.FOOD)
end

local foodShopItemGenerator = createItemGenerator(foodShopItemFilter, foodShopWeightAdjuster)
lp.defineSlot("dsh.cc:racket_food_shop_slot", {
	name = loc("Racket Food Shop"),
	activateDescription = loc("Spawns food to buy. Each bought item raises your {c r=0.6 g=0.576 b=1}credit score{/c} by 0.1."),
	image = "food_shop_slot",
	itemLock = true,
	lootplotTags = { lib.tags.SHOP_SLOT },
	triggers = { "REROLL", "PULSE" },
	baseMaxActivations = 20,
	itemReroller = foodShopItemGenerator,
	itemSpawner = foodShopItemGenerator,
	actionButtons = {
		SHOP_BUTTON,
		LOCK_REROLL_BUTTON
	},
	dontPropagateTriggerToItem = true,
	isItemListenBlocked = true,
	canActivate = function(ent)
		return (not ent.rerollLock) or (not lp.slotToItem(ent))
	end,
	canPlayerAccessItemInSlot = function(slotEnt, itemEnt)
		return not slotEnt.itemLock
	end,
	onActivate = function(slotEnt)
		setItemLock(slotEnt, true)
		setRerollLock(slotEnt, false)
	end,
	onItemDraw = function(selfEnt, itemEnt, x,y, _rot, sx,sy)
		if selfEnt.rerollLock then
			rendering.drawImage("slot_reroll_padlock", x,y, 0, sx,sy)
		end
		return drawItemPrice(selfEnt, itemEnt)
	end
})