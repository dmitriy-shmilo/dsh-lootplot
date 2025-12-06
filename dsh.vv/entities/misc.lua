local loc = localization.localize

lp.defineItem("dsh.vv:diamond_ornament", {
    name = loc("Diamond Ornament"),
    image = "dsh_diamond_ornament",
    activateDescription = loc("If {lootplot:MONEY_COLOR}money more than $%{moneyReq}{/lootplot:MONEY_COLOR}, permanently gain {lootplot:BONUS_COLOR}+%{buff} bonus.", {
        buff = 0.1,
        moneyReq = 40
    }),
    basePrice = 7,
    baseBonusGenerated = -1,
    baseMaxActivations = 4,

    onActivate = function(ent)
        if (lp.getMoney(ent) or 0) > 40 then
            lp.modifierBuff(ent, "bonusGenerated", 0.1, ent)
        end
    end,

    rarity = lp.rarities.UNCOMMON,
    triggers = { "PULSE" },
})

lp.defineItem("dsh.vv:vampire_gold_tooth", {
    name = loc("Golden Vampire Tooth"),
    image = "dsh_vampire_gold_tooth",
    activateDescription = loc("Steal {lootplot:MONEY_COLOR}$%{buff} money earned{/lootplot:MONEY_COLOR} from the slot. Gain {lootplot:MONEY_COLOR}$%{buff} money earned{/lootplot:MONEY_COLOR} permanently. Only works on slots, which earn money.", {
        buff = 0.2
    }),
    triggers = { "PULSE" },
    baseMaxActivations = 3,
    basePrice = 15,
    rarity = lp.rarities.EPIC,
    onActivate = function(ent)
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt then
            local income = slotEnt.moneyGenerated or 0
            if income < 0.2 then
                return
            end
            lp.modifierBuff(slotEnt, "moneyGenerated", -0.2, ent)
        end
        lp.modifierBuff(ent, "moneyGenerated", 0.2, ent)
    end,
})


lp.defineItem("dsh.vv:dry_grass", {
    name = loc("Dry Grass"),
    image = "dsh_dry_grass",
    triggers = { "REROLL" },
    activateDescription = loc("Reduces {lootplot:POINTS_COLOR}activations by -1{/lootplot:POINTS_COLOR} on items, and decreases the item prices by {lootplot:MONEY_COLOR}$4."),
    basePrice = 8,
    doomCount = 8,
    baseMaxActivations = 8,
    shape = lp.targets.DownShape(2),
    target = {
        type = "ITEM",
        activate = function(ent, ppos, targetEnt)
            if targetEnt.maxActivations > 1 then
                lp.modifierBuff(targetEnt, "maxActivations", -1, ent)
            end
            lp.modifierBuff(targetEnt, "price", -4, ent)
        end
    },

    rarity = lp.rarities.RARE,
})
