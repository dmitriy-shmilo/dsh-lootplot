local broadcasts = require("shared.broadcasts")
local globalScale = require("client.global_scale")
local lib = require("shared.lib")

local font = fonts.getDefaultFont(32)

local function setupCreditScoreRender()
	if not state then return end
	local state = state.peek()
	if not state.drawHUD then return end
	print(base.inspect(state, {depth = 2}))
	local oldHud = state.drawHUD
	state.drawHUD = function(state)
		local run = lp.singleplayer.getRun()
		local score = run:getAttribute("CREDIT_SCORE")
		if score == nil then return end

		local gs = globalScale.get()

		local fH = 32 * gs -- a guess
		local TXT_PAD = 1 * gs
		local LEFT_PAD = 10 * gs
		
		love.graphics.setColor(1, 1, 1, 1)
		rendering.drawImage(
			"dsh_credit_score_card",
			LEFT_PAD + 8 * gs,
			TXT_PAD + (fH + TXT_PAD) * 3  + fH / 2,
			0,
			gs,
			gs)
		text.printRich("{wavy amp=0.5 k=0.5}{outline thickness=2}{c r=0.6 g=0.576 b=1}" .. string.format("%.1f", score), font, LEFT_PAD + 20 * gs, TXT_PAD + (fH+TXT_PAD) * 3, 0xfffff, "left", 0, gs, gs)
		love.graphics.setColor(1, 1, 1, 1)
		oldHud(state)
	end
end

umg.on("dsh.cc:runInitialized", function(item, difficulty)
	if item == "dsh.cc:racket_ball" then
		setupCreditScoreRender()
	end
end)