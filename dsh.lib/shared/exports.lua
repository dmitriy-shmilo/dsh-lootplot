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

        -- custom tags
        RECORD = "dsh.vv:record"
    },

    -- vanilla entities, which need to be treated as if they have certain tags
    -- used with lib.hasTag
    TAGGED_ENTITIES = {
    },

    REROLLABLE_RARITIES = {
    }
}

lib.REROLLABLE_RARITIES[lp.rarities.COMMON] = true
lib.REROLLABLE_RARITIES[lp.rarities.UNCOMMON] = true
lib.REROLLABLE_RARITIES[lp.rarities.RARE] = true
lib.REROLLABLE_RARITIES[lp.rarities.EPIC] = true
lib.REROLLABLE_RARITIES[lp.rarities.LEGENDARY] = true

local taggedEntities = {
}

taggedEntities[lib.tags.RECORD] = {
    "lootplot.s0:record_green", 
    "lootplot.s0:record_blue", 
    "lootplot.s0:record_golden", 
    "lootplot.s0:record_white", 
    "lootplot.s0:record_red"
}

for tag, entities in pairs(taggedEntities) do
    for _, entity in pairs(entities) do
        local backTags = lib.TAGGED_ENTITIES[entity] or {}
        backTags[tag] = true
        lib.TAGGED_ENTITIES[entity] = backTags
    end    
end

-- checks whether the entity has the specified tag, or is
-- backtagged in lib.TAGGED_ENTITIES
lib.hasTag = function(ent, tag)
    local backTags = lib.TAGGED_ENTITIES[ent:type()] or {}
    return backTags[tag] or lp.hasTag(ent, tag)
end

-- destroys entity, draining all of its lives first
lib.erase = function(ent)
    if ent.lives then
        ent.lives = ent.lives - 1
    end
    lp.destroy(ent)
end

if client then
    lib.c = require("client.client_lib")
end

umg.expose("lib", lib)
return lib