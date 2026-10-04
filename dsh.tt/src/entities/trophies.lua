local loc = localization.localize
local trophies = require("shared.trophies")

lp.defineItem("dsh.tt:trophy_ball", {
    image = "dsh_trophy_ball",
    name = loc("Trophy Ball"),
    triggers = { "PULSE" },
    canItemFloat = true,
    description = loc("Shows your earned community trophies."),
    basePrice = 0,
    rarity = lp.rarities.UNIQUE,
    onActivateOnce = function(ent)
        local team = ent.lootplotTeam
        local sortedTrophies = trophies.names
        table.sort(sortedTrophies, function(a, b) return a:upper() < b:upper() end)
        local side = #sortedTrophies
        if side > 8 then
            side = math.ceil(math.sqrt(#sortedTrophies))
        end
        local ppos = lp.getPos(ent)
        ppos = ppos:move(-side + 1, -math.floor(#sortedTrophies / side))

        for i, n in ipairs(sortedTrophies) do
            local slot = lp.forceSpawnSlot(ppos, server.entities["dsh.tt:trophy_display_slot"], team)
            local def = trophies.definitions[n]
            if slot and def then
                slot.name = def.title
                slot.description = def:fullDescription()
                slot.trophyImage = def.image
                slot.isUnlocked = trophies.definitions[n]:isUnlocked()
            end
            if i % side == 0 then
                ppos = ppos:move(-side * 2 + 2, 2)
            else
                ppos = ppos:move(2, 0)
            end
        end
    end
})

lp.defineSlot("dsh.tt:trophy_display_slot", {
    image = "dsh_trophy_display_slot",
    triggers = {},
    dontPropagateTriggerToItem = true,
    isItemListenBlocked = true,
    rarity = lp.rarities.UNIQUE,
    onDraw = function (selfEnt, x,y, rot, sx,sy)
        local trophyImage = selfEnt.trophyImage
        if not trophyImage then
            return
        end

        if not selfEnt.isUnlocked then
            love.graphics.setColor(0, 0, 0)
        end
        rendering.drawImage(trophyImage, x, y, 0, sx, sy)
    end
})

lp.worldgen.STARTING_ITEMS:add("dsh.tt:trophy_ball")