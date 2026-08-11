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
  show_game_over_screen = true,
}

local configDesc = {
  disable_visage_forms = {
    voice = "Disable Visage Form voice modulation",
    model = "Disable Visage Form models/textures",
  },
  meta_reward_fix = "Fix final biomes having too many meta progression rewards",
  meta_reward_fix_chance_cap = "The % chance of getting a meta progression reward will be capped to this value",
  dream_resources = "Allow harvestable resources to spawn in Dream Dives",
  early_unlock = "Unlock Dream Dives earlier than intended, requires both Chronos and Typhon to be fought at least once",
  shop_music_fix = "Fix shop music being absent in Dream Dives",
  purging_well = "Spawn a purging well along with the well shop at rest spots",
  hermes_shrine_chance = "The % chance of spawning a Hermes Shrine instead of a Well Shop in post boss rooms",
  biome_count = "Set a longer/shorter number of Regions (2-12)",
  late_biome_damage_ramp = "Enemy damage ramp for biomes >= late_biome_start",
  late_biome_health_ramp = "Enemy health ramp for biomes >= late_biome_start",
  late_biome_start = "Biome depth to start ramping up the scaling from",
  show_game_over_screen = "Show Game Over screen on losing in a Dream Dive"
}

return config, configDesc