Install:andUse("MicMute")
hs.hotkey.bind(HYPER, "m", function()
    spoon.MicMute:toggleMicMute()
    local mic = hs.audiodevice.defaultInputDevice()
    if mic:muted() then
        hs.alert.show("🔇 Microphone Muted")
    else
        hs.alert.show("🎙️ Microphone Active")
    end
end)
