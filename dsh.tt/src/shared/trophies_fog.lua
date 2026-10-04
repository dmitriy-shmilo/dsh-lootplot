local trophies = require("shared.trophies")
local lib = require("shared.lib")
local loc = localization.localize
local meta = lp.metaprogression

local FOG_REVEALED_STAT = "dsh.tt:fogRevealed"
meta.defineStat(FOG_REVEALED_STAT, 0)

if server then
    umg.on("lootplot:plotFogChanged", function(_, _, _, hasFog)
        if not trophies.trophiesEnabled() then return end
        if not hasFog then
            local stat = meta.getStat(FOG_REVEALED_STAT)
            meta.setStat(FOG_REVEALED_STAT, stat + 1)
        end
    end)
end

do
    local ID = "dsh.tt:lookingAround"
    local RANDOM_SHAPE_NAME = loc("RANDOM-10")
    local FOG_REVEALED_REQUIRED = 10000

    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("Looking around"),
        description = loc("Clear 10000 slots from fog across all runs."),
        progressDescription = function(selfTrophy)
            return tostring(meta.getStat(FOG_REVEALED_STAT)) .. "/" .. tostring(FOG_REVEALED_REQUIRED)
        end,
        rewardDescription = loc("Unlocks a {lootplot:POINTS_COLOR}Map Scrap{/lootplot:POINTS_COLOR}."),
        image = "dsh_map_scrap",
        triggers = { "PULSE", "LEVEL_UP" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if meta.getStat(FOG_REVEALED_STAT) < FOG_REVEALED_REQUIRED then return false end
            return selfTrophy:unlock()
        end
    })

    lp.defineItem("dsh.tt:map_scrap", {
        name = loc("Map Scrap"),
        activateDescription = loc("Reveals fog in a random area."),
        image = "dsh_map_scrap",
        foodItem = true,
        baseMaxActivations = 1,
        rarity = lp.rarities.RARE,
        basePrice = 12,
        canItemFloat = true,
        shape = {
            name = RANDOM_SHAPE_NAME,
            relativeCoords = {
                {0, 0}
            }
        },
        lootplotTags = { lib.tags.FOOD },
        isEntityTypeUnlocked = function()
            return meta.getFlag(ID)
        end,
        init = function (itemEnt)
            local coords = lp.targets.CircleShape(6).relativeCoords
            local result = {}
            local indices = {}
            for i = 1, #coords do
                table.insert(indices, i)
            end

            indices = lib.shuffledRandom(indices)
            for i = 1, 10 do
                table.insert(result, coords[indices[i]])
            end

            itemEnt.shape = {
                name = RANDOM_SHAPE_NAME,
                relativeCoords = result
            }
        end,
        canActivate = function(selfEnt)
            local targets = lp.targets.getTargets(selfEnt)
            local plot = lp.getPos(selfEnt):getPlot()

            for _, ppos in ipairs(targets) do
                if not plot:isFogRevealed(ppos, selfEnt.lootplotTeam) then return true end
            end
            return false
        end,
        onActivate = function(selfEnt)
            local targets = lp.targets.getTargets(selfEnt)
            local plot = lp.getPos(selfEnt):getPlot()

            for _, ppos in ipairs(targets) do
                plot:setFogRevealed(ppos, selfEnt.lootplotTeam, true)
            end
        end,
        target = {
            filter = function (selfEnt, ppos)
                local plot = lp.getPos(selfEnt):getPlot()
                return not plot:isFogRevealed(ppos, selfEnt.lootplotTeam)
            end
        }
    })
end

do
    local ID = "dsh.tt:keepingToYourself"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("Keeping to yourself"),
        description = loc("Win a run with 150 or less revealed slots."),
        image = "dsh_trophy_normal",
        triggers = { "WIN" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            local fogs = run:getPlot().fogs[lp.singleplayer.PLAYER_TEAM]
            local revealCount = 0
            for x = 0, fogs.width - 1 do
                for y = 0, fogs.height - 1 do
                    local isFog = fogs:get(x,y)
                    if not isFog then revealCount = revealCount + 1 end
                    if revealCount > 150 then return false end
                end
            end
            return selfTrophy:unlock()
        end
    })
end

do
    local shouldRecountFog = true
    local lastRevealCount = 0
    if server then
        umg.on("lootplot:plotFogChanged", function(_, _, _, hasFog)
            if not hasFog then
                lastRevealCount = lastRevealCount + 1
            elseif lastRevealCount > 1 then
                lastRevealCount = lastRevealCount - 1
            end
        end)
    end

    local ID = "dsh.tt:enduringExplorer"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("Enduring explorer"),
        description = loc("Reveal every tile on the plot."),
        image = "dsh_honey_jar",
        rewardDescription = loc("Unlocks a {lootplot:POINTS_COLOR}Honey Jar{/lootplot:POINTS_COLOR}."),
        triggers = { "PULSE", "LEVEL_UP" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            local fogs = run:getPlot().fogs[lp.singleplayer.PLAYER_TEAM]

            if shouldRecountFog or trigger == "LEVEL_UP" then
                lastRevealCount = 0
                for x = 0, fogs.width - 1 do
                    for y = 0, fogs.height - 1 do
                        local isFog = fogs:get(x,y)
                        if not isFog then
                            lastRevealCount = lastRevealCount + 1
                        end
                    end
                end

                shouldRecountFog = false
            end

            if lastRevealCount >= fogs.width * fogs.height then
                return selfTrophy:unlock()
            end

            return false
        end
    })

    lp.defineItem("dsh.tt:honey_jar", {
        name = loc("Honey Jar"),
        activateDescription = loc("Makes locked slots earn {lootplot:MONEY_COLOR}+$5{/lootplot:MONEY_COLOR}."),
        image = "dsh_honey_jar",
        foodItem = true,
        baseMaxActivations = 1,
        rarity = lp.rarities.RARE,
        basePrice = 10,
        canItemFloat = true,
        shape = lp.targets.RookShape(1),
        lootplotTags = { lib.tags.FOOD },
        isEntityTypeUnlocked = function()
            return meta.getFlag(ID)
        end,
        target = {
            type = "SLOT",
            filter = function (selfEnt, ppos, targetEnt)
                return targetEnt and targetEnt:type() == "lootplot.unlocks:locked_slot"
            end,
            activate = function(selfEnt, ppos, targetEnt)
                lp.modifierBuff(targetEnt, "moneyGenerated", 5, selfEnt)
            end
        }
    })
end