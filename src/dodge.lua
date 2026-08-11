--#region Dodge logging

-- local totalDodge = 0

-- modutil.mod.Path.Wrap("SetLifeProperty", function (base, args)
--     if args.DestinationId == game.CurrentRun.Hero.ObjectId and args.Property == "DodgeChance" then
--         print(args.ValueChangeType, args.Value)
--         if args.ValueChangeType == "Add" then
--             totalDodge = totalDodge + args.Value
--             print("totalDodge", totalDodge)
--         end
--     end
--     return base(args)
-- end)

-- modutil.mod.Path.Wrap("LeaveRoom", function (base, ...)
--     totalDodge = 0
--     return base(...)
-- end)

-- modutil.mod.Path.Wrap("DeathAreaSwitchRoom", function (base, ...)
--     totalDodge = 0
--     return base(...)
-- end)

--#endregion

function ScaleDodge(linearLimit, decay, count, delta, softcapIncrement)
    if count <= linearLimit then
        return count * delta
    elseif decay * (count - linearLimit) <= delta then
        return count * delta - decay * (count - linearLimit) * (count - linearLimit - 1) / 2
    else
        local decayLimit = math.floor(delta/decay)
        return (decayLimit + linearLimit) * delta - decay * decayLimit * (decayLimit - 1) / 2 + (count - linearLimit - decayLimit) * softcapIncrement
    end
end

--#region WispyWiles scaling

function mod.GetLastHeroTrait( traitName )
	if game.CurrentRun.Hero.TraitDictionary[traitName] ~= nil then
		return game.CurrentRun.Hero.TraitDictionary[traitName][#(game.CurrentRun.Hero.TraitDictionary[traitName])]
	end
	return nil
end

function mod.ElementalDodgeBoonSetup(hero, traitArgs, args)
    local trait = mod.GetLastHeroTrait("ElementalDodgeBoon")
    if trait then
        local airCount = game.CurrentRun.Hero.Elements.Air
        trait.CurrentAirDodgeBonus = airCount * traitArgs.DodgePerAirElement
        if game.CurrentRun.IsDreamRun and config.biome_pool.dodge_softcap then
            trait.CurrentAirDodgeBonus = ScaleDodge(traitArgs.LinearLimit, traitArgs.Decay, airCount, traitArgs.DodgePerAirElement, traitArgs.SoftcapIncrement)
        end
        game.SetLifeProperty({ Property = "DodgeChance", Value = trait.CurrentAirDodgeBonus, ValueChangeType = "Add", DestinationId = game.CurrentRun.Hero.ObjectId, DataValue = false })
    else
        print("trying to setup non-existent ElementalDodgeBoon")
    end
end

function mod.ElementalDodgeBoonClear(traitArgs, trait)
    game.SetLifeProperty({ Property = "DodgeChance", Value = -trait.CurrentAirDodgeBonus, ValueChangeType = "Add", DestinationId = game.CurrentRun.Hero.ObjectId, DataValue = false })
end

local dodgeTraits = {
    ElementalDodgeBoon = {
        InheritFrom = {"UnityTrait"},
		Icon = "Boon_Aphrodite_33",
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Elements", "Air" },
				Comparison = ">=",
				Value = 2,
			},
		},
        ElementalMultipliers =
		{
			Air = true,
		},
        RarityLevels =
		{
			Common =
			{
				Multiplier = 1
			},
		},
        CurrentAirDodgeBonus = 0,
        SetupFunction =
		{
			Name = _PLUGIN.guid .. "." .. "ElementalDodgeBoonSetup",
			Args =
			{
				DodgePerAirElement = 0.02,
                Decay = 0.0005,
                SoftcapIncrement = 0.0002,
                LinearLimit = 1,
                ReportValues = {
                    ReportedDodgeBonus = "DodgePerAirElement",
                }
			},
		},
        OnExpire = {
            FunctionName = _PLUGIN.guid .. "." .. "ElementalDodgeBoonClear",
        },
        StatLines =
		{
			"ElementalDodgeStatDisplay1",
		},
		TrayStatLines =
		{
			"TotalDodgeChanceStatDisplay1",
		},
		ExtractValues =
		{
            {
				Key = "ReportedDodgeBonus",
				ExtractAs = "TooltipDodgeBonus",
				Format = "Percent",
                DecimalPlaces = 5,
			},
			{
				Key = "CurrentAirDodgeBonus",
				ExtractAs = "TooltipTotalDodgeBonus",
				Format = "Percent",
                DecimalPlaces = 5,
			},
		},
    }
}

game.OverwriteTableKeys(game.TraitData, dodgeTraits)

--#endregion

--#region Hermes dodge scaling

game.TraitData.DodgeChanceBoon.CurrentBoonCountDodgeChance = 0

game.TraitData.DodgeChanceBoon.ExtractValues[2] =
{
    Key = "CurrentBoonCountDodgeChance",
    ExtractAs = "TooltipTotalDodgeBonus",
    Format = "Percent",
    DecimalPlaces = 3,
}

modutil.mod.Path.Wrap("MultipliedSpeedDodgeSetup", function (base, hero, traitArgs, args)
    local trait = game.GetHeroTrait("DodgeChanceBoon")
    if game.CurrentRun.IsDreamRun and config.biome_pool.dodge_softcap then
        local rarity = trait.Rarity
        local rarityMulitplier = trait.RarityLevels[rarity].Multiplier

        local linearLimit = math.floor(18 / rarityMulitplier)
        local delta = traitArgs.SpeedDodgePerBoon
        local decay = (delta / 0.02) * 0.0005
        local count = game.CurrentRun.Hero.OlympianBoonCount or 0
        local softcapIncrement = (delta / 0.02) * 0.0002

        local totalSpeedChange = 1 + ScaleDodge(linearLimit, decay, count, delta, softcapIncrement)

        if game.SessionMapState.OlympianBoonCountBoost then
            game.ApplyUnitPropertyChanges( game.CurrentRun.Hero, game.SessionMapState.OlympianBoonCountBoostPropertyChanges, true, true )
        end
        local allPropertyChanges =
        {
            {
                LifeProperty = "DodgeChance",
                ChangeValue = totalSpeedChange - 1,
                ChangeType = "Add",
                DataValue = false,
            },
            {
                UnitProperty = "Speed",
                ChangeType = "Multiply",
                ChangeValue = totalSpeedChange,
            },
            {
                WeaponNames = { "WeaponSprint" },
                WeaponProperty = "SelfVelocity",
                ChangeValue = totalSpeedChange,
                ChangeType = "Multiply",
                ExcludeLinked = true,
            },
            {
                WeaponNames = { "WeaponSprint" },
                WeaponProperty = "SelfVelocityCap",
                ChangeValue = totalSpeedChange,
                ChangeType = "Multiply",
                ExcludeLinked = true,
            },
        }
        game.SessionMapState.OlympianBoonCountBoostPropertyChanges = allPropertyChanges
        game.SessionMapState.OlympianBoonCountBoost = totalSpeedChange
        game.ApplyUnitPropertyChanges( game.CurrentRun.Hero, game.SessionMapState.OlympianBoonCountBoostPropertyChanges )
        trait.CurrentBoonCountDodgeChance = game.SessionMapState.OlympianBoonCountBoost - 1
        return
    end
    base(hero, traitArgs, args)
    trait.CurrentBoonCountDodgeChance = game.SessionMapState.OlympianBoonCountBoost - 1
end)

--#endregion

game.SetupRunData()