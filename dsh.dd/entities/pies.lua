local config = require("shared.config")
local lib = require("shared.lib")
local etypes = require("shared.etypes")
local loc = localization.localize

if not config.piesDontAffectFood then return end

local function definePie(id, name, desc, addShape, rarity)
	etypes.redefineItem("lootplot.s0:" .. id, "dsh.dd:" .. id, {
		image = id,
		name = loc(name),
		activateDescription = loc(desc),
		foodItem = true,
		baseMaxActivations = 1,
		lootplotTags = { lib.tags.FOOD },

		basePrice = 7,

		rarity = rarity,

		shape = lp.targets.UP_SHAPE,

		target = {
			type = "ITEM",
			filter = function(selfEnt, ppos, targetItemEnt)
				return targetItemEnt.shape and not lib.hasTag(targetItemEnt, lib.tags.FOOD)
			end,
			activate = function(selfEnt, ppos, targetItemEnt)
				local oldShape = targetItemEnt.shape
				if oldShape then
					local newShape = lp.targets.UnionShape(
						targetItemEnt.shape,
						addShape
					)
					if #newShape.relativeCoords > #oldShape.relativeCoords then
						lp.targets.setShape(targetItemEnt, newShape)
					end
				end
			end
		}
	})
end

definePie("kings_pie", "King's Pie", "Adds {lootplot.targets:COLOR}KING-1{/lootplot.targets:COLOR} targets to item.\nDoesn't affect food.", lp.targets.KingShape(1), lp.rarities.RARE)
definePie("bishops_pie", "Bishop's Pie", "Adds {lootplot.targets:COLOR}BISHOP-2{/lootplot.targets:COLOR} targets to item.\nDoesn't affect food.", lp.targets.BishopShape(2), lp.rarities.RARE)
definePie("pi_pie", "Pi Pie", "Makes item target itself.\nDoesn't affect food.", lp.targets.ON_SHAPE, lp.rarities.RARE)
definePie("knights_pie", "Knight's Pie", "Adds {lootplot.targets:COLOR}KNIGHT{/lootplot.targets:COLOR} targets to item.\nDoesn't affect food.", lp.targets.KNIGHT_SHAPE, lp.rarities.EPIC)
definePie("rooks_pie", "Rook's Pie", "Adds {lootplot.targets:COLOR}ROOK-4{/lootplot.targets:COLOR} targets to item.\nDoesn't affect food.", lp.targets.RookShape(4), lp.rarities.EPIC)

local RANDOM_SHAPES = {
	lp.targets.UpShape(1),
	lp.targets.DownShape(1),
	lp.targets.HorizontalShape(3),
	lp.targets.VerticalShape(3),
	lp.targets.KingShape(1),
	lp.targets.KingShape(2),
	lp.targets.UpShape(2),
	lp.targets.DownShape(2),
	lp.targets.BishopShape(1),
	lp.targets.BishopShape(2),
	lp.targets.KNIGHT_SHAPE,
	lp.targets.QueenShape(2),
	lp.targets.RookShape(1),
	lp.targets.RookShape(2),
	lp.targets.CircleShape(8),
}

etypes.redefineItem("lootplot.s0:randomizer_pie", "dsh.dd:randomizer_pie", {
	name = loc("Randomizer Pie"),
	image = "randomizer_pie",
	activateDescription = loc("Randomizes item's shape. Doesn't affect food."),
	foodItem = true,
	baseMaxActivations = 1,
	lootplotTags = { lib.tags.FOOD },
	basePrice = 7,
	rarity = lp.rarities.RARE,
	shape = lp.targets.UP_SHAPE,
	target = {
		type = "ITEM",
		filter = function(selfEnt, ppos, targEnt)
			return targEnt.shape
		end,
		activate = function(selfEnt, ppos, targEnt)
			if targEnt.shape then
				local shape = table.random(RANDOM_SHAPES)
				lp.targets.setShape(targEnt, shape)
			end
		end
	}
})
