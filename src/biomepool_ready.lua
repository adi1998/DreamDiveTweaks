modutil.mod.Path.Wrap("SelectNextDreamBiome", function (base, ...)
    return mod.SelectNextDreamBiomeWrap(base, ...)
end)

table.insert(game.EncounterData.OpeningEmpty.GameStateRequirements.OrRequirements[2],
{
    Path = { "CurrentRun", "EnteredBiomes" },
    Comparison = ">",
    Value = 0
})