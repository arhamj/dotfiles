function toggleAudioOutput()
    return function()
        local current = hs.audiodevice.defaultOutputDevice()
        local speakers = hs.audiodevice.findOutputByName('MacBook Pro Speakers')
        local monitor = hs.audiodevice.findOutputByName('BenQ PD3205UA')
        local earbuds = hs.audiodevice.findOutputByName('OnePlus Buds Pro 2')

        local currentName = current:name()
        local nextDevice = nil
        local nextName = ""

        if currentName == speakers:name() then
            if monitor ~= nil then
                nextDevice = monitor
                nextName = "🖥️ BenQ PD3205UA"
            elseif earbuds ~= nil then
                nextDevice = earbuds
                nextName = "🎧 OnePlus Buds Pro 2"
            end
        elseif currentName == monitor:name() then
            if earbuds ~= nil then
                nextDevice = earbuds
                nextName = "🎧 OnePlus Buds Pro 2"
            else
                nextDevice = speakers
                nextName = "💻 MacBook Pro Speakers"
            end
        else
            nextDevice = speakers
            nextName = "💻 MacBook Pro Speakers"
        end

        if nextDevice ~= nil then
            nextDevice:setDefaultOutputDevice()
            hs.alert.show("Audio: " .. nextName)
        end
    end
end

function toggleAudioInput()
    return function()
        local current = hs.audiodevice.defaultInputDevice()
        local macMic = hs.audiodevice.findInputByName('MacBook Pro Microphone')
        local earbudsMic = hs.audiodevice.findInputByName('OnePlus Buds Pro 2')
        local obsbotMic = hs.audiodevice.findInputByName('OBSBOT Meet 2 Microphone')

        local currentName = current:name()
        local nextDevice = nil
        local nextName = ""

        if currentName == macMic:name() then
            if earbudsMic ~= nil then
                nextDevice = earbudsMic
                nextName = "🎧 OnePlus Buds Pro 2"
            elseif obsbotMic ~= nil then
                nextDevice = obsbotMic
                nextName = "🎥 OBSBOT Meet 2 Microphone"
            end
        elseif currentName == earbudsMic:name() then
            if obsbotMic ~= nil then
                nextDevice = obsbotMic
                nextName = "🎥 OBSBOT Meet 2 Microphone"
            else
                nextDevice = macMic
                nextName = "💻 MacBook Pro Microphone"
            end
        else
            nextDevice = macMic
            nextName = "💻 MacBook Pro Microphone"
        end

        if nextDevice ~= nil then
            nextDevice:setDefaultInputDevice()
            hs.alert.show("Microphone: " .. nextName)
        end
    end
end

hs.hotkey.bind(HYPER, "]", toggleAudioOutput())
hs.hotkey.bind(HYPER, "[", toggleAudioInput())

function getCurrentOutputDevicePrefix()
    if (hs.audiodevice.defaultOutputDevice() ~= nil and hs.audiodevice.defaultOutputDevice():name() ~= nil) then
        return string.sub(hs.audiodevice.defaultOutputDevice():name(), 0, 3)
    end
end

function audioChanged()
    audioMenu:setTitle(getCurrentOutputDevicePrefix())
end

audioMenu = hs.menubar.new()
audioChanged()
audioMenu:setClickCallback(toggleAudioOutput())

hs.audiodevice.watcher.setCallback(audioChanged)
hs.audiodevice.watcher.start()
