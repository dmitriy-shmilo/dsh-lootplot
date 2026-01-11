local trophies = require("shared.trophies")
local lib = require("shared.lib")
local loc = localization.localize
local meta = lp.metaprogression

local CURSES_DESTROYED_STAT = "dsh.tt:cursesDestroyed"
meta.defineStat(CURSES_DESTROYED_STAT, 0)

if server then
    umg.on("lootplot:entityDestroyed", function(ent)
        if not ent.isCurse then return end

        local t = type(ent.isInvincible)
        if t == "function" and ent:isInvincible() then
            return
        elseif t == "boolean" and ent.isInvincible then
            return
        end
        if not ent.lives or ent.lives == 0 then
            local stat = meta.getStat(CURSES_DESTROYED_STAT)
            meta.setStat(CURSES_DESTROYED_STAT, stat + 1)
        end
    end)
end

do
    local ID = "dsh.tt:cursedOnslaught"
    local CURSES_SPAWN_REQUIRED = 20
    local data = { isInvalidated = false, lastCount = 0 }
    local shouldRecountCurses = true

    -- TODO: don't subscribe if the trophy is already unlocked
    umg.on("lootplot:entitySpawned", function(ent)
        if not ent.isCurse then return end
        shouldRecountCurses = true
    end)

    umg.on("lootplot:entityDestroyed", function(ent)
        if not ent.isCurse then return end

        local t = type(ent.isInvincible)
        if t == "function" and ent:isInvincible() then
            return
        elseif t == "boolean" and ent.isInvincible then
            return
        end
        if not ent.lives or ent.lives == 0 then
            shouldRecountCurses = true
        end
    end)

    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("Cursed onslaught"),
        description = loc("Accumulate at least 20 curses on the board before level 1 ends, and win the game without ever going below 20 curses."),
        rewardDescription = loc("Unlocks a {lootplot:POINTS_COLOR}Crusader's Shield{/lootplot:POINTS_COLOR}."),
        image = "dsh_crusaders_shield",
        triggers = { "TROPHY_TICK", "WIN" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            data = trophies.getTrophyData(ID, data)

            if data.isInvalidated then return false end

            local curseCount = 0
            if shouldRecountCurses or trigger == "WIN" then
                local plot = run:getPlot()
                lib.plotForEachItem(plot, function(item)
                    if item.isCurse then
                        curseCount = curseCount + 1
                    end
                    return curseCount < CURSES_SPAWN_REQUIRED
                end)
                data.lastCount = curseCount
                trophies.setTrophyData(ID, data)
                shouldRecountCurses = false
            end

            if run:getAttribute("LEVEL") > 1 and curseCount < CURSES_SPAWN_REQUIRED then
                data.isInvalidated = true
                trophies.setTrophyData(ID, data)
                return false
            end

            if run:getAttribute("LEVEL") <= 1 and curseCount >= CURSES_SPAWN_REQUIRED then
                data.isInvalidated = false
                trophies.setTrophyData(ID, data)
                return false
            end

            if trigger == "WIN" then
                return selfTrophy:unlock()
            end

            return false
        end
    })

    lp.defineItem("dsh.tt:crusaders_shield", {
        name = loc("Crusader's Shield"),
        activateDescription = loc("Drains all activations from target curses, does not affect injuctions."),
        image = "dsh_crusaders_shield",
        baseMaxActivations = 1,
        rarity = lp.rarities.RARE,
        basePrice = 14,
        triggers = { "PULSE" },
        shape = lp.targets.RookShape(1),
        lootplotTags = { lib.tags.SHIELD },
        isEntityTypeUnlocked = function()
            return meta.getFlag(ID)
        end,
        target = {
            type = "ITEM",
            filter = function (selfEnt, ppos)
                local item = lp.posToItem(ppos)
                return item and item.isCurse and not lib.hasTag(item, lib.tags.INJUNCTION_CURSE)
            end,
            activate = function (selfEnt, ppos, targetEnt)
                targetEnt.activationCount = targetEnt.maxActivations
            end
        }
    })
end

do
    local ID = "dsh.tt:ifItBleeds"
    local CURSES_DESTROYED_REQUIRED = 5
    local data = { cursesDestroyed = 0 }

    if server then
        umg.on("lootplot:entityDestroyed", function(ent)
            if not ent.isCurse then return end
            if data.cursesDestroyed >= CURSES_DESTROYED_REQUIRED then return end

            if lp.isInvincible(ent) then return end
            data = trophies.getTrophyData(ID, data)
            data.cursesDestroyed = data.cursesDestroyed + 1
            trophies.setTrophyData(ID, data)
        end)
    end

    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("If it bleeds"),
        description = loc("Destroy 5 curses in a single run."),
        rewardDescription = loc("Unlocks a {lootplot:POINTS_COLOR}Ethereal Dagger{/lootplot:POINTS_COLOR}."),
        image = "dsh_ethereal_dagger",
        triggers = { "TROPHY_TICK" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if data.cursesDestroyed < CURSES_DESTROYED_REQUIRED then return false end
            return selfTrophy:unlock()
        end
    })

    lp.defineItem("dsh.tt:ethereal_dagger", {
        name = loc("Ethereal Dagger"),
        activateDescription = loc("Destroys target curses. Doesn't affect other items."),
        image = "dsh_ethereal_dagger",
        baseMaxActivations = 2,
        basePointsGenerated = -30,
        rarity = lp.rarities.EPIC,
        basePrice = 13,
        triggers = { "PULSE" },
        shape = lp.targets.DownShape(1),
        lootplotTags = { lib.tags.SHIELD },
        isEntityTypeUnlocked = function()
            return meta.getFlag(ID)
        end,
        init = function (ent)
            local rot = lp.SEED:randomMisc(0,3)
            if rot ~= 0 then
                lp.rotateItem(ent, rot)
            end
        end,
        target = {
            type = "ITEM",
            filter = function (selfEnt, ppos)
                local item = lp.posToItem(ppos)
                return item and item.isCurse
            end,
            activate = function (selfEnt, ppos, targetEnt)
                lp.destroy(targetEnt)
            end
        }
    })
end

do
    local ID = "dsh.tt:purge"
    local CURSES_DESTROYED_REQUIRED = 100

    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("The purge"),
        description = loc("Destroy 100 curses across all runs."),
        progressDescription = function(selfTrophy)
            return tostring(meta.getStat(CURSES_DESTROYED_STAT)) .. "/" .. tostring(CURSES_DESTROYED_REQUIRED)
        end,
        rewardDescription = loc("Unlocks a {lootplot:POINTS_COLOR}Holy Hand Grenade{/lootplot:POINTS_COLOR}."),
        image = "dsh_holy_grenade",
        triggers = { "TROPHY_TICK" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if meta.getStat(CURSES_DESTROYED_STAT) < CURSES_DESTROYED_REQUIRED then return false end
            return selfTrophy:unlock()
        end
    })

    lp.defineItem("dsh.tt:holy_grenade", {
        name = loc("Holy Hand Grenade"),
        activateDescription = loc("Halves the lives of all curses in range, then destroys them."),
        image = "dsh_holy_grenade",
        baseMaxActivations = 1,
        foodItem = true,
        rarity = lp.rarities.EPIC,
        basePrice = 14,
        triggers = { "PULSE" },
        shape = lp.targets.CircleShape(4),
        lootplotTags = { lib.tags.WEAPON },
        isEntityTypeUnlocked = function()
            return meta.getFlag(ID)
        end,
        target = {
            type = "ITEM",
            filter = function (selfEnt, ppos)
                local item = lp.posToItem(ppos)
                return item and item.isCurse
            end,
            activate = function (selfEnt, ppos, targetEnt)
                targetEnt.lives = math.floor((targetEnt.lives or 0) / 2)
                lp.destroy(targetEnt)
            end
        }
    })
end

do
    local ID = "dsh.tt:cursedRace"
    local data = { isInvalidated = true }

    if server then
        umg.on("lootplot:entityTriggered", function(trigger, ent)
            if trigger ~= "SPAWN" then return end
            local type = ent:type()
            if type ~= "lootplot.s0:stone_hand" then return end
            data.isInvalidated = false
            trophies.setTrophyData(ID, data)
        end)

        umg.on("lootplot:entityActivated", function(ent)
            local type = ent:type()
            if type ~= "lootplot.s0:stone_hand" then return end
            data = trophies.getTrophyData(ID, data)
            if data.isInvalidated then return end
            data = trophies.getTrophyData(ID, data)
            if ent.totalActivationCount >= ent.stoneHand_activations then
                data.isInvalidated = true
                trophies.setTrophyData(ID, data)
            end
        end)
    end

    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("Cursed race"),
        description = loc("Win a daily run before a stone hand has a chance to spawn any curses."),
        rewardDescription = loc("Unlocks a {lootplot:POINTS_COLOR}Petrified Heart{/lootplot:POINTS_COLOR}."),
        image = "dsh_petrified_heart",
        triggers = { "WIN" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if data.isInvalidated then return end
            return selfTrophy:unlock()
        end
    })

    lp.defineItem("dsh.tt:petrified_heart", {
        name = loc("Petrified Heart"),
        activateDescription = loc("Spawns a {lootplot:DOOMED_COLOR}DOOMED-1{/lootplot:DOOMED_COLOR} null slot under target curses."),
        image = "dsh_petrified_heart",
        baseMaxActivations = 1,
        rarity = lp.rarities.EPIC,
        basePrice = 16,
        triggers = { "PULSE" },
        shape = lp.targets.UpShape(1),
        isEntityTypeUnlocked = function()
            return meta.getFlag(ID)
        end,
        init = function (ent)
            local rot = lp.SEED:randomMisc(0,3)
            if rot ~= 0 then
                lp.rotateItem(ent, rot)
            end
        end,
        target = {
            type = "ITEM",
            filter = function (selfEnt, ppos)
                local item = lp.posToItem(ppos)
                return item and item.isCurse
            end,
            activate = function (selfEnt, ppos, targetEnt)
                local slotEnt = lp.trySpawnSlot(ppos, server.entities.null_slot, selfEnt.lootplotTeam)
                if slotEnt then
                    slotEnt.doomCount = 1
                end
            end
        }
    })
end