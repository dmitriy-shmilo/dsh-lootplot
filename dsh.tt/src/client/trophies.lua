local loc = localization.localize
local trophies = require("shared.trophies")
local globalScale = require("client.global_scale")

local FRAME_PADDING = 10
local ICON_PADDING = 5
local FRAME_MARGIN = 5
local TOTAL_PAUSE = 2

local unlockQueue = {}
local currentTrophy = nil
local currentText = ""
local currentImage = nil
local currentFrameHeight = 0
local currentFrameWidth = 0
local currentIconHeight = 0
local currentIconWidth = 0
local frameDy = 0.0
local frameOffset = 0.0
local currentPause = 0.0

local font = love.graphics.getFont()
local frameTitle = loc("Trophy unlocked")

local function ensureCurrentSizes()
    if not currentTrophy then return end
    currentText = currentTrophy.title
    currentImage = currentTrophy.image

    if not currentText or not currentImage then return end

    local _, _, iconWidth, iconHeight = client.assets.images[currentImage]:getViewport()
    local scale = globalScale.get()
    currentIconWidth = iconWidth * scale
    currentIconHeight = iconHeight * scale

    local titleWidth = math.max(font:getWidth(currentTrophy.title), font:getWidth(frameTitle))

    currentFrameHeight = currentIconHeight + FRAME_PADDING * 2 + ICON_PADDING * 2
    currentFrameWidth = titleWidth + FRAME_PADDING * 2 + currentIconWidth + ICON_PADDING * 4
    frameOffset = -currentFrameHeight
end


local function ensureCurrentTrophy()
    if #unlockQueue == 0 or currentTrophy then
        return
    end

    local id = table.remove(unlockQueue)
    local trophy = trophies.definitions[id]
    if trophy then
        currentTrophy = trophy
        ensureCurrentSizes()
    else
        umg.log.error("DSH.TT - Incorrect trophy ID was received: " .. id)
    end
end

local function drawFrame(dt)
    if not currentTrophy then return end
   

    local scale = globalScale:get()
    love.graphics.setLineWidth(scale)

    -- frame
    love.graphics.setColor(0.39, 0.42, 0.46)
    love.graphics.rectangle(
        "fill",
        FRAME_MARGIN,
        FRAME_MARGIN + frameOffset,
        currentFrameWidth,
        currentFrameHeight)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle(
        "line",
        FRAME_MARGIN,
        FRAME_MARGIN + frameOffset,
        currentFrameWidth,
        currentFrameHeight)

    -- icon
    love.graphics.setColor(0.5, 0.51, 0.55)
    love.graphics.rectangle(
        "fill",
        FRAME_MARGIN + FRAME_PADDING,
        FRAME_MARGIN + frameOffset + FRAME_PADDING,
        currentIconWidth + ICON_PADDING * 2,
        currentIconHeight + ICON_PADDING * 2)
    love.graphics.setColor(0.29, 0.33, 0.39)
    love.graphics.rectangle(
        "line",
        FRAME_MARGIN + FRAME_PADDING,
        FRAME_MARGIN + frameOffset + FRAME_PADDING,
        currentIconWidth + ICON_PADDING * 2,
        currentIconHeight + ICON_PADDING * 2)

    love.graphics.setColor(1, 1, 1)
    rendering.drawImage(
        currentImage,
        FRAME_MARGIN + FRAME_PADDING + currentIconWidth / 2 + ICON_PADDING,
        FRAME_MARGIN + FRAME_PADDING + currentIconHeight / 2 + frameOffset + ICON_PADDING,
        0,
        scale,
        scale)

    -- text
    love.graphics.setColor(0.6, 0.61, 0.65)
    love.graphics.print(
        frameTitle,
        FRAME_MARGIN + FRAME_PADDING  * 2 + currentIconWidth + ICON_PADDING * 2,
        FRAME_MARGIN + frameOffset + FRAME_PADDING)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print(
        currentTrophy.title,
        FRAME_MARGIN + FRAME_PADDING * 2 + currentIconWidth + ICON_PADDING * 2,
        FRAME_MARGIN + frameOffset + FRAME_PADDING * 2)
end

local function updateFrame(dt)
    if not currentTrophy then return end

    frameDy = frameDy + 15.0 * dt
    frameOffset = math.min(FRAME_PADDING, frameOffset + frameDy)
    if frameOffset >= FRAME_PADDING then
        currentPause = currentPause + dt
    end

    if currentPause >= TOTAL_PAUSE then
        currentPause = 0
        frameOffset = 0
        frameDy = 0
        currentTrophy = nil
    end
end

umg.on("@draw", 1, function()
    if not currentTrophy then return end

    local dt = love.timer.getDelta()
    drawFrame(dt)
end)

umg.on("@update", function(dt)
    ensureCurrentTrophy()
    updateFrame(dt)
end)


if client then
    client.on("dsh.tt:trophyUnlocked", function(t)
        table.insert(unlockQueue, t)
    end)
end