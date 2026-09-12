local config = require("shared.config")

if not config.tennisBall then return end

local function hijackPointsGeneration()
	local addPointsRaw = lp.addPointsRaw
	lp.addPointsRaw = function (fromEnt, x)
		local cscore = lp.getAttribute("CREDIT_SCORE", fromEnt)
		addPointsRaw(fromEnt, x * cscore)
	end
end

umg.on("dsh.cc:runInitialized", function(item, difficulty)
	if item == "dsh.cc:racket_ball" then
		hijackPointsGeneration()
	end
end)