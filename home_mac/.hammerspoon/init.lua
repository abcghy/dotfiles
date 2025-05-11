hs.hotkey.bind({ "cmd", "ctrl" }, "R", function()
    hs.reload()
end)

hs.alert.show("Config loaded")

function turnDownBrightness()
    hs.eventtap.event.newSystemKeyEvent("BRIGHTNESS_DOWN", true):post()
    hs.eventtap.event.newSystemKeyEvent("BRIGHTNESS_DOWN", false):post()
end

function turnUpBrightness()
    hs.eventtap.event.newSystemKeyEvent("BRIGHTNESS_UP", true):post()
    hs.eventtap.event.newSystemKeyEvent("BRIGHTNESS_UP", false):post()
end

-- I don't want to use the watch method to watch the volume slider, so F11, and F12 with command key for now?
hs.hotkey.bind({ "cmd" }, "F11", function()
    turnDownBrightness()
end)

hs.hotkey.bind({ "cmd" }, "F12", function()
    turnUpBrightness()
end)

-- hs.eventtap.new({ hs.eventtap.event.types.systemDefined }, function(event)
--     print("Key Pressed: " ..
--         event:systemKey().key ..
--         ", keyCode: " .. event:systemKey().keyCode .. ", down: " .. tostring(event:systemKey().down))
--     return false
-- end):start()
