game.ScreenData.RunClear.ComponentData[_PLUGIN.guid .. "EndlessButton"] =
{
    Graphic = "ContextualActionButton",
    X = game.UIData.ContextualButtonXRight,
    BottomOffset = game.UIData.ContextualButtonBottomOffset + 50,
    Alpha = 0.0,
    AlphaTarget = 1.0,
    AlphaTargetDuration = game.ScreenData.HUD.FadeInDuration,
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
        }
    }
}

function mod.StartEndlessRun(screen)
    game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] = true
    game.CloseRunClearScreen(screen)
end

modutil.mod.Path.Wrap("CloseRunClearScreen", function (base, screen)
    base(screen)
    game.notifyExistingWaiters(_PLUGIN.guid .. "CloseRunClearScreenTriggered")
end)

local function openDeathRunClearScreen()
    game.ScreenData.RunClear[_PLUGIN.guid .. "DeathScreen"] = true
    game.ScreenData.RunClear.ComponentData.DreamRunTitleText.Text = "G a m e  O v e r !"
    game.ShowHealthUI( { FadeDuration = 0.4, IgnoreLifePips = true } )
    game.ShowManaMeter( { FadeDuration = 0.4 } )
    game.OpenRunClearScreen()
    game.ScreenData.RunClear.ComponentData.DreamRunTitleText.Text = "RunClearScreen_Title"
    game.ScreenData.RunClear[_PLUGIN.guid .. "DeathScreen"] = nil
end

-- modutil.mod.Path.Wrap("DeathPresentation", function (base, ...)
--     base(...)
--     if game.CurrentRun.IsDreamRun and config.show_game_over_screen then
--         game.thread(openDeathRunClearScreen)
--         game.waitUntil(_PLUGIN.guid .. "CloseRunClearScreenTriggered")
--     end
-- end)