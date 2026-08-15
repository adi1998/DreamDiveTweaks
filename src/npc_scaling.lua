local npcsToScale = {
    NPC_Circe_01 = {
        ScalingKeyHeroic = "Epic",
        ScalingKeyEpic = "Rare",
    },
    NPC_Arachne_01 = {
        ScalingKeyHeroic = "Epic",
        ScalingKeyEpic = "Rare",
    },
    NPC_Echo_01 = {

    },
    NPC_Icarus_01 = {

    },
    NPC_Medea_01 = {
        ScalingKeyHeroic = "Epic",
        ScalingKeyEpic = "Rare",
    },
    NPC_Narcissus_01 = {
        ScalingKeyHeroic = "Epic",
        ScalingKeyEpic = "Rare",
    },

    -- ZJ NPCs
    NPC_Sisyphus_01 = {
        ScalingKeyHeroic = "Epic",
        ScalingKeyEpic = "Rare",
    },
    NPC_Eurydice_01 = {

    },
    NPC_Patroclus_01 = {

    }
}

local rarityOverrideData = {
    SupplyDropBoon = {
        [_PLUGIN.guid .. "RarityBiome" .. 1] = {
            Multiplier = 2/7
        },
        [_PLUGIN.guid .. "RarityBiome" .. 2] = {
            Multiplier = 2/7
        }
    },
    ArmorPenaltyCurse = {
        [_PLUGIN.guid .. "RarityBiome" .. 1] = {
            Multiplier = 92/50,
        },
        [_PLUGIN.guid .. "RarityBiome" .. 2] = {
            Multiplier = 95/50,
        }
    },
    EchoDeathDefianceRefill = {
        [_PLUGIN.guid .. "RarityBiome" .. 1] = {
            Multiplier = 0.75/0.5,
        },
        [_PLUGIN.guid .. "RarityBiome" .. 2] = {
            Multiplier = 0.8/0.5,
        }
    },
    DiminishingDodgeBoon = {
        [_PLUGIN.guid .. "RarityBiome" .. 1] = {
            Multiplier = 0.75/0.5,
        },
        [_PLUGIN.guid .. "RarityBiome" .. 2] = {
            Multiplier = 0.75/0.5,
        }
    },
    DiminishingHealthAndManaBoon = {
        [_PLUGIN.guid .. "RarityBiome" .. 1] = {
            Multiplier = 0.85/0.6,
        },
        [_PLUGIN.guid .. "RarityBiome" .. 2] = {
            Multiplier = 0.9/0.6,
        }
    },
    FocusAttackDamageTrait = {
        [_PLUGIN.guid .. "RarityBiome" .. 1] = {
            Multiplier = 6/3,
        },
        [_PLUGIN.guid .. "RarityBiome" .. 2] = {
            Multiplier = 7/3,
        }
    },
    FocusSpecialDamageTrait = {
        [_PLUGIN.guid .. "RarityBiome" .. 1] = {
            Multiplier = 6/3,
        },
        [_PLUGIN.guid .. "RarityBiome" .. 2] = {
            Multiplier = 7/3,
        }
    },
    CirceShrinkTrait = {
         [_PLUGIN.guid .. "RarityBiome" .. 1] = {
            Multiplier = 21/10,
        },
        [_PLUGIN.guid .. "RarityBiome" .. 2] = {
            Multiplier = 22/10,
        }
    },
    ModsNikkelMHadesBiomesBuffFutureBoonRarity = {
         [_PLUGIN.guid .. "RarityBiome" .. 1] = {
            Multiplier = 5/3,
        },
        [_PLUGIN.guid .. "RarityBiome" .. 2] = {
            Multiplier = 5/3,
        }
    }
}

function mod.GetPath(tbl, path)
    local current = tbl

    for i = 1, #path do
        if type(current) ~= "table" then
            return nil
        end

        current = current[path[i]]

        if current == nil then
            return nil
        end
    end
    return current
end

local function scaleNPCTrait(rarityData, npc)
    local scalingKeyHeroic = npcsToScale[npc].ScalingKeyHeroic or "Heroic"
    local scalingKeyEpic = npcsToScale[npc].ScalingKeyEpic or "Epic"
    local rarityDelta = rarityData[scalingKeyHeroic].Multiplier - rarityData[scalingKeyEpic].Multiplier
    local rarityDeltaInverse = 1 / rarityData[scalingKeyHeroic].Multiplier - 1 / rarityData[scalingKeyEpic].Multiplier
    for i = 1, 2 do
        if rarityDelta > 0 then
            rarityData[_PLUGIN.guid .. "RarityBiome" .. i] = {
                Multiplier = rarityData.Heroic.Multiplier + i * rarityDelta
            }
        else
            rarityData[_PLUGIN.guid .. "RarityBiome" .. i] = {
                Multiplier = 1 / ( 1 / rarityData.Heroic.Multiplier + i * rarityDeltaInverse )
            }
        end
    end
end

for npc, _ in pairs(npcsToScale) do
    local npcData = game.EnemyData[npc]
    if npcData and npcData.Traits then
        local traitList = npcData.Traits
        for _, traitName in ipairs(traitList) do
            local rarityData = game.TraitData[traitName].RarityLevels
            if rarityData and not rarityOverrideData[traitName] then
                scaleNPCTrait(rarityData, npc)
            elseif rarityOverrideData[traitName] then
                game.OverwriteTableKeys(rarityData, rarityOverrideData[traitName])
            end
            local customRarityData = mod.GetPath(game.TraitData, {traitName, "AcquireFunctionArgs", "AngleIncrement", "CustomRarityMultiplier"})
            customRarityData = customRarityData or mod.GetPath(game.TraitData, {traitName, "OnEnemyDamagedAction", "Args", "Cooldown", "CustomRarityMultiplier"})
            if customRarityData then
                scaleNPCTrait(customRarityData, npc)
            end
            -- print(traitName, dump(rarityData), dump(customRarityData))
        end
    end
end

if mod.IsZagAvailable then
    modutil.mod.Path.Wrap(ZJ_guid .. "." .. "ScaleNPCTraitsForDreamRun", function (base, upgradeOptions)
        if game.CurrentRun.EnteredBiomes > 4 and game.CurrentRun.EnteredBiomes <= 6 then
            for _, item in pairs(upgradeOptions) do
                if (game.TraitData[item.ItemName].RarityLevels or {})["Heroic"] then
                    item.Rarity = "Heroic"
                end
            end
        end
        if game.CurrentRun.EnteredBiomes > 6 and game.CurrentRun.EnteredBiomes <= 10 then
            for _, item in pairs(upgradeOptions) do
                if (game.TraitData[item.ItemName].RarityLevels or {})[_PLUGIN.guid .. "RarityBiome1"] then
                    print("overriding rarity for", item.ItemName)
                    item.Rarity = _PLUGIN.guid .. "RarityBiome1"
                else
                    item.Rarity = "Heroic"
                end
            end
        end
        if game.CurrentRun.EnteredBiomes > 10 then
            for _, item in pairs(upgradeOptions) do
                if (game.TraitData[item.ItemName].RarityLevels or {})[_PLUGIN.guid .. "RarityBiome2"] then
                    print("overriding rarity for", item.ItemName)
                    item.Rarity = _PLUGIN.guid .. "RarityBiome2"
                else
                    item.Rarity = "Heroic"
                end
            end
        end
        return base(upgradeOptions)
    end)
end