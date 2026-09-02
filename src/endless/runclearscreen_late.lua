modutil.mod.Path.Context.Env("OpenRunClearScreen", function ()
    modutil.mod.Path.Wrap("RecordRunCleared", function (base)
        if game.ScreenData.RunClear[_PLUGIN.guid .. "DeathScreen"] then
            print("skipping RecordRunCleared on death")
            return
        end
        return base()
    end)
end)

if mod.IsZagAvailable then
    modutil.mod.Path.Context.Env(ZJ_guid .. "." .. "ModsNikkelMHadesBiomesBenefitChoice", function (source, args, screen)
        modutil.mod.Path.Wrap("RandomSynchronize", function (base, offset, rngId)
            if game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
                offset = math.random(1,9)
            end
            return base(offset, rngId)
        end)
    end)
end