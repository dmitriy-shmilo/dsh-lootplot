local loc = localization.localize
local interp = localization.newInterpolator


local BAR_DESC = interp("After {lootplot:INFO_COLOR}%{count} activations{/lootplot:INFO_COLOR}, spawns a %{spawnTarget}.")

local BAR_ACT_CURSED = 8
lp.defineItem("dsh.vv:bar_cursed", {
    name = loc("Cursed Bar"),
    image = "dsh_bar_cursed",
    triggers = { "PULSE" },
    canItemFloat = true,
    basePrice = 13,
    baseMaxActivations = 4,
    rarity = lp.rarities.RARE,
    activateDescription = function (ent)
        return  BAR_DESC({
            count = BAR_ACT_CURSED - (ent.totalActivationCount or 0),
            spawnTarget = "Curse Button Slot"
        })
    end,
    onActivate = function(ent)
        if (ent.totalActivationCount or 0) > BAR_ACT_CURSED - 1 then
            local ppos = lp.getPos(ent)
            if ppos then
                lp.forceSpawnSlot(ppos, server.entities["curse_button_slot"], ent.lootplotTeam)
            end
            lp.destroy(ent)
        end
    end,

    onDraw = function(ent)
        lib.c.drawDelayItemNumber(ent, BAR_ACT_CURSED)
    end
})

local BAR_ACT_MYSTERY = 10
lp.defineItem("dsh.vv:bar_mystery", {
    name = loc("Mystery Bar"),
    image = "dsh_bar_mystery",
    triggers = { "PULSE" },
    canItemFloat = true,
    basePrice = 11,
    baseMaxActivations = 5,
    rarity = lp.rarities.RARE,

    activateDescription = function (ent)
        return  BAR_DESC({
            count = BAR_ACT_CURSED - (ent.totalActivationCount or 0),
            spawnTarget = "Locked Slot"
        })
    end,
    onActivate = function(ent)
        if (ent.totalActivationCount or 0) > BAR_ACT_MYSTERY - 1 then
            local ppos = lp.getPos(ent)
            if ppos then
                lp.forceSpawnSlot(ppos, server.entities["locked_slot"], ent.lootplotTeam)
            end
            lp.destroy(ent)
        end
    end,

    onDraw = function(ent)
        lib.c.drawDelayItemNumber(ent, BAR_ACT_MYSTERY)
    end
})

local BAR_ACT_REVERSAL = 30
lp.defineItem("dsh.vv:bar_orichalcum", {
    name = loc("Orichalcum Bar"),
    image = "dsh_bar_orichalcum",
    triggers = { "PULSE" },
    canItemFloat = true,
    basePrice = 100,
    baseMaxActivations = 2,
    rarity = lp.rarities.RARE,

    activateDescription = function (ent)
        return  BAR_DESC({
            count = BAR_ACT_REVERSAL - (ent.totalActivationCount or 0),
            spawnTarget = "Reversal Button Slot"
        })
    end,
    onActivate = function(ent)
        if (ent.totalActivationCount or 0) > BAR_ACT_REVERSAL - 1 then
            local ppos = lp.getPos(ent)
            if ppos then
                lp.forceSpawnSlot(ppos, server.entities["reversal_button_slot"], ent.lootplotTeam)
            end
            lp.destroy(ent)
        end
    end,

    onDraw = function(ent)
        lib.c.drawDelayItemNumber(ent, BAR_ACT_REVERSAL)
    end
})

local BAR_ACT_TAX = 5
lp.defineItem("dsh.vv:bar_copper", {
    name = loc("Copper Bar"),
    image = "dsh_bar_copper",
    triggers = { "PULSE" },
    canItemFloat = true,
    basePrice = 100,
    baseMaxActivations = 2,
    rarity = lp.rarities.RARE,

    activateDescription = function (ent)
        return  BAR_DESC({
            count = BAR_ACT_TAX - (ent.totalActivationCount or 0),
            spawnTarget = "Tax Button Slot"
        })
    end,
    onActivate = function(ent)
        if (ent.totalActivationCount or 0) > BAR_ACT_TAX - 1 then
            local ppos = lp.getPos(ent)
            if ppos then
                lp.forceSpawnSlot(ppos, server.entities["tax_button_slot"], ent.lootplotTeam)
            end
            lp.destroy(ent)
        end
    end,

    onDraw = function(ent)
        lib.c.drawDelayItemNumber(ent, BAR_ACT_TAX)
    end
})