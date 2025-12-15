local trophies = {
    names = {},
    definitions = {}
}

umg.defineEvent("dsh.tt:trophyDefined")
umg.definePacket("dsh.tt:trophyUnlocked", {
    typelist = { "string" }
})

local function defaultIsUnlocked(selfTrophy)
    return lp.metaprogression.getFlag(selfTrophy.unlockFlag)
end

local function defaultLock(selfTrophy)
    return lp.metaprogression.setFlag(selfTrophy.unlockFlag, false)
end

local function defaultUnlock(selfTrophy)
    lp.metaprogression.setFlag(selfTrophy.unlockFlag, true)
    return true
end

local function emptyLock(selfTrophy)
    umg.log.warn("DSH.TT - " .. selfTrophy.id .. " can't be locked.")
end

local function emptyUnlock(selfTrophy)
    umg.log.warn("DSH.TT - " .. selfTrophy.id .. " can't be unlocked.")
    return false
end

local function emptyProgressDescription(selfTrophy)
    return ""
end

local function fullDescription(selfTrophy)
    local description = selfTrophy.description
    if objects.isCallable(description) then
        description = selfTrophy:description()
    end
    local progressDescription = selfTrophy.progressDescription
    if objects.isCallable(progressDescription) then
        progressDescription = selfTrophy:progressDescription()
    end
    return description .. "\n" .. progressDescription
end

local defaultTriggers = {
    "PULSE"
}

function trophies.defineTrophy(id, def)
    if trophies.definitions[id] then
        umg.log.error("DSH.TT - " .. id .. " trophy is already defined.")
        return
    end

    def.id = id

    if not def.tryUnlock or type(def.tryUnlock) ~= "function" then
        umg.log.error("DSH.TT - " .. id .. " trophy must have a 'tryUnlock' function.")
        return
    end

    if not def.isUnlocked or type(def.isUnlocked) ~= "function" then
        if not def.unlockFlag then
            umg.log.error("DSH.TT - " .. id .. " trophy must have an 'isUnlocked' function or 'unlockFlag'.")
            return
        end
        def.isUnlocked = defaultIsUnlocked
    end

    if not def.lock or type(def.lock) ~= "function" then
        if not def.unlockFlag then
            umg.log.warn("DSH.TT - " .. id .. " doesn't have a 'lock' function nor 'unlockFlag'. A placeholder will be used.")
            def.lock = emptyLock
        else
            def.lock = defaultLock
        end
    end

    if not def.unlock or type(def.unlock) ~= "function" then
        if not def.unlockFlag then
            umg.log.warn("DSH.TT - " .. id .. " doesn't have an 'unlock' function nor 'unlockFlag'. A placeholder will be used.")
            def.unlock = emptyUnlock
        else
            def.unlock = defaultUnlock
        end
    end

    if not def.title then
        umg.log.warn("DSH.TT - " .. id .. " trophy doesn't have a title, its ID will be used instead.")
        def.title = id
    end

    if not def.description then
        umg.log.warn("DSH.TT - " .. id .. " feat doesn't have a description. An empty string will be set.")
        def.description = ""
    end

    if not def.progressDescription then
        def.progressDescription = emptyProgressDescription
    end

    if not def.image then
        umg.log.warn("DSH.TT - " .. id .. " doesn't have an image, will use a placeholder.")
        def.image = "dsh_trophy_ball"
    end

    local triggers = def.triggers or {}
    if not #triggers then
        umg.log.warn("DSH.TT - " .. id .. " doesn't have triggers defined. Will use PULSE as default.")
        def.triggers = defaultTriggers
    end

    def.fullDescription = fullDescription

    trophies.definitions[id] = def
    table.insert(trophies.names, id)
    umg.call("dsh.tt:trophyDefined", def)
end

umg.expose("trophies", trophies)
return trophies