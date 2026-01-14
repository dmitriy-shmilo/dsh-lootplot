local globalScale = require("client.global_scale")
local DescriptionBox = require("client.DescriptionBox")
local query = require("shared.query")

local toolbarState = {
    isActive = false,
    searchButton = {
        x = 0,
        y = 0,
        width = 16,
        height = 16,
        isActive = false,
        getTooltip = function ()
            if query.isSearchActive() then
                return "Clear search."
            else
                return "Search items by name or description."
            end
        end
    },
    triggerFilters = {
        "PULSE",
        "REROLL",
        "ROTATE",
        "LEVEL_UP",
        "BUY",
        "UNLOCK",
        "BUFF",
        "DESTROY"
    },
    triggerFilterGroupButton = {
        x = 0,
        y = 0,
        width = 16,
        height = 16,
        isActive = false,
        getTooltip = function(self)
            if self.isActive then
                return "Clear trigger filtering."
            else
                return "Filter items by triggers."
            end
        end
    },
    triggerFilterButtons = {},
    tooltip = nil
}

for i, t in ipairs(toolbarState.triggerFilters) do
    local button = {
        width = 16,
        height = 16,
        x = 0,
        y = 0,
        trigger = t,
        image = "dsh_trigger_" .. t:lower(),
        isActive = false,
        click = function (self)
            self.isActive = not self.isActive
            query.setTriggerFilter(self.trigger, self.isActive)
        end,
        getTooltip = function() return t end
    }
    table.insert(toolbarState.triggerFilterButtons, button)
end

local function isClicked(button, x, y)
    return x > button.x - button.width / 2
    and x < button.x + button.width / 2
    and y > button.y - button.height / 2
    and y < button.y + button.height / 2
end

local function tryClick(button, x, y)
    if not button.click then return false end
    if not isClicked(button, x, y) then return false end
    button:click()
    return true
end

local function isHowering(item, x, y)
    return x > item.x - item.width / 2
    and x < item.x + item.width / 2
    and y > item.y - item.height / 2
    and y < item.y + item.height / 2
end

local function getHoweredItem(x, y)
    if isHowering(toolbarState.searchButton, x, y) then return toolbarState.searchButton end
    if isHowering(toolbarState.triggerFilterGroupButton, x, y) then return toolbarState.triggerFilterGroupButton end

    for _, b in pairs(toolbarState.triggerFilterButtons) do
        if isHowering(b, x, y) then return b end
    end
    return nil
end

function toolbarState.searchButton:click()
    if query.isSearchActive() then
        query.search("")
    else
        local chatbox = chat.getChatBoxElement()
        if chatbox:isChatOpen() then return end
        chatbox:openChat()
        chatbox:inputText("/q ")
    end
end

function toolbarState.triggerFilterGroupButton:click()
    self.isActive = not self.isActive
    if not self.isActive then
        for _, b in ipairs(toolbarState.triggerFilterButtons) do
            b.isActive = false
        end
        query.clearTriggerFilters()
    end
end

umg.on("@update", function()
    local howered = getHoweredItem(input.getPointerPosition())
    if howered and howered.getTooltip then
        toolbarState.tooltip = howered:getTooltip()
        toolbarState.descriptionBox:clearContents()
        toolbarState.descriptionBox:addRichText(toolbarState.tooltip)
    else
        toolbarState.tooltip = nil
    end

    if toolbarState.isActive then return end
    if lp.singleplayer.getRun() then
        toolbarState.isActive = true
    end
end)

umg.on("@mousepressed", function(x, y, button, istouch, presses)
    tryClick(toolbarState.searchButton, x, y)
    tryClick(toolbarState.triggerFilterGroupButton, x, y)
    if toolbarState.triggerFilterGroupButton.isActive then
        for _, b in ipairs(toolbarState.triggerFilterButtons) do
            tryClick(b, x, y)
        end
    end
end)

umg.on("@draw", 1, function()
    if not toolbarState.isActive then return end
    local scale = globalScale:get()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    love.graphics.setLineWidth(scale)

    if query.isSearchActive() then
        rendering.drawImage(
            "dsh_magnifying_glass_crossed",
            toolbarState.searchButton.x,
            toolbarState.searchButton.y,
            0,
            scale,
            scale)
    else
        rendering.drawImage(
            "dsh_magnifying_glass",
            toolbarState.searchButton.x,
            toolbarState.searchButton.y,
            0,
            scale,
            scale)
    end

    rendering.drawImage(
        "dsh_trigger",
        toolbarState.triggerFilterGroupButton.x,
        toolbarState.triggerFilterGroupButton.y,
        0,
        scale,
        scale)

    if toolbarState.triggerFilterGroupButton.isActive then
        for i, b in ipairs(toolbarState.triggerFilterButtons) do
            if b.isActive then
                love.graphics.setColor(1, 1, 1, 1)
            else
                love.graphics.setColor(1, 1, 1, 0.3)
            end

            rendering.drawImage(
                b.image,
                b.x,
                b.y,
                0,
                scale,
                scale)
        end
    end

    if toolbarState.tooltip then
        local mx, my = input.getPointerPosition()
        local idealDescW = screenWidth / 3
        local bestDescW, descH = toolbarState.descriptionBox:getBestFitDimensions(idealDescW)
        local descW = math.min(idealDescW, bestDescW)
        local descRegion = layout.Region(
            math.max(mx - 16 - descW, 16),
            math.min(my + 16, screenHeight - descH - 16),
            descW,
            descH
        )
        toolbarState.descriptionBox:draw(descRegion:get())
    end
end)

local BUTTON_MARGIN = 16
local BUTTON_SIZE = 16

local function updatePositions(w, h)
    local scale = globalScale:get()

    toolbarState.searchButton.width = BUTTON_SIZE * scale
    toolbarState.searchButton.height = BUTTON_SIZE * scale
    toolbarState.searchButton.x = w - toolbarState.searchButton.width * 1.5
    toolbarState.searchButton.y = toolbarState.searchButton.width * 1.5

    toolbarState.triggerFilterGroupButton.width = BUTTON_SIZE * scale
    toolbarState.triggerFilterGroupButton.height = BUTTON_SIZE * scale
    toolbarState.triggerFilterGroupButton.x = w - toolbarState.searchButton.width * 1.5
    toolbarState.triggerFilterGroupButton.y = toolbarState.searchButton.y + toolbarState.searchButton.height + BUTTON_MARGIN

    for i, b in ipairs(toolbarState.triggerFilterButtons) do
        b.width = BUTTON_SIZE * scale
        b.height = BUTTON_SIZE * scale
        b.x = toolbarState.triggerFilterGroupButton.x - i * (b.width + BUTTON_MARGIN)
        b.y = toolbarState.triggerFilterGroupButton.y
    end
end


umg.on("@load", function()
    toolbarState.descriptionBox = DescriptionBox()
    updatePositions(love.graphics.getDimensions())
end)

umg.on("@resize", updatePositions)