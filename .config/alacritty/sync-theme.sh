#!/bin/sh
# Sync Alacritty's Catppuccin flavour with the OS light/dark appearance.
#   sync-theme.sh        write ~/.config/alacritty/current-theme.toml (latte/frappe)
#                        and ~/.claude/themes/catppuccin.json (Claude Code custom theme)
#   sync-theme.sh mode   just print "dark" or "light" (used by nvim)
# Triggered by tmux (status-right, every status-interval in ~/.tmux.conf).
# Alacritty live-reloads imported files, so open windows update automatically.

mode() {
  case "$(uname -s)" in
    Darwin)
      defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark && echo dark || echo light
      ;;
    *)
      # freedesktop portal: 1 = prefer dark (GNOME, KDE, and most portal backends)
      v=$(dbus-send --session --print-reply=literal --reply-timeout=500 \
            --dest=org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop \
            org.freedesktop.portal.Settings.Read \
            string:org.freedesktop.appearance string:color-scheme 2>/dev/null)
      case "$v" in
        *"uint32 1"*) echo dark; return ;;
        *"uint32 2"*) echo light; return ;;
      esac
      gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null \
        | grep -q dark && echo dark || echo light
      ;;
  esac
}

if [ "$1" = mode ]; then mode; exit; fi

dir="$HOME/.config/alacritty"
if [ "$(mode)" = dark ]; then flavour=frappe; else flavour=latte; fi
src="$dir/themes/themes/catppuccin_$flavour.toml"
dst="$dir/current-theme.toml"
cmp -s "$src" "$dst" || cp "$src" "$dst"

# Claude Code reloads ~/.claude/themes/*.json live, so selecting the
# "catppuccin" custom theme in /theme makes running sessions follow along.
if [ "$flavour" = frappe ]; then
  base=dark; text='#c6d0f5'; usermsg='#414559'
else
  base=light; text='#4c4f69'; usermsg='#ccd0da'
fi
claude_theme="$HOME/.claude/themes/catppuccin.json"
new=$(cat <<JSON
{
  "name": "Catppuccin (auto latte/frappe)",
  "base": "$base",
  "overrides": {
    "text": "$text",
    "userMessageBackground": "$usermsg"
  }
}
JSON
)
mkdir -p "$(dirname "$claude_theme")"
[ "$(cat "$claude_theme" 2>/dev/null)" = "$new" ] || printf '%s\n' "$new" > "$claude_theme"
