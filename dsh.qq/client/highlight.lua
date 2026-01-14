local query = require("shared.query")

local RENDER_AFTER_ENTITY_ORDER = 1
local RENDER_BEFORE_ENTITY_ORDER = -1

umg.on("rendering:drawEntity", RENDER_BEFORE_ENTITY_ORDER, function (selfEnt, x, y, rot, sx, sy)
    if not query.isActive() then
        selfEnt.opacity = 1.0
        selfEnt.searchMatch = nil
        return
    end

    if lp.isItemEntity(selfEnt) then
        if query.isMatch(selfEnt) then
            selfEnt.opacity = 1.0
            selfEnt.searchMatch = true
        else
            selfEnt.opacity = 0.2
            selfEnt.searchMatch = false
        end
    end
end)

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function (selfEnt, x, y, rot, sx, sy)
    if not query.isActive() then return end
    if selfEnt.searchMatch then
        local time = love.timer.getTime()
        local scale = 1 + math.sin(time * 4) / 10.0
        love.graphics.setColor(1, 0.843, 0.1, 1)
        rendering.drawImage("select", x, y, 0, scale, scale)
        love.graphics.setColor(1, 1, 1, 1)
    end
end)