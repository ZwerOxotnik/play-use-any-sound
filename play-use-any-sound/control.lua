--[[
Copyright (C) 2018-2020 ZwerOxotnik <zweroxotnik@gmail.com>
Licensed under the EUPL, Version 1.2 only (the "LICENCE");
Author: ZwerOxotnik

You can write and receive any information on the links below.
Source: https://gitlab.com/ZwerOxotnik/play-use-any-sound
Mod portal: https://mods.factorio.com/mod/play-use-any-sound
]]--

local module = {}

-- TODO: create rendering instead of create_entity
local function check_need_flying_text(player, message)
	if script.mod_name ~= 'level' and settings.get_player_settings(player)["flying-text-sounds"].value then
		player.surface.create_entity{name = "flying-text", position = player.position, text = message}
	end
end

local function is_have_event(event_name)
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

local function play_on_event_sound(event, name_event)
	local have_sound = global.play_sounds[event.player_index]
	if not have_sound then return end
	local sound_path = have_sound[name_event]
	if not sound_path then return end

	local player = game.players[event.player_index]
	if game.is_valid_sound_path(sound_path) then
		player.surface.play_sound{path = sound_path, position = player.position}
		check_need_flying_text(player, string.match(sound_path, "/(.+)"))
	else
		have_sound[name_event] = nil
	end
end

local function play_sound(player, text, allow_output)
	if text then
		local params = {}
		for param in string.gmatch(text, "%g+") do table.insert(params, param) end
		if #params == 1 then
		local name = params[1]
		if game.is_valid_sound_path("utility/" .. name) then
			player.surface.play_sound{path = "utility/" .. name, position = player.position}
			check_need_flying_text(player, name)
		elseif game.is_valid_sound_path("ambient/" .. name) then
			player.surface.play_sound{path = "ambient/" .. name, position = player.position}
			check_need_flying_text(player, name)
		elseif game.is_valid_sound_path("tile-walking/" .. name) then
			player.surface.play_sound{path = "tile-walking/" .. name, position = player.position}
			check_need_flying_text(player, name)
		elseif game.is_valid_sound_path("entity-mined/" .. name) then
			player.surface.play_sound{path = "entity-mined/" .. name, position = player.position}
			check_need_flying_text(player, name)
		elseif game.is_valid_sound_path("entity-vehicle_impact/" .. name) then
			player.surface.play_sound{path = "entity-vehicle_impact/" .. name, position = player.position}
			check_need_flying_text(player, name)
		elseif game.is_valid_sound_path("entity-open/" .. name) then
			player.surface.play_sound{path = "entity-open/" .. name, position = player.position}
			check_need_flying_text(player, name)
		elseif game.is_valid_sound_path("entity-close/" .. name) then
			player.surface.play_sound{path = "entity-close/" .. name, position = player.position}
			check_need_flying_text(player, name)
		elseif game.is_valid_sound_path("tile-build/" .. name) then
			player.surface.play_sound{path = "tile-build/" .. name, position = player.position}
			check_need_flying_text(player, name)
		elseif game.is_valid_sound_path("entity-build/" .. name) then
			player.surface.play_sound{path = "entity-build/" .. name, position = player.position}
			check_need_flying_text(player, name)
		elseif game.is_valid_sound_path(name) then
			player.surface.play_sound{path = name, position = player.position}
			check_need_flying_text(player, name)
		else
			if allow_output then player.print({"cannot-found"}) end
		end
		elseif #params == 2 then

		local path = params[1] .. "/" .. params[2]
		if game.is_valid_sound_path(path) then
			player.surface.play_sound{path = path, position = player.position}
			check_need_flying_text(player, params[2])
			return
		end

		path = params[2] .. "/" .. params[1]
		if game.is_valid_sound_path(path) then
			player.surface.play_sound{path=path, position = player.position}
			check_need_flying_text(player, params[1])
			return
		end

		if allow_output then player.print({"cannot-found"}) end
		elseif allow_output then player.print({"play-use-any-sound.sound-help"}) end
	elseif allow_output then player.print({"play-use-any-sound.sound-help"}) end
end

local function play_sound_command(cmd)
	-- Validation of data
	local player = game.players[cmd.player_index]
	if not (player and player.valid) then return end

	play_sound(player, cmd.parameter, true)
end

-- TODO: refactor this
local function add_sound(player, text)
	if text then
		local params = {}
		for param in string.gmatch(text, "%g+") do table.insert(params, param) end
		if global.play_sounds[player.index] == nil then
			global.play_sounds[player.index] = {}
		end

		if #params == 2 then
			local event = string.lower(params[1])
			local name = params[2]
			local path
			if not is_have_event(event) then
				event = string.lower(params[2])
				name = params[1]
				if not is_have_event(event) then player.print{"gui-browse-games.none"}; return; end
			end

			if game.is_valid_sound_path("utility/" .. name) then
				path = "utility/" .. name
			elseif game.is_valid_sound_path("ambient/" .. name) then
				path = "ambient/" .. name
			elseif game.is_valid_sound_path("tile-walking/" .. name) then
				path = "tile-walking/" .. name
			elseif game.is_valid_sound_path("entity-mined/" .. name) then
				path = "entity-mined/" .. name
			elseif game.is_valid_sound_path("entity-vehicle_impact/" .. name) then
				path = "entity-vehicle_impact/" .. name
			elseif game.is_valid_sound_path("entity-open/" .. name) then
				path = "entity-open/" .. name
			elseif game.is_valid_sound_path("entity-close/" .. name) then
				path = "entity-close/" .. name
			elseif game.is_valid_sound_path("tile-build/" .. name) then
				path = "tile-build/" .. name
			elseif game.is_valid_sound_path("entity-build/" .. name) then
				path = "entity-build/" .. name
			elseif game.is_valid_sound_path(name) then
				path = name
			else
				player.print({"cannot-found"})
			end
			global.play_sounds[player.index][event] = path
			player.print({"permissions-command-output.added-player-to-group", path, event})
			elseif #params == 3 then
			local event = string.lower(params[1])
			local path = params[2] .. "/" .. params[3]
			if game.is_valid_sound_path(path) then
				if is_have_event(event) then
				global.play_sounds[player.index][event] = path
				player.print({"permissions-command-output.added-player-to-group", path, event})
				else player.print({"cannot-found"}) end
				return
			end
			path = params[3] .. "/" .. params[2]
			if game.is_valid_sound_path(path) then
				if is_have_event(event) then
				global.play_sounds[player.index][event] = path
				player.print({"permissions-command-output.added-player-to-group", path, event})
				else player.print({"cannot-found"}) end
				return
			end
			player.print({"cannot-found"})
		else player.print({"play-use-any-sound.add-sound-help"}) end
	else player.print({"play-use-any-sound.add-sound-help"}) end
end

local function add_sound_command(cmd)
	-- Validation of data
	local player = game.players[cmd.player_index]
	if not (player and player.valid) then return end

	add_sound(player, cmd.parameter)
end

local function remove_sound(player, parameter)
	if is_have_event(parameter) then
		local have_any_sound = global.play_sounds[player.index]
		if have_any_sound == nil then return end
		local have_sound = have_any_sound[parameter]
		if have_sound then
		global.play_sounds[player.index][parameter] = nil
		player.print({"permissions-command-output.added-player-to-group", have_sound, "_"})
		else
		player.print({"gui-browse-games.none"})
		end
	else
		player.print({"cannot-found"})
	end
end

local function remove_sound_command(cmd)
	remove_sound(game.players[cmd.player_index], string.lower(cmd.parameter))
end

module.add_commands = function()
	commands.add_command("add-sound", {"play-use-any-sound.add-sound-help"}, add_sound_command)
	commands.add_command("remove-sound", {"play-use-any-sound.remove-sound-help"}, remove_sound_command)
	commands.add_command("sound", {"play-use-any-sound.sound-help"}, play_sound_command)
end

module.remove_commands = function()
	commands.remove_command("add-sound")
	commands.remove_command("remove-sound")
	commands.remove_command("sound")
end

module.play_on_event_sound = play_on_event_sound

module.on_init = function()
	global.play_sounds = global.play_sounds or {}
end


function clear_player_data(event)
	global.play_sounds[event.player_index] = nil
end

local function on_console_chat(event)
	if not event.player_index then return end

	if script.mod_name ~= 'level' and not settings.global["play-sounds-on-chat"].value then return end
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	if script.mod_name ~= 'level' and not settings.get_player_settings(player)["play-sounds-on-chat-user"].value then return end

	if string.len(event.message) <= 50 then
		play_sound(player, event.message, false)
	end
end

local function on_console_command(event)
	if not event.player_index then return end

	if script.mod_name ~= 'level' and not settings.global["play-sounds-on-chat"].value then return end
	if event.command == "s" or event.command == "shout" then return end -- TODO: change
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	if script.mod_name ~= 'level' and not settings.get_player_settings(player)["play-sounds-on-chat-user"].value then return end

	if string.len(event.parameters) <= 50 then
		play_sound(player, event.parameters , false)
	end
end

module.events = {
	[defines.events.on_console_command] = on_console_command,
	[defines.events.on_console_chat] = on_console_chat,
	[defines.events.on_player_removed] = clear_player_data,
}

local events_list = {"on_pre_player_died", "on_player_respawned", "on_rocket_launched", "on_player_joined_game",
	"on_player_promoted", "on_player_demoted", "on_player_cheat_mode_disabled", "on_player_cheat_mode_enabled"
}
for _, event_name in pairs(events_list) do -- TODO: REFACTOR!!!
	module.events[defines.events[event_name]] = function(event)
		play_on_event_sound(event, event_name)
	end
end

return module
