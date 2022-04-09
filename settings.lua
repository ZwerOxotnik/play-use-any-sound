require("models/BetterCommands/control"):create_settings() -- Adds switchable commands

data:extend({
	{type = "bool-setting", name = "play-sounds-on-chat", setting_type = "runtime-global", default_value = true},
	{type = "bool-setting", name = "play-sounds-on-chat-user", setting_type = "runtime-per-user", default_value = true},
	{type = "bool-setting", name = "flying-text-sounds", setting_type = "runtime-per-user", default_value = true}
})
