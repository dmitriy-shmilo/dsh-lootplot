local runStats = require("shared.run_stats")
local lib = require("shared.lib")

local run = nil
local function getRun()
    if run then return run end
    run = lp.singleplayer.getRun()
    if not run then
        return nil
    end
    return run
end

umg.on("lootplot:winGame", function()
    local run = getRun()
    if not run then return end
    runStats:finishRun()
end)


umg.on("lootplot:loseGame", function()
    local run = getRun()
    if not run then return end
    runStats:finishRun()
end)

lib.hooks.addAfterCallback(lp, "initialize", function()
    runStats:startRun()
end)