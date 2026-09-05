local globalScale = require("client.global_scale")
local DescriptionBox = require("client.DescriptionBox")
local query = require("shared.query")
local overlay = require("client.overlay")
local runStats = require("client.run_stats")

local timerFont = love.graphics.newFont("/assets/fonts/monogram-extended.ttf", 64, "mono", 1) or love.graphics.getFont()

local timerState = {
    isVisible = false,
    isFinished = false,
    timeText = "00:00:00.000",
    lastTimestamp = 0,
    x = 0,
    y = 0,
    width = 0,
    height = 0
}

local H_PADDING = 4
local V_PADDING = 2

local function updateTimeDiff(startTime, endTime)
    local timeDiff = endTime - startTime
    local totalSeconds = math.floor(timeDiff / 1000)
    local milliseconds = timeDiff % 1000

    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor(totalSeconds / 60) % 60
    local seconds = totalSeconds % 60

    timerState.timeText =  string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
    timerState.lastTimestamp = currentTime
end

local function drawBackground(scale)
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", timerState.x, timerState.y, timerState.width, timerState.height, 4, 4)

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("line", timerState.x, timerState.y, timerState.width, timerState.height, 4, 4)
end

local function drawActiveTimer(scale)
    drawBackground(scale)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(timerState.timeText, timerFont, timerState.x + H_PADDING * scale, timerState.y + V_PADDING * scale)
end

local function drawFinishedTimer(scale)
    drawBackground(scale)
    local wave = (math.sin(love.timer.getTime() * 2) * 0.9 + 1) / 2

    love.graphics.setColor(1, 1, 1, wave)
    love.graphics.print(timerState.timeText, timerFont, timerState.x + H_PADDING * scale, timerState.y + V_PADDING * scale)
end

umg.on("@draw", 1, function()
    if not timerState.isVisible then return end
    local lw = love.graphics.getLineWidth()
    local scale = globalScale:get()
    love.graphics.setLineWidth(scale)

    if timerState.isFinished then
        drawFinishedTimer(scale)
    else
        drawActiveTimer(scale)
    end

    love.graphics.setLineWidth(lw)
    love.graphics.setColor(1, 1, 1, 1)
end)

umg.on("@update", function(dt)
    local runData = runStats:getData()
    if runData.startTimestamp <= 0 then
        timerState.timeText = "00:00:00.000"
        return
    end

    timerState.isFinished = runData.isFinished

    if runData.isFinished and runData.endTimestamp >= 0 then
        updateTimeDiff(runData.startTimestamp, runData.endTimestamp)
        return
    end

    local currentTime = love.timer.getTime() * 1000
    updateTimeDiff(runData.startTimestamp, currentTime)
end)

local function updatePositions(w, h)
    local scale = globalScale:get()

    local textWidth = timerFont:getWidth(timerState.timeText)
    local textHeight = timerFont:getHeight()

    timerState.width = textWidth + 2 * H_PADDING * scale
    timerState.height = textHeight + 2 * V_PADDING * scale
    timerState.x = w / 2 - timerState.width / 2
    timerState.y = 20
end

umg.on("@load", function()
    updatePositions(love.graphics.getDimensions())
end)

umg.on("@resize", updatePositions)


function timerState:setVisible(isVisible)
    self.isVisible = isVisible
    updatePositions(love.graphics.getDimensions())
end

return timerState