function toggleTailscale()
  return function()
    -- First check current status
    hs.task.new("/usr/local/bin/tailscale", function(statusCode, statusOut, statusErr)
      local isDisconnected = false

      -- Check if disconnected (status command may fail when disconnected)
      if statusCode ~= 0 or
          (statusOut and (statusOut:find("Stopped") or statusOut:find("stopped"))) or
          (statusErr and (statusErr:find("Stopped") or statusErr:find("stopped") or statusErr:find("not running"))) then
        isDisconnected = true
      end

      if isDisconnected then
        -- Currently disconnected, connect it
        hs.task.new("/usr/local/bin/tailscale", function(exitCode, stdOut, stdErr)
          if exitCode == 0 then
            hs.alert.show("🔗 Tailscale connected")
          else
            hs.alert.show("❌ Tailscale connection failed")
            if stdErr and stdErr ~= "" then
              print("Tailscale error: " .. stdErr)
            end
          end
        end, { "up" }):start()
      else
        -- Currently connected, disconnect it
        hs.task.new("/usr/local/bin/tailscale", function(exitCode, stdOut, stdErr)
          if exitCode == 0 then
            hs.alert.show("🔌 Tailscale disconnected")
          else
            hs.alert.show("❌ Tailscale disconnect failed")
            if stdErr and stdErr ~= "" then
              print("Tailscale error: " .. stdErr)
            end
          end
        end, { "down" }):start()
      end
    end, { "status" }):start()
  end
end

hs.hotkey.bind(HYPER, "t", toggleTailscale())
