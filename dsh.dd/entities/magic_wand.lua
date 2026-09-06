local config = require("shared.config")
local lib = require("shared.lib")
local etypes = require("shared.etypes")
local loc = localization.localize
local interp = localization.newInterpolator

local function getRandomPlotItem(plot)
	local arr = objects.Array()
	plot:foreachItem(function(itemEnt, ppos)
		arr:add(itemEnt)
	end)
	if #arr > 0 then
		return table.random(arr)
	end
end

if config.stableInjunctions then
	etypes.redefineItem("lootplot.s0:magic_wand", "dsh.dd:magic_wand", {
		name = loc("Magic Wand"),
		image = "magic_wand",
		activateDescription = loc("Transform items into a clone of a random item on the board. Doesn't affect injunctions."),

		triggers = { "PULSE" },

		unlockAfterWins = 6,

		rarity = lp.rarities.EPIC,

		basePrice = 16,
		baseMaxActivations = 10,

		shape = lp.targets.NorthEastShape(1),
		target = {
			type = "ITEM",
			filter = function(selfEnt, ppos, targetEnt)
				if lib.hasTag(targetEnt, lib.tags.INJUNCTION_CURSE) then
					return false
				end
				return true
			end,
			activate = function(selfEnt, ppos, targetEnt)
				local plot = ppos:getPlot()
				local itemEnt = getRandomPlotItem(plot)
				if itemEnt then
					lp.forceCloneItem(itemEnt, ppos)
				end
			end
		}
	})
end