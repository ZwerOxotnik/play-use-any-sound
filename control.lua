event_listener = require('__zk-lib__/event-listener/branch-1/stable-version')
local modules = {}
modules.play_use_any_sound = require("play-use-any-sound/control")

event_listener.add_libraries(modules) -- incompatible with stdlib (https://mods.factorio.com/mod/stdlib)
