local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 20.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- Dim unfocused windows so the focused one is obvious at a glance.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

-- get_config_overrides() hands back a copy, so the current value is never the
-- same table we last stored; compare the fields instead of the identity.
local function same_text_hsb(actual, expected)
	if actual == nil or expected == nil then
		return actual == expected
	end
	return actual.hue == expected.hue
		and actual.saturation == expected.saturation
		and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	local text_hsb, opacity
	if not window:is_focused() then
		text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
		opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
	end

	-- Only write when one of the two values we own actually changes; a redundant
	-- set_config_overrides() call would trigger another config reload.
	if same_text_hsb(overrides.foreground_text_hsb, text_hsb) and overrides.window_background_opacity == opacity then
		return
	end

	overrides.foreground_text_hsb = text_hsb
	overrides.window_background_opacity = opacity
	window:set_config_overrides(overrides)
end)

-- Zed-style Cmd shortcuts, active only while nvim (or herdr, which hosts it) is the
-- foreground program. They send nvim's own keys: Ctrl-\ Ctrl-n drops to normal mode
-- first (also from the Claude terminal), then the leader sequence.
local act = wezterm.action
local TO_NORMAL = "\x1c\x0e"

local function nvim_key(key, mods, keys)
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(window, pane)
			local name = pane:get_foreground_process_name() or ""
			if name:find("nvim", 1, true) or name:find("herdr", 1, true) then
				window:perform_action(act.SendString(TO_NORMAL .. keys), pane)
			else
				window:perform_action(act.SendKey({ key = key, mods = mods }), pane)
			end
		end),
	}
end

config.keys = {
	nvim_key("p", "CMD", " f"), -- quick open file
	nvim_key("p", "CMD|SHIFT", " p"), -- command palette
	nvim_key("f", "CMD|SHIFT", " s"), -- search in project
	nvim_key("o", "CMD|SHIFT", " o"), -- symbols in file
	nvim_key("m", "CMD|SHIFT", " d"), -- problems
	nvim_key("b", "CMD", " e"), -- sidebar explorer
	nvim_key("j", "CMD", " t"), -- terminal panel
	nvim_key("l", "CMD", " ac"), -- Claude Code
	nvim_key("w", "CMD", " x"), -- close tab
	nvim_key("s", "CMD", "\x1b"), -- save
	nvim_key("LeftArrow", "CMD|ALT", "H"), -- previous tab
	nvim_key("RightArrow", "CMD|ALT", "L"), -- next tab
}

return config
