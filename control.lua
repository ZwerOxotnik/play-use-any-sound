
event_listener = require('__event-listener__/branch-2/stable-version')
local modules = {}
modules.play_use_any_sound = require("play-use-any-sound/control")

event_listener.add_events(modules) -- incompatible with stdlib (https://mods.factorio.com/mod/stdlib)
