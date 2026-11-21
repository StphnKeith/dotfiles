# Rename the tmux window on each prompt / command, controlled entirely by
# fish so that programs emitting terminal-title escapes (claude, etc.) can't
# override it. Requires automatic-rename/allow-rename off in tmux.conf.

function __tmux_set_window_name
    if set -q TMUX
        # @manual_name is set by the prefix-, binding in tmux.conf when the
        # user names a window by hand; skip auto-rename until prefix-.
        # clears it, so a manual name isn't immediately overwritten here.
        # Captured into a variable first: on a brand-new window the option is
        # unset, so the command substitution is empty, and splicing an empty
        # substitution straight into `test` leaves it with too few arguments.
        set -l manual_name (tmux show-option -t $TMUX_PANE -wqv @manual_name)
        if test "$manual_name" = 1
            return
        end
        # -t $TMUX_PANE targets this shell's own window; without it tmux renames
        # whichever window is active, so hooks firing in an unfocused window
        # (e.g. while a script creates windows) would rename the wrong tab.
        tmux rename-window -t $TMUX_PANE "$argv[1]@"(basename (pwd))
    end
end

function tmux_rename_window --on-event fish_prompt
    # At the prompt, fish is the running command
    __tmux_set_window_name fish
end

function tmux_rename_preexec --on-event fish_preexec
    # $argv[1] is the command line about to run; use its first word
    set -l cmd (string split ' ' -- $argv[1])[1]
    __tmux_set_window_name (basename $cmd)
end
