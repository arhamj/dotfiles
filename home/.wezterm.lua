local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()
local random_words =
	{ "apple", "blaze", "cloud", "dream", "flame", "grape", "mango", "ocean", "quest", "tiger", "vivid", "zesty" }
local tab_titles = {}
local rng_seeded = false

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

wezterm.on("format-tab-title", function(tab)
	local tab_id = tab.tab_id
	if tab_titles[tab_id] == nil then
		tab_titles[tab_id] = random_five_letter_word()
	end

	local tab_num = tab.tab_index + 1
	return string.format("  %d: %s  ", tab_num, tab_titles[tab_id])
end)

config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 15
config.max_fps = 120

-- config.color_scheme = "Catppuccin Macchiato"
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 10000
config.audible_bell = "Disabled"

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.enable_tab_bar = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.94
config.macos_window_background_blur = 24
config.default_cursor_style = "SteadyBar"
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
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = act.SendKey({ key = "a", mods = "CTRL" }),
	},
}

return config
