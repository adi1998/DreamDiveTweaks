function public.RegisterBiome(biomeName, biomeData)
    biomeData = game.DeepCopyTable(biomeData)
    biomeData.GameStateRequirements = biomeData.GameStateRequirements or {}
    table.insert(biomeData.GameStateRequirements, {
        PathFalse = { "ModData", _PLUGIN.guid, "banned_biomes", biomeName }
    })
    biomeData.Name = biomeName
    if not ModBiomeData[biomeName] then
        ModBiomeData[biomeName] = biomeData
    else
        rom.log.warning("Tried to register duplicate biome, skipping addition of", biomeName)
    end
end

function mod.IsBiomeEligible(biome, depth, args)
    args = args or {}
    if args.ForceBiome then
        return true
    end
    local selectCount = args.SelectCount
    if selectCount and (selectCount[biome.Name] or 0) > config.max_repeats_allowed then
        return false
    end
    if not args.IgnoreRestrictions and depth == 1 and biome.StartingBiome and not config.biome_pool.larger_starting_pool then
        return false
    end
    if not args.IgnoreRestrictions and depth == 1 and not biome.EasyBiome and config.biome_pool.easy_first_biome then
        return false
    end
    if not args.IgnoreRestrictions and depth == game.GameData.FullRunBiomeCount and not biome.HardBiome and config.biome_pool.hard_last_biome then
        return false
    end
    if not (game.IsEmpty(biome.GameStateRequirements) or game.IsGameStateEligible(biome, biome.GameStateRequirements)) then
        return false
    end
    if not game.IsGameStateEligible(biome, {
        {
            PathFalse = { "ModData", _PLUGIN.guid, "banned_biomes_depth", depth, biome.Name }
        }
    }) then
        return false
    end
    return true
end

local function getBiome(depth, args)
    args = args or {}
    local eligible_biomes = {}
    for biomeName, biomeData in pairs(ModBiomeData) do
        if mod.IsBiomeEligible(biomeData, depth, args) then
            table.insert(eligible_biomes, biomeName)
        end
    end
    print(dump(eligible_biomes))
    if not game.IsEmpty(eligible_biomes) then
        local biome = mod.GetRandomTableValue(eligible_biomes)
        return biome
    else
        return nil, "Failed to find eligible biome at depth " .. depth
    end
end

function GenerateRouteNew()
    local route = {}
    local selectCount = {}
    local args = {
        SelectCount = {}
    }
    local err
    route[1], err = getBiome(1, args)
    if err then
        return nil, err
    end
    args.SelectCount[route[1]] = (args.SelectCount[route[1]] or 0) + 1
    for i = game.GameData.FullRunBiomeCount, 2, -1 do
        route[i], err = getBiome(i, args)
        if err then
            return nil, err
        end
        args.SelectCount[route[i]] = (args.SelectCount[route[i]] or 0) + 1
    end
    return route
end

function RetryGenerateRoute()
    local repeat_limit = #game.CollapseTable(ModBiomeData) - 1
    local repeat_start = math.min(config.max_repeats_allowed, repeat_limit)
    config.max_repeats_allowed = repeat_start
    local retries_per_limit = 6
    local route, msg
    for rep = repeat_start, repeat_limit do
        for retry = 1, retries_per_limit do
            route, msg = GenerateRouteNew()
            if route then
                if retry > 1 then
                    msg = "Warning: Biome bans maybe too restrictive. Required " .. retry .. " retries to find route."
                end
                if rep > repeat_start then
                    msg = "Warning: Biome bans too restrictive, increasing duplicate biome limit to " .. config.max_repeats_allowed
                end
                return route, msg
            end
            print(retry, rep, msg)
        end
        config.max_repeats_allowed = math.min(config.max_repeats_allowed + 1, repeat_limit)
    end
    config.biome_count = 4
    game.GameData.FullRunBiomeCount = 4
    return {"F", "G", "H", "I"}, "Error: Unable to create Dream Dive route. Check bans and other restrictions."
end

if game.CurrentRun then
    config.max_repeats_allowed = 0
    mod.Data.banned_biomes = {}
    mod.Data.banned_biomes["Q"] = true
    mod.Data.banned_biomes["Styx"] = true
    mod.Data.banned_biomes["I"] = true
    mod.Data.banned_biomes["P"] = true
    mod.Data.banned_biomes["Elysium"] = true
    local a,b = RetryGenerateRoute()
    print (dump(a), b)
end