--[[
Copyright (C) 2018-2020, 2022-2023 ZwerOxotnik <zweroxotnik@gmail.com>
Licensed under the EUPL, Version 1.2 only (the "LICENCE");

You can write and receive any information on the links below.
Source: https://github.com/ZwerOxotnik/play-use-any-sound
Mod portal: https://mods.factorio.com/mod/play-use-any-sound
]]--


---@class PUAS : module
local M = {}


--#region Global data
local mod_data
---@type table<number, table>
local players_sounds
--#endregion


--#region Constants
local lower = string.lower
local gmatch = string.gmatch
local match = string.match
local print_to_rcon = rcon.print
--#endregion


local surface_sound = {path = "", position = {}}
local flying_text_data = {name = "flying-text", position = {}, text = ""}


--#region Function for RCON

---@param name string
function getRconData(name)
	print_to_rcon(game.table_to_json(mod_data[name]))
end

--#endregion


---@param player LuaPlayer
---@param message string
local function check_need_flying_text(player, message)
	-- INFO: perhaps, this \/ should be improved
	if settings.get_player_settings(player)["flying-text-sounds"].value == false then
		return
	end

	-- TODO: perhaps, create rendering instead of create_entity
	flying_text_data.position = player.position
	flying_text_data.text = message
	player.surface.create_entity(flying_text_data)
end


-- INFO: perhaps, this \/ should be improved
---@param event_name string
---@return boolean
local function is_event_playable(event_name)
	if event_name == "on_pre_player_died" then return true end
	if event_name == "on_player_respawned" then return true end
	if event_name == "on_rocket_launched" then return true end
	if event_name == "on_player_joined_game" then return true end
	if event_name == "on_player_promoted" then return true end
	if event_name == "on_player_demoted" then return true end
	if event_name == "on_player_cheat_mode_disabled" then return true end
	if event_name == "on_player_cheat_mode_enabled" then return true end
	return false
end


---@param event table
---@param name_event string
local function play_on_event_sound(event, name_event)
	local player_sounds = players_sounds[event.player_index]
	if not player_sounds then return end
	local sound_path = player_sounds[name_event]
	if not sound_path then return end
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	if game.is_valid_sound_path(sound_path) then
		surface_sound.path = sound_path
		surface_sound.position = player.position
		player.surface.play_sound(surface_sound)
		check_need_flying_text(player, match(sound_path, "/(.+)"))
	else
		player_sounds[name_event] = nil
	end
end

---@param player LuaPlayer
---@param text string
---@param is_global_message boolean?
local function play_sound_individually(player, text, is_global_message)
	if text == "" then return end

	local is_valid_sound_path = game.is_valid_sound_path
	local sound_path
	if is_valid_sound_path("utility/" .. text) then
		sound_path = "utility/" .. text
	elseif is_valid_sound_path("ambient/" .. text) then
		sound_path = "ambient/" .. text
	elseif is_valid_sound_path("tile-walking/" .. text) then
		sound_path = "tile-walking/" .. text
	elseif is_valid_sound_path("entity-mined/" .. text) then
		sound_path = "entity-mined/" .. text
	elseif is_valid_sound_path("entity-vehicle_impact/" .. text) then
		sound_path = "entity-vehicle_impact/" .. text
	elseif is_valid_sound_path("entity-open/" .. text) then
		sound_path = "entity-open/" .. text
	elseif is_valid_sound_path("entity-close/" .. text) then
		sound_path = "entity-close/" .. text
	elseif is_valid_sound_path("tile-build/" .. text) then
		sound_path = "tile-build/" .. text
	elseif is_valid_sound_path("entity-build/" .. text) then
		sound_path = "entity-build/" .. text
	elseif is_valid_sound_path(text) then
		sound_path = text
	else
		return
	end

	local get_player_settings = settings.get_player_settings
	---@type LuaPlayer.play_sound_param
	local sound_param = {path = sound_path}
	local targets
	if is_global_message then
		targets = game.connected_players
	else
		targets = player.force.connected_players
	end
	for _, _player in pairs(targets) do
		if _player.valid and get_player_settings(_player)["play-sounds-on-chat-user"].value then
			_player.play_sound(sound_param)
		end
	end
	check_need_flying_text(player, text)
end


---@param player LuaPlayer
---@param text? string
local function play_sound_by_command(player, text)
	local surface = player.surface
	local is_valid_sound_path = game.is_valid_sound_path
	if text == nil then
		player.print({"play-use-any-sound-commands.sound"})
		return
	end

	local params = {}
	for param in gmatch(text, "%g+") do params[#params+1] = param end
	if #params == 1 then
		local name = params[1]
		local sound_path
		if is_valid_sound_path("utility/" .. name) then
			sound_path = "utility/" .. name
		elseif is_valid_sound_path("ambient/" .. name) then
			sound_path = "ambient/" .. name
		elseif is_valid_sound_path("tile-walking/" .. name) then
			sound_path = "tile-walking/" .. name
		elseif is_valid_sound_path("entity-mined/" .. name) then
			sound_path = "entity-mined/" .. name
		elseif is_valid_sound_path("entity-vehicle_impact/" .. name) then
			sound_path = "entity-vehicle_impact/" .. name
		elseif is_valid_sound_path("entity-open/" .. name) then
			sound_path = "entity-open/" .. name
		elseif is_valid_sound_path("entity-close/" .. name) then
			sound_path = "entity-close/" .. name
		elseif is_valid_sound_path("tile-build/" .. name) then
			sound_path = "tile-build/" .. name
		elseif is_valid_sound_path("entity-build/" .. name) then
			sound_path = "entity-build/" .. name
		elseif is_valid_sound_path(name) then
			sound_path = name
		else
			player.print({"cannot-found"})
			return
		end
		surface_sound.path = sound_path
		surface_sound.position = player.position
		surface.play_sound(surface_sound)
	elseif #params == 2 then
		local path = params[1] .. "/" .. params[2]
		if is_valid_sound_path(path) then
			surface.play_sound{path = path, position = player.position}
			check_need_flying_text(player, params[2])
			return
		end
		path = params[2] .. "/" .. params[1]
		if is_valid_sound_path(path) then
			surface.play_sound{path=path, position = player.position}
			check_need_flying_text(player, params[1])
			return
		end
		player.print({"cannot-found"})
	else
		player.print({"play-use-any-sound-commands.sound"})
	end
end


-- TODO: refactor this
---@param player LuaPlayer
---@param text string
local function add_sound(player, text)
	local params = {}
	for param in gmatch(text, "%g+") do params[#params+1] = param end
	local player_index = player.index
	if players_sounds[player_index] == nil then
		players_sounds[player_index] = {}
	end

	local is_valid_sound_path = game.is_valid_sound_path
	if #params == 2 then
		local event = lower(params[1])
		local name = params[2]
		local path
		if not is_event_playable(event) then
			event = lower(params[2])
			name = params[1]
			if not is_event_playable(event) then
				player.print{"gui-browse-games.none"}
				return
			end
		end

		if is_valid_sound_path("utility/" .. name) then
			path = "utility/" .. name
		elseif is_valid_sound_path("ambient/" .. name) then
			path = "ambient/" .. name
		elseif is_valid_sound_path("tile-walking/" .. name) then
			path = "tile-walking/" .. name
		elseif is_valid_sound_path("entity-mined/" .. name) then
			path = "entity-mined/" .. name
		elseif is_valid_sound_path("entity-vehicle_impact/" .. name) then
			path = "entity-vehicle_impact/" .. name
		elseif is_valid_sound_path("entity-open/" .. name) then
			path = "entity-open/" .. name
		elseif is_valid_sound_path("entity-close/" .. name) then
			path = "entity-close/" .. name
		elseif is_valid_sound_path("tile-build/" .. name) then
			path = "tile-build/" .. name
		elseif is_valid_sound_path("entity-build/" .. name) then
			path = "entity-build/" .. name
		elseif is_valid_sound_path(name) then
			path = name
		else
			player.print({"cannot-found"})
			return
		end

		players_sounds[player_index][event] = path
		player.print({"permissions-command-output.added-player-to-group", path, event})
	elseif #params == 3 then
		local event = lower(params[1])
		local path = params[2] .. "/" .. params[3]
		if is_valid_sound_path(path) then
			if is_event_playable(event) then
			players_sounds[player.index][event] = path
			player.print({"permissions-command-output.added-player-to-group", path, event})
			else player.print({"cannot-found"}) end
			return
		end
		path = params[3] .. "/" .. params[2]
		if is_valid_sound_path(path) then
			if is_event_playable(event) then
			players_sounds[player_index][event] = path
			player.print({"permissions-command-output.added-player-to-group", path, event})
			else player.print({"cannot-found"}) end
			return
		end
		player.print({"cannot-found"})
	else player.print({"play-use-any-sound-commands.add-sound"}) end
end


---@param player LuaPlayer
---@param parameter string
local function remove_sound(player, parameter)
	parameter = lower(parameter)
	if is_event_playable(parameter) == false then
		player.print({"cannot-found"})
		return
	end

	local player_sounds = players_sounds[player.index]
	if player_sounds == nil then return end
	local have_sound = player_sounds[parameter]
	if have_sound then
		player_sounds[parameter] = nil
		player.print({"permissions-command-output.added-player-to-group", have_sound, "_"})
	else
		player.print({"gui-browse-games.none"})
	end
end


---@param event EventData.on_console_chat
local function on_console_chat(event)
	local message = event.message
	if #message > 50 then return end
	if not event.player_index then return end
	-- INFO: perhaps, this \/ should be improved
	if not settings.global["play-sounds-on-chat"].value then return end
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	play_sound_individually(player, message)
end


---@param event EventData.on_console_command
local function on_console_command(event)
	local parameters = event.parameters
	if #parameters > 50 then return end
	if not (event.command == "s" or event.command == "shout") then return end
	if not event.player_index then return end
	-- INFO: perhaps, this \/ should be improved
	if not settings.global["play-sounds-on-chat"].value then return end
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	play_sound_individually(player, parameters, true)
end


local function link_data()
	mod_data = global.play_use_any_sound
	players_sounds = mod_data.players_sounds
end

local function update_global_data()
	global.play_use_any_sound = global.play_use_any_sound or {}
	mod_data = global.play_use_any_sound
	mod_data.players_sounds = mod_data.players_sounds or {}

	link_data()
end

M.add_remote_interface = function()
	-- https://lua-api.factorio.com/latest/LuaRemote.html
	remote.remove_interface("play-use-any-sound") -- For safety
	remote.add_interface("play-use-any-sound", {
		get_source = function()
			return script.mod_name
		end,
		get_mod_data = function()
			return mod_data
		end
	})
end


M.on_configuration_changed = function(event)
	local mod_changes = event.mod_changes["play-use-any-sound"]
	if not (mod_changes and mod_changes.old_version) then return end
	update_global_data()

	local version = tonumber(gmatch(mod_changes.old_version, "%d+.%d+")())

	if version < 1.16 then
		for player_index, data in pairs(global.play_sounds) do
			players_sounds[player_index] = data
		end
	end
end

M.on_init = update_global_data
M.on_load = link_data

M.events = {
	[defines.events.on_console_command] = on_console_command,
	[defines.events.on_console_chat] = on_console_chat,
	[defines.events.on_player_removed] = function(event)
		players_sounds[event.player_index] = nil
	end,
}

do
	local events_list = {"on_pre_player_died", "on_player_respawned", "on_rocket_launched", "on_player_joined_game",
		"on_player_promoted", "on_player_demoted", "on_player_cheat_mode_disabled", "on_player_cheat_mode_enabled"
	}
	for _, event_name in pairs(events_list) do -- TODO: refactor
		M.events[defines.events[event_name]] = function(event)
			play_on_event_sound(event, event_name)
		end
	end
end


M.commands = {
	["add-sound"] = function(cmd)
		add_sound(game.get_player(cmd.player_index), cmd.parameter)
	end,
	["remove-sound"] = function(cmd)
		remove_sound(game.get_player(cmd.player_index), cmd.parameter)
	end,
	["sound"] = function(cmd)
		play_sound_by_command(game.get_player(cmd.player_index), cmd.parameter)
	end
}


return M
