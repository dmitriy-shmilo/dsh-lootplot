local loc = localization.localize
local lib = require("shared.lib")

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

lp.defineItem("dsh.vv:purple_balloon", {
    name = loc("Purple Balloon"),
    image = "dsh_purple_balloon",
    activateDescription = loc("When a doomed item is purchased, gives it {lootplot:DOOMED_LIGHT_COLOR}+2 doomed{lootplot:DOOMED_LIGHT_COLOR}."),
    basePrice = 12,
    baseMaxActivations = 4,
    sticky = true,
    shape = lp.targets.CircleShape(2),
    listen = {
        type = "ITEM",
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            if not targetEnt.doomCount then return end
            targetEnt.doomCount = targetEnt.doomCount + 2
        end,
    },

    rarity = lp.rarities.EPIC
})

local function isHorizontalMatch(ppos, type)
    local item1 = nil
    local item2 = nil
    local pos1 = ppos:move(-1, 0)
    local pos2 = ppos:move(1, 0)

    if not pos1 or not pos2 then return nil end

    item1 = lp.posToItem(pos1)
    item2 = lp.posToItem(pos2)

    if not item1 or not item2 then return nil end

    if type == item1:type() and type == item2:type() then
        return item1, item2
    end

    return nil
end

local function isVerticalMatch(ppos, type)
    local item1 = nil
    local item2 = nil
    local pos1 = ppos:move(0, -1)
    local pos2 = ppos:move(0, 1)

    if not pos1 or not pos2 then return nil end

    item1 = lp.posToItem(pos1)
    item2 = lp.posToItem(pos2)

    if not item1 or not item2 then return nil end

    if type == item1:type() and type == item2:type() then
        return item1, item2
    end
end


local weaponGenerator = nil

function getWeaponGenerator()
    if not weaponGenerator then
        weaponGenerator = lp.newItemGenerator({
            filter = function(item, weight)
                return lib.hasTag(item, lib.tags.WEAPON)
            end,
            adjustWeights = function(item, _)
                local etype = server.entities[item]
                if etype.rarity then
                    return lib.SHOP_RARITY_WEIGHTS[etype.rarity.id] or 0
                end
                return 0
            end
        })
    end
    return weaponGenerator
end

lp.defineItem("dsh.vv:weapon_parts", {
    name = loc("Weapon Parts"),
    image = "dsh_weapon_parts",
    activateDescription = loc("When 3 are in a line:\nSpawns a random weapon."),
    basePrice = 3,
    onUpdateServer = function(ent) 
        local ppos = lp.getPos(ent)
        if not ppos then return end

        local slotEnt = lp.itemToSlot(ent)
        if slotEnt and not lp.canSlotPropagateTriggerToItem(slotEnt) then
            return
        end

        local type = ent:type()
        local item1, item2 = isHorizontalMatch(ppos, type)
        if not item1 or not item2 then
            item1, item2 = isVerticalMatch(ppos, type)
        end

        if not item1 or not item2 then return end
        
        lib.erase(item1)
        lib.erase(item2)
        lib.erase(ent)
        local generator = getWeaponGenerator()
        local weapon = server.entities[generator:query()]
        if not weapon then return end
        lp.forceSpawnItem(ppos, weapon, ent.lootplotTeam)
    end,

    rarity = lp.rarities.UNCOMMON,
})
