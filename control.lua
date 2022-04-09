---@type table<string, module>
local modules = {
	better_commands = require("models/BetterCommands/control"),
	play_use_any_sound = require("models/play-use-any-sound")
}

local event_handler
if script.active_mods["zk-lib"] then
	event_handler = require("__zk-lib__/static-libs/lualibs/event_handler_vZO.lua")
else
	event_handler = require("event_handler")
end

modules.better_commands:handle_custom_commands(modules.play_use_any_sound) -- adds commands
event_handler.add_libraries(modules)
