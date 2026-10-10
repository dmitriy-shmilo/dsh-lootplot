return function(gui)
	local WIDTH = 16
	local HEIGHT = 9
	gui.elements = gui.elements or {}

	local PagedUniformList = ui.Element("ui:PagedUniformList")

	local function noop()end

	local function updateHeight(self, newHeight, gs)
		local itemsPerPage = math.max(1, math.floor(newHeight / self.itemHeight / gs))
		self._lastHeight = newHeight
		self._itemsPerPage = itemsPerPage
		self._totalPages = math.max(1, math.ceil(#self._itemCache / itemsPerPage))
		self:setPage(1) -- TODO: calculate new page index
	end

	local function recycleItems(self, oldTop, oldBottom, newTop, newBottom)
		for i = oldTop, oldBottom do
			local item = self._itemCache[i]
			if item then
				self.teardownItem(self, i, item)
			end
		end

		for i = newTop, newBottom do
			local item = self._itemCache[i]
			if item then
				self.setupItem(self, i, item)
			end
		end

		-- TODO: skip recycling intersecting items
	end

	function PagedUniformList:init(args)
		args = args or {}
		self.itemHeight = args.itemHeight or 45
		self.renderItem = args.renderItem or noop
		self.setupItem = args.prepareItem or noop
		self.teardownItem = args.teardownItem or noop
		self._currentPage = 1
		self._totalPages = 1
		self._lastHeight = -1
		self._topItemIndex = -1
		self._bottomItemIndex = -1
		self._itemsPerPage = 1
		self._itemCache = args.items or {}
	end

	function PagedUniformList:setItems(items)
		local itemCount = #items
		self._itemCache = items
		self._totalPages = math.max(1, math.ceil(#items / self._itemsPerPage))
		self:setPage(1) -- TODO: do better
	end

	function PagedUniformList:setPage(pageIndex)
		if self._lastHeight < 1 then return end
		if #self._itemCache < 1 then return end

		if pageIndex < 1 then
			pageIndex = 1
		elseif pageIndex > self._totalPages then
			pageIndex = self._totalPages
		end
		local ipp = self._itemsPerPage
		local oldTop = self._topItemIndex
		local oldBot = self._bottomItemIndex
		local newTop = ipp * (pageIndex - 1) + 1
		local newBot = ipp * (pageIndex - 1) + ipp
		self._topItemIndex = newTop
		self._bottomItemIndex = newBot
		self._currentPage = pageIndex

		recycleItems(self, oldTop, oldBot, newTop, newBot)
	end

	function PagedUniformList:nextPage()
		self:setPage(self._currentPage + 1)
	end

	function PagedUniformList:previousPage()
		self:setPage(self._currentPage - 1)
	end

	function PagedUniformList:getTotalPages()
		return self._totalPages
	end

	function PagedUniformList:getItemsPerPage()
		return self._itemsPerPage
	end

	function PagedUniformList:hasNextPage()
		return self._currentPage < self._totalPages
	end

	function PagedUniformList:hasPreviousPage()
		return self._currentPage > 1
	end

	function PagedUniformList:onRender(x, y, w, h)
		local gs = gui.globalScale.get()
		if h ~= self._lastHeight then
			updateHeight(self, h, gs)
		end

		for i = self._topItemIndex, self._bottomItemIndex do
			local item = self._itemCache[i]
			if item then
				local offset = i - self._topItemIndex
				self.renderItem(self, i, item, x, y + offset * self.itemHeight * gs, w, self.itemHeight * gs)
			end
		end
	end

	gui.elements.PagedUniformList = PagedUniformList
end