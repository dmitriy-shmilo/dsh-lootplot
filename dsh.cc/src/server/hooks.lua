local lib = require("shared.lib")
local broadcasts = require("shared.broadcasts")

lib.hooks.addAfterCallback(lp, "initialize", function()
	local run = lp.singleplayer.getRun()
	if not run then return end
	umg.call("dsh.cc:runInitialized", run.starterItem, run.difficulty)
	server.broadcast("dsh.cc:runInitialized", run.starterItem, run.difficulty)
end)