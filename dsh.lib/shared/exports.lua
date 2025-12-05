local lib = {
    -- shared stuff
    tags = {
        -- taken from lootplot.s0/shared/constants.lua
        -- item tags:
        TREASURE = "lootplot.s0:treasure",
        ROCKS = "lootplot.s0:rocks",
        DESTRUCTIVE = "lootplot.s0:destructive",
        FOOD = "lootplot.s0:food",
        CAT = "lootplot.s0:cat",
        CONTRAPTION = "lootplot.s0:contraption",

        SWORD = "lootplot.s0:sword",
        AXE = "lootplot.s0:axe",

        -- item curse tags:
        INJUNCTION_CURSE = "lootplot.s0:injunction_curse",

        -- slot tags:
        GLASS_SLOT = "lootplot.s0:glass_slot",
        BASIC_SLOT = "lootplot.s0:basic_slot",
        SHOP_SLOT = "lootplot.s0:shop_slot",
    }
}

if client then
    lib.c = require("client.client_lib")
end

umg.expose("lib", lib)
return lib