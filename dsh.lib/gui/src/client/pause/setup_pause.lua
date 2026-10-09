local function noop()end

local pauseBoxInternal = {
	isSetup = false
}

local function setupStandardControls(self)
	if not pauseBoxInternal.isSetup then
		pauseBoxInternal.gameSpeedLabel = self.gameSpeedLabel
		pauseBoxInternal.gameSpeedSlider = self.gameSpeedSlider
		pauseBoxInternal.sfxLabel = self.sfxLabel
		pauseBoxInternal.sfxSlider = self.sfxSlider
		pauseBoxInternal.musicLabel = self.musicLabel
		pauseBoxInternal.musicSlider = self.musicSlider

		pauseBoxInternal.quitButton = self.quitButton
		pauseBoxInternal.resumeButton = self.resumeButton
		pauseBoxInternal.isSetup = true
	else
		self:addChild(pauseBoxInternal.gameSpeedLabel)
		self:addChild(pauseBoxInternal.gameSpeedSlider)
		self:addChild(pauseBoxInternal.sfxLabel)
		self:addChild(pauseBoxInternal.sfxSlider)
		self:addChild(pauseBoxInternal.musicLabel)
		self:addChild(pauseBoxInternal.musicSlider)
		self:addChild(pauseBoxInternal.quitButton)
		self:addChild(pauseBoxInternal.resumeButton)
	end
end

local function teardownStandardControls(self)
	self:removeChild(pauseBoxInternal.gameSpeedLabel)
	self:removeChild(pauseBoxInternal.gameSpeedSlider)
	self:removeChild(pauseBoxInternal.sfxLabel)
	self:removeChild(pauseBoxInternal.sfxSlider)
	self:removeChild(pauseBoxInternal.musicLabel)
	self:removeChild(pauseBoxInternal.musicSlider)
	self:removeChild(pauseBoxInternal.quitButton)
	self:removeChild(pauseBoxInternal.resumeButton)
end

local function renderStandardControls(self, contentRegion)
	local contentBase, buttonBase = contentRegion:splitVertical(12, 3)
	contentBase = contentBase:padRatio(0.15)

	local leftSliders, _, rightSliders = contentBase:splitHorizontal(1,0.2, 1)

	local _, gameSpeedSliderBase = leftSliders:splitVertical(1, 2, 1)
	local gameSpeedSliderLabel, gameSpeedSlider = gameSpeedSliderBase:padRatio(0.2):splitVertical(1, 1)
	self.gameSpeedLabel:render(gameSpeedSliderLabel:get())
	self.gameSpeedSlider:render(gameSpeedSlider:get())

	local sfxSliderBase, musicSliderBase = rightSliders:splitVertical(1,1)
	local sfxLabel, sfxSlider = sfxSliderBase:padRatio(0.2):splitVertical(1, 1)
	local musicLabel, musicSlider = musicSliderBase:padRatio(0.2):splitVertical(1, 1)
	self.musicLabel:render(musicLabel:get())
	self.musicSlider:render(musicSlider:get())
	self.sfxSlider:render(sfxSlider:get())
	self.sfxLabel:render(sfxLabel:get())

	local buttonContent = buttonBase:padRatio(0.3, 0, 0.3, 0)
	local quitButton, _, resumeButton = buttonContent:splitHorizontal(1, 0.2, 1)
	self.quitButton:render(quitButton:get())
	self.resumeButton:render(resumeButton:get())
end

local function setupDefaults(gui)
	local defaultItemGroup = {
		id = "_default",
		priority = -1,
		items = {
			[1] = {
				color = { r = 215 / 255, g = 215 / 255, b = 215/255 },
				tooltip = "Main Settings",
				image = "gear",
				renderContent = renderStandardControls,
				setupContent = setupStandardControls,
				teardownContent = teardownStandardControls
			}
		}
	}

	gui.pause.registerItemGroup(defaultItemGroup)
	gui.pause.selectItem(defaultItemGroup.items[1])
end


return function(gui)
	if gui.pause then
		umg.log.error("Prevented an attempt to register gui.pause twice.")
		return
	end

	gui.pause = gui.pause or {}
	gui.pause.itemGroups = {}
	gui.pause.sortedItemGroups = {}
	gui.pause.sortedItems = {}
	gui.pause.selectedItem = nil
	gui.pause.onItemsChanged = gui.pause.onItemsChanged or noop
	gui.pause.onItemSelected = gui.pause.onItemSelected or noop
	gui.pause.onItemUnselected = gui.pause.onItemUnselected or noop

	function gui.pause.registerItemGroup(itemGroup)
		local id = itemGroup.id
		if not id then
			umg.log.error("Can't register pause item group: no id given.", base.inspect(itemGroup, { depth = 1 }))
			return
		end

		if gui.pause.itemGroups[id] then
			umg.log("Prevented an attempt to register a pause item group with an existing id", id)
			return
		end

		if not itemGroup.priority then
			itemGroup.priority = 0
		end

		gui.pause.itemGroups[id] = itemGroup
		table.insert(gui.pause.sortedItemGroups, id) -- TODO: actually sort

		gui.pause.reloadItems()
	end

	function gui.pause.reloadItems()
		local sortedItems = gui.pause.sortedItems
		table.clear(sortedItems)

		local runningIndex = 0
		for _, v in ipairs(gui.pause.sortedItemGroups) do
			local itemGroup = gui.pause.itemGroups[v]

			for _, item in ipairs(itemGroup.items) do
				table.insert(gui.pause.sortedItems, item)
			end
		end

		gui.pause.onItemsChanged()
	end

	function gui.pause.selectItem(item)
		local prev = gui.pause.selectedItem
		gui.pause.selectedItem = item
		gui.pause.onItemUnselected(prev)
		gui.pause.onItemSelected(item)
	end

	setupDefaults(gui)
end