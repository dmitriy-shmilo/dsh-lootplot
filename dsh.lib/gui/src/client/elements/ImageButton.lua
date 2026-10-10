return function(gui)
	gui.elements = gui.elements or {}

	local ImageButton = ui.Element("ui:ImageButton")

	local background9 = n9slice.new({
		image = client.atlas:getTexture(),
		quad = client.assets.images["white_big"],
		padding = { 4, 5, 5, 7 },
		stretchType = "repeat"
	})

	local backgroundPressed9 = n9slice.new({
		image = client.atlas:getTexture(),
		quad = client.assets.images["white_pressed_big"],
		padding = { 4, 5, 5, 7 },
		stretchType = "repeat"
	})

	local noop = function()end

	function ImageButton:init()
		self.backgroundColor = { 1, 1, 1}
		self.image = ""
		self.isPushButton = false
		self.isPushed = false
		self._onClick = noop
		self._onHover = noop
	end

	function ImageButton:setColor(rgba)
		if not rgba then return end
		self.backgroundColor = rgba
	end

	function ImageButton:setImage(image)
		self.image = image
	end

	function ImageButton:setIsPushButton(isPushButton)
		if self.isPushButton == isPushButton then return end
		self.isPushButton = isPushButton
		self.isPushed = false
	end

	function ImageButton:setIsPushed(isPushed)
		if not self.isPushButton then return end
		self.isPushed = isPushed
	end

	function ImageButton:setOnClick(onClick)
		self._onClick = onClick
	end

	function ImageButton:setOnHover(onHover)
		self._onHover = onHover
	end

	function ImageButton:isPressed()
		return self:isPressedBy("input:CLICK_PRIMARY") or self.isPushed
	end

	function ImageButton:onRender(x, y, w, h)
		local gs = gui.globalScale.get()
		love.graphics.setColor(self.backgroundColor)
		if self:isPressed() then
			backgroundPressed9:draw(x, y, w / gs, h / gs, 0, gs, gs)
		else
			background9:draw(x, y, w / gs, h / gs, 0, gs, gs)
		end
		love.graphics.setColor(1, 1, 1)

		if self.image then
			if self:isPressed() then
				rendering.drawImage(self.image, x + w / 2, y + h / 2, 0, gs, gs)
			else
				rendering.drawImage(self.image, x + w / 2, y + h / 2 - 3 * gs, 0, gs, gs)
			end
		end
	end

	function ImageButton:onControlRelease(cont)
		self._onClick(self, cont)
	end

	function ImageButton:onStartHover(mx, my)
		self._onHover(self, true, mx, my)
	end

	function ImageButton:onEndHover(mx, my)
		self._onHover(self, false, mx, my)
	end

	gui.elements.ImageButton = ImageButton
end