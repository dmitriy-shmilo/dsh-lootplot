local trophies = require("shared.trophies")
local loc = localization.localize
local meta = lp.metaprogression

local MONEY_EARNED_STAT = "dsh.tt:moneyEarned"
meta.defineStat(MONEY_EARNED_STAT, 0)

if server then
    umg.on("lootplot:moneyChanged", function(_, delta)
    	if not trophies.trophiesEnabled() then return end
        if delta and delta > 0 then
            local m = meta.getStat(MONEY_EARNED_STAT)
            meta.setStat(MONEY_EARNED_STAT, m + delta)
        end
    end)
end

do
    local ID = "dsh.tt:breadwinner"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("Breadwinner"),
        description = loc("Earn a total of {lootplot:MONEY_COLOR}$100 000{/lootplot:MONEY_COLOR} across all runs."),
        progressDescription = function(selfTrophy)
            return tostring(meta.getStat(MONEY_EARNED_STAT)) .. "/100000"
        end,
        image = "dsh_trophy_easy",
        triggers = { "PULSE", "REROLL" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if meta.getStat(MONEY_EARNED_STAT) < 100000 then return false end
            return selfTrophy:unlock()
        end
    })
end

do
    local ID = "dsh.tt:savings"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("Savings"),
        description = loc("Have {lootplot:MONEY_COLOR}$100{/lootplot:MONEY_COLOR} at one time."),
        image = "dsh_trophy_easy",
        triggers = { "PULSE", "TROPHY_TICK" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if run:getAttribute("MONEY") < 100 then return false end
            return selfTrophy:unlock()
        end
    })
end

do
    local ID = "dsh.tt:collegeFund"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("College fund"),
        description = loc("Have {lootplot:MONEY_COLOR}$1000{/lootplot:MONEY_COLOR} at one time."),
        image = "dsh_trophy_normal",
        triggers = { "PULSE", "TROPHY_TICK" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if run:getAttribute("MONEY") < 1000 then return false end
            return selfTrophy:unlock()
        end
    })
end

do
    local ID = "dsh.tt:dragonHoard"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("Dragon hoard"),
        description = loc("Have {lootplot:MONEY_COLOR}$10000{/lootplot:MONEY_COLOR} at one time."),
        image = "dsh_trophy_hard",
        triggers = { "PULSE", "TROPHY_TICK" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if run:getAttribute("MONEY") < 10000 then return false end
            return selfTrophy:unlock()
        end
    })
end