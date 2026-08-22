ModBiomeData = {}

local biomeData =
{
    F =
    {
        StartingBiome = true,
        EasyBiome = true,
    },
    G =
    {
        EasyBiome = true,
    },
    H =
    {
        EasyBiome = true,
    },
    I =
    {
        HardBiome = true,
    },

    N =
    {
        StartingBiome = true,
        EasyBiome = true,
    },
    O =
    {
        EasyBiome = true,
    },
    P =
    {
        HardBiome = true,
    },
    Q =
    {
        HardBiome = true,
    }
}

if mod.IsZagAvailable then
    game.OverwriteTableKeys(biomeData, {
        Tartarus =
        {
            StartingBiome = true,
            EasyBiome = true,
            GameStateRequirements =
            {
                Path = {"GameState", "ModsNikkelMHadesBiomesClearedRunsCache"},
                Comparison = ">=",
			    Value = 1,
            }
        },
        Asphodel =
        {
            EasyBiome = true,
            GameStateRequirements =
            {
                Path = {"GameState", "ModsNikkelMHadesBiomesClearedRunsCache"},
                Comparison = ">=",
			    Value = 1,
            }
        },
        Elysium =
        {
            HardBiome = true,
            GameStateRequirements =
            {
                Path = {"GameState", "ModsNikkelMHadesBiomesClearedRunsCache"},
                Comparison = ">=",
			    Value = 1,
            }
        },
        Styx =
        {
            HardBiome = true,
            GameStateRequirements =
            {
                Path = {"GameState", "ModsNikkelMHadesBiomesClearedRunsCache"},
                Comparison = ">=",
			    Value = 1,
            }
        }
    })
end

for name, data in pairs(biomeData) do
    public.RegisterBiome(name, data)
end