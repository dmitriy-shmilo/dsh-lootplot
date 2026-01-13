local query = require("shared.query")

chat.handleCommand("q", {
    adminLevel = 0,
    arguments = { name = "text", type = "string" },
    handler = function(clientId, text)
        query.search(text)
    end
})