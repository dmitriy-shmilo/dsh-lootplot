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
        RECORD = "dsh.lib:record",
        WEAPON = "dsh.lib:weapon",
        SHIELD = "dsh.lib:shield"
    },

    -- vanilla entities, which need to be treated as if they have certain tags
    -- used with lib.hasTag
    TAGGED_ENTITIES = {
    },

    STARTING_ITEM_TYPES = {
        ["lootplot.s0:one_ball"] = true,
        ["lootplot.s0:six_ball"] = true,
        ["lootplot.s0:five_ball"] = true,
        ["lootplot.s0:G_ball"] = true,
        ["lootplot.s0:S_ball"] = true,
        ["lootplot.s0:eight_ball"] = true,
        ["lootplot.s0:seven_ball"] = true,
        ["lootplot.s0:blank_ball"] = true,
        ["lootplot.s0:azazel_ball"] = true,
        ["lootplot.s0:nine_ball"] = true,
        ["lootplot.s0:L_ball"] = true,
        ["lootplot.s0:rainbow_ball"] = true,
        ["lootplot.s0:eden_ball"] = true,
        ["lootplot.s0:negative_one_ball"] = true,
        ["lootplot.s0:bowling_ball"] = true,
        ["lootplot.s0:basketball"] = true
    },

    REROLLABLE_RARITIES = {
    },

    -- default weights to use when rolling for items,
    -- used by shops and reroll slots
    SHOP_RARITY_WEIGHTS = {
        COMMON = 10,
        UNCOMMON = 1,
        RARE = 0.03,
        EPIC = 0.02
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

taggedEntities[lib.tags.WEAPON] = {
    "lootplot.s0:shuriken",
    "lootplot.s0:morning_star",
    "lootplot.s0:dagger",
    "lootplot.s0:golden_dagger",
    "lootplot.s0:lava_sword",
    "lootplot.s0:water_sword",
    "lootplot.s0:boomerang",
    "lootplot.s0:golden_knuckles",
    "lootplot.s0:curse_knife",
    "lootplot.s0:ghost_knife",
    "lootplot.s0:demon_knife",
    "lootplot.s0:lokis_axe",
    "lootplot.s0:odins_axe"
}

local material = { "iron", "ruby", "emerald", "golden" }
local weaponTypes = { "sword", "axe", "spear", "hammer", "crossbow", "greatsword" }

for _, m in pairs(material) do
    for _, w in pairs(weaponTypes) do
        table.insert(taggedEntities[lib.tags.WEAPON], "lootplot.s0:" .. m .. "_" .. w)
    end
end

for tag, entities in pairs(taggedEntities) do
    for _, entity in pairs(entities) do
        local backTags = lib.TAGGED_ENTITIES[entity] or {}
        backTags[tag] = true
        lib.TAGGED_ENTITIES[entity] = backTags
    end
end

lp.defineTag(lib.tags.WEAPON)
lp.defineTag(lib.tags.RECORD)

-- Checks whether the entity has the specified tag, or is
-- backtagged in lib.TAGGED_ENTITIES.
-- @param entOrType Entity|string either an entity or an entity type name.
-- @param tag string a tag to check for.
lib.hasTag = function(entOrType, tag)
    local typeName
    local etype

    if not entOrType or not tag then return false end
    
    if type(entOrType) == "table" and entOrType.type then
        typeName = entOrType:type()
        etype = entOrType
    elseif type(entOrType) == "string" then
        typeName = entOrType
        etype = server.entities[typeName]
    end
    
    local backTags = lib.TAGGED_ENTITIES[typeName] or {}
    return backTags[tag] or lp.hasTag(etype, tag)
end

-- destroys entity, draining all of its lives first
lib.erase = function(ent)
    if not ent then return end
    if ent.lives then
        ent.lives = ent.lives - 1
    end
    lp.destroy(ent)
end

-- returns a new array, with shuffled elements
-- see https://stackoverflow.com/a/68486276
-- if the input contains 1 or less elements, returns input
lib.shuffledRandom = function (t)
    local len = #t
    if len < 2 then
        return t
    end

    local s = {}
    for i = 1, #t do s[i] = t[i] end
    for i = #t, 2, -1 do
        local j = math.random(i)
        s[i], s[j] = s[j], s[i]
    end
    return s
end

lib.plotForEachItem = function(plot, predicate)
    for y = 0, plot.height - 1 do
        for x = plot.width - 1, 0, -1 do
            local ppos = plot:getPPos(x, y)
            local item = lp.posToItem(ppos)
            if item and not predicate(item, ppos, plot) then return end
        end
    end
end

if client then
    require("client.lib")(lib)
end

return lib