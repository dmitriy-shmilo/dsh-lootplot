local interp = localization.newInterpolator

local trophies = {
    names = {},
    definitions = {},
    trackingStarted = false,
    trophiesEnabled = function() return false end
}

umg.defineEvent("dsh.tt:started")
umg.defineEvent("dsh.tt:pulsed")
umg.defineEvent("dsh.tt:leveled")
umg.defineEvent("dsh.tt:rerolled")
umg.defineEvent("dsh.tt:trophyTick")
umg.defineEvent("dsh.tt:won")
umg.defineEvent("dsh.tt:lost")

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

local function valueOrResult(maybeCallable, selfTrophy)
    if not maybeCallable then return "" end
    if objects.isCallable(maybeCallable) then
        return maybeCallable(selfTrophy) or ""
    end
    return maybeCallable
end

local authorPrefix = interp("{lootplot:BORING_COLOR}Author: %{author}{/lootplot:BORING_COLOR}")
local function fullDescription(selfTrophy)
    local description = valueOrResult(selfTrophy.description, selfTrophy)

    local rewardDescription = valueOrResult(selfTrophy.rewardDescription, selfTrophy)
    if #rewardDescription > 0 then
        description = description .. "\n" .. rewardDescription
    end

    local progressDescription = valueOrResult(selfTrophy.progressDescription, selfTrophy)
    if #progressDescription > 0 then
        description = description .. "\n" .. progressDescription
    end

    if selfTrophy.author and #selfTrophy.author > 0 then
        local author = authorPrefix(selfTrophy)
        description = description .. "\n" .. author
    end

    return description
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

do -- trophy data
    local trophyData
    local TROPHY_DATA_FILE = "trophy_data.json"
    local function saveTrophyData()
        local fsobj = server.getSaveFilesystem()
        local data = json.encode(trophyData)
        fsobj:write(TROPHY_DATA_FILE, data)
    end

    function trophies.getTrophyData(id, defaultData)
        if not server then return nil end
        if not trophyData then
            trophies.loadTrophyData()
        end

        if not trophyData[id] then
            trophyData[id] = defaultData
        end

        return trophyData[id]
    end

    function trophies.setTrophyData(id, data)
        if not server then return end
        if not trophyData then
            trophies.loadTrophyData()
        end

        if not trophyData[id] then
            trophyData[id] = data
        end

        saveTrophyData()
    end

    function trophies.resetTrophyData()
        if not server then return end
        trophyData = {}
        saveTrophyData()
    end

    function trophies.loadTrophyData()
        if not server then return end
        local fsobj = server.getSaveFilesystem()
        local data = fsobj:read(TROPHY_DATA_FILE)
        if not data then
            umg.log.error("DSH.TT - Unable to load trophy data. Will reset instead.")
            trophies.resetTrophyData()
            return
        end

        trophyData = json.decode(data)
        if not trophyData then
            umg.log.error("DSH.TT - Unable to decode trophy data. Will reset instead.")
            trophies.resetTrophyData()
        end
    end
end

umg.expose("trophies", trophies)
return trophies