game.ScreenData.RunClear.ComponentData[_PLUGIN.guid .. "EndlessButton"] =
{
    Graphic = "ContextualActionButton",
    GroupName = "Combat_Menu_TraitTray_Overlay",
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
            PathTrue = {"CurrentRun", "IsDreamRun"}
        },
        {
            Path = { "CurrentRun", "ScreenViewRecord", "RunClear" },
            Comparison = "==",
            Value = 1,
        },
        {
            PathFromSource = true,
            PathFalse = { "zerp-GameOverScreen" .. "SkipRecordRunCleared" }
        },
        {
            PathFromSource = true,
            PathFalse = { _PLUGIN.guid .. "DeathScreen" }
        }
    }
}

table.insert(game.ScreenData.RunClear.ComponentData.Order, _PLUGIN.guid .. "EndlessButton")

function mod.StartEndlessRun(screen)
    game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] = true
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
            (rom.mods["zerp-GameOverScreen"] and rom.mods["zerp-GameOverScreen"].config and rom.mods["zerp-GameOverScreen"].config.enabled ) then
        game.thread(openDeathRunClearScreen)
        game.waitUntil(_PLUGIN.guid .. "CloseRunClearScreenTriggered")
    end
end)

modutil.mod.Path.Wrap("RunClearMessagePresentation", function (base, screen, message, tooltipData)
    base(screen, message, tooltipData)
    if screen.Components[_PLUGIN.guid .. "EndlessButton"] then
        game.SetAlpha({ Id = screen.Components[_PLUGIN.guid .. "EndlessButton"].Id, Duration = game.HUDScreen.FadeInDuration, Fraction = 1.0 })
        game.Move({ Ids = {screen.Components.BadgeRankIcon.Id}, Distance = 80, Angle = 180, Duration = game.HUDScreen.FadeInDuration, EaseOut = 1, Additive = true })
    end
end)