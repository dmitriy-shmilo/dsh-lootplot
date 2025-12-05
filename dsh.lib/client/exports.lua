local lib = {
    colors = {
        NICE_GREEN = objects.Color(49/255,189/255,32/255)
    }
}

local TEXT_MAX_WIDTH = 200

-- helper functions lifted from lootplot.s0/shared/helper.lua
local function printCenterWithOutline(text, x, y, rot, sx, sy, oy, kx, ky)
    local r, g, b, a = love.graphics.getColor()
    local ox = TEXT_MAX_WIDTH / 2
    love.graphics.setColor(0, 0, 0, a)
    for outY = -1, 1 do
        for outX = -1, 1 do
            if not (outX == 0 and outY == 0) then
                love.graphics.printf(text, x + outX * sx, y + outY * sy, TEXT_MAX_WIDTH, "center", rot, sx, sy, ox, oy, kx, ky)
            end
        end
    end
    love.graphics.setColor(r, g, b, a)
    love.graphics.printf(text, x, y, TEXT_MAX_WIDTH, "center", rot, sx, sy, ox, oy, kx, ky)
end

lib.drawDelayItemNumber = function (ent, delayCount)
    local totActivs = (ent.totalActivationCount or 0)
    local remaining = delayCount - totActivs
    if totActivs > 0 then
        local txt,color
        local dx,dy=0,3
        if remaining <= 1 then
            txt = "!!!"
            color = NICE_GREEN
            local t = (love.timer.getTime() * 10)
            dx = 2 * math.sin(t)
        else
            txt = tostring(remaining)
            color = lp.COLORS.INFO_COLOR
        end
        love.graphics.push("all")
        love.graphics.setColor(color)
        printCenterWithOutline(txt, ent.x + dx, ent.y + dy, 0, 1,1, 20, 0, 0)
        love.graphics.pop()
    end
end

umg.expose("lib", lib)

return lib