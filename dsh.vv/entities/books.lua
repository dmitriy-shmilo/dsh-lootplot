local loc = localization.localize

lp.defineItem("dsh.vv:book_of_recipes", {
    name = loc("Book of Recipes"),
    image = "dsh_book_of_recipes",
    triggers = { "PULSE" },
    basePrice = 15,
    baseMaxActivations = 10,
    doomCount = 20,
    shape = lp.targets.UP_SHAPE,
    rarity = lp.rarities.EPIC,
    activateDescription = loc("Converts slot(s) into Food Shop Slot."),

    target = {
        type = "SLOT",

        filter = function(selfEnt, ppos, targetEnt)
            if targetEnt.buttonSlot then
                local plot = ppos:getPlot()
                local count = 0
                plot:foreachSlot(function(slotEnt)
                    if slotEnt:type() == targetEnt:type() then
                        count = count + 1
                    end
                end)
                if count <= 1 then
                    return false
                end
            end
            return true
        end,

        activate = function(selfEnt, ppos)
            local slotEType = server.entities["food_shop_slot"]
            if not slotEType then
                return
            end
            lp.forceSpawnSlot(ppos, slotEType, selfEnt.lootplotTeam)
        end
    }
})

local SHOP_SLOTS = {
}
SHOP_SLOTS["lootplot.s0:shop_slot"] = true
SHOP_SLOTS["lootplot.s0:food_shop_slot"] = true
SHOP_SLOTS["lootplot.s0:purple_shop_slot"] = true
SHOP_SLOTS["lootplot.s0:pink_shop_slot"] = true
SHOP_SLOTS["lootplot.s0:emerald_shop_slot"] = true

local SHOP_SLOT_KEYS = {
    "lootplot.s0:shop_slot",
    "lootplot.s0:food_shop_slot",
    "lootplot.s0:purple_shop_slot",
    "lootplot.s0:pink_shop_slot",
    "lootplot.s0:emerald_shop_slot"
}

lp.defineItem("dsh.vv:book_of_random_shopping", {
    name = loc("Book of Random Shopping"),
    image = "dsh_book_of_random_shopping",
    triggers = { "PULSE" },
    basePrice = 18,
    baseMaxActivations = 5,
    doomCount = 10,
    shape = lp.targets.UP_SHAPE,
    rarity = lp.rarities.LEGENDARY,
    activateDescription = loc("Converts Shop Slot(s) into other random Shop Slot(s)."),

    target = {
        type = "SLOT",

        filter = function(selfEnt, ppos, targetEnt)
            return SHOP_SLOTS[targetEnt:type()]
        end,

        activate = function(selfEnt, ppos)
            local idx = lp.SEED:randomMisc(1, #SHOP_SLOT_KEYS)
            local slotEType = server.entities[SHOP_SLOT_KEYS[idx]]
            if not slotEType then
                return
            end
            lp.forceSpawnSlot(ppos, slotEType, selfEnt.lootplotTeam)
        end
    }
})

local GEM_SLOTS = {
}
GEM_SLOTS["lootplot.s0:diamond_slot"] = true
GEM_SLOTS["lootplot.s0:emerald_slot"] = true
GEM_SLOTS["lootplot.s0:ruby_slot"] = true
GEM_SLOTS["lootplot.s0:sapphire_slot"] = true
GEM_SLOTS["dsh.vv:jade_slot"] = true


local GEM_SLOT_KEYS = {
    "lootplot.s0:diamond_slot",
    "lootplot.s0:emerald_slot",
    "lootplot.s0:ruby_slot",
    "lootplot.s0:sapphire_slot",
    "dsh.vv:jade_slot"
}

lp.defineItem("dsh.vv:book_of_minerals", {
    name = loc("Book of Minerals"),
    image = "dsh_book_of_minerals",
    triggers = { "PULSE" },
    basePrice = 18,
    baseMaxActivations = 1,
    doomCount = 5,
    shape = lp.targets.UP_SHAPE,
    rarity = lp.rarities.LEGENDARY,
    activateDescription = loc("Converts Gem Slot(s) into random Gem Slot(s)."),

    target = {
        type = "SLOT",
        filter = function(selfEnt, ppos, targetEnt)
            return GEM_SLOTS[targetEnt:type()]
        end,
        activate = function(selfEnt, ppos)
            local idx = lp.SEED:randomMisc(1, #GEM_SLOT_KEYS)
            local slotEType = server.entities[GEM_SLOT_KEYS[idx]]
            if not slotEType then
                return
            end
            lp.forceSpawnSlot(ppos, slotEType, selfEnt.lootplotTeam)
        end
    }
})

local REROLL_SLOTS = {
}

REROLL_SLOTS["lootplot.s0:reroll_slot"] = true
REROLL_SLOTS["dsh.vv:reroll_fair_slot"] = true
REROLL_SLOTS["dsh.vv:reroll_doomed_slot"] = true
REROLL_SLOTS["dsh.vv:reroll_grubby_slot"] = true

local REROLL_SLOT_KEYS = {
    "lootplot.s0:reroll_slot",
    "dsh.vv:reroll_fair_slot",
    "dsh.vv:reroll_doomed_slot",
    "dsh.vv:reroll_grubby_slot",
}

lp.defineItem("dsh.vv:book_of_random_rerolling", {
    name = loc("Book of Random Rerolling"),
    image = "dsh_book_of_random_rerolling",
    triggers = { "PULSE" },
    basePrice = 18,
    baseMaxActivations = 1,
    doomCount = 5,
    shape = lp.targets.UP_SHAPE,
    rarity = lp.rarities.LEGENDARY,
    activateDescription = loc("Converts Reroll Slot(s) into random Reroll Slot(s)."),

    target = {
        type = "SLOT",
        filter = function(selfEnt, ppos, targetEnt)
            return REROLL_SLOTS[targetEnt:type()]
        end,
        activate = function(selfEnt, ppos)
            local idx = lp.SEED:randomMisc(1, #REROLL_SLOT_KEYS)
            local slotEType = server.entities[REROLL_SLOT_KEYS[idx]]
            if not slotEType then
                return
            end
            lp.forceSpawnSlot(ppos, slotEType, selfEnt.lootplotTeam)
        end
    }
})