modutil.mod.Path.Wrap("SelectNextDreamBiome", function (base, ...)
    return mod.SelectNextDreamBiomeWrap(base, ...)
end)

table.insert(game.EncounterData.OpeningEmpty.GameStateRequirements.OrRequirements[2],
{
    Path = { "CurrentRun", "EnteredBiomes" },
    Comparison = ">",
    Value = 0
})

if mod.IsZagAvailable then
    modutil.mod.Path.Wrap(ZJ_guid .. "." .. "ApplyDreamDiveExclusionConfig", function (base, ...)
        mod.ProcessZjDreamDiveConfigChange()
        return base(...)
    end)
end