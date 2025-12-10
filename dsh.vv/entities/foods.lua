local slots = require("shared.slots")
local loc = localization.localize

lp.defineItem("dsh.vv:marble_apple", {
    baseMaxActivations = 1,
    lootplotTags = { FOOD_TAG },
    foodItem = true,
    image = "dsh_marble_apple",
    name = loc("Marble Apple"),
    activateDescription = loc("Converts a slot into a marble slot, which triggers {lootplot:TRIGGER_COLOR}pulse{/lootplot:TRIGGER_COLOR} on buffed items."),
    rarity = lp.rarities.UNCOMMON,
    basePrice = 5,
    shape = lp.targets.ON_SHAPE,
    target = {
        type = "SLOT",
        activate = function (selfEnt, ppos)
            local etype = server.entities["dsh.vv:marble_slot"]
            lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
        end
    }
})

lp.defineItem("dsh.vv:jade_apple", {
    baseMaxActivations = 1,
    lootplotTags = { FOOD_TAG },
    foodItem = true,
    image = "dsh_jade_apple",
    name = loc("Jade Apple"),
    activateDescription = loc("Converts a slot into a jade slot, which triggers {lootplot:TRIGGER_COLOR}reroll{/lootplot:TRIGGER_COLOR} on items."),
    rarity = lp.rarities.UNCOMMON,
    basePrice = 5,
    shape = lp.targets.ON_SHAPE,
    target = {
        type = "SLOT",
        activate = function (selfEnt, ppos)
            local etype = server.entities["dsh.vv:jade_slot"]
            lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
        end
    }
})

lp.defineItem("dsh.vv:unripe_avocado", {
    baseMaxActivations = 1,
    lootplotTags = { FOOD_TAG },
    foodItem = true,
    image = "dsh_unripe_avocado",
    name = loc("Unripe Avocado"),
    activateDescription = loc("Spawns jade slots, which trigger {lootplot:TRIGGER_COLOR}reroll{/lootplot:TRIGGER_COLOR} on items."),
    rarity = lp.rarities.RARE,
    basePrice = 7,
    shape = lp.targets.KingShape(1),
    target = {
        type = "NO_SLOT",
        filter = function (selfEnt, ppos)
            local itemEnt = lp.posToItem(ppos)
            if itemEnt and lp.curses.isCurse(itemEnt) then
                return false
            end
            return true
        end,
        activate = function (selfEnt, ppos)
            local etype = server.entities["dsh.vv:jade_slot"]
            lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
        end
    }
})

lp.defineItem("dsh.vv:bergamot", {
    image = "dsh_bergamot",
    name = loc("Bergamot"),
    activateDescription = loc("Spawns random {lootplot:DOOMED_COLOR}DOOMED-5{/lootplot:DOOMED_COLOR} Reroll Slots"),
    lootplotTags = { FOOD_TAG },
    foodItem = true,
    rarity = lp.rarities.RARE,
    basePrice = 8,

    target = {
        type = "NO_SLOT",
        filter = function (selfEnt, ppos)
            local itemEnt = lp.posToItem(ppos)
            if itemEnt and lp.curses.isCurse(itemEnt) then
                return false
            end
            return true
        end,
        activate = function (selfEnt, ppos)
            -- FIXME: should probably be weighted random
            local idx = lp.SEED:randomMisc(1, #slots.REROLL_SLOT_KEYS)
            local slotEType = server.entities[slots.REROLL_SLOT_KEYS[idx]]
            if not slotEType then
                return
            end
            local slotEnt = lp.trySpawnSlot(ppos, slotEType, selfEnt.lootplotTeam)
            if slotEnt then
                slotEnt.doomCount = 5
            end
        end
    },
    shape = lp.targets.KingShape(2)
})