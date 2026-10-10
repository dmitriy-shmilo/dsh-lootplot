local H_PADDING = 4

return function(gui)
	gui.elements = gui.elements or {}

	local DisclosureButton = ui.Element("ui:DisclosureButton")

	local background9 = n9slice.new({
		image = client.atlas:getTexture(),
		quad = client.assets.images["white_big"],
		padding = { 4, 5, 5, 7 },
		stretchType = "repeat"
	})

	local backgroundPressed9 = n9slice.new({
		image = client.atlas:getTexture(),
		quad = client.assets.images["white_pressed_big"],
		padding = { 4, 8, 5, 7 },
		stretchType = "repeat"
	})

	local noop = function()end

	function DisclosureButton:init(args)
		local args = args or {}
		self.backgroundColor = args.backgroundColor or { 1, 1, 1 }
		self:setIndicator(args.indicator or "dsh_disclosure_arrow")
		self.textColor = args.textColor or { 0, 0, 0}
		self.text = args.text or ""
		self.font = args.font or love.graphics.getFont()
		self._onClick = args.onClick or noop
		self._onHover = args.onHover or noop
		self._fontHeight = self.font:getHeight()
	end

	function DisclosureButton:setColor(rgba)
		if not rgba then return end
		self.backgroundColor = rgba
	end

	function DisclosureButton:setFont(font)
		self.font = font
	end

	function DisclosureButton:setText(text)
		self.text = text
	end

	function DisclosureButton:setIndicator(indicator)
		if not indicator then
			self.indicator = nil
			self._indicatorWidth = 1
			self._indicatorHeight = 1
			return
		end
		self.indicator = indicator
		local _, _, w, h = client.assets.images[indicator]:getViewport()
		self._indicatorWidth = w
		self._indicatorHeight = h
	end

	function DisclosureButton:setOnClick(onClick)
		self._onClick = onClick
	end

	function DisclosureButton:setOnHover(onHover)
		self._onHover = onHover
	end

	function DisclosureButton:isPressed()
		return self:isPressedBy("input:CLICK_PRIMARY")
	end

	function DisclosureButton:onRender(x, y, w, h)
		local gs = gui.globalScale.get()
		local pressedOffset = 0
		love.graphics.setColor(self.backgroundColor)
		if self:isPressed() then
			backgroundPressed9:draw(x, y, w / gs, h / gs, 0, gs, gs)
		else
			pressedOffset = -3 * gs
			background9:draw(x, y, w / gs, h / gs, 0, gs, gs)
		end
		love.graphics.setColor(self.textColor)
		love.graphics.print(self.text, x + H_PADDING * gs, y + h / 2 - self._fontHeight / 2 * gs + pressedOffset, 0, gs, gs)
		love.graphics.setColor(1, 1, 1)
		rendering.drawImage(self.indicator, x + w - (H_PADDING + self._indicatorWidth / 2) * gs, y + h / 2 + pressedOffset, 0, gs, gs)
	end

	function DisclosureButton:onControlRelease(cont)
		self._onClick(self, cont)
	end

	function DisclosureButton:onStartHover(mx, my)
		self._onHover(self, true, mx, my)
	end

	function DisclosureButton:onEndHover(mx, my)
		self._onHover(self, false, mx, my)
	end

	gui.elements.DisclosureButton = DisclosureButton
end