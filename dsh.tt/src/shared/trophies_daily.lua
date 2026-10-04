local trophies = require("shared.trophies")
local lib = require("shared.lib")
local loc = localization.localize
local meta = lp.metaprogression

local DAILY_WINS_STAT = "dsh.tt:dailyWins"
meta.defineStat(DAILY_WINS_STAT, 0)

umg.on("dsh.tt:won", function(run)
    if run.starterItem ~= "lootplot.s0:basketball" then return false end
    local stat = meta.getStat(DAILY_WINS_STAT)
    meta.setStat(DAILY_WINS_STAT, stat + 1)
end)

do
    local ID = "dsh.tt:longDay"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("A long day"),
        description = loc("Win a hard daily run with at least two injunctions on the board."),
        image = "dsh_trophy_hard",
        triggers = { "WIN" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            local _, diff = lp.getDifficulty()
            if diff.difficulty < 2 then return false end
            if run.starterItem ~= "lootplot.s0:basketball" then return false end
            local plot = run:getPlot()
            if not plot then return false end

            local injunctionCount = 0
            lib.plotForEachItem(plot, function(item)
                if lib.hasTag(item, lib.tags.INJUNCTION_CURSE) then
                    injunctionCount = injunctionCount + 1
                end
                return injunctionCount < 2
            end)

            if injunctionCount >= 2 then
                return selfTrophy:unlock()
            end
            return false
        end,
    })
end

do
    local ID = "dsh.tt:fullWeek"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("A full week"),
        description = loc("Win seven daily runs on any difficulty."),
        image = "dsh_trophy_hard",
        triggers = { "WIN", "PULSE" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if meta.getStat(DAILY_WINS_STAT) >= 7 then
                return selfTrophy:unlock()
            end
            return false
        end,
    })
end

do
    local ID = "dsh.tt:dailyCleanup"
    meta.defineFlag(ID)

    local PROGRESS_STAT = ID .. "Progress"
    meta.defineStat(PROGRESS_STAT, 0)

    local REQUIRED_STAT = 50

    if server then
        lib.hooks.addBeforeCallback(lp, "setSlot", function(ppos, _)
            if not trophies.trophiesEnabled() then return end
            local slot = lp.posToSlot(ppos)
            if not slot then return end
            if slot:type() ~= "lootplot.s0:stone_slot" then return end
            print("set slot +1")
            local stat = meta.getStat(PROGRESS_STAT)
            if stat >= REQUIRED_STAT then return end
            meta.setStat(PROGRESS_STAT, stat + 1)
        end)

        umg.on("lootplot:entityDestroyed", function (ent)
            if not trophies.trophiesEnabled() then return end
            if ent:type() ~= "lootplot.s0:stone_slot" then return end
            if lp.isInvincible(ent) then return end
            print("entityDestroyed +1")
            local stat = meta.getStat(PROGRESS_STAT)
            if stat >= REQUIRED_STAT then return end
            meta.setStat(PROGRESS_STAT, stat + 1)
        end)
    end

    
    trophies.defineTrophy(ID, {
        title = loc("Daily cleanup"),
        description = loc("Get rid of 50 stone slots across all daily runs."),
        image = "dsh_trophy_normal",
        triggers = { "PULSE", "LEVEL_UP" },
        unlockFlag = ID,
        progressDescription = function(selfTrophy)
            return tostring(meta.getStat(PROGRESS_STAT)) .. "/" .. tostring(REQUIRED_STAT)
        end,
        tryUnlock = function (selfTrophy, run, trigger)
            if meta.getStat(PROGRESS_STAT) >= REQUIRED_STAT then
                return selfTrophy:unlock()
            end
            return false
        end,
    })
end