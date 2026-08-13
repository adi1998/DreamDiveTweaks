modutil.mod.Path.Wrap("StartOver", function (base, args)
    if args.ActiveBounty and game.BountyData[args.ActiveBounty] then
        args.StartingRoomName = game.BountyData[args.ActiveBounty].StartingRoomName
    end
    return base(args)
end)

modutil.mod.Path.Wrap("CheckPackagedBountyCompletion", function (base, ...)
    if game.CurrentRun.IsDreamRun then
        return
    end
    return base(...)
end)

modutil.mod.Path.Wrap("DeathPresentation", function (base, ...)
    local activeBounty
    if game.CurrentRun.IsDreamRun then
        activeBounty = game.CurrentRun.ActiveBounty
        game.CurrentRun.ActiveBounty = nil
    end
    local retval = base(...)
    if game.CurrentRun.IsDreamRun then
        game.CurrentRun.ActiveBounty = activeBounty
    end
    return retval
end)

modutil.mod.Path.Wrap("HubPostBountyLoad", function (base, args)
    if game.CurrentRun[_PLUGIN.guid .. "GeneratedRoute"] then
        if type(game.CurrentRun[_PLUGIN.guid .. "StoredFullBiomeCount"]) == "number" then
            config.biome_count = game.CurrentRun[_PLUGIN.guid .. "StoredFullBiomeCount"]
            config.biome_count = math.min(config.biome_count, mod.MaxAllowedBiomeCount)
            config.biome_count = math.max(config.biome_count, 2)
            game.GameData.FullRunBiomeCount = config.biome_count
        end
    end
    return base(args)
end)

modutil.mod.Path.Wrap("TraitTrayScreenSetupTabs", function (base, screen, data)
    local hudBountyOffset = game.HUDScreen.Components.BountyActive.OffsetX
    local showingShrinePoints = false
    if game.CurrentRun and game.IsGameStateEligible( game.HUDScreen, game.ScreenData.TraitTrayScreen.ItemCategories[4].GameStateRequirements ) then
    	showingShrinePoints = true
    end
    if not screen.HideBounty and game.CurrentRun.IsDreamRun then
        hudBountyOffset = game.HUDScreen.Components.BountyActive.OffsetX
        game.HUDScreen.Components.BountyActive.OffsetX = game.HUDScreen.Components.BountyActive.OffsetX - (showingShrinePoints and 200 or 280)
    end
    local retval = base(screen, data)
    if not screen.HideBounty and game.CurrentRun.IsDreamRun then
        game.HUDScreen.Components.BountyActive.OffsetX = hudBountyOffset
    end
    return retval
end)

modutil.mod.Path.Wrap("TraitTrayScreenClose", function (base, screen, button, args)
    if screen == nil or screen.Closing then
		return
	end
    local showingShrinePoints = false
    if game.CurrentRun and game.IsGameStateEligible( game.HUDScreen, game.ScreenData.TraitTrayScreen.ItemCategories[4].GameStateRequirements ) then
    	showingShrinePoints = true
    end
    local hudBountyOffset = game.HUDScreen.Components.BountyActive.OffsetX
    if not screen.HideBounty and game.CurrentRun.IsDreamRun then
        hudBountyOffset = game.HUDScreen.Components.BountyActive.OffsetX
        game.HUDScreen.Components.BountyActive.OffsetX = game.HUDScreen.Components.BountyActive.OffsetX - (showingShrinePoints and 200 or 280)
    end
    local retval = base(screen, button, args)
    if not screen.HideBounty and game.CurrentRun.IsDreamRun then
        game.HUDScreen.Components.BountyActive.OffsetX = hudBountyOffset
    end
    return retval
end)

modutil.mod.Path.Wrap("UpdateTraitSummary", function (base, args)
    local bountyActive = game.HUDScreen.Components.BountyActive
    local shrinePointX
    local dreamActiveFearPadding
    local showingShrinePoints = false

    local wrapCondition = (not game.ConfigOptionCache.ShowUIAnimations or not game._G.ShowingCombatUI) or
        (game.CurrentHubRoom ~= nil and not game.CurrentHubRoom.ShowShrinePoints)

    if not wrapCondition then
        if game.CurrentRun and game.GameState.SpentShrinePointsCache and game.GameState.SpentShrinePointsCache >= 1 then
            showingShrinePoints = true
        end
        if game.CurrentRun and game.CurrentRun.IsDreamRun then
            shrinePointX = game.HUDScreen.Components.ShrinePointCount.X
            dreamActiveFearPadding = game.HUDScreen.Components.DreamActive.NoFearPaddingX
            if not showingShrinePoints then
                -- shifts dream and bounty icons to right
                game.HUDScreen.Components.ShrinePointCount.X = game.HUDScreen.Components.ShrinePointCount.X + 80
                -- shifts dream icon back to the left
                game.HUDScreen.Components.DreamActive.NoFearPaddingX = game.HUDScreen.Components.DreamActive.NoFearPaddingX - 80
            end
        end
    end

    local retval = base(args)
    if not wrapCondition then
        if game.CurrentRun and game.CurrentRun.IsDreamRun then
            game.HUDScreen.Components.ShrinePointCount.X = shrinePointX
            game.HUDScreen.Components.DreamActive.NoFearPaddingX = dreamActiveFearPadding
        end
        if game.CurrentRun and game.CurrentRun.IsDreamRun and game.CurrentRun.ActiveBounty and showingShrinePoints and game.CurrentHubRoom == nil then
            -- shift bounty icon to the right if dream run is also active
            game.Teleport({ Id = bountyActive.Id, OffsetX = bountyActive.X + bountyActive.OffsetX + 80, OffsetY = bountyActive.Y })
        end
    end
    return retval
end)

game.ObstacleData.GiftRack.SetupEvents[1].GameStateRequirements[2] = nil

game.ObstacleData.GiftRack.SetupEvents[1].GameStateRequirements.OrRequirements =
{
    {
        {
            Path = { "CurrentRun", "ActiveBounty" },
            IsAny = game.GameData.AllRandomPackagedBounties,
        },
    },
    {
        {
            PathTrue = { "CurrentRun", "Dream_RandomPackagedBounty" },
        }
    }
}