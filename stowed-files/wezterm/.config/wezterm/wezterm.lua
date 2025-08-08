local wezterm = require 'wezterm';
local config = wezterm.config_builder();

-- Color scheme names
local DARK_COLOR_SCHEME_NAME = 'Default Dark (base16)'
local LIGHT_COLOR_SCHEME_NAME = 'Default Light (base16)'

-- WezTerm default keys are pretty nice
--
-- Paste: Ctrl+Shift+V
-- Increase Font Size: Ctrl+=
-- Decrease Font Size: Ctrl+-
--
-- Biggest issue is lack of osc52 support for copying to clipboard, must use
-- `yank` command to copy to clipboard

config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = DARK_COLOR_SCHEME_NAME

config.font = wezterm.font_with_fallback({
  { family = "Google Sans Code", weight = 400 },
  -- Google Sans currently only installed on Mac, fallback for Linux
  { family = "JetBrains Mono",   weight = 400 },
})

config.window_padding = {
  left = 4,
  right = 4,
  top = 0,
  bottom = 0,
}

wezterm.on('toggle-color-scheme', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local effective = window:effective_config() or {}
  local current_scheme = overrides.color_scheme or effective.color_scheme
  if current_scheme == DARK_COLOR_SCHEME_NAME then
    overrides.color_scheme = LIGHT_COLOR_SCHEME_NAME
  else
    overrides.color_scheme = DARK_COLOR_SCHEME_NAME
  end
  window:set_config_overrides(overrides)

  wezterm.background_child_process({
    'bash',
    '-lc',
    [[. ~/.profile && . ~/.bashrc && \
echo -n "[$(date "+%Y-%m-%d %H:%M:%S")] " >> /tmp/wezterm-toggle.log && \
~/dotfiles/stowed-files/bash/.local/bin/toggle-color-scheme >> /tmp/wezterm-toggle.log 2>&1]]
  })
end)

config.keys = {
  -- Toggle colorscheme with Ctrl+Shift+L
  {
    key = "L",
    mods = "CTRL|SHIFT",
    action = wezterm.action.Multiple {
      wezterm.action.EmitEvent "toggle-color-scheme",
    },
  },
}

return config
