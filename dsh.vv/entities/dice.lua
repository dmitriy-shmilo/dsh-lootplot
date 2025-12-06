local loc = localization.localize

lp.defineItem("dsh.vv:die_blue", {
    name = loc("Blue Die"),
    image = "dsh_die_blue",
    triggers = {"REROLL", "PULSE"},
    activateDescription = loc("When Rerolled, gain {lootplot:POINTS_BONUS_COLOR}+0.1 bonus."),

    baseBonusGenerated = 0.1,
    baseMaxActivations = 6,
    basePrice = 8,

    onTriggered = function(ent, name)
        if name == "REROLL" then
            lp.modifierBuff(ent, "bonusGenerated", 0.2)
        end
    end,

    rarity = lp.rarities.RARE,
})

lp.defineItem("dsh.vv:die_pink", {
    name = loc("Pink Die"),
    image = "dsh_die_pink",
    triggers = {"REROLL", "DESTROY"},
    activateDescription = loc("When Rerolled, gain {lootplot:POINTS_LIFE_COLOR}+1 life."),

    basePointsGenerated = 36,
    baseMaxActivations = 6,
    basePrice = 6,
    lives = 6,
    onTriggered = function(ent, name)
        if name == "REROLL" then
            ent.lives = (ent.lives or 0) + 1
        end
    end,

    rarity = lp.rarities.UNCOMMON,
})

lp.defineItem("dsh.vv:die_purple", {
    name = loc("Purple Die"),
    image = "dsh_die_purple",
    triggers = { "REROLL" },
    basePointsGenerated = 60,
    baseBonusGenerated = 6,
    baseMultGenerated = 6,
    baseMaxActivations = 6,
    basePrice = 12,
    doomCount = 6,
    rarity = lp.rarities.EPIC,
})