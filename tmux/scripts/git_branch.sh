#!/usr/bin/env bash

main() {
    local current_path=$(tmux display-message -p '#{pane_current_path}')
    local branch=$(git -C "$current_path" rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [[ -z "$branch" ]]; then
        return
    fi

    echo -n " $branch"
}

main
