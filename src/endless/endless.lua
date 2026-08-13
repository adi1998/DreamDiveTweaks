local fullRunBiomeCountProxy = {
    FullRunBiomeCount = game.GameData.FullRunBiomeCount
}

game.GameData.FullRunBiomeCount = nil

setmetatable(game.GameData, {
    __index = function(t, k)
        if k == "FullRunBiomeCount" then
            if not game.CurrentHubRoom and game.CurrentRun and game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
                return 999
            end
            return fullRunBiomeCountProxy[k]
        end
    end,

    __newindex = function(t, k, v)
        if k == "FullRunBiomeCount" then
            fullRunBiomeCountProxy[k] = v
        else
            rawset(t, k, v)
        end
    end
})

setmetatable(game.RoomSets.Dream, {
    __index = function(t, k)
        if type(k) == "number" and not rawget(t, k) then
            return rawget(t, (k - 2) % 3 + 2)
        end
    end,
})

-- endless is always in second half
modutil.mod.Path.Wrap(_PLUGIN.guid .. "." .. "DreamFirstHalf", function(base, source, args)
    args = args or {}
    if game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
        return args.Invert
    end
    return base(source, args)
end)

-- VoR is only active in Endless if BossDifficultyShrineUpgrade is maxed out
modutil.mod.Path.Wrap("IsBossDifficultyShrineUpgradeActive", function(base, source, args)
    if game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
        if game.GameState.ShrineUpgrades.BossDifficultyShrineUpgrade == #game.MetaUpgradeData.BossDifficultyShrineUpgrade.Ranks then
            return true
        end
        return false
    end
    return base(source, args)
end)

function mod.CleanupBiomeVisits()
    game.CurrentRun.EncountersOccurredCache = {}
    game.CurrentRun.EncountersCompletedCache = {}
    game.CurrentRun.RoomsEntered = {}
    game.CurrentRun.SpawnRecord.SoulPylon = 0
    game.CurrentRun.ClosedDoors = {}
    game.CurrentRun.RoomCreations = {}
    game.CurrentRun.RoomCountCache = {}

    if npcRando and npcRando.config and npcRando.config.enabled then
        game.CurrentRun[_PLUGIN.guid .. "SwappedStoryMap"] = {}
        game.CurrentRun[_PLUGIN.guid .. "StoryRoomsCreated"] = {}
    end

    -- for i = 1, #game.CurrentRun.RoomHistory do
    --     if game.CurrentRun.RoomHistory[i].Name == "N_Hub" then
    --         table.remove(game.CurrentRun.RoomHistory, i)
    --     end
    -- end

    game.CurrentRun.RoomHistory = {}
    game.CurrentRun.BiomesReached = {}
    game.CurrentRun.MusicRecord = {}
end

modutil.mod.Path.Wrap("SelectNextDreamBiome", function(base, source, args)
    if game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
        if game.IsEmpty(game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"]) then
            game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"] = game.CombineTablesIPairs(
                game.CurrentRun[_PLUGIN.guid .. "GeneratedRoute"],
                game.CurrentRun[_PLUGIN.guid .. "UnusedBiomes"] or {}
            )
            game.FYShuffle(game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"])
            mod.CleanupBiomeVisits()
        end
        local nextRoomSet = game.RemoveValueAndCollapse(game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"], math.random(#game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"]))
        game.CurrentRun.CurrentRoom.NextRoomSet = { nextRoomSet }
        return
    end
    return base(source, args)
end)

function  mod.GetScaledDreamBiomeData(dreamBiomeData, depth)
    local entry = dreamBiomeData[12]
    local prev_entry = dreamBiomeData[11]
    local new_entry = game.DeepCopyTable(entry)
    if entry.AddOutgoingDamageModifier and entry.AddOutgoingDamageModifier.PlayerMultiplier then
        new_entry.AddOutgoingDamageModifier.PlayerMultiplier = entry.AddOutgoingDamageModifier.PlayerMultiplier *
            ((entry.AddOutgoingDamageModifier.PlayerMultiplier / prev_entry.AddOutgoingDamageModifier.PlayerMultiplier) ^ (depth - 12))
    end
    if entry.DataOverrides and entry.DataOverrides.HealthMultiplier then
        new_entry.DataOverrides.HealthMultiplier = entry.DataOverrides.HealthMultiplier *
            (entry.DataOverrides.HealthMultiplier / prev_entry.DataOverrides.HealthMultiplier) ^ (depth - 12)
    end
    if entry.DataOverrides and entry.DataOverrides.OutgoingDamageModifiers then
        for index, modifier in ipairs(entry.DataOverrides.OutgoingDamageModifiers) do
            if modifier.PlayerMultiplier ~= nil then
                new_entry.DataOverrides.OutgoingDamageModifiers[index].PlayerMultiplier = modifier.PlayerMultiplier *
                    (modifier.PlayerMultiplier / prev_entry.DataOverrides.OutgoingDamageModifiers[index].PlayerMultiplier ) ^ (depth - 12)
            end
            if modifier.NonPlayerMultiplier ~= nil then
                new_entry.DataOverrides.OutgoingDamageModifiers[index].NonPlayerMultiplier = modifier.NonPlayerMultiplier *
                    (modifier.NonPlayerMultiplier / prev_entry.DataOverrides.OutgoingDamageModifiers[index].NonPlayerMultiplier ) ^ (depth - 12)
            end
        end
    end
    return new_entry
end

local scalingCache = {}

modutil.mod.Path.Wrap("SetupUnit", function (base, unit, currentRun, args)
    if unit.DreamBiomeData and currentRun.IsDreamRun and currentRun.EnteredBiomes > 12 then
        scalingCache[unit.Name] = scalingCache[unit.Name] or {}
        scalingCache[unit.Name].DreamBiomeData = scalingCache[unit.Name].DreamBiomeData or {}
        scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes] = scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes] or mod.GetScaledDreamBiomeData(unit.DreamBiomeData, currentRun.EnteredBiomes)
        scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes + 1] = scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes + 1] or mod.GetScaledDreamBiomeData(unit.DreamBiomeData, currentRun.EnteredBiomes + 1)
        unit.DreamBiomeData[currentRun.EnteredBiomes] = scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes]
        unit.DreamBiomeData[currentRun.EnteredBiomes + 1] = scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes + 1]
    end
    return base(unit, currentRun, args)
end)