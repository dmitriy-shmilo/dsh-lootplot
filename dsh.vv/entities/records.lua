local loc = localization.localize

lp.defineTag("dsh.vv:record")

lp.defineItem("dsh.vv:record_plain", {
    name = loc("Plain Record"),
    image = "dsh_record_plain",
    basePointsGenerated = 30,
    lootplotTags = { lib.tags.RECORD },
    triggers = { "ROTATE" },
    baseMaxActivations = 6,
    basePrice = 4,
    rarity = lp.rarities.COMMON
})


lp.defineItem("dsh.vv:record_teal", {
    name = loc("Teal Record"),
    image = "dsh_record_teal",
    baseBonusGenerated = 2,
    lootplotTags = { lib.tags.RECORD },
    triggers = { "ROTATE" },
    baseMaxActivations = 6,
    basePrice = 6,
    rarity = lp.rarities.UNCOMMON
})

lp.defineItem("dsh.vv:record_pink", {
    name = loc("Pink Record"),
    image = "dsh_record_pink",
    activateDescription = loc("Add {lootplot:LIFE_COLOR}+%{buff} life{/lootplot:LIFE_COLOR} to items.", {
        buff = 1
    }),
    lootplotTags = { lib.tags.RECORD },
    triggers = { "ROTATE" },
    baseMaxActivations = 6,
    basePrice = 15,
    rarity = lp.rarities.EPIC,
    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + 1
        end
    }
})

lp.defineItem("dsh.vv:record_purple", {
    name = loc("Purple Record"),
    image = "dsh_record_purple",
    activateDescription = loc("Gives {lootplot:DOOMED_LIGHT_COLOR}+1 Doomed{/lootplot:DOOMED_LIGHT_COLOR} to doomed items.", {
        buff = 1
    }),
    lootplotTags = { lib.tags.RECORD },
    triggers = { "ROTATE" },
    baseMaxActivations = 6,
    basePrice = 15,
    rarity = lp.rarities.EPIC,
    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return targetEnt.doomCount
        end,
        activate = function(selfEnt, ppos, targetEnt)
            if targetEnt.doomCount then
                targetEnt.doomCount = targetEnt.doomCount + 1
            end
        end
    }
})

lp.defineItem("dsh.vv:record_platinum", {
    name = loc("Platinum Record"),
    image = "dsh_record_platinum",
    activateDescription = loc("Gives {lootplot:POINTS_COLOR}+1 activations{/lootplot:POINTS_COLOR} to record items.", {
        buff = 1
    }),
    lootplotTags = { lib.tags.RECORD },
    triggers = { "ROTATE" },
    baseMaxActivations = 1,
    basePrice = 16,
    rarity = lp.rarities.LEGENDARY,
    shape = lp.targets.UpShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return lib.hasTag(targetEnt, lib.tags.RECORD)
        end,
        activate = function(ent, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "maxActivations", 1, ent)
        end
    }
})

lp.defineItem("dsh.vv:record_star", {
    name = loc("Platinum Record"),
    image = "dsh_record_star",
    activateDescription = loc("Shuffle {lootplot.targets:COLOR}target-shapes{/lootplot.targets:COLOR} between items."),
    lootplotTags = { lib.tags.RECORD },
    triggers = { "ROTATE" },
    baseMaxActivations = 1,
    basePrice = 16,
    rarity = lp.rarities.LEGENDARY,
    shape = lp.targets.HorizontalShape(1),
    onActivate = function(selfEnt) 
        local targets = lp.targets.getTargets(selfEnt)
        if not targets then
            return
        end

        local entities = {}
        local values = {}

        for _, ppos in ipairs(targets) do
            local itemEnt = lp.posToItem(ppos)
            if itemEnt then
                entities[#entities+1] = itemEnt
                values[#entities] = itemEnt.shape
            end
        end

        values = lib.shuffledRandom(values)

        for i, ent in ipairs(entities) do
            local value = values[i]
            if ent.shape ~= value then
                ent.shape = value
                sync.syncComponent(ent, "shape")
            end
        end
    end,
    target = {
        type = "ITEM",
        filter = function(ent, ppos, targEnt)
            return targEnt.target and targEnt.shape
        end
    }
})