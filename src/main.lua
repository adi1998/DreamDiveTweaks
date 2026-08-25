---@meta _
-- grabbing our dependencies,
-- these funky (---@) comments are just there
--     to help VS Code find the definitions of things

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'LuaENVY-ENVY-auto'
mods['LuaENVY-ENVY'].auto()
-- ^ this gives us `public` and `import`, among others
--    and makes all globals we define private to this plugin.
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

-- get definitions for the game's globals
---@module 'game'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'config'
configChalk = chalk.auto 'config.lua'
-- ^ this updates our `.cfg` file in the config folder!
-- public.config = config -- so other mods can access our config

local function DeepCopyTable( orig )
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		-- slightly more efficient to call next directly instead of using pairs
		for k,v in next, orig, nil do
			copy[k] = DeepCopyTable(v)
		end
	else
		copy = orig
	end

	return copy
end

local function DeepConfigMetatable( orig, origCopy )
	local orig_type = type(orig)
	local proxy
	if orig_type == 'table' then
		proxy = {}
        local mt = {
            __newindex = function (t,k,v)
                orig[k] = v
                origCopy[k] = v
            end,

            __index = function (t,k)
                return origCopy[k]
            end
        }
        setmetatable(proxy, mt)
		for k,v in pairs(orig) do
			rawset(proxy, k, DeepConfigMetatable(v, origCopy[k]))
		end
	end
	return proxy
end

configCopy = DeepCopyTable(configChalk)

config = DeepConfigMetatable(configChalk, configCopy)

public.config = config

function dump(o, depth)
    depth = depth or 0
    if type(o) == 'table' then
        local s = "\n" .. string.rep("\t", depth) .. '{\n'
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. string.rep("\t",(depth+1)) .. '['..k..'] = ' .. dump(v, depth + 1) .. ',\n'
        end
        return s .. string.rep("\t", depth) .. '}'
    elseif type(o) == "string" then
        return "\"" .. o .. "\""
    else
        return tostring(o)
    end
end

NPCRando_guid = "zerp-NPCRoomRandomizer"
ZJ_guid = "NikkelM-Zagreus_Journey"
GameOver_guid = "zerp-GameOverScreen"

local function on_ready()
    -- what to do when we are ready, but not re-do on reload.
    if config.enabled == false then return end

    npcRando = rom.mods[NPCRando_guid]
    zj = rom.mods[ZJ_guid]
    gameOver = rom.mods[GameOver_guid]

    mod = modutil.mod.Mod.Register(_PLUGIN.guid)
    mod.config = config

    mod.IsZagAvailable = zj and
                         zj.IsModEnabledAndInstallationValid and
                         zj.IsModEnabledAndInstallationValid() and
                         not zj.GetModConfigValueByLeafKey("z_ExcludeFromDreamDives")

    mod.IsZag = mod.IsZagAvailable and (not config.biome_pool.disable_zag_biomes)

    mod.MaxAllowedBiomeCount = (mod.IsZag and 12) or 8

    import 'visage.lua'
    import 'harvest.lua'
    import 'early_unlock.lua'
    import 'runlength.lua'
    import 'late_biome_scaling.lua'
    import 'runlength_late.lua'
    import 'music_fix.lua'
    import 'metareward.lua'
    import 'hermes_shrine.lua'
    import 'purging_well.lua'
    import 'bounty.lua'
    import 'npc_scaling.lua'
    import 'dodge.lua'
    import 'scorch.lua'

    import 'biomepool_ready.lua'

    import 'dialogue.lua'

    import 'endless/endless.lua'
    import 'endless/runclearscreen.lua'
end

local function on_reload()
    -- what to do when we are ready, but also again on every reload.
    -- only do things that are safe to run over and over.
    if config.enabled == false then return end
    import 'imgui.lua'
    import 'biomepool_reload.lua'
end

local function on_ready_late()
    if config.enabled == false then return end
    import 'visage_late.lua'
    import 'donk_late.lua'
    import 'endless/runclearscreen_late.lua'
end

local function on_reload_late()
    if config.enabled == false then return end
end

-- this allows us to limit certain functions to not be reloaded.
local loader = reload.auto_multiple()

-- this runs only when modutil and the game's lua is ready
modutil.once_loaded.game(function()
    loader.load("early", on_ready, on_reload)
end)

mods.on_all_mods_loaded(function()
	modutil.once_loaded.game(function()
		loader.load("late", on_ready_late, on_reload_late)
	end)
end)