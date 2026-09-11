game.ScreenData.RunClear.ComponentData[_PLUGIN.guid .. "EndlessButton"] =
{
    Graphic = "ContextualActionButton",
    X = game.UIData.ContextualButtonXRight,
    BottomOffset = game.UIData.ContextualButtonBottomOffset + 50,
    Alpha = 0.0,
    AlphaTarget = 0.0,
    Data =
    {
        OnMouseOverFunctionName = "MouseOverContextualAction",
        OnMouseOffFunctionName = "MouseOffContextualAction",
        OnPressedFunctionName = _PLUGIN.guid .. "." .. "StartEndlessRun",
        ControlHotkeys = { "ItemPin", },
    },
    Text = "{IP} ENDLESS",
    TextArgs = game.UIData.ContextualButtonFormatRight,
    Requirements =
    {
        {
            Path = { "CurrentRun", "ScreenViewRecord", "RunClear" },
            Comparison = "==",
            Value = 1,
        },
        {
            PathFromSource = true,
            PathFalse = { GameOver_guid .. "SkipRecordRunCleared" }
        },
        {
            PathFromSource = true,
            PathFalse = { _PLUGIN.guid .. "DeathScreen" }
        },
        {
            PathFalse = { "CurrentRun", "ActiveBounty" },
        },
        OrRequirements =
        {
            {
                {
                    PathTrue = { "CurrentRun", "IsDreamRun" },
                },
            },
            {
                {
					PathTrue = { "GameState", "ReachedTrueEnding" },
				},
            }
        },
        NamedRequirements = { "DreamRunsUnlocked" },
    }
}

function mod.StartEndlessRun(screen)
    game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] = true
    if not game.CurrentRun.IsDreamRun then
        game.CurrentRun.IsDreamRun = true
        game.CurrentRun[_PLUGIN.guid .. "GeneratedRoute"], game.CurrentRun[_PLUGIN.guid .. "UnusedBiomes"] = GenerateRoute()
        local key = "DreamPointsDrop"
        local id = game.SpawnObstacle({ Name = key, DestinationId = game.CurrentRun.Hero.ObjectId, Group = "Standing" })
        local reward = game.CreateConsumableItem( id, key, 0 )
        game.MapState.RoomRequiredObjects[reward.ObjectId] = reward
    end
    print("Starting endless mode.")
    game.CloseRunClearScreen(screen)
end

modutil.mod.Path.Wrap("CloseRunClearScreen", function (base, screen)
    base(screen)
    game.ScreenData.RunClear.ComponentData.DreamRunTitleText.Text = "RunClearScreen_Title"
    game.ScreenData.RunClear[_PLUGIN.guid .. "DeathScreen"] = nil
    game.notifyExistingWaiters(_PLUGIN.guid .. "CloseRunClearScreenTriggered")
end)

local function openDeathRunClearScreen()
    game.ScreenData.RunClear[_PLUGIN.guid .. "DeathScreen"] = true
    game.ScreenData.RunClear.ComponentData.DreamRunTitleText.Text = "G a m e  O v e r !"
    game.ShowHealthUI( { FadeDuration = 0.4, IgnoreLifePips = true } )
    game.ShowManaMeter( { FadeDuration = 0.4 } )
    game.OpenRunClearScreen()
end

modutil.mod.Path.Wrap("DeathPresentation", function (base, ...)
    base(...)
    if game.CurrentRun.IsDreamRun and game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] and not
            (gameOver and gameOver.config and gameOver.config.enabled ) then
        game.thread(openDeathRunClearScreen)
        game.waitUntil(_PLUGIN.guid .. "CloseRunClearScreenTriggered")
    end
    if game.CurrentRun.IsDreamRun and game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
        game.CurrentRun.Cleared = nil
    end
end)

modutil.mod.Path.Wrap("RunClearMessagePresentation", function (base, screen, message, tooltipData)
    base(screen, message, tooltipData)
    if screen.Components[_PLUGIN.guid .. "EndlessButton"] then
        game.SetAlpha({ Id = screen.Components[_PLUGIN.guid .. "EndlessButton"].Id, Duration = game.HUDScreen.FadeInDuration, Fraction = 1.0 })
        game.Move({ Ids = {screen.Components.BadgeRankIcon.Id}, Distance = 80, Angle = 180, Duration = game.HUDScreen.FadeInDuration, EaseOut = 1, Additive = true })
    end
end)