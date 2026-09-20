if _G.fonts then return end

_G.fonts = {
	_fontMap = {}
}

-- TODO: since "lib" is included statically in every mod, all of its assets will be copied multiple times
-- find a way to reduce the redundancy without relying on lootplot's mod dependency system
local DEFAULT_FONT = "dshDefault"
local MONOGRAM_FONT = "/assets/fonts/monogram-extended.ttf"

function fonts.getDefaultFont(size)
	local map = fonts._fontMap[DEFAULT_FONT]
	if not map then
		map = {}
		fonts._fontMap[DEFAULT_FONT] = map
	end

	local font = map[size]
	if not font then
		font = love.graphics.newFont("/assets/fonts/monogram-extended.ttf", size, "mono", 1)
		map[size] = font
	end
	return font
end

return fonts