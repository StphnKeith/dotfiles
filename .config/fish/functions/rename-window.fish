# Rename a tmux window and lock it against the fish-driven auto-rename hook
# (see conf.d/tmux_rename_window.fish), same as prefix+,. Defaults to the
# current window; -t/--target takes any tmux window target (index, name, or
# pane/window id). -a/--auto clears the lock and hands the window back to
# automatic naming instead of renaming it.
function rename-window --description 'Rename a tmux window and lock it, or -a to return it to automatic naming'
    if not set -q TMUX
        echo "rename-window: not inside tmux" >&2
        return 1
    end

    argparse 't/target=' 'a/auto' -- $argv
    or return 1

    set -l target $TMUX_PANE
    if set -q _flag_target
        set target $_flag_target
    end

    # A bare numeric target like "0" is tried as a session name first; when
    # that fails to match, tmux silently falls back to the CURRENT window
    # instead of erroring, so "-t 0" would resolve to whatever window you're
    # already in rather than window 0. A leading ":" forces tmux to parse it
    # as a window index instead. Only do this for purely-numeric targets --
    # the same prefix breaks pane-id targets like %0 (used by the default
    # $TMUX_PANE case above), which already resolve correctly unprefixed.
    set -l resolved $target
    if string match -qr '^\d+$' -- $target
        set resolved ":$target"
    end

    # Resolve to the window's stable @id before acting: renaming by name and
    # then setting the option by that same name would hit a window that no
    # longer has that name once the rename takes effect.
    set -l window_id (tmux display-message -t $resolved -p '#{window_id}' 2>/dev/null)
    if test -z "$window_id"
        echo "rename-window: no such window: $target" >&2
        return 1
    end

    if set -q _flag_auto
        tmux set-option -w -t $window_id -u @manual_name
        return
    end

    if test (count $argv) -eq 0
        echo "usage: rename-window [-t target] <name> | rename-window [-t target] -a" >&2
        return 1
    end

    tmux rename-window -t $window_id -- "$argv"
    tmux set-option -w -t $window_id @manual_name 1
end
