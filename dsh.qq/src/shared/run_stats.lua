local runStats = {
}
local statsData = {
}

local RUN_DATA_FILE = "last_run_data.json"

local function saveData()
    local fsobj = server.getSaveFilesystem()
    local data = json.encode(statsData)
    fsobj:write(RUN_DATA_FILE, data)
end

function runStats:reset()
    if not server then return end
    statsData = {
        isFinished = false,
        startTimestamp = 0,
        endTimstamp = 0
    }
    saveData()
end

function runStats:load()
    if not server then return end
    local fsobj = server.getSaveFilesystem()
    local data = fsobj:read(RUN_DATA_FILE)
    if not data then
        umg.log.error("DSH.QQ - Unable to load run data. Will reset instead.")
        self:reset()
        return
    end

    statsData = json.decode(data)
    if not statsData then
        umg.log.error("DSH.QQ - Unable to decode run data. Will reset instead.")
        self:reset()
    end
end

function runStats:startRun()
    self:reset()
    statsData.startTimestamp = math.floor(love.timer.getTime() * 1000)
    self:sync()
end

function runStats:finishRun()
    statsData.isFinished = true
    statsData.endTimestamp = math.floor(love.timer.getTime() * 1000)
    saveData()

    self:sync()
end


local syncPacket = "dsh.qq:syncStats"

umg.definePacket(syncPacket, {
    dynamic = true
})

function runStats:sync()
    if server then
        server.broadcast(syncPacket, statsData)
    end
end

return runStats