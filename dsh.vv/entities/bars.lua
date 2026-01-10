local loc = localization.localize
local interp = localization.newInterpolator
local lib = require("shared.lib")

local BAR_DESC = interp("After {lootplot:INFO_COLOR}%{count} activations{/lootplot:INFO_COLOR}, spawns a %{spawnTarget}.")

-- taken from lootplot.s0.worldgen\entities\basic_worldgen.lua without changes
local function spawnLockedChest(ppos, team)
    local slotEnt = server.entities.null_slot()
    slotEnt.lootplotTeam = team

    local r = lp.SEED:randomWorldGen()
    local itemEnt
    if r < 0.85 then
        itemEnt = server.entities.chest_epic()
    else
        itemEnt = server.entities.chest_legendary()
    end
    itemEnt.stuck = true
    itemEnt.lootplotTeam = team
    lp.unlocks.forceSpawnLockedSlot(ppos, slotEnt, itemEnt)
end

-- taken from lootplot.s0.worldgen\entities\basic_worldgen.lua without changes
local function spawnLockedIncomeSlot(ppos, team, islandSize)
    local slotId = "lootplot.s0:slot"
    local slotEnt = server.entities[slotId]()
    slotEnt.baseMoneyGenerated = 1
    slotEnt.lootplotTeam = team

    if islandSize > 5 then
        slotEnt.doomCount = 2
    elseif islandSize > 2 then
        slotEnt.doomCount = 3
    else
        slotEnt.doomCount = 4
    end
    local itemEnt = nil

    lp.unlocks.forceSpawnLockedSlot(ppos, slotEnt, itemEnt)
end

-- taken from lootplot.s0.worldgen\entities\basic_worldgen.lua without changes
local function spawnLockedOfferSlot(ppos, team)
    local slotEnt = server.entities["lootplot.s0:offer_slot"]()
    slotEnt.lootplotTeam = team

    local rar = lp.rarities.RARE
    local r = lp.SEED:randomWorldGen()
    if (r < 0.02) then
        rar = lp.rarities.LEGENDARY
    elseif (r < 0.2) then
        rar = lp.rarities.EPIC
    end

    local itemType = lp.rarities.randomItemOfRarity(rar, lp.SEED.worldGenRNG)
    local itemEnt = itemType and itemType()
    if itemEnt then
        itemEnt.lootplotTeam = team
        lp.unlocks.forceSpawnLockedSlot(ppos, slotEnt, itemEnt)
    else
        umg.log.error("Waht the HECK. why didnt it spawn??", itemType)
    end
end

local BAR_ACT_CURSED = 12
lp.defineItem("dsh.vv:bar_cursed", {
    name = loc("Cursed Bar"),
    image = "dsh_bar_cursed",
    triggers = { "PULSE" },
    canItemFloat = true,
    basePrice = 13,
    baseMaxActivations = BAR_ACT_CURSED / 2,
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
            lib.erase(ent)
        end
    end,

    onDraw = function(ent)
        lib.drawDelayItemNumber(ent, BAR_ACT_CURSED)
    end
})

local BAR_ACT_MYSTERY = 8
lp.defineItem("dsh.vv:bar_mystery", {
    name = loc("Mystery Bar"),
    image = "dsh_bar_mystery",
    triggers = { "PULSE" },
    canItemFloat = true,
    basePrice = 11,
    baseMaxActivations = BAR_ACT_MYSTERY / 2,
    rarity = lp.rarities.RARE,

    activateDescription = function (ent)
        return  BAR_DESC({
            count = BAR_ACT_MYSTERY - (ent.totalActivationCount or 0),
            spawnTarget = "Locked Slot"
        })
    end,
    onActivate = function(ent)
        if (ent.totalActivationCount or 0) > BAR_ACT_MYSTERY - 1 then
            local ppos = lp.getPos(ent)
            if ppos then
                local r = lp.SEED:randomWorldGen()
                if r < 0.33 then
                    spawnLockedChest(ppos, ent.lootplotTeam)
                elseif r < 0.66 then
                    spawnLockedOfferSlot(ppos, ent.lootplotTeam)
                else
                    spawnLockedOfferSlot(ppos, ent.lootplotTeam, 1)
                end
            end
            lib.erase(ent)
        end
    end,

    onDraw = function(ent)
        lib.drawDelayItemNumber(ent, BAR_ACT_MYSTERY)
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
            lp.erase(ent)
        end
    end,

    onDraw = function(ent)
        lib.drawDelayItemNumber(ent, BAR_ACT_REVERSAL)
    end
})

local BAR_ACT_TAX = 8
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
            lp.erase(ent)
        end
    end,

    onDraw = function(ent)
        lib.drawDelayItemNumber(ent, BAR_ACT_TAX)
    end
})