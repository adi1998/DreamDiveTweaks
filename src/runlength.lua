local original_scaled_count = 0
local original_full_scaled_count = 0
for enemy, data in pairs(game.EnemyData) do
    if data.DreamBiomeData then
        original_scaled_count = original_scaled_count + 1
        if data.DreamBiomeData[12] then
            original_full_scaled_count = original_full_scaled_count + 1
        end
    end
end
print("enemies with scaling data", original_scaled_count)
print("enemies with scaling data for 12 biomes", original_full_scaled_count)

import 'EnemyScalingData.lua'

local count = 0
local count2 = 0
for enemy, data in pairs(game.EnemyData) do
    if data.DreamBiomeData and not (data.DreamBiomeData[12] and data.DreamBiomeData[8]) then
        print("unscaled unit", enemy)
        count = count + 1
    elseif data.DreamBiomeData and (data.DreamBiomeData[12] and data.DreamBiomeData[8]) then
        count2 = count2 + 1
    end
end
print("unpatched enemies remainaing", count, "/", count2 + count)

import 'NewEnemyScalingData.lua'
import 'EncounterScalingLogic.lua'

count2 = 0
for enemy, data in pairs(game.EnemyData) do
    if data.DreamBiomeData then
        count2 = count2 + 1
    end
end
print("new scaling data added for", count2 - original_scaled_count, "enemies")

--#region Basic runlength changes

if type(config.biome_count) == "number" then
    config.biome_count = math.min(config.biome_count, mod.MaxAllowedBiomeCount)
    config.biome_count = math.max(config.biome_count, 2)
else
    config.biome_count = 4
end

game.GameData.FullRunBiomeCount = config.biome_count

game.ConcatTableValuesIPairs(game.RoomSets.Dream, {
    "Dream_PostBoss01",
    "Dream_PostBoss02",
    "Dream_PostBoss03",
    "Dream_PostBoss01",
    "Dream_PostBoss02",
    "Dream_PostBoss03",
    "Dream_PostBoss01",
    "Dream_PostBoss02",
    "Dream_PostBoss03",
    "Dream_PostBoss01",
    "Dream_PostBoss02",
    "Dream_PostBoss03",
})

function mod.SanitizeKeepsakeCache()
    local shortenedKeepsakes = {}
    for i = 1, 4 do
        shortenedKeepsakes[i] = game.CurrentRun.KeepsakeCache[i]
    end
    game.CurrentRun.KeepsakeCache = shortenedKeepsakes
end

modutil.mod.Path.Wrap("KillHero", function (base, ...)
    mod.SanitizeKeepsakeCache()
    return base(...)
end)

modutil.mod.Path.Wrap("DeathAreaRoomTransition", function (base, ...)
    mod.SanitizeKeepsakeCache()
    return base(...)
end)

modutil.mod.Path.Wrap("CheckDreamBiomeCompletion", function (base, ...)
    if not game.CurrentRun.CurrentRoom.UseRecord.DreamPointsDrop then
		return false
	end
    -- safeguard incase config is modfified erroneously or a different save is loaded
    if game.CurrentRun.EnteredBiomes > game.GameData.FullRunBiomeCount then
        game.TraitTrayScreenClose( game.ActiveScreens.TraitTrayScreen )
        game.CloseBoonInfoScreen( game.ActiveScreens.BoonInfo )
        game.CloseCodexScreen( game.ActiveScreens.Codex )
        game.CloseInventoryScreen( game.ActiveScreens.InventoryScreen )

        game.thread( game.EndDreamRunPresentation )
        return true
    end
    return base(...)
end)

function mod.DreamFirstHalf(source, args)
    args = args or {}
    local invert = args.Invert
    local result = (game.CurrentRun.EnteredBiomes or 0) <= (game.GameData.FullRunBiomeCount / 2)
    if invert then
        return not result
    end
    return result
end

game.NamedRequirementsData.InRunFirstHalf =
{
    OrRequirements =
    {
        {
            {
                Path = { "CurrentRun", "EnteredBiomes" },
                Comparison = "<=",
                Value = 2,
            },
            {
                PathFalse = { "CurrentRun", "IsDreamRun" }
            }
        },
        {
            {
                FunctionName = _PLUGIN.guid .. "." .. "DreamFirstHalf",
            },
            {
                PathTrue = { "CurrentRun", "IsDreamRun" }
            }
        }
    }
}

game.NamedRequirementsData.InRunSecondHalf =
{
    OrRequirements =
    {
        {
            {
                Path = { "CurrentRun", "EnteredBiomes" },
                Comparison = ">",
                Value = 2,
            },
            {
                PathFalse = { "CurrentRun", "IsDreamRun" }
            }
        },
        {
            {
                FunctionName = _PLUGIN.guid .. "." .. "DreamFirstHalf",
                FunctionArgs =
                {
                    Invert = true,
                }
            },
            {
                PathTrue = { "CurrentRun", "IsDreamRun" }
            }
        }
    }
}

--#endregion

modutil.mod.Path.Wrap("IsBossDifficultyShrineUpgradeActive", function (base, source, args)
    if game.CurrentRun.IsDreamRun and game.GameData.FullRunBiomeCount ~= 4 then
        args = args or {}

        if args.UseShrineUpgradesCache then
            if (game.CurrentRun.ShrineUpgradesCache.BossDifficultyShrineUpgrade or 0) * game.GameData.FullRunBiomeCount < game.CurrentRun.EnteredBiomes * 4 then
                return false
            end
        else
            if (game.GameState.ShrineUpgrades.BossDifficultyShrineUpgrade or 0) * game.GameData.FullRunBiomeCount < game.CurrentRun.EnteredBiomes * 4 then
                return false
            end
	    end

        if game.CurrentRun.IsDreamRun and game.CurrentRun.EnteredBiomes > 0 then
            -- Block VoR boss encounters in dream runs if they've never been seen before
            local latestBiomeVisited = game.CurrentRun.BiomeVisitOrder[game.CurrentRun.EnteredBiomes]
            local encounterMapData = game.BossDifficultyShrineEncounterBiomeMap[latestBiomeVisited]
            if encounterMapData.OnlyRequireSeen then
                return game.GameState.EncountersOccurredCache[encounterMapData.Encounter]
            else
                return game.GameState.EncountersCompletedCache[encounterMapData.Encounter]
            end
        end
        return true
    end
    return base(source, args)
end)

--#region Run result subtitle

modutil.mod.Path.Wrap("GetVisitedBiomeIcons", function (base, run)
    local tooltipData = {}
    local route = run[_PLUGIN.guid .. "GeneratedRoute"] or {}
	for i=1, math.max( #(run.BiomeVisitOrder), 4, #route) do
		local icon = game.RoomSetIcons[run.BiomeVisitOrder[i]] or "BiomeMysteryIcon"
		tooltipData[i] = game.IconData[icon].TexturePath
	end
	return tooltipData
end)

modutil.mod.Path.Wrap("RunClearMessagePresentation", function (base, screen, message, tooltipData)
    if message == "ClearDreamRun" and type(tooltipData) == "table" and #tooltipData > 4 then
        local iconTemplate = "{!TooltipData[{{index}}]}"
        message = string.gsub(iconTemplate, "{{index}}", 1)
        for i = 2, #tooltipData do
            message = message .. " " .. string.gsub(iconTemplate, "{{index}}", i)
        end
    end
    return base(screen, message, tooltipData)
end)

--#endregion

--#region 3rd hammer after 4th region

game.NamedRequirementsData[_PLUGIN.guid.."LateHammerLootRequirements"] =
{
    -- unlock requirements
    {
        Path = { "GameState", "TextLinesRecord" },
        CountOf =
        {
            "PoseidonFirstPickUp",
            "DemeterFirstPickUp",
            "HestiaFirstPickUp",
            "AphroditeFirstPickUp",
            "ZeusFirstPickUp",
            "HephaestusFirstPickUp",
        },
        Comparison = ">=",
        Value = 4,
    },

    -- run requirements
    {
        FunctionName = "RequiredNotInStore",
        FunctionArgs = { Name = "WeaponUpgradeDrop", },
    },
    {
        Path = { "CurrentRun", "EnteredBiomes" },
        Comparison = ">",
        Value = 4,
    },
    {
        Path = { "CurrentRun", "LootTypeHistory", "WeaponUpgrade" },
        Comparison = "==",
        Value = 2,
    },
}

table.insert(game.RewardStoreData.RunProgress, {
    Name = "WeaponUpgrade",
    GameStateRequirements =
    {
        NamedRequirements = { _PLUGIN.guid.."LateHammerLootRequirements" },
    }
})

table.insert(game.RewardStoreData.TartarusRewards, {
    Name = "WeaponUpgrade",
    GameStateRequirements =
    {
        NamedRequirements = { _PLUGIN.guid.."LateHammerLootRequirements" },
    }
})

table.insert(game.RewardStoreData.TyphonBossRewards, {
    Name = "WeaponUpgrade",
    GameStateRequirements =
    {
        NamedRequirements = { _PLUGIN.guid.."LateHammerLootRequirements" },
    }
})

table.insert(game.PresetEventArgs.NemesisBuyItemChoices.GetOptions,{
    Name = "WeaponUpgrade", CostResourceName = "Money", CostResourceMin = 180, CostResourceMax = 205,
    GameStateRequirements =
    {
        NamedRequirements = { _PLUGIN.guid.."LateHammerLootRequirements", },
    },
})

table.insert(game.StoreData.WorldShop.GroupsOf[2].OptionsData, 3, {
    Name = "WeaponUpgradeDrop", Weight = 2.5,
    ReplaceRequirements =
    {
        {
            PathTrue = { "GameState", "UseRecord", "WeaponUpgrade" },
        },
        NamedRequirements = { _PLUGIN.guid.."LateHammerLootRequirements" },
    },
})

--#endregion

--#region 4th hammer after 8th region

game.NamedRequirementsData[_PLUGIN.guid.."LaterHammerLootRequirements"] =
{
    -- unlock requirements
    {
        Path = { "GameState", "TextLinesRecord" },
        CountOf =
        {
            "PoseidonFirstPickUp",
            "DemeterFirstPickUp",
            "HestiaFirstPickUp",
            "AphroditeFirstPickUp",
            "ZeusFirstPickUp",
            "HephaestusFirstPickUp",
        },
        Comparison = ">=",
        Value = 4,
    },

    -- run requirements
    {
        FunctionName = "RequiredNotInStore",
        FunctionArgs = { Name = "WeaponUpgradeDrop", },
    },
    {
        Path = { "CurrentRun", "EnteredBiomes" },
        Comparison = ">",
        Value = 8,
    },
    {
        Path = { "CurrentRun", "LootTypeHistory", "WeaponUpgrade" },
        Comparison = "==",
        Value = 3,
    },
}

table.insert(game.RewardStoreData.RunProgress, {
    Name = "WeaponUpgrade",
    GameStateRequirements =
    {
        NamedRequirements = { _PLUGIN.guid.."LaterHammerLootRequirements" },
    }
})

table.insert(game.RewardStoreData.TartarusRewards, {
    Name = "WeaponUpgrade",
    GameStateRequirements =
    {
        NamedRequirements = { _PLUGIN.guid.."LaterHammerLootRequirements" },
    }
})

table.insert(game.RewardStoreData.TyphonBossRewards, {
    Name = "WeaponUpgrade",
    GameStateRequirements =
    {
        NamedRequirements = { _PLUGIN.guid.."LaterHammerLootRequirements" },
    }
})

table.insert(game.PresetEventArgs.NemesisBuyItemChoices.GetOptions,{
    Name = "WeaponUpgrade", CostResourceName = "Money", CostResourceMin = 180, CostResourceMax = 205,
    GameStateRequirements =
    {
        NamedRequirements = { _PLUGIN.guid.."LaterHammerLootRequirements", },
    },
})

table.insert(game.StoreData.WorldShop.GroupsOf[2].OptionsData, 3, {
    Name = "WeaponUpgradeDrop", Weight = 2.5,
    ReplaceRequirements =
    {
        {
            PathTrue = { "GameState", "UseRecord", "WeaponUpgrade" },
        },
        NamedRequirements = { _PLUGIN.guid.."LaterHammerLootRequirements" },
    },
})

--#endregion

--#region 3rd Hermes drop
game.NamedRequirementsData[_PLUGIN.guid.."LateHermesUpgradeRequirements"] =
{
    -- unlock requirements
    {
        Path = { "GameState", "TextLinesRecord" },
        HasAll = { "HermesFirstPickUp" },
    },

    -- run requirements
    {
        FunctionName = "RequiredNotInStore",
        FunctionArgs = { Name = "ShopHermesUpgrade", },
    },
    {
        Path = { "CurrentRun", "BiomeUseRecord", },
        HasNone = { "HermesUpgrade", "ShopHermesUpgrade", },
    },
    {
        Path = { "CurrentRun", "LootTypeHistory", "HermesUpgrade" },
        Comparison = "==",
        Value = 2,
    },
    {
        Path = { "CurrentRun", "EnteredBiomes" },
        Comparison = ">",
        Value = 4,
    },
}

table.insert(game.RewardStoreData.HubRewards, {
    Name = "HermesUpgrade",
    GameStateRequirements =
    {
        NamedRequirements = { _PLUGIN.guid.."LateHermesUpgradeRequirements", },
    }
})

table.insert(game.RewardStoreData.RunProgress, {
    Name = "HermesUpgrade",
    GameStateRequirements =
    {
        NamedRequirements = { _PLUGIN.guid.."LateHermesUpgradeRequirements", },
    }
})
--#endregion

--#region 5th and 6th god

modutil.mod.Path.Wrap("StartRoom", function (base, currentRun, currentRoom)
    base(currentRun, currentRoom)
    if currentRun.IsDreamRun and (currentRun.EnteredBiomes - 1) % 4 == 0 and currentRoom.BiomeStartRoom then
        game.CurrentRun.MaxGodsPerRun = 4 + (currentRun.EnteredBiomes - 1) / 4
        if currentRun.EnteredBiomes > 12 then
            game.CurrentRun.LootTypeHistory.WeaponUpgrade = math.min(game.CurrentRun.LootTypeHistory.WeaponUpgrade or 0, 3)
            game.CurrentRun.LootTypeHistory.HermesUpgrade = math.min(game.CurrentRun.LootTypeHistory.HermesUpgrade or 0, 2)
        end
    end
end)

--#endregion

--#region Hermes early spawn

local shopRooms = {
    "F_PreBoss01",
    "G_PreBoss01",
    "H_PreBoss01",
    "I_PreBoss02",
    "I_PreBoss01",

    "N_PreBoss01",
    "O_PreBoss01",
    "P_PreBoss01",

    "A_PreBoss01",
    "X_PreBoss01",
    "Y_PreBoss01",
}

local function getEventIndex(events, functionName)
    for index, event in ipairs(events) do
        if event.FunctionName == functionName then
            return index
        end
    end
end

function mod.CheckLastBiome(source, args)
    return (game.CurrentRun.EnteredBiomes == game.GameData.FullRunBiomeCount)
end

for _, roomName in ipairs(shopRooms) do
    local roomData = game.RoomData[roomName]
    if roomData then
        roomData.StartUnthreadedEvents = roomData.StartUnthreadedEvents or {}
        local eventIndex = getEventIndex(roomData.StartUnthreadedEvents, "CompleteSurfaceShopItems")
        if eventIndex then
            roomData.StartUnthreadedEvents[eventIndex].GameStateRequirements[3] = {
                FunctionName = _PLUGIN.guid .. "." .. "CheckLastBiome"
            }
        else
            table.insert(roomData.StartUnthreadedEvents,
            {
                FunctionName = "CompleteSurfaceShopItems",
                GameStateRequirements =
                {
                    {
                        PathTrue = { "CurrentRun", "IsDreamRun" },
                    },
                    {
                        PathTrue = { "CurrentRun", "CurrentRoom", "AutocompleteSurfaceShopDelivery" },
                    },
                    {
                        FunctionName = _PLUGIN.guid .. "." .. "CheckLastBiome"
                    }
                }
            })
        end
    end
end

function mod.CheckLastBiomeSummit(source, args)
    return (game.CurrentRun.EnteredBiomes == game.GameData.FullRunBiomeCount and game.CurrentRun.IsDreamRun) or (game.CurrentRun.EnteredBiomes == 4 and not game.CurrentRun.IsDreamRun)
end

if game.RoomData["Q_PreBoss01"].DistanceTriggers[1].GameStateRequirements.OrRequirements then
    table.insert(game.RoomData["Q_PreBoss01"].DistanceTriggers[1].GameStateRequirements.OrRequirements, {
        {
            FunctionName = _PLUGIN.guid .. "." .. "CheckLastBiomeSummit"
        }
    })
else
    game.RoomData["Q_PreBoss01"].DistanceTriggers[1].GameStateRequirements =
    {
        OrRequirements =
        {
            {
                {
                    FunctionName = _PLUGIN.guid .. "." .. "CheckLastBiomeSummit"
                },
            }
        }
    }
end

--#endregion

modutil.mod.Path.Wrap("ZagreusDeathDefiancePresentation", function (base, boss, currentRun, aiStage)
    boss.MaxHealth = aiStage.NewMaxHealth or boss.MaxHealth
	if currentRun.IsDreamRun and boss.DreamBiomeData ~= nil then
		local dreamBiomeData = boss.DreamBiomeData[currentRun.EnteredBiomes]
		if dreamBiomeData ~= nil and dreamBiomeData.DataOverrides ~= nil and dreamBiomeData.DataOverrides.HealthMultiplier ~= nil then
			boss.MaxHealth = boss.MaxHealth / dreamBiomeData.DataOverrides.HealthMultiplier
		end
	end
    return base(boss, currentRun, aiStage)
end)