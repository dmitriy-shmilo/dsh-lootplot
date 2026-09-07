local config = require("shared.config")
local etypes = require("shared.etypes")
local loc = localization.localize

if not config.weakerCurseButton then return end

etypes.redefineSlot("lootplot.s0:curse_button_slot", "dsh.dd:curse_button_slot", {
    image = "curse_button_up",

    name = loc("Curse Button"),
    activateDescription = loc("Spawns a random Curse somewhere!"),

    activateAnimation = {
        activate = "curse_button_hold",
        idle = "curse_button_up",
        duration = 0.1
    },

    baseMaxActivations = 2,
    baseMoneyGenerated = 15,

    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.LEGENDARY,

    onDraw = function(ent)
        if not lp.canActivateEntity(ent) then
            ent.opacity = 0.3
        else
            ent.opacity = 1
        end
    end,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            local cEnt = lp.curses.spawnRandomCurse(ppos:getPlot(), ent.lootplotTeam)
            if cEnt then cEnt.lives = 6 end
        end
    end,
})