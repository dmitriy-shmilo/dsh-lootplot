local trophies = require("shared.trophies")
local loc = localization.localize
local meta = lp.metaprogression

do
    local countByItemType = {}
    local ID = "dsh.tt:itemFarmer"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("Item Farmer"),
        description = loc("Have 50 or more instances of the same item at the same time."),
        rewardDescription = loc("Unlocks {lootplot:POINTS_COLOR}Mitosis Turnip{/lootplot:POINTS_COLOR}."),
        image = "dsh_mitosis_turnip",
        author = "Vibre",
        triggers = { "LEVEL_UP", "TROPHY_TICK" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            for k, _ in pairs(countByItemType) do
                countByItemType[k] = 0
            end

            local plot = run:getPlot()
            plot:foreachItem(function(item)
                local count = countByItemType[item:type()] or 0
                count = count + 1
                countByItemType[item:type()] = count
            end)

            for k, c in pairs(countByItemType) do
                if k ~= "lootplot.s0:compendium_unseen_item" and c >= 50 then
                    return selfTrophy:unlock()
                end
            end

            return false
        end,
    })

    lp.defineItem("dsh.tt:mitosis_turnip", {
        name = loc("Mitosis Turnip"),
        activateDescription = loc("Duplicates the target item twice, and places duplicates to the left and to the right of itself. Doesn't work on food."),
        image = "dsh_mitosis_turnip",
        foodItem = true,
        baseMaxActivations = 1,
        rarity = lp.rarities.LEGENDARY,
        basePrice = 15,
        shape = lp.targets.UpShape(1),
        lootplotTags = { lib.tags.FOOD },
        isEntityTypeUnlocked = function()
            return meta.getFlag(ID)
        end,
        canActivate = function(selfEnt)
            local targets = lp.targets.getTargets(selfEnt)

            for _, ppos in ipairs(targets) do
                local itemEnt = lp.posToItem(ppos)
                if itemEnt and not lp.hasTag(itemEnt, lib.tags.FOOD) then
                    return true
                end
            end
        end,
        onActivate = function(selfEnt)
            local ppos = lp.getPos(selfEnt)
            local left = ppos:move(-1, 0)
            local right = ppos:move(1, 0)
            local targets = lp.targets.getTargets(selfEnt)

            for _, ppos in ipairs(targets) do
                local itemEnt = lp.posToItem(ppos)
                if itemEnt and not lp.hasTag(itemEnt, lib.tags.FOOD) then
                    lp.tryCloneItem(itemEnt, left)
                    lp.tryCloneItem(itemEnt, right)
                end
            end
        end,
        target = {
            type = "ITEM",
            filter = function (selfEnt, ppos)
                local itemEnt = lp.posToItem(ppos)
                return itemEnt and not lp.hasTag(itemEnt, lib.tags.FOOD)
            end
        }
    })
end