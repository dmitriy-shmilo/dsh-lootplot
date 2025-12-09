local loc = localization.localize

local function propertyShuffler(getter, setter, includeSlots)
    return function(selfEnt)
        local targets = lp.targets.getTargets(selfEnt)
        if not targets then return end

        local entities = {}
        local values = {}

        for _, ppos in ipairs(targets) do
            local itemEnt = lp.posToItem(ppos)
            local slotEnt = lp.posToSlot(ppos)
            if itemEnt then
                entities[#entities + 1] = itemEnt
                values[#entities] = getter(itemEnt)
            elseif slotEnt and includeSlots then
                entities[#entities + 1] = slotEnt
                values[#entities] = getter(slotEnt)
            end
        end

        values = lib.shuffledRandom(values)

        for i, ent in ipairs(entities) do
            local value = values[i]
            setter(ent, value)
        end
    end
end

local function priceGetter(ent)
    return ent.price or 0
end

local function priceSetter(ent, value)
    if ent.price ~= value then
        local actualPrice = (ent.price or 0)
        local delta = value - actualPrice
        lp.modifierBuff(ent, "price", delta, selfEnt)
    end
end


lp.defineItem("dsh.ff:juice_banana", {
    baseMaxActivations = 1,
    lootplotTags = { lib.tags.FOOD_TAG },
    foodItem = true,
    image = "dsh_juice_banana",
    name = loc("Banana Juice"),
    activateDescription = loc("Randomly shuffles prices between all target items."),
    rarity = lp.rarities.RARE,
    basePrice = 10,
    shape = lp.targets.KING_SHAPE,
    onActivate = propertyShuffler(priceGetter, priceSetter),
    target = {
        type = "ITEM"
    }
})


local function bonusGetter(ent)
    return ent.bonusGenerated or 0
end

local function bonusSetter(ent, value)
    if ent.bonusGenerated ~= value then
        local actualValue = (ent.bonusGenerated or 0)
        local delta = value - actualValue
        lp.modifierBuff(ent, "bonusGenerated", delta, selfEnt)
    end
end

lp.defineItem("dsh.ff:juice_mint", {
    baseMaxActivations = 1,
    lootplotTags = { lib.tags.FOOD_TAG },
    foodItem = true,
    image = "dsh_juice_mint",
    name = loc("Mint Juice"),
    activateDescription = loc("Randomly shuffles {lootplot:BONUS_COLOR}bonuses{/lootplot:BONUS_COLOR} between all target items and slots."),
    rarity = lp.rarities.RARE,
    basePrice = 10,
    shape = lp.targets.KING_SHAPE,
    onActivate = propertyShuffler(bonusGetter, bonusSetter, true),
    target = {
        type = "ITEM_OR_SLOT"
    }
})


local function doomCountGetter(ent)
    return ent.doomCount or 0
end

local function doomCountSetter(ent, value)
    ent.doomCount = value
end

lp.defineItem("dsh.ff:juice_grape", {
    baseMaxActivations = 1,
    lootplotTags = { lib.tags.FOOD_TAG },
    foodItem = true,
    image = "dsh_juice_grape",
    name = loc("Grape Juice"),
    activateDescription = loc("Randomly shuffles {lootplot:DOOMED_COLOR}DOOM-COUNT{/lootplot:DOOMED_COLOR} between all doomed target items and slots."),
    rarity = lp.rarities.RARE,
    basePrice = 10,
    shape = lp.targets.KING_SHAPE,
    onActivate = propertyShuffler(doomCountGetter, doomCountSetter, true),
    canActivate = function(selfEnt)
        local targets = lp.targets.getTargets(selfEnt)
        local doomedCount = 0
        for _, ppos in ipairs(targets) do
            local itemEnt = lp.posToItem(ppos)
            local slotEnt = lp.posToSlot(ppos)
            if itemEnt and itemEnt.doomCount then
                doomedCount = doomedCount + 1
            end
            if slotEnt and slotEnt.doomCount then
                doomedCount = doomedCount + 1
            end
        end
        return doomedCount > 1
    end,
    target = {
        type = "ITEM_OR_SLOT",
        filter = function(selfEnt, ppos, targeEnt)
            return targeEnt.doomCount
        end
    }
})

local function repeaterGetter(ent)
    return ent.repeatActivations or false
end

local function repeaterSetter(ent, value)
    if ent.repeatActivations ~= value then
        ent.repeatActivations = value
        sync.syncComponent(ent, "repeatActivations")
    end
end

lp.defineItem("dsh.ff:juice_raspberry", {
    baseMaxActivations = 1,
    lootplotTags = { lib.tags.FOOD_TAG },
    foodItem = true,
    image = "dsh_juice_raspberry",
    name = loc("Raspberry Juice"),
    activateDescription = loc("Randomly shuffles {lootplot:REPEATER_COLOR}REPEATER{/lootplot:REPEATER_COLOR} between all target items and slots."),
    rarity = lp.rarities.EPIC,
    basePrice = 15,
    shape = lp.targets.KING_SHAPE,
    onActivate = propertyShuffler(repeaterGetter, repeaterSetter, true),
    target = {
        type = "ITEM_OR_SLOT"
    }
})


local function livesGetter(ent)
    return ent.lives or 0
end

local function livesSetter(ent, value)
    if ent.lives ~= value then
        ent.lives = value
        sync.syncComponent(ent, "lives")
    end
end

lp.defineItem("dsh.ff:juice_lychee", {
    baseMaxActivations = 1,
    lootplotTags = { lib.tags.FOOD_TAG },
    foodItem = true,
    image = "dsh_juice_lychee",
    name = loc("Lychee Juice"),
    activateDescription = loc("Randomly shuffles {lootplot:LIFE_COLOR}lives{/lootplot:LIFE_COLOR} between all target items and slots."),
    rarity = lp.rarities.EPIC,
    basePrice = 15,
    shape = lp.targets.KING_SHAPE,
    onActivate = propertyShuffler(livesGetter, livesSetter, true),
    target = {
        type = "ITEM_OR_SLOT"
    }
})