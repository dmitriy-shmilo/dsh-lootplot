local query = require("shared.query")

chat.handleCommand("q", {
    adminLevel = 0,
    arguments = { name = "text", type = "string" },
    handler = function(clientId, text)
        if type(text) ~= "string" then return end
        query.search(text)
    end
})