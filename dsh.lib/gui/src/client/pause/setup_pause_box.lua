local ITEM_SPACING = 1
local ITEM_COLOR = { 215 / 255, 215 / 255, 215 / 255 }
local ITEM_IMAGE = "gear"

local gui = {}
local itemButtons = {}
local pauseBox = nil
local tooltipBox = nil
local hoveredButton = nil
local tooltip = nil
local originalRender = nil

local function refreshTooltip()
	tooltipBox:clearContents()
	if tooltip and #tooltip then
		tooltipBox:addRichText(tooltip)
	end
end

local function renderHeader(self, headerRegion)
	local titleTextBase, buttonsBase = headerRegion:splitHorizontal(2, 10)
	local titleText = titleTextBase:padUnit(0, 0, 0, 8)
	self.titleText:render(titleText:get())

	buttonsBase = buttonsBase:padUnit(0, 8)
	local x, y, w, h = buttonsBase:get()

	local runningIndex = 0
	for i, v in ipairs(itemButtons) do
		itemButtons[i]:render(x + (i - 1) * (h + ITEM_SPACING * gui.globalScale.get()), y, h, h)
	end

	love.graphics.setColor(1, 1, 1)
end

local function renderTooltip(self)
	if tooltip and #tooltip then
		local screenWidth, screenHeight = love.graphics.getDimensions()
		local mx, my = input.getPointerPosition()
		local idealDescW = screenWidth / 3
		local bestDescW, descH = tooltipBox:getBestFitDimensions(idealDescW)
		local descW = math.min(idealDescW, bestDescW)
		local descRegion = layout.Region(
			math.max(mx - 16 - descW, 16),
			math.min(my + 16, screenHeight - descH - 16),
			descW,
			descH)
		tooltipBox:draw(descRegion:get())
	end
end

local function renderContent(self, region)
	if not gui.pause.selectedItem then return end
	gui.pause.selectedItem.renderContent(self, region)
end

local function pauseBoxRender(self, x, y, w, h)
	love.graphics.setColor(objects.Color.WHITE)
	self.background:render(x, y, w, h)

	local region = layout.Region(x, y, w, h):padRatio(0.05)
	local header, content = region:splitVertical(2, 15)
	renderHeader(self, header)
	renderContent(self, content)
	renderTooltip(self)
end

local function refreshPauseBoxItems()
	local items = gui.pause.sortedItems
	if not items or #items == 1 then
		pauseBox.onRender = originalRender
		return
	else
		pauseBox.onRender = pauseBoxRender
	end

	local runningIndex = 0
	for i, item in ipairs(items) do
		local button = itemButtons[i]
		if not button then
			button = gui.elements.ImageButton()
			button.pause = {}
			table.insert(itemButtons, button)
			pauseBox:addChild(button)
		end
		button.pause.item = item
		button:setColor(item.color or ITEM_COLOR)
		button:setImage(item.image or ITEM_IMAGE)
		button:setIsPushButton(true)
		button:setOnClick(function(button)
			gui.pause.selectItem(item)
		end)
		button:setOnHover(function(button, isHover, mx, my)
			if isHover then
				hoveredButton = button
				tooltip = item.tooltip
			elseif hoveredButton == button then
				hoveredButton = nil
				tooltip = nil
			end
			refreshTooltip(mx, my)
		end)
	end

	for i = #itemButtons, #items + 1, -1 do
		pauseBox:removeChild(itemButtons[i])
		itemButtons[i] = nil
	end
end

local function refreshPauseBoxSelection()
	for _, b in pairs(itemButtons) do
		b:setIsPushed(b.pause.item == gui.pause.selectedItem)
	end
end

return function(_gui)
	gui = _gui
	gui.pause = gui.pause or {}
	function gui.pause.pauseBoxInit(self)
		pauseBox = self
		originalRender = pauseBox.onRender
		tooltipBox = gui.elements.DescriptionBox()

		gui.pause.onItemsChanged = refreshPauseBoxItems
		gui.pause.onItemUnselected = function(item)
			if item.teardownContent then
				item.teardownContent(pauseBox)
			end
		end
		gui.pause.onItemSelected = function(item)
			if item.setupContent then
				item.setupContent(pauseBox)
			end
			refreshPauseBoxSelection()
		end

		refreshPauseBoxItems()
		refreshPauseBoxSelection()
	end
end