local commandLookup = {}
local lastCommand = ""
local lastClientId = ""
local lastArgs = {}
local itemNames = nil
local fqItemNames = nil

-- taken from lootplot.singleplayer/shared/devtools.lua
local function getPPos(clientId)
    local ctx = assert(lp.singleplayer.getRun())
    local plot = ctx:getPlot()

    local player = control.getControlledEntities(clientId)[1]
    return plot:getClosestPPos(player.x, player.y)
end

local function ensureItemNames()
    if itemNames then return end

    fqItemNames = objects.Array(lp.newItemGenerator():getEntries())
        :map(function(name)
            return name
        end)
    itemNames = fqItemNames
        :map(function(name) 
            local iter = string.gmatch(name, "[^:]+")
            local k, _ = iter()
            k, _ = iter()
            return k
        end)

    fqItemNames
        :sortInPlace(function(lhs, rhs)
            return #lhs < #rhs
        end)

    itemNames
        :sortInPlace(function(lhs, rhs)
            return #lhs < #rhs
        end)
end

local function findItem(name)
    local isFq = string.find(name, ":", 1, true)
    local names = itemNames
    if isFq then names = fqItemNames end

    -- TODO: this can be a binary search
    for i = 1, #names do
        local candidate = names[i]
        if string.sub(candidate, 1, #name) == name then
            return candidate
        end
    end

    return nil
end

-- spawn an item at the center of the screen or a nearby suitable slot
-- will perform an item lookup by name
local SPIRAL_STEPS = 45
commandLookup["si"] = {
    adminLevel = 120,
    arguments = {
        { name = "entityType", type = "string" },
    },
    handler = function(clientId, etype)
        if not server then
            return
        end

        lastCommand = "si"
        lastArgs = { etype }
        lastClientId = clientId

        local ent = server.entities[etype]
        ensureItemNames()

        if not ent then
            local bestMatch = findItem(etype)
            if bestMatch then
                chat.privateMessage(clientId, etype .. " entity type doesn't exist, found " .. bestMatch .. " as the best match.")
                ent = server.entities[bestMatch]
            end
        end

        if (not ent) then
            chat.privateMessage(clientId, etype .. " entity type doesn't exist.")
            return
        end

        if (not lp.isItemEntity(ent)) then
            chat.privateMessage(clientId, etype .. " is not an item entity type.")
            return
        end

        -- adapted from https://jonseymour.medium.com/investigating-the-properties-of-a-square-spiral-6aa635a4d803
        local cursor = getPPos(clientId)
        local motions = {
            cursor.right,
            cursor.up,
            cursor.left,
            cursor.down
        }
        local motionIdx = 0
        local stepCount = SPIRAL_STEPS
        local extent = 0

        while stepCount > 0 do
            if motionIdx == 0 or motionIdx == 2 then
                extent = extent + 1
            end
            local leg = math.min(extent, stepCount)
            stepCount = stepCount - leg
            while leg > 0 do 
                cursor = motions[motionIdx + 1](cursor)
                leg = leg - 1

                local slotEnt = lp.posToSlot(cursor)

                if slotEnt or ent.canItemFloat then
                    if lp.forceSpawnItem(cursor, ent, lp.singleplayer.PLAYER_TEAM) then
                        chat.privateMessage(clientId, "Spawned " .. etype .. " at " .. tostring(cursor))
                        return
                    end
                end
            end
            motionIdx = (motionIdx + 1) % #motions
        end

        chat.privateMessage(clientId, "Can not spawn " .. etype .. ": can't find a suitable nearby slot.")
    end
}

-- spawn a slot at the center of the screen, replacing any slot that was there previously
-- accepts, optionally, a slot type name (string, defaults to "slot") and size (number, defaults to 0)
commandLookup["ss"] = {
    adminLevel = 120,
    arguments = {},
    handler = function(clientId, ...)
        if not server then
            return
        end

        lastCommand = "ss"
        lastArgs = {...}
        lastClientId = clientId

        local slotType = "slot"
        local size = 0
        if #lastArgs >= 2 then
            slotType = lastArgs[1] or "slot"
            size = tonumber(lastArgs[2]) or 0
        elseif #lastArgs == 1 then
            if tonumber(lastArgs[1]) then
                size = tonumber(lastArgs[1]) or 0
            else
                slotType = lastArgs[1]
            end
        end

        local ctor = server.entities[slotType]
        if (not ctor) then
            chat.privateMessage(clientId, "Can not spawn " .. slotType .. ": no such slot type.")
            return
        end

        if (not lp.isSlotEntity(ctor)) then
            chat.privateMessage(clientId, "Can not spawn " .. slotType .. ": not a slot type.")
            return
        end

        local ppos = getPPos(clientId)
        ppos:move(-size, -size)

        for x = -size, size do
            for y = -size, size do
                local cursor = ppos:move(x, y)
                if cursor then
                    lp.forceSpawnSlot(cursor, ctor, lp.singleplayer.PLAYER_TEAM)
                end
            end
        end
    end
}

for name, handler in pairs(commandLookup) do
    chat.handleCommand(name, handler)
end

-- re-execute the last successfully executed command
chat.handleCommand("", {
    adminLevel = 120,
    arguments = {},
    handler = function(clientId, ...)
        if not lastCommand then
            return
        end
        if not lastArgs then
            lastArgs = {}
        end
        
        local command = commandLookup[lastCommand]
        if not command then
            return
        end
        command.handler(lastClientId, unpack(lastArgs))
    end
})


