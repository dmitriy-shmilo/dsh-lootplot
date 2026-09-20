local lib = require("shared.lib")

local stateStack = {}
state.height = 0

lib.hooks.addAfterCallback(state, "push", function(frame)
	stateStack[#stateStack + 1] = frame
	state.height = #stateStack
end)

lib.hooks.addAfterCallback(state, "pop", function(frame)
	stateStack[#stateStack] = nil
	state.height = #stateStack
end)

function state.peek(index)
	index = index or #stateStack
	return stateStack[#stateStack]
end

return state