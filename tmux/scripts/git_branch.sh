#!/usr/bin/env bash

main() {
    local current_path=$(tmux display-message -p '#{pane_current_path}')
    local branch=$(git -C "$current_path" rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [[ -z "$branch" ]]; then
        return
    fi

    local show_short=$(tmux show-option -gqv @show_short_status_left)

    if [[ "$show_short" == "1" ]] && [[ ${#branch} -gt 15 ]]; then
        branch="${branch:0:15}..."
    fi

    echo -n " $branch"
}

main
