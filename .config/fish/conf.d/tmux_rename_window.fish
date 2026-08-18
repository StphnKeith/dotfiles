# Rename the tmux window on each prompt / command, controlled entirely by
# fish so that programs emitting terminal-title escapes (claude, etc.) can't
# override it. Requires automatic-rename/allow-rename off in tmux.conf.

function __tmux_set_window_name
    if set -q TMUX
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
