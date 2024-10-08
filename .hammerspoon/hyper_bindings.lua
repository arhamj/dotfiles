function focusOrOpen(app)
	local focus = mkFocusByPreferredApplicationTitle(true, app)
	return (focus() or hs.application.launchOrFocus(app))
end

function hyperFocusOrOpen(key, app)
	hs.hotkey.bind(HYPER, key, function()
		focusOrOpen(app)
	end)
end

function mkFocusByPreferredApplicationTitle(stopOnFirst, ...)
	local arguments = { ... }
	return function()
		local nowFocused = hs.window.focusedWindow()
		local appFound = false
		for _, app in ipairs(arguments) do
			if stopOnFirst and appFound then
				break
			end
			log:d("Searching for app ", app)
			local application = hs.application.get(app)
			if application ~= nil then
				log:d("Found app", application)
				local window = application:mainWindow()
				if window ~= nil then
					log:d("Found main window", window)
					if window == nowFocused then
						log:d("Already focused, moving on", application)
					else
						window:focus()
						appFound = true
					end
				end
			end
		end
		return appFound
	end
end

local applicationHotkeys = {
	a = "Activity monitor",
	b = "Brave Browser",
	c = "Visual Studio Code",
	-- p = 'Postman',
	i = "Insomnia",
	w = "Bitwarden",
	h = "Hammerspoon",
	n = "Notes",
	s = "Slack",
	t = "WezTerm",
	d = "Discord",
	g = "Goland",
}
for key, app in pairs(applicationHotkeys) do
	hyperFocusOrOpen(tostring(key), app)
end
