local syncPacket = "dsh.qq:syncStats"

local runStats = {
}

local statsData = {
    isFinished = false,
    startTimestamp = 0,
    endTimstamp = 0
}

umg.definePacket(syncPacket, {
    dynamic = true
})

client.on(syncPacket, function(newData)
    statsData = newData
end)

function runStats:getData()
    return statsData
end

return runStats