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
    game.CurrentRun.BiomeRoomCountCache = {}
    game.CurrentRun.EncountersOccurredBiomeCache = {}

    game.CurrentRun.FieldsMaxDoorsRolled = 0

    if npcRando and npcRando.config and npcRando.config.enabled then
        game.CurrentRun[NPCRando_guid .. "SwappedStoryMap"] = {}
        game.CurrentRun[NPCRando_guid .. "StoryRoomsCreated"] = {}
    end

    -- for i = 1, #game.CurrentRun.RoomHistory do
    --     if game.CurrentRun.RoomHistory[i].Name == "N_Hub" then
    --         table.remove(game.CurrentRun.RoomHistory, i)
    --     end
    -- end

    game.CurrentRun.RoomHistory = {}
    game.CurrentRun.BiomesReached = {}
    game.CurrentRun.MusicRecord = {}

    -- ZJ
    if mod.IsZagAvailable then
        game.CurrentRun.CompletedStyxWings = 0
        game.CurrentRun.ThanatosSpawns = 0
        game.CurrentRun.SupportAINames = {}
    end
end

modutil.mod.Path.Wrap("SelectNextDreamBiome", function(base, source, args)
    if game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
        if game.IsEmpty(game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"]) then
            game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"] = game.CombineTablesIPairs(
                game.CurrentRun[_PLUGIN.guid .. "GeneratedRoute"],
                game.CurrentRun[_PLUGIN.guid .. "UnusedBiomes"] or {}
            )
            game.FYShuffle(game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"])
            print("New shuffled biome order", dump(game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"]))
            mod.CleanupBiomeVisits()
        end
        local nextRoomSet = table.remove(game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"])
        game.CurrentRun.CurrentRoom.NextRoomSet = { nextRoomSet }
        return
    end
    return base(source, args)
end)

function  mod.GetScaledDreamBiomeData(dreamBiomeData, depth)
    local entry = dreamBiomeData[12]
    local endlessDamageRamp = 1.25
    local endlessHealthRamp = 1.1
    local new_entry = game.DeepCopyTable(entry)
    if entry.AddOutgoingDamageModifier and entry.AddOutgoingDamageModifier.PlayerMultiplier then
        new_entry.AddOutgoingDamageModifier.PlayerMultiplier = entry.AddOutgoingDamageModifier.PlayerMultiplier * ( endlessDamageRamp ^ (depth - 12))
        print("Damage", entry.AddOutgoingDamageModifier.PlayerMultiplier, "to", new_entry.AddOutgoingDamageModifier.PlayerMultiplier)
    end
    if entry.DataOverrides and entry.DataOverrides.HealthMultiplier then
        new_entry.DataOverrides.HealthMultiplier = entry.DataOverrides.HealthMultiplier * (endlessHealthRamp ^ (depth - 12))
        print("HealthMultiplier", entry.DataOverrides.HealthMultiplier, "to", new_entry.DataOverrides.HealthMultiplier)
    end
    if entry.DataOverrides and entry.DataOverrides.HealingMultiplier then
        new_entry.DataOverrides.HealingMultiplier = entry.DataOverrides.HealingMultiplier * (endlessHealthRamp ^ (depth - 12))
        print("HealingMultiplier", entry.DataOverrides.HealingMultiplier, "to", new_entry.DataOverrides.HealingMultiplier)
    end
    if entry.DataOverrides and entry.DataOverrides.OutgoingDamageModifiers then
        for index, modifier in ipairs(entry.DataOverrides.OutgoingDamageModifiers) do
            if modifier.PlayerMultiplier ~= nil then
                new_entry.DataOverrides.OutgoingDamageModifiers[index].PlayerMultiplier = modifier.PlayerMultiplier * ( endlessDamageRamp ^ (depth - 12))
            end
            if modifier.NonPlayerMultiplier ~= nil then
                new_entry.DataOverrides.OutgoingDamageModifiers[index].NonPlayerMultiplier = modifier.NonPlayerMultiplier * (endlessHealthRamp ^ (depth - 12))
            end
        end
    end
    return new_entry
end

local scalingCache = {}

modutil.mod.Path.Wrap("SetupUnit", function (base, unit, currentRun, args)
    currentRun = currentRun or game.CurrentRun
	args = args or {}
    if unit and unit.DreamBiomeData and unit.DreamBiomeData[12] and currentRun and currentRun.IsDreamRun and currentRun.EnteredBiomes > 12 then
        print("scaling unit ", unit.Name, "for depth ", currentRun.EnteredBiomes)
        scalingCache[unit.Name] = scalingCache[unit.Name] or {}
        scalingCache[unit.Name].DreamBiomeData = scalingCache[unit.Name].DreamBiomeData or {}
        scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes] = scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes] or mod.GetScaledDreamBiomeData(unit.DreamBiomeData, currentRun.EnteredBiomes)
        scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes + 1] = scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes + 1] or mod.GetScaledDreamBiomeData(unit.DreamBiomeData, currentRun.EnteredBiomes + 1)
        unit.DreamBiomeData[currentRun.EnteredBiomes] = scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes]
        unit.DreamBiomeData[currentRun.EnteredBiomes + 1] = scalingCache[unit.Name].DreamBiomeData[currentRun.EnteredBiomes + 1]
        if VorBossSetupEventIndex[unit.Name] then
            local setupEvents = unit.SetupEvents or {}
            for _, event in ipairs(setupEvents) do
                if event.FunctionName == "OverwriteSelf" and event.Args and event.Args.DreamBiomeData then
                    event.Args.DreamBiomeData[currentRun.EnteredBiomes] = unit.DreamBiomeData[currentRun.EnteredBiomes]
                end
            end
        end
    end
    return base(unit, currentRun, args)
end)

modutil.mod.Path.Wrap("SetupEncounter", function (base, encounterData, room)
    if encounterData and encounterData.DreamBiomeData and encounterData.DreamBiomeData[12] and game.CurrentRun and game.CurrentRun.IsDreamRun and (game.CurrentRun.EnteredBiomes or 1) > 12 then
        encounterData.DreamBiomeData[game.CurrentRun.EnteredBiomes or 1] = encounterData.DreamBiomeData[game.CurrentRun.EnteredBiomes or 1] or encounterData.DreamBiomeData[12]
    end
    return base(encounterData, room)
end)

local totalDodge = 0
local totalCappedDodge = 0
local dodgeCap = 0.96

game.OnAnyLoad
{
    function ()
        if game.CurrentRun and game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
            game.zerpDreamDiveTweaksEndlessDodgeMessage = "Capped to " .. dodgeCap * 100 .. "% in Endless."
        else
            game.zerpDreamDiveTweaksEndlessDodgeMessage = ""
        end
    end
}

local locales = {
    "de",
    "el",
    "en",
    "es",
    "fr",
    "it",
    "ja",
    "ko",
    "pl",
    "pt-BR",
    "ru",
    "tr",
    "uk",
    "zh-CN",
    "zh-TW",
}

for _, locale in pairs(locales) do
    local filePath = rom.path.combine(rom.paths.Content, "Game\\Text\\" .. locale .."\\HelpText." .. locale .. ".sjson")
    sjson.hook(filePath, function (data)
        for _, value in pairs(data.Texts) do
            if value.Id == "Dodge" then
                value.Description = value.Description .. " {$zerpDreamDiveTweaksEndlessDodgeMessage}"
            end
        end
        return data
    end)
end

modutil.mod.Path.Wrap("SetLifeProperty", function (base, args)
    if args.DestinationId == game.CurrentRun.Hero.ObjectId and args.Property == "DodgeChance" and game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
        print(args.ValueChangeType, args.Value)
        if args.ValueChangeType == "Add" then
            local value = args.Value
            if totalDodge < dodgeCap then
                if totalDodge + args.Value > dodgeCap then
                    args.Value = dodgeCap - totalDodge
                else

                end
            else
                if totalDodge + args.Value < dodgeCap then
                    args.Value = (totalDodge + args.Value) - dodgeCap
                else
                    args.Value = 0
                end
            end

            totalDodge = totalDodge + value
            totalCappedDodge = totalCappedDodge + args.Value
            print("totalDodge", totalDodge)
            print("totalCappedDodge", totalCappedDodge)
        end
    end
    return base(args)
end)

modutil.mod.Path.Wrap("LeaveRoom", function (base, ...)
    totalDodge = 0
    totalCappedDodge = 0
    return base(...)
end)

modutil.mod.Path.Wrap("DeathAreaSwitchRoom", function (base, ...)
    totalDodge = 0
    totalCappedDodge = 0
    return base(...)
end)

local NPC_fucntions = {
    "EchoChoice",
    "ArachneCostumeChoice",
    "NarcissusBenefitChoice",
    "MedeaCurseChoice",
    "CirceBlessingChoice",
    "IcarusBenefitChoice",
}

if mod.IsZagAvailable then
    table.insert(NPC_fucntions, ZJ_guid .. "." .. "ModsNikkelMHadesBiomesBenefitChoice")
end

for _, functionName in ipairs(NPC_fucntions) do
    modutil.mod.Path.Wrap(functionName, function (base, source, args, screen)
        local options = {}
        args = game.ShallowCopyTable(args)
        for key, value in pairs(args.UpgradeOptions) do
            if not game.HeroHasTrait(value.ItemName) then
                table.insert(options, value)
            end
        end
        args.UpgradeOptions = options
        return base(source, args, screen)
    end)
end