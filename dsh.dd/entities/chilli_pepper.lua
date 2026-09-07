local config = require("shared.config")
local etypes = require("shared.etypes")
local lib = require("shared.lib")
local loc = localization.localize

if not config.mildPepper then return end

etypes.redefineItem("lootplot.s0:chilli_pepper", "dsh.dd:chilli_pepper", {
    name = loc("Chilli Pepper"),
    image = "chilli_pepper",
    foodItem = true,
    lootplotTags = { lib.tags.FOOD, lib.tags.ORGANIC },
    rarity = lp.rarities.UNCOMMON,
    activateDescription = loc("Spawns basic slots.\nRemoves all {lootplot:LIFE_COLOR}lives{/lootplot:LIFE_COLOR} from target curses."),

    baseMoneyGenerated = -20,
    canGoIntoDebt = true,
    unlockAfterWins = 2,

    basePrice = 2,

    shape = lp.targets.HorizontalShape(2),

    target = {
        filter = function (selfEnt, ppos)
            local slotEnt = lp.posToSlot(ppos)
            local itemEnt = lp.posToItem(ppos)
            if not slotEnt then
                return true
            end
            if itemEnt and lp.curses.isCurse(itemEnt) then
                return true
            end
        end,
        activate = function (selfEnt, ppos, targEnt)
            local slotEnt = lp.posToSlot(ppos)
            local itemEnt = lp.posToItem(ppos)
            if not slotEnt then
                lp.forceSpawnSlot(ppos, server.entities.slot, selfEnt.lootplotTeam)
            end
            if itemEnt and lp.curses.isCurse(itemEnt) then
                itemEnt.lives = 0
            end
        end
    }
})