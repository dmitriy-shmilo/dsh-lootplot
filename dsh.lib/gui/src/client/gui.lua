local VERSION = {
	major = 1,
	minor = 0,
	patch = 0

}
VERSION.tag = string.format("%d.%d.%d", VERSION.major, VERSION.minor, VERSION.patch)

local oldLib = base.dshGui

if oldLib and VERSION.tag ~= oldLib.version.tag then
	umg.log.warn(string.format("A different dshGui version (%s) is already present, it will not be replaced by dshGui %s.", oldLib.version.tag, VERSION.tag))
	return oldLib
end

if oldLib then
	return oldLib
end

local gui = {
	version = VERSION,
	lpState = nil,
	continueState = nil,
	startState = nil
}

function gui.setContinueState(frame)
	gui.continueState = frame
end

function gui.setStartState(frame)
	gui.startState = frame
end

function gui.setLpState(frame)
	gui.lpState = frame
	local scene = frame.scene
	if not scene then
		umg.log.error("Can't find scene field on the lpState frame.")
		return
	end

	local pauseBox = scene.pauseBox
	if not pauseBox then
		umg.log.error("Can't find pause box on the lpScene.")
		return
	end

	gui.pause.pauseBoxInit(pauseBox)
end

function gui.clearContinueState()
	gui.continueState = nil
end

function gui.clearStartState()
	gui.startState = nil
end

function gui.clearLpState()
	gui.lpState = nil
end


require("client.setup_global_scale")(gui)
require("client.elements.setup_elements")(gui)
require("client.setup_state")(gui)
require("client.pause.setup_pause")(gui)
require("client.pause.setup_pause_box")(gui)

-- for whatever reason umg.expose("dshGui", gui) won't make dshGui globally
-- available for subsequent mods, so I'm forced to squat in a built-in global object
base.dshGui = gui
_G.dshGui = gui

return gui