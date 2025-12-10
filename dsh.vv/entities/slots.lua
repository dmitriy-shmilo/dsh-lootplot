-- see lootplot.s0\entities\slots\shop_reroll_slots.lua
local loc = localization.localize

local _itemGeneratorsByRarity = {}
local _defaultItemGenerator

local function createItemGenerator(rarity)
    return lp.newItemGenerator({
        filter = function (etypeName, _)
            local etype = server.entities[etypeName]
            if lp.hasTag(etype, lib.tags.FOOD) then
                return false
            end

            if etype and etype.rarity and etype.rarity.id == rarity.id then
                return lp.metaprogression.isEntityTypeUnlocked(etype)
            end
            return false
        end
    })
end

-- lazily gets the item generator to be used for rarity-bound rerolling
local function getItemGenerator(rarity)
    local gen = _itemGeneratorsByRarity[rarity]
    if not gen then
        gen = createItemGenerator(rarity)
        _itemGeneratorsByRarity[rarity] = gen
    end
    return gen
end

-- lazily gets the item generator to be used for most item rerolling entities
-- TODO: a lib candidate
local function getDefaultItemGenerator()
    _defaultItemGenerator = _defaultItemGenerator or lp.newItemGenerator({
        filter = function (etypeName, _)
            local etype = server.entities[etypeName]
            if lp.hasTag(etype, lib.tags.FOOD) then
                return false
            end

            if etype then
                return lp.metaprogression.isEntityTypeUnlocked(etype)
            end
            return false
        end,
        adjustWeights = function(item, _)
            local etype = server.entities[item]
            if etype.rarity then
                return lib.SHOP_RARITY_WEIGHTS[etype.rarity.id] or 0
            end
            return 0
        end
    })
    return _defaultItemGenerator
end

local LOCK_TEXT = loc("Lock")
local UNLOCK_TEXT = loc("Unlock")

local LOCK_REROLL_BUTTON = {
    action = function(ent, clientId)
        if server then
            ent.rerollLock = not ent.rerollLock
            sync.syncComponent(ent, "rerollLock")
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

lp.defineSlot("dsh.vv:reroll_fair_slot", {
    image = "dsh_reroll_fair_slot",
    name = loc("Fair Reroll Slot"),
    activateDescription = loc("Transforms items into a random item preserving rarity."),
    baseMaxActivations = 20,
    triggers = { "REROLL" },
    rarity = lp.rarities.RARE,

    dontPropagateTriggerToItem = true,
    isItemListenBlocked = true,

    canActivate = function(ent)
        return not ent.rerollLock
    end,

    onActivate = function(slotEnt)
        local item = lp.slotToItem(slotEnt)
        if not item then return end

        local r = item.rarity
        if not lib.REROLLABLE_RARITIES[r] then
            return
        end
        local gen = getItemGenerator(r)
        if not gen then
            return
        end
        local etype = server.entities[gen:query()]
        if etype then
            lp.forceSpawnItem(lp.getPos(slotEnt), etype, item.lootplotTeam)
        end
    end,

    actionButtons = {
        LOCK_REROLL_BUTTON
    }
})

lp.defineSlot("dsh.vv:reroll_doomed_slot", {
    image = "dsh_reroll_doomed_slot",
    name = loc("Purple Reroll Slot"),
    activateDescription = loc("Transforms items into a random item and gives it {lootplot:DOOMED_COLOR}DOOMED-5{/lootplot:DOOMED_COLOR}."),
    baseMaxActivations = 20,
    triggers = { "REROLL" },
    rarity = lp.rarities.RARE,
    dontPropagateTriggerToItem = true,
    isItemListenBlocked = true,

    itemReroller = function() 
        return getDefaultItemGenerator():query()
    end,

    canActivate = function(ent)
        return not ent.rerollLock
    end,

    onPostActivate = function(ent)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            itemEnt.doomCount = 5
        end
    end,

    actionButtons = {
        LOCK_REROLL_BUTTON
    }
})

lp.defineSlot("dsh.vv:reroll_grubby_slot", {
    image = "dsh_reroll_grubby_slot",
    name = loc("Grubby Reroll Slot"),
    activateDescription = loc("Transforms items into a random item and gives it {lootplot:GRUB_COLOR_LIGHT}GRUBBY{/lootplot:GRUB_COLOR_LIGHT}."),
    baseMaxActivations = 20,
    triggers = { "REROLL" },
    rarity = lp.rarities.RARE,
    dontPropagateTriggerToItem = true,
    isItemListenBlocked = true,

    itemReroller = function() 
        return getDefaultItemGenerator():query()
    end,

    canActivate = function(ent)
        return not ent.rerollLock
    end,

    onPostActivate = function(ent)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            itemEnt.grubMoneyCap = true
            sync.syncComponent(itemEnt, "grubMoneyCap")
        end
    end,

    actionButtons = {
        LOCK_REROLL_BUTTON
    }
})

lp.defineSlot("dsh.vv:jade_slot", {
    image = "dsh_jade_slot",
    name = loc("Jade Slot"),
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Reroll{/lootplot:TRIGGER_COLOR} on item."),
    baseMaxActivations = 20,
    triggers = { "PULSE" },
    rarity = lp.rarities.COMMON,

    onActivate = function(slotEnt)
        local item = lp.slotToItem(slotEnt)
        if item then
            lp.tryTriggerEntity("REROLL", item)
        end
    end
})

umg.on("lootplot:entityBuffed", function(ent, _, amount)
    if not server then return end
    if amount <= 0 then return end
    local slot = lp.itemToSlot(ent)
    if not slot then return end
    local slotListen = slot.slotListen
    if not slotListen then return end
    if slotListen.trigger == "BUFF" and slotListen.activate then
        slotListen.activate(slot)
    end
end)


lp.defineSlot("dsh.vv:marble_slot", {
    image = "dsh_marble_slot",
    name = loc("Marble Slot"),
    activateDescription = loc("When item is buffed, triggers {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} on item."),
    baseMaxActivations = 20,
    rarity = lp.rarities.UNCOMMON,
    triggers = {},
    slotListen = {
        trigger = "BUFF",
        activate = function(slotEnt)
            local item = lp.slotToItem(slotEnt)
            if item then
                lp.tryTriggerEntity("PULSE", item)
            end
        end
    }
})