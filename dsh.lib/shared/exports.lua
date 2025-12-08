local lib = require("shared.lib")

if client then
    lib.c = require("client.lib")
end

umg.expose("lib", lib)
return lib