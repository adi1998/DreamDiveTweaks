local vanillaComboBreakerRatio = {
    Chronos = 2000/22000,
    Eris = 800/18500,
    Hecate = 800/7250,
    Heracles = 600/34000,
    InfestedCerberus = 600/31500,
    Prometheus = 600/36000,
    Scylla = 620/7750,
    SirenDrummer = 590/7100,
    SirenKeytarist = 400/5100,
    Zagreus = 650/10800
}

modutil.mod.Path.Wrap("CheckComboBreakerDamageInWindow", function (base, victim, args, contextArgs)
    args = args or {}
    if victim and vanillaComboBreakerRatio[victim.Name] and not args[_PLUGIN.guid .. "ScaledComboBreakerData"] then
        local ratio = vanillaComboBreakerRatio[victim.Name]
        local max_health = victim.MaxHealth
        args.Threshold = max_health * ratio
        args[_PLUGIN.guid .. "ScaledComboBreakerData"] = true
    end
    return base(victim, args, contextArgs)
end)