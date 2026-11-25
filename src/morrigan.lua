game.ProjectileData.WomboStrike.IgnoreAllModifiers = nil

local function isMorriganBoostActive()
    return game.CurrentRun and config.morrigan_dmg_boost and game.CurrentRun.EnteredBiomes >= config.morrigan_dmg_boost_start
end

setmetatable(game.ProjectileData.WomboStrike, {
    __index = function (t, k)
        if k == "IgnoreAllModifiers" then
            return game.CurrentHubRoom ~= nil or not isMorriganBoostActive()
        end
        return rawget(t, k)
    end,

    __newindex = function (t, k, v)
        if k ~= "IgnoreAllModifiers" then
            rawset(t, k, v)
        end
    end
})