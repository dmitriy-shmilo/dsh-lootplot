local trophies = require("shared.trophies")
local loc = localization.localize
local meta = lp.metaprogression

do
    local ID = "dsh.tt:goodStart"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("Good start"),
        description = loc("Get 1000 points before level 1 ends."),
        image = "dsh_trophy_easy",
        triggers = { "PULSE", "TROPHY_TICK", "LEVEL_UP" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if run:getAttribute("POINTS") < 1000 then return false end
            if run:getAttribute("LEVEL") > 1 then return false end
            return selfTrophy:unlock()
        end,
    })
end

do
    local ID = "dsh.tt:tooEasy"
    meta.defineFlag(ID)
    trophies.defineTrophy(ID, {
        title = loc("This is too easy"),
        description = loc("Reach level 2 before the end of the round 2."),
        image = "dsh_trophy_normal",
        triggers = { "LEVEL_UP" },
        unlockFlag = ID,
        tryUnlock = function (selfTrophy, run, trigger)
            if run:getAttribute("LEVEL") > 1 then return false end
            if run:getAttribute("ROUND") > 2 then return false end
            return selfTrophy:unlock()
        end,
    })
end

