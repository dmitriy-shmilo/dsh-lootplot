local trophies = require("shared.trophies")
local trophiesByTrigger = {
    PULSE = {},
    REROLL = {},
    LEVEL_UP = {}
}
local run = nil

local function getRun()
    if run then return run end
    run = lp.singleplayer.getRun()
    if not run then
        umg.log.warn("DSH.TT - Can't find the singleplayer run.")
        return nil
    end
    return run
end

umg.defineEvent("dsh.tt:pulsed")
umg.defineEvent("dsh.tt:leveled")
umg.defineEvent("dsh.tt:rerolled")

umg.on("dsh.tt:trophyDefined", function(t)
    if not t.id or not t then return end
    local triggers = t.triggers
    if not triggers or not #triggers then return end
    if t:isUnlocked() then return end

    for _, g in pairs(triggers) do
        table.insert(trophiesByTrigger[g], t)
    end
end)

umg.on("lootplot:entityActivated", function(ent)
    if not ent.type then return end
    local run = getRun()
    if not run then return end

    if ent:type() == "lootplot.s0:pulse_button_slot" then
        umg.call("dsh.tt:pulsed", run)
        return
    end

    if ent:type() == "lootplot.s0:next_level_button_slot" then
        umg.call("dsh.tt:leveled", run)
        return
    end

    if ent:type() == "lootplot.s0:reroll_button_slot" then
        umg.call("dsh.tt:rerolled", run)
        return
    end
end)

umg.on("dsh.tt:pulsed", function(run)
    for i, v in pairs(trophiesByTrigger.PULSE) do
        if not v:isUnlocked() then
            if v:tryUnlock(run, "PULSE") then
                server.broadcast("dsh.tt:trophyUnlocked", v.id)
            end
        end
    end
end)

umg.on("dsh.tt:rerolled", function(run)
    for i, v in pairs(trophiesByTrigger.REROLL) do
        if not v:isUnlocked() then
            if v:tryUnlock(run, "REROLL") then
                server.broadcast("dsh.tt:trophyUnlocked", v.id)
            end
        end
    end
end)

umg.on("dsh.tt:leveled", function(run)
    for i, v in pairs(trophiesByTrigger.LEVEL_UP) do
        if not v:isUnlocked() then
            if v:tryUnlock(run, "LEVEL_UP") then
                server.broadcast("dsh.tt:trophyUnlocked", v.id)
            end
        end
    end
end)

