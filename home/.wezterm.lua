local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()
local random_words =
	{ "apple", "blaze", "cloud", "dream", "flame", "grape", "mango", "ocean", "quest", "tiger", "vivid", "zesty" }
local tab_titles = {}
local rng_seeded = false
local matrix = {
	background = "#010704",
	foreground = "#8FD6A2",
	bright = "#B7F7C5",
	muted = "#4F8F61",
	surface = "#0B1A10",
	selection = "#12351F",
	diff_added = "#7DCFFF",
	diff_added_bright = "#B5E8FF",
	diff_removed = "#FF9E64",
	diff_removed_bright = "#FFBD8A",
}
local themes = {
	Matrix = {
		colors = {
			foreground = matrix.foreground,
			background = matrix.background,
			cursor_bg = matrix.bright,
			cursor_border = matrix.bright,
			cursor_fg = matrix.background,
			selection_bg = matrix.selection,
			selection_fg = matrix.bright,
			split = matrix.selection,
			scrollbar_thumb = matrix.muted,
			ansi = { "#07120B", matrix.diff_removed, matrix.diff_added, "#93DCA3", "#4E9D63", "#67B57A", "#82D696", "#A9E9B5" },
			brights = { "#234D30", matrix.diff_removed_bright, matrix.diff_added_bright, "#B0F4BC", "#74C789", "#8FDFA1", "#A3EFB2", "#D0F8D7" },
			tab_bar = {
				background = matrix.background,
				active_tab = {
					bg_color = matrix.surface,
					fg_color = matrix.bright,
					intensity = "Bold",
				},
				inactive_tab = {
					bg_color = matrix.background,
					fg_color = matrix.muted,
				},
				inactive_tab_hover = {
					bg_color = matrix.selection,
					fg_color = matrix.foreground,
				},
				new_tab = {
					bg_color = matrix.background,
					fg_color = matrix.muted,
				},
				new_tab_hover = {
					bg_color = matrix.selection,
					fg_color = matrix.bright,
				},
			},
		},
		opacity = 0.9,
		blur = 12,
		status_bg = matrix.bright,
		status_fg = matrix.background,
	},
	Coolnight = {
		colors = {
			foreground = "#CBE0F0",
			background = "#011423",
			cursor_bg = "#47FF9C",
			cursor_border = "#47FF9C",
			cursor_fg = "#011423",
			selection_bg = "#033259",
			selection_fg = "#CBE0F0",
			ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#A277FF", "#24EAF7", "#24EAF7" },
			brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#A277FF", "#24EAF7", "#24EAF7" },
		},
		opacity = 0.94,
		blur = 24,
		status_bg = "#47FF9C",
		status_fg = "#011423",
	},
}
local default_theme = "Matrix"
local theme_state_dir = wezterm.home_dir .. "/.cache/wezterm"

local function random_five_letter_word()
	if not rng_seeded then
		math.randomseed(os.time() + math.floor(os.clock() * 1000000))
		math.random()
		math.random()
		math.random()
		rng_seeded = true
	end

	return random_words[math.random(#random_words)]
end

local function active_theme_name(window)
	local overrides = window:get_config_overrides()
	local name = overrides and overrides.color_scheme or default_theme
	return themes[name] and name or default_theme
end

local function sync_theme_state(window, theme_name)
	local states = wezterm.GLOBAL.theme_states or {}
	local changed = false

	for _, tab in ipairs(window:mux_window():tabs()) do
		for _, pane in ipairs(tab:panes()) do
			local pane_id = tostring(pane:pane_id())
			local state_key = tostring(window:window_id()) .. ":" .. pane_id

			if states[state_key] ~= theme_name then
				local path = theme_state_dir .. "/theme-" .. pane_id
				local success, _, stderr = wezterm.run_child_process({
					"/bin/sh",
					"-c",
					'umask 077; /bin/mkdir -p "$1" && printf "%s\\n" "$2" > "$3"',
					"wezterm-theme",
					theme_state_dir,
					theme_name,
					path,
				})

				if success then
					states[state_key] = theme_name
					changed = true
				else
					wezterm.log_error("Unable to sync theme state for pane " .. pane_id .. ": " .. stderr)
				end
			end
		end
	end

	if changed then
		wezterm.GLOBAL.theme_states = states
	end
end

wezterm.on("format-tab-title", function(tab)
	local tab_id = tab.tab_id
	if tab_titles[tab_id] == nil then
		tab_titles[tab_id] = random_five_letter_word()
	end

	local tab_num = tab.tab_index + 1
	return string.format("  %d: %s  ", tab_num, tab_titles[tab_id])
end)

wezterm.on("toggle-theme", function(window)
	local current_name = active_theme_name(window)
	local next_name = current_name == "Matrix" and "Coolnight" or "Matrix"
	local next_theme = themes[next_name]
	local overrides = window:get_config_overrides() or {}
	local environment = overrides.set_environment_variables or {}

	overrides.color_scheme = next_name
	overrides.window_background_opacity = next_theme.opacity
	overrides.macos_window_background_blur = next_theme.blur
	environment.WEZTERM_THEME = next_name
	overrides.set_environment_variables = environment
	window:set_config_overrides(overrides)
	sync_theme_state(window, next_name)
	window:toast_notification("WezTerm", next_name .. " theme", nil, 1500)
end)

wezterm.on("update-right-status", function(window)
	sync_theme_state(window, active_theme_name(window))

	local key_table = window:active_key_table()
	if key_table == "resize_pane" then
		local theme = themes[active_theme_name(window)]
		window:set_right_status(wezterm.format({
			{ Background = { Color = theme.status_bg } },
			{ Foreground = { Color = theme.status_fg } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = " RESIZE " },
		}))
	else
		window:set_right_status("")
	end
end)

config.color_schemes = {}
for name, theme in pairs(themes) do
	config.color_schemes[name] = theme.colors
end
config.color_scheme = default_theme

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 15
config.max_fps = 120
config.front_end = "WebGpu"
config.default_cwd = wezterm.home_dir .. "/projects"
config.set_environment_variables = { WEZTERM_THEME = default_theme }

-- config.color_scheme = "Catppuccin Macchiato"
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.enable_tab_bar = true
config.window_decorations = "RESIZE"
config.window_background_opacity = themes[default_theme].opacity
config.macos_window_background_blur = themes[default_theme].blur
config.default_cursor_style = "SteadyBlock"
config.window_padding = {
	left = 14,
	right = 14,
	top = 12,
	bottom = 12,
}

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "t", mods = "LEADER", action = act.EmitEvent("toggle-theme") },
	{
		key = "r",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
			timeout_milliseconds = 2000,
		}),
	},
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = act.SendKey({ key = "a", mods = "CTRL" }),
	},
}

config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 3 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 3 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 3 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 3 }) },
		{ key = "Escape", action = "PopKeyTable" },
	},
}

return config
