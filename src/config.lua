local config = {
  enabled = true;
  disable_visage_forms = {
    voice = true,
    model = true,
  },
  biome_pool = {
    easy_first_biome = false,
    hard_last_biome = false,
    larger_starting_pool = false,
    deterministic_biome_order = false,
    disable_zag_biomes = false,
    custom_order = false,
    custom_order_data = {
      ["1"] = "Random",
      ["2"] = "Random",
      ["3"] = "Random",
      ["4"] = "Random",
      ["5"] = "Random",
      ["6"] = "Random",
      ["7"] = "Random",
      ["8"] = "Random",
      ["9"] = "Random",
      ["10"] = "Random",
      ["11"] = "Random",
      ["12"] = "Random",
    },
    dodge_softcap = true,
  },
  meta_reward_fix = true,
  meta_reward_fix_chance_cap = 50,
  dream_resources = true,
  early_unlock = false,
  shop_music_fix = true,
  purging_well = true,
  hermes_shrine_chance = 50,
  biome_count = 4,
  donk = false,
  increase_scorch_cap = true,
  late_biome_damage_ramp = 100,
  late_biome_health_ramp = 100,
  late_biome_start = 5,
}

---@type mod_settings.config_desc
local configDesc = {
  enabled = {
    -- displayName and all other text properties support localization tables
    displayName = { en = "Enabled" },
    description = "Enable or disable Dream Dive Tweaks.",
    restartRequired = true,
  },

  -- Lives at the config root, but belongs with the biome-pool settings in the menu, so `group` moves it
  biome_count = {
    group = "biomePool",
    order = 1,
    displayName = "Number of Regions",
    description = "How many Regions a Dream Dive has. Maximum of 8, or 12 if Zagreus' Journey is installed.",
    min = 2,
    max = function() return (mod and mod.MaxAllowedBiomeCount) or 8 end,
    onChanged = function(key, new_value)
      game.GameData.FullRunBiomeCount = new_value
    end,
  },

  biome_pool = {
    displayName = "Biome pool",
    description = "Which Regions can appear, and in what order.",

    disable_zag_biomes = {
      group = "biomePool",
      order = 2,
      displayName = "Disable Zagreus' Journey Regions",
      description = "Leave the regions added by Zagreus' Journey out of the available pool.",
      disabled = function() return not (mod and mod.IsZagAvailable) end,
      disabledDescription = "Requires Zagreus' Journey to be installed and enabled.",
      onChanged = function(key, new_value)
        mod.IsZag = not new_value
        mod.MaxAllowedBiomeCount = (mod.IsZag and 12) or 8
        if mod and mod.config then
          mod.config.biome_count = math.min(mod.config.biome_count, mod.MaxAllowedBiomeCount)
        end
        mod.RefreshBiomeSets()
      end,
    },

    custom_order = {
      group = "biomePool",
      order = 3,
      displayName = "Use custom Region order",
      description = "Pick the Region for each slot yourself instead of letting the game randomly generate an order.",
    },

    easy_first_biome = {
      group = "biomePool",
      displayName = "Easy first Region",
      description = "Always start the run in an easier Region, such as Oceanus, the Mourning Fields, or Thessaly.",
      disabled = function() return mod and mod.config.biome_pool.custom_order == true end,
      disabledDescription = "Not used while a custom Region order is set.",
    },
    hard_last_biome = {
      group = "biomePool",
      displayName = "Hard final Region",
      description = "Always end the run in a harder Region, such as Tartarus, Olympus, or the Summit.",
      disabled = function() return mod and mod.config.biome_pool.custom_order == true end,
      disabledDescription = "Not used while a custom Region order is set.",
    },
    larger_starting_pool = {
      group = "biomePool",
      displayName = "Larger starting pool",
      description = "Allow more Regions to be picked as the run's first.",
      disabled = function() return mod and mod.config.biome_pool.custom_order == true end,
      disabledDescription = "Not used while a custom Region order is set.",
    },
    deterministic_biome_order = {
      group = "biomePool",
      displayName = "Deterministic order",
      description = "Always generate the same Region order for the same seed (after undoing the night).",
      disabled = function() return mod and mod.config.biome_pool.custom_order == true end,
      disabledDescription = "Not used while a custom Region order is set.",
    },

    dodge_softcap = {
      group = "gameplay",
      displayName = "Dodge softcap",
      description = "Apply a softcap to dodge chance so it cannot reach 100%.",
    },

    custom_order_data = {
      displayName = "Custom Region order",
      group = "biomePool",
      order = 4,

      -- A virtual row: no config key behind it, so it reads and writes through the mod instead.
      preset = {
        virtual = true,
        group = { "biomePool", "customOrder" },
        order = 1,
        displayName = "Order preset",
        description = "Apply a predefined Region order. This also sets the number of Regions to match the preset. Presets needing more Regions than are currently available are not listed.",
        -- get() is nil until the mod has loaded, so the widget kind cannot be inferred from it.
        type = "enum",
        get = function() return mod and (ForcedPreset or mod.GetCurrentPresetName()) end,
        set = function(value) return mod and mod.ApplyBiomeOrderPreset(value) end,
        values = function() return mod and mod.GetPresetNames() end,
      },

      order_validity = {
        virtual = true,
        group = { "biomePool", "customOrder" },
        order = 2,
        displayName = "Order status",
        description = "Whether the current order can actually be generated.",
        text = function()
          if not CheckOrderValid then return "Unavailable" end
          return CheckOrderValid() and "Valid" or "Invalid (resets to default on run start)"
        end,
      },

      -- One selector per Region slot. Slots past the configured number of Regions are greyed out.
      ["1"] = {
        group = { "biomePool", "customOrder" },
        order = 11,
        displayName = "Region 1",
        description = "The Region the run starts in.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
      },
      ["2"] = {
        group = { "biomePool", "customOrder" },
        order = 12,
        displayName = "Region 2",
        description = "The Region entered in slot 2 of the run.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
      },
      ["3"] = {
        group = { "biomePool", "customOrder" },
        order = 13,
        displayName = "Region 3",
        description = "The Region entered in slot 3 of the run.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
        disabled = function() return mod and mod.config.biome_count < 3 end,
        disabledDescription = "The run is set to fewer Regions than this.",
      },
      ["4"] = {
        group = { "biomePool", "customOrder" },
        order = 14,
        displayName = "Region 4",
        description = "The Region entered in slot 4 of the run.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
        disabled = function() return mod and mod.config.biome_count < 4 end,
        disabledDescription = "The run is set to fewer Regions than this.",
      },
      ["5"] = {
        group = { "biomePool", "customOrder" },
        order = 15,
        displayName = "Region 5",
        description = "The Region entered in slot 5 of the run.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
        disabled = function() return mod and mod.config.biome_count < 5 end,
        disabledDescription = "The run is set to fewer Regions than this.",
      },
      ["6"] = {
        group = { "biomePool", "customOrder" },
        order = 16,
        displayName = "Region 6",
        description = "The Region entered in slot 6 of the run.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
        disabled = function() return mod and mod.config.biome_count < 6 end,
        disabledDescription = "The run is set to fewer Regions than this.",
      },
      ["7"] = {
        group = { "biomePool", "customOrder" },
        order = 17,
        displayName = "Region 7",
        description = "The Region entered in slot 7 of the run.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
        disabled = function() return mod and mod.config.biome_count < 7 end,
        disabledDescription = "The run is set to fewer Regions than this.",
      },
      ["8"] = {
        group = { "biomePool", "customOrder" },
        order = 18,
        displayName = "Region 8",
        description = "The Region entered in slot 8 of the run.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
        disabled = function() return mod and mod.config.biome_count < 8 end,
        disabledDescription = "The run is set to fewer Regions than this.",
      },
      ["9"] = {
        group = { "biomePool", "customOrder" },
        order = 19,
        displayName = "Region 9",
        description = "The Region entered in slot 9 of the run. Needs the Zagreus' Journey Regions to be in the pool.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
        disabled = function() return mod and mod.config.biome_count < 9 end,
        disabledDescription = "The run is set to fewer Regions than this.",
      },
      ["10"] = {
        group = { "biomePool", "customOrder" },
        order = 20,
        displayName = "Region 10",
        description = "The Region entered in slot 10 of the run. Needs the Zagreus' Journey Regions to be in the pool.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
        disabled = function() return mod and mod.config.biome_count < 10 end,
        disabledDescription = "The run is set to fewer Regions than this.",
      },
      ["11"] = {
        group = { "biomePool", "customOrder" },
        order = 21,
        displayName = "Region 11",
        description = "The Region entered in slot 11 of the run. Needs the Zagreus' Journey Regions to be in the pool.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
        disabled = function() return mod and mod.config.biome_count < 11 end,
        disabledDescription = "The run is set to fewer Regions than this.",
      },
      ["12"] = {
        group = { "biomePool", "customOrder" },
        order = 22,
        displayName = "Region 12",
        description = "The Region entered in slot 12 of the run. Needs the Zagreus' Journey Regions to be in the pool.",
        values = function() return mod and mod.GetBiomeOptions() end,
        labels = function() return mod and mod.GetBiomeLabels() end,
        disabled = function() return mod and mod.config.biome_count < 12 end,
        disabledDescription = "The run is set to fewer Regions than this.",
      },
    },
  },

  meta_reward_fix = {
    group = "gameplay",
    order = 1,
    displayName = "Fix meta reward count",
    description = "Stop the final Regions having too many meta progression rewards (Ash, Bones, Nectar).",
  },
  meta_reward_fix_chance_cap = {
    group = "gameplay",
    order = 2,
    displayName = "Meta reward chance cap",
    description = "Upper bound on the chance of a room offering a meta progression reward.",
    min = 0,
    max = 100,
    step = 5,
    showAsPercentage = true,
    disabled = function() return not (mod and mod.config.meta_reward_fix) end,
    disabledDescription = "Turn on Fix meta reward count first.",
  },
  hermes_shrine_chance = {
    group = "gameplay",
    displayName = "Shrine of Hermes chance",
    description = "Chance of a Shrine of Hermes showing in the rooms between regions.",
    min = 0,
    max = 100,
    step = 5,
    showAsPercentage = true,
  },
  dream_resources = {
    group = "gameplay",
    displayName = "Harvestable resources",
    description = "Let resources spawn during Dream Dives.",
  },
  purging_well = {
    group = "gameplay",
    displayName = "Spawn Pools of Purging",
    description = "Spawn a Pool of Purging in the rooms between regions.",
  },
  increase_scorch_cap = {
    group = "gameplay",
    displayName = "Raise Scorch cap",
    description = "Increase the maximum amount of Scorch that can be accumulated on a single enemy at a time.",
  },
  early_unlock = {
    group = "gameplay",
    displayName = "Unlock Dream Dives early",
    description = "Unlock Dream Dives sooner. Chronos and Typhon still need to have been fought once. \n Warning: Dream Dives are permanently unlocked after your first dream dive.",
    editableContext = "mainMenu",
  },

  late_biome_start = {
    group = "lateScaling",
    order = 1,
    displayName = "Ramp starts at Region",
    description = "The Region depth from which the extra enemy scaling kicks in.",
    min = 2,
    max = function() return (mod and mod.MaxAllowedBiomeCount) or 8 end,
  },
  late_biome_damage_ramp = {
    group = "lateScaling",
    order = 2,
    displayName = "Enemy damage ramp",
    description = "Enemy damage scaling applied from the starting Region onwards.",
    min = 0,
    max = 300,
    step = 10,
    showAsPercentage = true,
  },
  late_biome_health_ramp = {
    group = "lateScaling",
    order = 3,
    displayName = "Enemy health ramp",
    description = "Enemy health scaling applied from the starting Region onwards.",
    min = 0,
    max = 300,
    step = 10,
    showAsPercentage = true,
  },
  apply_late_scaling = {
    group = "lateScaling",
    order = 4,
    action = function() mod.ApplyLateBiomeScaling() end,
    displayName = "Apply to current save",
    description = "Re-apply the scaling values above immediately. A save reload picks them up as well.",
    editableContext = "inSave",
    disabled = function() return not (mod and mod.ApplyLateBiomeScaling) end,
    disabledDescription = "To showcase editableContext, only available in loaded saves (can actually be changed in the main menu as well since a save will reload and apply it as well).",
  },

  disable_visage_forms = {
    displayName = "Visage Forms",

    voice = {
      group = "misc",
      displayName = "Disable voice modulation",
      description = "Skip the Visage Form voice filter.",
    },
    model = {
      group = "misc",
      displayName = "Disable model swaps",
      description = "Skip the Visage Form model swap.",
    },
  },
  shop_music_fix = {
    group = "misc",
    displayName = "Fix shop music",
    description = "Restore the missing shop music in Dream Dives.",
  },

  donk = {
    group = "misc",
    displayName = "Alternate Dream Dive Start Animation",
    description = "Swaps out the hover animation with a diving animation on Dream Dive start."
  },

  -- Menu categories that are not config sections. Rows opt into them with `group`.
  groups = {
    biomePool = {
      displayName = "Biome pool",
      description = "Which Regions appear in Dream Dives, and in what order.",
      order = 1,
      groups = {
        customOrder = {
          displayName = "Custom Region order",
          description = "Pick the Region for each slot.",
          -- Greys the whole page and blocks opening it, so the rows inside never repeat this.
          disabled = function()
            return not (mod and mod.config.biome_pool.custom_order == true)
          end,
          disabledDescription = "Turn on Use custom Region order first.",
        },
      },
    },
    gameplay = {
      displayName = "Gameplay tweaks",
      order = 2,
    },
    lateScaling = {
      displayName = "Late Region scaling",
      description = "Extra enemy scaling for the later Regions of a run.",
      order = 3,
    },
    misc = {
      displayName = "Misc tweaks",
      order = 4,
    },
  },
}

return config, configDesc