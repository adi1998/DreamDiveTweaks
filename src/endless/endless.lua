local fullRunBiomeCountProxy = {
    FullRunBiomeCount = game.GameData.FullRunBiomeCount
}

game.GameData.FullRunBiomeCount = nil

setmetatable(game.GameData, {
    __index = function (t, k)
        if k == "FullRunBiomeCount" then
            if not game.CurrentHubRoom and game.CurrentRun and game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
                return 999
            end
            return fullRunBiomeCountProxy[k]
        end
    end,

    __newindex = function (t, k, v)
        if k == "FullRunBiomeCount" then
            fullRunBiomeCountProxy[k] = v
        else
            rawset(t,k,v)
        end
    end
})

setmetatable(game.RoomSets.Dream, {
    __index = function (t, k)
        if type(k) == "number" and not rawget(t, k) then
            return rawget(t, (k-2)%3 + 2)
        end
    end,
})

-- endless is always in second half
modutil.mod.Path.Wrap(_PLUGIN.guid .. "." .. "DreamFirstHalf", function (base, source, args)
    if game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
        return false
    end
    return base(source, args)
end)

-- VoR is only active in Endless if BossDifficultyShrineUpgrade is maxed out 
modutil.mod.Path.Wrap("IsBossDifficultyShrineUpgradeActive", function (base, source, args)
    if game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
        if game.GameState.ShrineUpgrades.BossDifficultyShrineUpgrade == #game.MetaUpgradeData.BossDifficultyShrineUpgrade.Ranks then
            return true
        end
        return false
    end
    return base(source, args)
end)

modutil.mod.Path.Wrap("SelectNextDreamBiome", function (base, source, args)
    if game.CurrentRun[_PLUGIN.guid .. "EndlessStarted"] then
        if game.IsEmpty(game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"]) then
            game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"] = game.CombineTablesIPairs(game.CurrentRun[_PLUGIN.guid .. "GeneratedRoute"], game.CurrentRun[_PLUGIN.guid .. "UnusedBiomes"])
            game.FYShuffle(game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"])
        end
        local nextRoomSet = game.RemoveValueAndCollapse(game.CurrentRun[_PLUGIN.guid .. "EndlessBiomePool"])
        game.CurrentRun.CurrentRoom.NextRoomSet = { nextRoomSet }
        return
    end
    return base(source, args)
end)

modutil.mod.Path.Wrap("RemoveInputBlock", function (base, args)
    print("Removing input block", args.Name)
    return base(args)
end)

modutil.mod.Path.Wrap("AddInputBlock", function (base, args)
    print("Adding input block", args.Name)
    return base(args)
end)