local globalScale = require("client.global_scale")
local lib = require("shared.lib")

local RENDER_AFTER_ENTITY_ORDER = 10001
local ITEM_SIZE = 16
local SLOT_SIZE = 24

local defaultFontLarge = love.graphics.newFont("/assets/fonts/monogram-extended.ttf", 64, "mono", 1) or love.graphics.getFont()

local function lerp(a, b, t)
	return a + t * (b - a)
end

local function lerpColor(c1, c2, t)
	t = math.max(0, math.min(1, t))
	return lerp(c1.r, c2.r, t), lerp(c1.g, c2.g, t), lerp(c1.b, c2.b, t), lerp(c1.a or 1, c2.a or 1, t)
end

local function normalize(t, min, max)
	return math.max(0, math.min(1, (t - min) / (max - min)))
end

local function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text)
	local font = love.graphics.getFont()
	local textWidth = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print(text, rectX + rectWidth / 2, rectY + rectHeight / 2, 0, 1, 1, textWidth / 2, textHeight / 2)
end

local function drawOverlaySquare(left, top, opacity, color)
	love.graphics.setColor(0, 0, 0, 0.75 * opacity)
	love.graphics.rectangle("fill", left, top, SLOT_SIZE, SLOT_SIZE, 2, 2)

	love.graphics.setColor(color.r, color.g, color.b, 0.75 * opacity)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", left, top, SLOT_SIZE, SLOT_SIZE, 2, 2)
end

local overlays = {
	rarity = {
		onItemDraw = function (self, selfEnt, x, y, rot, sx, sy)
			local rarity = selfEnt.rarity
			local opacity = selfEnt.opacity or 1

			if not rarity then rarity = lp.rarities.UNIQUE end
			local top, left = y - SLOT_SIZE / 2, x - SLOT_SIZE / 2
			drawOverlaySquare(left, top, opacity, rarity.color)

			local text = ""
			if rarity == lp.rarities.COMMON then
				text = "I"
			elseif rarity == lp.rarities.UNCOMMON then
				text = "II"
			elseif rarity == lp.rarities.RARE then
				text = "III"
			elseif rarity == lp.rarities.EPIC then
				text = "IV"
			elseif rarity == lp.rarities.LEGENDARY then
				text = "V"
			else
				text = "*"
			end

			love.graphics.setColor(rarity.color.r, rarity.color.g, rarity.color.b, opacity)
			drawCenteredText(left, top, SLOT_SIZE, SLOT_SIZE, text)
		end
	},
	price = {
		minPrice = -99,
		maxPrice = 99,
		lowestPrice = 99,
		highestPrice = -99,
		tmpColor = { r = 1, g = 1, b = 1, a = 1},
		zeroColor = {
			r = 180 / 255,
			g = 180 / 255,
			b = 180 / 255
		},
		minColor = {
			r = 177 / 255,
			g = 33 / 255,
			b = 73 / 255
		},
		maxColor = {
			r = 6 / 255,
			g = 239 / 255,
			b = 94 / 255
		},
		onActivate = function (self)
			self.lowestPrice = self.maxPrice
			self.highestPrice = self.minPrice
			local run = lp.singleplayer.getRun()
			if not run then return end
			local plot = run:getPlot()
			lib.plotForEachItem(plot, function(item)
				local price = item.price or 0
				if price > self.highestPrice then
					self.highestPrice = math.min(self.maxPrice, price)
				end

				if price < self.lowestPrice then
					self.lowestPrice = math.max(self.minPrice, price)
				end
				return self.highestPrice < self.maxPrice or self.lowestPrice > self.minPrice
			end)
		end,
		onItemDraw = function (self, selfEnt, x, y, rot, sx, sy)
			local price = selfEnt.price or 0
			local opacity = selfEnt.opacity or 1
			local top, left = y - SLOT_SIZE / 2, x - SLOT_SIZE / 2
			local r, g, b, a, value
			if price <= 0 then
				value = normalize(price, self.lowestPrice, 0)
				r, g, b, a = lerpColor(self.minColor, self.zeroColor, value)
			else
				value = normalize(price, 0, self.highestPrice)
				r, g, b, a = lerpColor(self.zeroColor, self.maxColor, value)
			end
			self.tmpColor.r = r
			self.tmpColor.g = g
			self.tmpColor.b = b
			self.tmpColor.a = a
			drawOverlaySquare(left, top, opacity, self.tmpColor)

			local text = "$" .. tostring(price)
			love.graphics.setColor(r, g, b, a * opacity)
			drawCenteredText(left, top, SLOT_SIZE, SLOT_SIZE, text)
		end
	}
}

local overlay = {
	activeOverlay = nil,
}

function overlay.setOverlay(o, isActive)
	local o = overlays[o]
	if not isActive or not o then 
		overlay.activeOverlay = nil
		return
	end

	if o.onActivate then
		o:onActivate()
	end
	overlay.activeOverlay = o
end

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function (selfEnt, x, y, rot, sx, sy)
	local activeOverlay = overlay.activeOverlay
	if not activeOverlay then return end
	if lp.isItemEntity(selfEnt) and activeOverlay.onItemDraw then
		activeOverlay:onItemDraw(selfEnt, x, y, rot, sx, sy)
	end
end)

return overlay