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
        SHIELD = "dsh.lib:shield",
        ORGANIC = "dsh.lib:organic",
        FIREPROOF = "dsh.lib:fireproof"
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

taggedEntities[lib.tags.SHIELD] = {
    "lootplot.s0:doomed_shield",
    "lootplot.s0:wooden_shield",
    "lootplot.s0:broken_shield",
    "lootplot.s0:mini_wooden_shield",
    "lootplot.s0:level_shield",
    "lootplot.s0:interdimensional_shield",
    "lootplot.s0:multiplier_shield",
    "lootplot.s0:money_shield",
    "lootplot.s0:bonus_shield",
    "lootplot.s0:points_shield"
}

taggedEntities[lib.tags.FIREPROOF] = {
    "lootplot.s0:clone_rocks"
}

taggedEntities[lib.tags.ORGANIC] = {
    "lootplot.s0:cheese_slice",
    "lootplot.s0:evil_cheese_slice",
    "lootplot.s0:butter",
    "lootplot.s0:magic_turnip",
    "lootplot.s0:golden_turnip",
    "lootplot.s0:doomed_turnip",
    "lootplot.s0:slot_turnip",
    "lootplot.s0:gray_turnip",
    "lootplot.s0:green_olive",
    "lootplot.s0:green_squash",
    "lootplot.s0:red_olive",
    "lootplot.s0:red_squash",
    "lootplot.s0:teal_olive",
    "lootplot.s0:black_olive",
    "lootplot.s0:eggplant",
    "lootplot.s0:raspberry",
    "lootplot.s0:fortune_cookie",
    "lootplot.s0:heartfruit_half",
    "lootplot.s0:heartfruit_purple",
    "lootplot.s0:raw_steak",
    "lootplot.s0:raw_potato",
    "lootplot.s0:salmon_steak",
    "lootplot.s0:salmon",
    "lootplot.s0:cucumber_slices",
    "lootplot.s0:dirty_muffin",
    "lootplot.s0:sniper_berries",
    "lootplot.s0:ginger_roots",
    "lootplot.s0:stone_fruit",
    "lootplot.s0:chocolate_square",
    "lootplot.s0:sliced_stone_fruit",
    "lootplot.s0:dragonfruit",
    "lootplot.s0:dragonfruit_slice",
    "lootplot.s0:sausage",
    "lootplot.s0:ruby_candy",
    "lootplot.s0:diamond_candy",
    "lootplot.s0:steelberry",
    "lootplot.s0:avacado",
    "lootplot.s0:fried_egg",
    "lootplot.s0:burned_loaf",
    "lootplot.s0:golden_loaf",
    "lootplot.s0:food_loaf",
    "lootplot.s0:coconut",
    "lootplot.s0:lime",
    "lootplot.s0:lemon",
    "lootplot.s0:black_bean",
    "lootplot.s0:evil_cheese_slice",
    "lootplot.s0:tangerine",
    "lootplot.s0:sliced_apple",
    "lootplot.s0:bananas",
    "lootplot.s0:blueberry",
    "lootplot.s0:golden_apple",
    "lootplot.s0:ruby_apple",
    "lootplot.s0:diamond_apple",
    "lootplot.s0:green_apple",
    "lootplot.s0:lychee",
    "lootplot.s0:purple_brain",
    "lootplot.s0:cloneberries",
    "lootplot.s0:doomed_cloneberries",
    "lootplot.s0:slice_of_cake",
    "lootplot.s0:red_cheesecake",
    "lootplot.s0:blue_cheesecake",
    "lootplot.s0:mushroom_red",
    "lootplot.s0:mushroom_purple",
    "lootplot.s0:mushroom_pink",
    "lootplot.s0:mushroom_green",
    "lootplot.s0:mushroom_blue",
    "lootplot.s0:mushroom_floaty",
    "lootplot.s0:pink_donut",
    "lootplot.s0:frosted_donut",
    "lootplot.s0:bread",

    "lootplot.s0:copycat",
    "lootplot.s0:dangerously_funny_cat",
    "lootplot.s0:splatter_cat",
    "lootplot.s0:copykitten",
    "lootplot.s0:midas_cat",
    "lootplot.s0:pink_cat",
    "lootplot.s0:crappy_cat",
    "lootplot.s0:evil_cat",
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
lp.defineTag(lib.tags.SHIELD)
lp.defineTag(lib.tags.ORGANIC)
lp.defineTag(lib.tags.FIREPROOF)

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

if server then
    
end

lib.hooks = require("shared.hooks")
require("shared.patch")()

return lib