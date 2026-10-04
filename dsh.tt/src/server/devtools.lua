local trophies = require("shared.trophies")

chat.handleCommand("ttlock", {
    adminLevel = 120,
    arguments = {},
    handler = function(clientId, id)
        for _, def in pairs(trophies.definitions) do
            if id == "all" or id == def.id then
                chat.privateMessage(clientId, "Locking trophy " .. def.id)
                def:lock()
            end
        end
    end
})

chat.handleCommand("ttunlock", {
    adminLevel = 120,
    arguments = {},
    handler = function(clientId, id)
        for _, def in pairs(trophies.definitions) do
            if id == "all" or id == def.id then
                chat.privateMessage(clientId, "Unlocking trophy " .. def.id)
                if def:unlock() then
                    server.broadcast("dsh.tt:trophyUnlocked", def.id)
                end
            end
        end
    end
})