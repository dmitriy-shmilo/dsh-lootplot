local hooks = {}

local function initCallbacks(root, fname)
    if not root then
        umg.log.error("DSH.LIB - Can't init callbacks: invalid root.")
        return
    end
    if not root.dshHooks then
        umg.log.error("DSH.LIB - Can't init callbacks: root doesn't have dshHooks.")
        return
    end

    local original = root[fname]
    if not original then
        umg.log.error("DSH.LIB - Can't init callbacks: root doesn't have a member named " .. fname)
        return
    end

    if type(original) ~= "function" then
        umg.log.error("DSH.LIB - Can't init callbacks: " .. fname .. " is not a function")
        return
    end

    root.dshHooks.beforeCallbacks[fname] = {}
    root.dshHooks.afterCallbacks[fname] = {}
    root[fname] = function (...)
        local callbacks = root.dshHooks.beforeCallbacks[fname]
        local allow = true

        for _, c in pairs(callbacks) do
            local result = c(...)
            if type(result) == "boolean" then
                allow = allow and result
            end
        end

        if allow then
            local result = original(...)
            local callbacks = root.dshHooks.afterCallbacks[fname]

            for _, c in pairs(callbacks) do
                c(...)
            end

            return result
        end

        return false
    end

    umg.log.info("DSH.LIB - Hooked " .. fname)

end

local function hookLp()
    if not lp then return end

    if lp.dshHooks then return end
    umg.log.info("DSH.LIB - Hooking lp.")

    lp.dshHooks = {
        beforeCallbacks = {},
        afterCallbacks = {}
    }

    -- lifecycle
    initCallbacks(lp, "initialize")

    -- spawning
    initCallbacks(lp, "forceSpawnItem")
    initCallbacks(lp, "trySpawnItem")
    initCallbacks(lp, "setSlot")
    initCallbacks(lp, "forceSpawnSlot")
    initCallbacks(lp, "trySpawnSlot")

    -- run attributes
    initCallbacks(lp, "setPoints")
    initCallbacks(lp, "addPointsRaw")
    initCallbacks(lp, "addPoints")
    initCallbacks(lp, "addPointsBonus")
    initCallbacks(lp, "setPointsBonus")
    initCallbacks(lp, "setPointsMult")
    initCallbacks(lp, "addPointsMult")
    initCallbacks(lp, "addMoney")
    initCallbacks(lp, "subtractMoney")
    initCallbacks(lp, "setMoney")

    -- definition
    initCallbacks(lp, "defineItem")
    initCallbacks(lp, "defineSlot")
    initCallbacks(lp, "defineTrigger")

    umg.log.info("DSH.LIB - lp hooked.")
end

local function initHooks()
    hookLp()
end

function hooks.addBeforeCallback(root, fname, callback)
    if not root.dshHooks then
        umg.log.error("DSH.LIB - Can't add callback: invalid root.")
        return
    end

    if not root.dshHooks.beforeCallbacks[fname] then
        umg.log.error("DSH.LIB - Can't add callback: " .. fname .. " hook is not defined.")
        return
    end

    table.insert(root.dshHooks.beforeCallbacks[fname], callback)
end

function hooks.addAfterCallback(root, fname, callback)
    if not root.dshHooks then
        umg.log.error("DSH.LIB - Can't add callback: invalid root.")
        return
    end

    if not root.dshHooks.afterCallbacks[fname] then
        umg.log.error("DSH.LIB - Can't add callback: " .. fname .. " hook is not defined.")
        return
    end

    table.insert(root.dshHooks.afterCallbacks[fname], callback)
end

initHooks()

return hooks