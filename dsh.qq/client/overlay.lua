local globalScale = require("client.global_scale")

local RENDER_AFTER_ENTITY_ORDER = 10001
local ITEM_SIZE = 16
local SLOT_SIZE = 24

local defaultFontLarge = love.graphics.newFont("/assets/fonts/monogram-extended.ttf", 64, "mono", 1) or love.graphics.getFont()

function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text)
	local font = love.graphics.getFont()
	local textWidth = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print(text, rectX + rectWidth / 2, rectY + rectHeight / 2, 0, 1, 1, textWidth / 2, textHeight / 2)
end

local overlays = {
	rarity = {
		onItemDraw = function (selfEnt, x, y, rot, sx, sy)
			local rarity = selfEnt.rarity
			local opacity = selfEnt.opacity or 1

			if not rarity then rarity = lp.rarities.UNIQUE end
			local top, left = y - SLOT_SIZE / 2, x - SLOT_SIZE / 2
			love.graphics.setColor(0, 0, 0, 0.75 * opacity)
			love.graphics.rectangle("fill", left, top, SLOT_SIZE, SLOT_SIZE, 2, 2)

			love.graphics.setColor(rarity.color.r, rarity.color.g, rarity.color.b, 0.75 * opacity)
			love.graphics.setLineWidth(2)
			love.graphics.rectangle("line", left, top, SLOT_SIZE, SLOT_SIZE, 2, 2)

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
	}
}

local overlay = {
	activeOverlay = nil,
}

function overlay.setOverlay(o, isActive)
	print(base.inspect(overlay))
	if not isActive then 
		overlay.activeOverlay = nil
		return
	end
	overlay.activeOverlay = overlays[o]
end

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function (selfEnt, x, y, rot, sx, sy)
	local activeOverlay = overlay.activeOverlay
	if not activeOverlay then return end
	if lp.isItemEntity(selfEnt) and activeOverlay.onItemDraw then
		activeOverlay.onItemDraw(selfEnt, x, y, rot, sx, sy)
	end
end)

return overlay