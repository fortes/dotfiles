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

config.color_scheme = 'Builtin Dark'

-- Toggle colorscheme with Ctrl+Shift+L
wezterm.on('toggle-color-scheme', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if overrides.color_scheme == 'Builtin Dark' then
    overrides.color_scheme = 'Builtin Light'
  else
    overrides.color_scheme = 'Builtin Dark'
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
  ~/dotfiles/stowed-files/wezterm/.local/bin/toggle-color-scheme >> /tmp/wezterm-toggle.log 2>&1
          ]]
        }
      },
    },
  },
}

return config
