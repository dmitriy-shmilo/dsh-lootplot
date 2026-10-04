local lib = require("shared.lib")

local worldDimensions = nil

local function ensureWorldDimensions(run)
	local plot = run:getPlot()
	local topPPos = plot:getPPos(0, 0)
	local bottomPPos = plot:getPPos(
		lp.singleplayer.constants.WORLD_PLOT_SIZE[1] - 1,
		lp.singleplayer.constants.WORLD_PLOT_SIZE[2] - 1
	)

	local topWorldX, topWorldY = topPPos:getWorldPos()
	local bottomWorldX, bottomWorldY = bottomPPos:getWorldPos()
	topWorldX = topWorldX - lp.constants.WORLD_SLOT_DISTANCE / 2
	topWorldY = topWorldY - lp.constants.WORLD_SLOT_DISTANCE / 2
	bottomWorldX = bottomWorldX + lp.constants.WORLD_SLOT_DISTANCE / 2
	bottomWorldY = bottomWorldY + lp.constants.WORLD_SLOT_DISTANCE / 2

	worldDimensions = {
		top = topWorldY,
		left = topWorldX,
		bottom = bottomWorldY,
		right = bottomWorldX,
		topCutoff = bottomWorldY / 5,
		bottomCutoff = bottomWorldY / 5 * 4
	}
end

local function isSeeingBottom()
	local run = lp.singleplayer.getRun()
	if run then
		if not worldDimensions then
			ensureWorldDimensions(run)
		end
		

		local cam = camera.get()
		local _, ty = cam:toWorldCoords(0, 0)
		local _, by = cam:toWorldCoords(love.graphics.getDimensions())

		if ty < worldDimensions.topCutoff or by < worldDimensions.bottomCutoff then
			return false
		end

		return true
	end
end

local function renderActionButtons(scene, x, y, w, h)
	local buttonCount = #scene.secretSlotActionButtons
	if buttonCount > 0 then
		local r = layout.Region(x, y, w, h)
		local bottomArea
		if scene.renderTopButtons then
			bottomArea, _ = r:splitVertical(1, 5)
		else
			_, bottomArea = r:splitVertical(5, 1)
		end
		if buttonCount == 1 then
			_,bottomArea = bottomArea:splitHorizontal(1,1,1)
		else
			_,bottomArea = bottomArea:splitHorizontal(1,3,1)
		end
		local grid = bottomArea:grid(#scene.secretSlotActionButtons, 1)

		for i, button in ipairs(scene.secretSlotActionButtons) do
			local region = grid[i]:padRatio(0.2)
			button:render(region:get())
		end
	end
end

local function hijackActionButtons(scene)
	local setSelection = scene.setSelection
	scene.secretSlotActionButtons = {}
	scene.setSelection = function(scene, selection)
		setSelection(scene, selection)
		scene.secretSlotActionButtons = scene.slotActionButtons
		scene.slotActionButtons = {}
		scene.renderTopButtons = isSeeingBottom()
	end
end

local function reorderRender(state, scene)
	local oldSceneRender = scene.render
	local chatElement = chat.getChatBoxElement()
	local oldChatRender = chatElement.render
	scene.renderX = 0
	scene.renderY = 0
	scene.renderW = 0
	scene.renderH = 0
	scene.render = function(scene, x, y, w, h)
		scene.renderX = x or 0
		scene.renderY = y or 0
		scene.renderW = w or 0
		scene.renderH = h or 0
	end

	chatElement.render = function(chat, x, y, w, h)
		oldSceneRender(scene, scene.renderX , scene.renderY, scene.renderW, scene.renderH)
		renderActionButtons(scene, scene.renderX , scene.renderY, scene.renderW, scene.renderH)
		oldChatRender(chat, x, y, w, h)
	end
end

lib.hooks.addBeforeCallback(state, "push", function(state)
	if not state then return end
	local scene = state.scene
	if not scene then return end
	if scene.slotActionButtons then
		reorderRender(state, scene)
		hijackActionButtons(scene)
	end
end)

