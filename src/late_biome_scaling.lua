config.late_biome_start = math.max(5, config.late_biome_start)
config.late_biome_start = math.min(12, config.late_biome_start)

local scalingCache = {}

local function SaveOriginalScaling()
    for enemyName, enemyData in pairs(game.EnemyData) do
        if enemyData.DreamBiomeData then
            local saved = {}
            for biomeIdx = 1, 12 do
                local entry = enemyData.DreamBiomeData[biomeIdx]
                if entry then
                    saved[biomeIdx] = game.DeepCopyTable(entry)
                end
            end
            if not game.IsEmpty(saved) then
                scalingCache[enemyName] = saved
            end
        end
    end
end

local function RestoreOriginalScaling()
    for enemyName, saved in pairs(scalingCache) do
        local enemyData = game.EnemyData[enemyName]
        if enemyData and enemyData.DreamBiomeData then
            for biomeIdx, savedEntry in pairs(saved) do
                enemyData.DreamBiomeData[biomeIdx] = game.DeepCopyTable(savedEntry)
            end
        end
    end
end

local function ScaleEntry(entry, power, damageRamp, healthRamp)
    if entry.AddOutgoingDamageModifier and entry.AddOutgoingDamageModifier.PlayerMultiplier then
        entry.AddOutgoingDamageModifier.PlayerMultiplier = entry.AddOutgoingDamageModifier.PlayerMultiplier * (damageRamp ^ power)
    end
    if entry.DataOverrides and entry.DataOverrides.HealthMultiplier then
        entry.DataOverrides.HealthMultiplier = entry.DataOverrides.HealthMultiplier * (healthRamp ^ power)
    end
    if entry.DataOverrides and entry.DataOverrides.HealingMultiplier then
        entry.DataOverrides.HealingMultiplier = entry.DataOverrides.HealingMultiplier * (healthRamp ^ power)
    end
    if entry.DataOverrides and entry.DataOverrides.OutgoingDamageModifiers then
        for _, modifier in ipairs(entry.DataOverrides.OutgoingDamageModifiers) do
            if modifier.PlayerMultiplier ~= nil then
                modifier.PlayerMultiplier = modifier.PlayerMultiplier * (damageRamp ^ power)
            end
            if modifier.NonPlayerMultiplier ~= nil then
                modifier.NonPlayerMultiplier = modifier.NonPlayerMultiplier * (healthRamp ^ power)
            end
        end
    end
end

local function UpdateVoRScaling()
    local startBiome = config.late_biome_start
    for enemy, _ in pairs(VorBossSetupEventIndex) do
        local enemyData = game.EnemyData[enemy]
        if enemyData and enemyData.DreamBiomeData then
            local setupEvents = enemyData.SetupEvents or {}
            for _, event in ipairs(setupEvents) do
                if event and event.FunctionName == "OverwriteSelf" and event.Args and event.Args.DreamBiomeData then
                    for b = startBiome, 12 do
                        event.Args.DreamBiomeData[b] = enemyData.DreamBiomeData[b]
                    end
                end
            end
        end
    end
end

function mod.ApplyLateBiomeScaling()
    RestoreOriginalScaling()

    local damageRamp = config.late_biome_damage_ramp / 100
    local healthRamp = config.late_biome_health_ramp / 100
    local startBiome = config.late_biome_start

    if damageRamp ~= 1 or healthRamp ~= 1 then
        for _, enemyData in pairs(game.EnemyData) do
            if enemyData.DreamBiomeData then
                for biomeIndex = startBiome, 12 do
                    local entry = enemyData.DreamBiomeData[biomeIndex]
                    if entry then
                        local power = biomeIndex - startBiome + 1
                        ScaleEntry(entry, power, damageRamp, healthRamp)
                    end
                end
            end
        end
    end

    UpdateVoRScaling()
end

SaveOriginalScaling()
mod.ApplyLateBiomeScaling()