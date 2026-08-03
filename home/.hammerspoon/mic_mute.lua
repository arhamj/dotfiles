-- Loading the spoon through SpoonInstall calls its initializer, which creates a
-- clickable microphone status item in the menu bar. Load its toggle logic
-- directly and disable its menu-only status update instead.
local micMute = require("MicMute")
micMute.updateMicMute = function() end

hs.hotkey.bind(HYPER, "m", function()
    micMute:toggleMicMute()
    local mic = hs.audiodevice.defaultInputDevice()
    if mic:muted() then
        hs.alert.show("🔇 Microphone Muted")
    else
        hs.alert.show("🎙️ Microphone Active")
    end
end)
