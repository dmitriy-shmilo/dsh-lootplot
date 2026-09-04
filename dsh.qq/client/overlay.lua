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
		minValue = -50,
		maxValue = 50,
		lowestValue = 50,
		highestValue = -50,
		tmpColor = { r = 1, g = 1, b = 1, a = 1},
		zeroColor = {
			r = 180 / 255,
			g = 180 / 255,
			b = 180 / 255,
			a = 0.3
		},
		minNegativeColor = {
			r = 177 / 255,
			g = 33 / 255,
			b = 73 / 255
		},
		maxNegativeColor = {
			r = 251 / 255,
			g = 137 / 255,
			b = 30 / 255
		},
		minPositiveColor = {
			r = 255 / 255,
			g = 248 / 255,
			b = 27 / 255
		},
		maxPositiveColor = {
			r = 6 / 255,
			g = 239 / 255,
			b = 94 / 255
		},
		onActivate = function (self)
			self.lowestValue = self.maxValue
			self.highestValue = self.minValue

			local run = lp.singleplayer.getRun()
			if not run then return end
			local plot = run:getPlot()
			lib.plotForEachItem(plot, function(item)
				local value = item.price or 0
				if value > self.highestValue then
					self.highestValue = math.min(self.maxValue, value)
				end

				if value < self.lowestValue then
					self.lowestValue = math.max(self.minValue, value)
				end
				return self.highestValue < self.maxValue or self.lowestValue > self.minValue
			end)
		end,
		onItemDraw = function (self, selfEnt, x, y, rot, sx, sy)
			local value = selfEnt.price or 0
			local opacity = selfEnt.opacity or 1
			local top, left = y - SLOT_SIZE / 2, x - SLOT_SIZE / 2
			local r, g, b, a
			if value < 0 then
				value = normalize(value, self.lowestValue, 0)
				r, g, b, a = lerpColor(self.minNegativeColor, self.maxNegativeColor, value)
			elseif value > 0 then
				value = normalize(value, 0, self.highestValue)
				r, g, b, a = lerpColor(self.minPositiveColor, self.maxPositiveColor, value)
			else
				r, g, b, a = self.zeroColor.r, self.zeroColor.g, self.zeroColor.b, self.zeroColor.a
			end
			self.tmpColor.r = r
			self.tmpColor.g = g
			self.tmpColor.b = b
			self.tmpColor.a = a
			drawOverlaySquare(left, top, opacity, self.tmpColor)

			local text = "$" .. tostring(selfEnt.price or 0)
			love.graphics.setColor(r, g, b, a * opacity)
			drawCenteredText(left, top, SLOT_SIZE, SLOT_SIZE, text)
		end
	},
	income = {
		minValue = -50,
		maxValue = 50,
		lowestValue = 50,
		highestValue = -50,
		tmpColor = { r = 1, g = 1, b = 1, a = 1},
		zeroColor = {
			r = 180 / 255,
			g = 180 / 255,
			b = 180 / 255,
			a = 0.3
		},
		minNegativeColor = {
			r = 177 / 255,
			g = 33 / 255,
			b = 73 / 255
		},
		maxNegativeColor = {
			r = 251 / 255,
			g = 137 / 255,
			b = 30 / 255
		},
		minPositiveColor = {
			r = 255 / 255,
			g = 248 / 255,
			b = 27 / 255
		},
		maxPositiveColor = {
			r = 6 / 255,
			g = 239 / 255,
			b = 94 / 255
		},
		onActivate = function (self)
			self.lowestValue = self.maxValue
			self.highestValue = self.minValue

			local run = lp.singleplayer.getRun()
			if not run then return end
			local plot = run:getPlot()
			lib.plotForEachItem(plot, function(item)
				local value = item.moneyGenerated or 0
				if value > self.highestValue then
					self.highestValue = math.min(self.maxValue, value)
				end

				if value < self.lowestValue then
					self.lowestValue = math.max(self.minValue, value)
				end
				return self.highestValue < self.maxValue or self.lowestValue > self.minValue
			end)
		end,
		onItemDraw = function (self, selfEnt, x, y, rot, sx, sy)
			local factualValue = umg.ask("dsh.qq:factualIncome", selfEnt)
			local value = factualValue
			local opacity = selfEnt.opacity or 1
			local top, left = y - SLOT_SIZE / 2, x - SLOT_SIZE / 2
			local r, g, b, a
			if value < 0 then
				value = normalize(value, self.lowestValue, 0)
				r, g, b, a = lerpColor(self.minNegativeColor, self.maxNegativeColor, value)
			elseif value > 0 then
				value = normalize(value, 0, self.highestValue)
				r, g, b, a = lerpColor(self.minPositiveColor, self.maxPositiveColor, value)
			else
				r, g, b, a = self.zeroColor.r, self.zeroColor.g, self.zeroColor.b, self.zeroColor.a
			end
			self.tmpColor.r = r
			self.tmpColor.g = g
			self.tmpColor.b = b
			self.tmpColor.a = a
			drawOverlaySquare(left, top, opacity, self.tmpColor)

			local text = "$" .. tostring(factualValue)
			love.graphics.setColor(r, g, b, a * opacity)
			drawCenteredText(left, top, SLOT_SIZE, SLOT_SIZE, text)
		end
	},
	points = {
		minValue = -1000,
		maxValue = 1000,
		lowestValue = 1000,
		highestValue = -1000,
		tmpColor = { r = 1, g = 1, b = 1, a = 1},
		zeroColor = {
			r = 180 / 255,
			g = 180 / 255,
			b = 180 / 255,
			a = 0.3
		},
		minNegativeColor = {
			r = 188 / 255,
			g = 33 / 255,
			b = 30 / 255
		},
		maxNegativeColor = {
			r = 251 / 255,
			g = 171 / 255,
			b = 30 / 255
		},
		minPositiveColor = {
			r = 87 / 255,
			g = 139 / 255,
			b = 52 / 255
		},
		maxPositiveColor = {
			r = 53 / 255,
			g = 200 / 255,
			b = 63 / 255
		},
		onActivate = function (self)
			self.lowestValue = self.maxValue
			self.highestValue = self.minValue

			local run = lp.singleplayer.getRun()
			if not run then return end
			local plot = run:getPlot()
			lib.plotForEachItem(plot, function(item)
				local value = item.pointsGenerated or 0
				if value > self.highestValue then
					self.highestValue = math.min(self.maxValue, value)
				end

				if value < self.lowestValue then
					self.lowestValue = math.max(self.minValue, value)
				end
				return self.highestValue < self.maxValue or self.lowestValue > self.minValue
			end)
		end,
		onItemDraw = function (self, selfEnt, x, y, rot, sx, sy)
			local factualValue = umg.ask("dsh.qq:factualPoints", selfEnt)
			local value = factualValue
			local opacity = selfEnt.opacity or 1
			local top, left = y - SLOT_SIZE / 2, x - SLOT_SIZE / 2
			local r, g, b, a
			if value < 0 then
				value = normalize(value, self.lowestValue, 0)
				r, g, b, a = lerpColor(self.minNegativeColor, self.maxNegativeColor, value)
			elseif value > 0 then
				value = normalize(value, 0, self.highestValue)
				r, g, b, a = lerpColor(self.minPositiveColor, self.maxPositiveColor, value)
			else
				r, g, b, a = self.zeroColor.r, self.zeroColor.g, self.zeroColor.b, self.zeroColor.a
			end
			self.tmpColor.r = r
			self.tmpColor.g = g
			self.tmpColor.b = b
			self.tmpColor.a = a
			drawOverlaySquare(left, top, opacity, self.tmpColor)

			love.graphics.setColor(r, g, b, a * opacity)
			if factualValue < 1000 then
				local text = tostring(factualValue)
				drawCenteredText(left, top, SLOT_SIZE, SLOT_SIZE, text)
			else
				drawCenteredText(left, top, SLOT_SIZE, SLOT_SIZE, "999+")
			end
		end
	},
	totalActivations = {
		minValue = 0,
		maxValue = 20,
		lowestValue = 0,
		highestValue = 20,
		tmpColor = { r = 1, g = 1, b = 1, a = 1},
		zeroColor = {
			r = 180 / 255,
			g = 180 / 255,
			b = 180 / 255,
			a = 0.3
		},
		minPositiveColor = {
			r = 255 / 255,
			g = 248 / 255,
			b = 27 / 255
		},
		maxPositiveColor = {
			r = 6 / 255,
			g = 239 / 255,
			b = 94 / 255
		},
		onActivate = function (self)
			self.lowestValue = self.maxValue
			self.highestValue = self.minValue

			local run = lp.singleplayer.getRun()
			if not run then return end
			local plot = run:getPlot()
			lib.plotForEachItem(plot, function(item)
				local value = umg.ask("dsh.qq:factualTotalActivations", item) or 0
				if value > self.highestValue then
					self.highestValue = math.min(self.maxValue, value)
				end

				if value < self.lowestValue then
					self.lowestValue = math.max(self.minValue, value)
				end
				return self.highestValue < self.maxValue or self.lowestValue > self.minValue
			end)
		end,
		onItemDraw = function (self, selfEnt, x, y, rot, sx, sy)
			local factualValue = umg.ask("dsh.qq:factualTotalActivations", selfEnt)
			local value = normalize(factualValue, self.lowestValue, self.highestValue)
			local opacity = selfEnt.opacity or 1
			local top, left = y - SLOT_SIZE / 2, x - SLOT_SIZE / 2
			local r, g, b, a

			if value == 0 then
				r, g, b, a = self.zeroColor.r, self.zeroColor.g, self.zeroColor.b, self.zeroColor.a
			else
				r, g, b, a = lerpColor(self.minPositiveColor, self.maxPositiveColor, value)
			end

			self.tmpColor.r = r
			self.tmpColor.g = g
			self.tmpColor.b = b
			self.tmpColor.a = a
			drawOverlaySquare(left, top, opacity, self.tmpColor)

			local text = tostring(factualValue)
			love.graphics.setColor(r, g, b, a * opacity)
			drawCenteredText(left, top, SLOT_SIZE, SLOT_SIZE, text)
		end
	},
	remainingActivations = {
		minValue = 0,
		maxValue = 20,
		lowestValue = 0,
		highestValue = 20,
		tmpColor = { r = 1, g = 1, b = 1, a = 1},
		zeroColor = {
			r = 180 / 255,
			g = 180 / 255,
			b = 180 / 255,
			a = 0.3
		},
		minPositiveColor = {
			r = 255 / 255,
			g = 248 / 255,
			b = 27 / 255
		},
		maxPositiveColor = {
			r = 6 / 255,
			g = 239 / 255,
			b = 94 / 255
		},
		onActivate = function (self)
			self.lowestValue = self.maxValue
			self.highestValue = self.minValue

			local run = lp.singleplayer.getRun()
			if not run then return end
			local plot = run:getPlot()
			lib.plotForEachItem(plot, function(item)
				local value = umg.ask("dsh.qq:factualRemainingActivations", item) or 0
				if value > self.highestValue then
					self.highestValue = math.min(self.maxValue, value)
				end

				if value < self.lowestValue then
					self.lowestValue = math.max(self.minValue, value)
				end
				return self.highestValue < self.maxValue or self.lowestValue > self.minValue
			end)
		end,
		onItemDraw = function (self, selfEnt, x, y, rot, sx, sy)
			local factualValue = umg.ask("dsh.qq:factualRemainingActivations", selfEnt)
			local value = normalize(factualValue, self.lowestValue, self.highestValue)
			local opacity = selfEnt.opacity or 1
			local top, left = y - SLOT_SIZE / 2, x - SLOT_SIZE / 2
			local r, g, b, a

			if value == 0 then
				r, g, b, a = self.zeroColor.r, self.zeroColor.g, self.zeroColor.b, self.zeroColor.a
			else
				r, g, b, a = lerpColor(self.minPositiveColor, self.maxPositiveColor, value)
			end

			self.tmpColor.r = r
			self.tmpColor.g = g
			self.tmpColor.b = b
			self.tmpColor.a = a
			drawOverlaySquare(left, top, opacity, self.tmpColor)

			local text = tostring(factualValue)
			love.graphics.setColor(r, g, b, a * opacity)
			drawCenteredText(left, top, SLOT_SIZE, SLOT_SIZE, text)
		end
	},
	doomCount = {
		minValue = 0,
		maxValue = 99,
		lowestValue = 0,
		highestValue = 0,
		tmpColor = { r = 1, g = 1, b = 1, a = 1},
		zeroColor = {
			r = 180 / 255,
			g = 180 / 255,
			b = 180 / 255,
			a = 0.3
		},
		minPositiveColor = {
			r = 235 / 255,
			g = 47 / 255,
			b = 96 / 255
		},
		maxPositiveColor = {
			r = 195 / 255,
			g = 70 / 255,
			b = 210 / 255
		},
		onActivate = function (self)
			self.lowestValue = self.maxValue
			self.highestValue = self.minValue

			local run = lp.singleplayer.getRun()
			if not run then return end
			local plot = run:getPlot()
			lib.plotForEachItem(plot, function(item)
				local value = item.doomCount or 0
				if value > self.highestValue then
					self.highestValue = math.min(self.maxValue, value)
				end

				if value < self.lowestValue then
					self.lowestValue = math.max(self.minValue, value)
				end
				return self.highestValue < self.maxValue or self.lowestValue > self.minValue
			end)
			print(base.inspect(self))
		end,
		onItemDraw = function (self, selfEnt, x, y, rot, sx, sy)
			local factualValue = selfEnt.doomCount or 0
			local value = normalize(factualValue, self.lowestValue, self.highestValue)
			local opacity = selfEnt.opacity or 1
			local top, left = y - SLOT_SIZE / 2, x - SLOT_SIZE / 2
			local r, g, b, a

			if value == 0 then
				r, g, b, a = self.zeroColor.r, self.zeroColor.g, self.zeroColor.b, self.zeroColor.a
			else
				r, g, b, a = lerpColor(self.minPositiveColor, self.maxPositiveColor, value)
			end

			self.tmpColor.r = r
			self.tmpColor.g = g
			self.tmpColor.b = b
			self.tmpColor.a = a
			drawOverlaySquare(left, top, opacity, self.tmpColor)

			local text = tostring(factualValue)
			love.graphics.setColor(r, g, b, a * opacity)
			drawCenteredText(left, top, SLOT_SIZE, SLOT_SIZE, text)
		end
	},
	lives = {
		minValue = 0,
		maxValue = 99,
		lowestValue = 0,
		highestValue = 0,
		tmpColor = { r = 1, g = 1, b = 1, a = 1},
		zeroColor = {
			r = 180 / 255,
			g = 180 / 255,
			b = 180 / 255,
			a = 0.3
		},
		minPositiveColor = {
			r = 149 / 255,
			g = 28 / 255,
			b = 123 / 255
		},
		maxPositiveColor = {
			r = 253 / 255,
			g = 137 / 255,
			b = 217 / 255
		},
		onActivate = function (self)
			self.lowestValue = self.maxValue
			self.highestValue = self.minValue

			local run = lp.singleplayer.getRun()
			if not run then return end
			local plot = run:getPlot()
			lib.plotForEachItem(plot, function(item)
				local value = item.lives or 0
				if value > self.highestValue then
					self.highestValue = math.min(self.maxValue, value)
				end

				if value < self.lowestValue then
					self.lowestValue = math.max(self.minValue, value)
				end
				return self.highestValue < self.maxValue or self.lowestValue > self.minValue
			end)
			print(base.inspect(self))
		end,
		onItemDraw = function (self, selfEnt, x, y, rot, sx, sy)
			local factualValue = selfEnt.lives or 0
			local value = normalize(factualValue, self.lowestValue, self.highestValue)
			local opacity = selfEnt.opacity or 1
			local top, left = y - SLOT_SIZE / 2, x - SLOT_SIZE / 2
			local r, g, b, a

			if value == 0 then
				r, g, b, a = self.zeroColor.r, self.zeroColor.g, self.zeroColor.b, self.zeroColor.a
			else
				r, g, b, a = lerpColor(self.minPositiveColor, self.maxPositiveColor, value)
			end

			self.tmpColor.r = r
			self.tmpColor.g = g
			self.tmpColor.b = b
			self.tmpColor.a = a
			drawOverlaySquare(left, top, opacity, self.tmpColor)

			local text = tostring(factualValue)
			love.graphics.setColor(r, g, b, a * opacity)
			drawCenteredText(left, top, SLOT_SIZE, SLOT_SIZE, text)
		end
	},
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
	if not selfEnt.originalOnDraw then
		selfEnt.originalOnDraw = selfEnt.onDraw
		selfEnt.onDraw = function()end
	end

	if not activeOverlay then return end
	if lp.isItemEntity(selfEnt) and activeOverlay.onItemDraw then
		activeOverlay:onItemDraw(selfEnt, x, y, rot, sx, sy)
	end
end)

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER - 1, function (selfEnt, x, y, rot, sx, sy)
	if selfEnt.originalOnDraw then
		selfEnt.originalOnDraw(selfEnt, x, y, rot, sx, sy)
	end
end)

umg.defineQuestion("dsh.qq:factualIncome", reducers.ADD)
umg.defineQuestion("dsh.qq:factualPoints", reducers.ADD)
umg.defineQuestion("dsh.qq:factualTotalActivations", reducers.PRIORITY)
umg.defineQuestion("dsh.qq:factualRemainingActivations", reducers.PRIORITY)

umg.answer("dsh.qq:factualIncome", function(ent)
	return ent.moneyGenerated or 0
end)

umg.answer("dsh.qq:factualPoints", function(ent)
	return ent.pointsGenerated or 0
end)

umg.answer("dsh.qq:factualTotalActivations", function(ent)
	return ent.maxActivations or 0, 0
end)

umg.answer("dsh.qq:factualRemainingActivations", function(ent)
	local total = ent.maxActivations or 0
	local used = ent.activationCount or 0
	return math.max(0, total - used), 0
end)

require("client.factual_income")()
require("client.factual_points")()
require("client.factual_activations")()

return overlay