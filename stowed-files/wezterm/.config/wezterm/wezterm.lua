local wezterm = require 'wezterm';
local config = wezterm.config_builder();

-- WezTerm default keys are pretty nice
--
-- Copy: Ctrl+Shift+C
-- Paste: Ctrl+Shift+V
-- Increase Font Size: Ctrl+=
-- Decrease Font Size: Ctrl+-

config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = 'OneDark (Gogh)'

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

wezterm.on('window-config-reloaded', function(window, pane)
  window:toast_notification(
    'wezterm',
    'Configuration reloaded',
    nil,
    4000
  )
end)

return config
