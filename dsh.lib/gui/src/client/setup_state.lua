return function(gui)
	if not state then
		umg.log.error("Can't find 'state'. Make sure this mod depends on lootplot.singleplayer.")
		return
	end

	local statePush = state.push
	state.push = function(frame, order)
		if frame.continueRun and frame.startRun then
			gui.setContinueState(frame)
		elseif frame.startNewRun then
			gui.setStartState(frame)
		elseif frame.scene and frame.scene.pauseBox then
			gui.setLpState(frame)
		end
		statePush(frame, order)
	end


	local statePop = state.pop
	state.pop = function(frame)
		if gui.continueState == frame then
			gui.clearContinueState()
		elseif gui.startState == frame then
			gui.clearStartState()
		elseif gui.lpState == frame then
			gui.clearLpState()
		end
		statePop(frame)
	end
end