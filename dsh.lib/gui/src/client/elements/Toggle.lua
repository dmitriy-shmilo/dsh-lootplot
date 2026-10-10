return function(gui)
	local WIDTH = 16
	local HEIGHT = 9
	gui.elements = gui.elements or {}
	
	local Toggle = ui.Element("ui:Toggle")

	local defaultClick = function(toggle)
		toggle:setIsToggled(not toggle.isToggled)
	end

	function Toggle:init()
		self.isToggled = false
		self._onClick = defaultClick
		self._onHover = function()end
	end

	function Toggle:setIsToggled(isToggled)
		self.isToggled = isToggled
	end

	function Toggle:setOnClick(onClick)
		self._onClick = onClick
	end

	function Toggle:setOnHover(onHover)
		self._onHover = onHover
	end

	function Toggle:getSize()
		return WIDTH, HEIGHT
	end

	function Toggle:onRender(x, y, w, h)
		local gs = gui.globalScale.get()
		if self.isToggled then
			rendering.drawImage("dsh_toggle_on", x + w / 2, y + h / 2, 0, w / WIDTH, h / HEIGHT)
		else
			rendering.drawImage("dsh_toggle_off", x + w / 2, y + h / 2, 0, w / WIDTH, h / HEIGHT)
		end
	end

	function Toggle:onControlRelease(cont)
		self._onClick(self, cont)
	end

	function Toggle:onStartHover(mx, my)
		self._onHover(self, true, mx, my)
	end

	function Toggle:onEndHover(mx, my)
		self._onHover(self, false, mx, my)
	end

	gui.elements.Toggle = Toggle
end