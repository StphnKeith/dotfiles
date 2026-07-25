function fish_prompt
	# if git rev-parse --is-inside-work-tree >/dev/null 2>&1
	# 	set git_prompt (printf '%s%s%s%s' (set_color normal) '|' (set_color green) (git branch --show-current))
	# else
	# 	set git_prompt ''
	# end
	set -g __fish_git_prompt_color_prefix white
	set -g __fish_git_prompt_color blue
	printf '(%s%s%s) <%s%s%s> [%s%s%s%s]\n> ' (set_color cyan) (date -Iseconds) (set_color normal) (set_color blue) $status (set_color normal) (set_color green) (prompt_pwd --dir-length 0) (fish_git_prompt '|%s') (set_color normal)
end
