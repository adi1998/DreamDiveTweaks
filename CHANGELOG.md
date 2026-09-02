# Changelog

## [Unreleased]

- Allow configuring how frequently new gods/hammers are added to the loot pool.
- Fix Worry Free staying visisble after triggering endless mode.

## [1.9.0] - 2026-08-25

- Allow configuring how endless scales enemy health and damage after 12 regions.
- Fix some voice lines not playing at the appropriate run depth.
- Cleanup more stuff on triggering endless mode.

## [1.8.1] - 2026-08-16

- Allow repeat NPC encounters in endless mode.

## [1.8.0] - 2026-08-16

- Added endless mode. Can activate it in the Victory screen of a Dream Dive to continue that run.

## [1.7.5] - 2026-08-13

- Minor GameOverScreen compat (failed runs will show the remaining biomes as ?)
- ImGui perf improvements
- Optional ZJ dependency

## [1.7.4] - 2026-08-01

- Minor compat update for Zagreus Journey v1.2.0
- Minor UI fix

#### Dev

- Replace Context.Wrap.Static with Context.Env

## [1.7.3] - 2026-07-22

- Fix the "Hard last biome" setting sometimes picking an already vistied biome

## [1.7.2] - 2026-07-20

- Fig lag when opening keepsake and chaos trial menus

## [1.7.1] - 2026-07-18

- BoonOverflowFix is now a dependency, as boons are very likely to overflow in 8+ zone runs
- Nerf Circe's shrink/dodge boon
- Dream Purging Wells now have a shadow tile :)

## [1.7.0] - 2026-07-05

- Add support for dependant mods to draw their ImGui in this mod's ImGui window
- Potential fix for shop music
- Block purging well from spawning if normal well shop is not eligible

## [1.6.5] - 2026-07-02

- Fix Chronos and Typhon shops never scaling up in the second half of the run.

## [1.6.4] - 2026-06-26

- Fix enabling/disabling ZJ biomes not working properly for Custom Order.
- Fix Chronos and Typhon shops scaling up earlier than expected.

## [1.6.3] - 2026-06-23

- Bump h2m and remove vsync workaround

## [1.6.2] - 2026-06-19

- More perf improvements for the ImGui menu
- Fix scorch cap being removed outside Dream Dives
- Fix Shrine of Hermes delivering rewards a bit too far in Hypnos rooms

## [1.6.1] - 2026-06-17

- Fix nil reference

## [1.6.0] - 2026-06-17

- Add trap scaling for H1 biomes
- Allow configuring damage and health scaling ramp up

## [1.5.0] - 2026-06-10

- Change scorch cap to 9999 in Dream Dives
- Allow Random biome selection in custom order fields

## [1.4.0] - 2026-06-05

- Fix Hermes early delivery in longer/shorter runs after Post Launch Patch 2 - Hotfix 3
- Add toggle for H1 biomes to appear in dream dives.
- Add a soft cap to Wisply Wiles and Hasty Retreat during Dream Dives.

## [1.3.2] - 2026-05-31

- Plentiful Forage overrides now part of Resources_In_Chaos_Trials

## [1.3.1] - 2026-05-29

- Fix HUD being disabled during Typhon tiny Mel phase
- Give better feedback whenever a config is automatically changed when certain requirements are not met

## [1.3.0] - 2026-05-28

- Add NPC boon scaling for biomes 5-12
- Fix Unrivaled Eris not equipping the correct rail model when visage forms are disabled

## [1.2.0] - 2026-05-26

- Adjust scaling for various enemies
- Add 6th god and 4th hammer after 8 regions
- Initial support for future Dream Dives x Chaos Trials

## [1.1.1] - 2026-05-21

- Fix readme

## [1.1.0] - 2026-05-21

- Add scaling for secret boss fights
- Add more options to configure random biome pool selection behavior
- Fix scaling for biomes 9-12
- Fix mod not working if Zagreus' Journey is not installed

## [1.0.2] - 2026-05-18

- Add additional chceks for max biome count allowed when ZJ is installed

## [1.0.1] - 2026-05-18

- Add a minimum required version check (1.1.0) for Zagreus Journey support
- Patch enemy scaling in a better way to avoid conflicts with mods like Dx2_Enemies, etc.

## [1.0.0] - 2026-05-17

- First version of the mod!

[unreleased]: https://github.com/adi1998/DreamDiveTweaks/compare/1.9.0...HEAD
[1.9.0]: https://github.com/adi1998/DreamDiveTweaks/compare/1.8.1...1.9.0
[1.8.1]: https://github.com/adi1998/DreamDiveTweaks/compare/1.8.0...1.8.1
[1.8.0]: https://github.com/adi1998/DreamDiveTweaks/compare/1.7.5...1.8.0
[1.7.5]: https://github.com/adi1998/DreamDiveTweaks/compare/1.7.4...1.7.5
[1.7.4]: https://github.com/adi1998/DreamDiveTweaks/compare/1.7.3...1.7.4
[1.7.3]: https://github.com/adi1998/DreamDiveTweaks/compare/1.7.2...1.7.3
[1.7.2]: https://github.com/adi1998/DreamDiveTweaks/compare/1.7.1...1.7.2
[1.7.1]: https://github.com/adi1998/DreamDiveTweaks/compare/1.7.0...1.7.1
[1.7.0]: https://github.com/adi1998/DreamDiveTweaks/compare/1.6.5...1.7.0
[1.6.5]: https://github.com/adi1998/DreamDiveTweaks/compare/1.6.4...1.6.5
[1.6.4]: https://github.com/adi1998/DreamDiveTweaks/compare/1.6.3...1.6.4
[1.6.3]: https://github.com/adi1998/DreamDiveTweaks/compare/1.6.2...1.6.3
[1.6.2]: https://github.com/adi1998/DreamDiveTweaks/compare/1.6.1...1.6.2
[1.6.1]: https://github.com/adi1998/DreamDiveTweaks/compare/1.6.0...1.6.1
[1.6.0]: https://github.com/adi1998/DreamDiveTweaks/compare/1.5.0...1.6.0
[1.5.0]: https://github.com/adi1998/DreamDiveTweaks/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/adi1998/DreamDiveTweaks/compare/1.3.2...1.4.0
[1.3.2]: https://github.com/adi1998/DreamDiveTweaks/compare/1.3.1...1.3.2
[1.3.1]: https://github.com/adi1998/DreamDiveTweaks/compare/1.3.0...1.3.1
[1.3.0]: https://github.com/adi1998/DreamDiveTweaks/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/adi1998/DreamDiveTweaks/compare/1.1.1...1.2.0
[1.1.1]: https://github.com/adi1998/DreamDiveTweaks/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/adi1998/DreamDiveTweaks/compare/1.0.2...1.1.0
[1.0.2]: https://github.com/adi1998/DreamDiveTweaks/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/adi1998/DreamDiveTweaks/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/adi1998/DreamDiveTweaks/compare/...1.0.0