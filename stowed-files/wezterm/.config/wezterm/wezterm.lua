local wezterm = require 'wezterm';
local config = wezterm.config_builder();

-- WezTerm default keys are pretty nice
--
-- Paste: Ctrl+Shift+V
-- Increase Font Size: Ctrl+=
-- Decrease Font Size: Ctrl+-
--
-- Biggest issue is lack of osc52 support for copying to clipboard, must use
-- `yank` command to copy to clipboard

config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = 'Default Dark (base16)'

config.window_padding = {
  left = 4,
  right = 4,
  top = 4,
  bottom = 4,
}

-- Toggle colorscheme with Ctrl+Shift+L
wezterm.on('toggle-color-scheme', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if overrides.color_scheme == 'Default Dark (base 16)' then
    overrides.color_scheme = 'Default Light (base 16)'
  else
    overrides.color_scheme = 'Default Dark (base 16)'
  end
  window:set_config_overrides(overrides)
end)

config.keys = {
  {
    key="L",
    mods="CTRL|SHIFT",
    action= wezterm.action.Multiple {
      wezterm.action.EmitEvent "toggle-color-scheme",
      -- Spawn shell to run `toggle-color-scheme`
      wezterm.action.SpawnCommandInNewTab {
        args = {
          'bash',
          '-c',
          [[\
. ~/.profile && . ~/.bashrc && \
  echo -n "[$(date "+%Y-%m-%d %H:%M:%S")] " >> /tmp/wezterm-toggle.log && \
  ~/dotfiles/stowed-files/bash/.local/bin/toggle-color-scheme >> /tmp/wezterm-toggle.log 2>&1
          ]]
        }
      },
    },
  },
}

return config
