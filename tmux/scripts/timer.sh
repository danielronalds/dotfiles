#!/usr/bin/env bash

TIMER_OPTION="@timer_end"

main() {
    local subcommand="$1"
    shift

    case "$subcommand" in
        display) display_timer ;;
        set) set_timer "$@" ;;
        *) return 1 ;;
    esac
}

display_timer() {
    local end
    end=$(tmux show-option -gqv "$TIMER_OPTION")

    if [[ -z "$end" ]]; then
        return
    fi

    local now=$(date +%s)
    local remaining=$(( end - now ))

    if (( remaining <= 0 )); then
        fire_expiry
        tmux set -g "$TIMER_OPTION" ""
        return
    fi

    printf ' %s ' "$(format_remaining "$remaining")"
}

set_timer() {
    local input="$1"

    if [[ -z "$input" || "$input" == "cancel" || "$input" == "clear" ]]; then
        tmux set -g "$TIMER_OPTION" ""
        tmux refresh-client -S
        return
    fi

    local existing
    existing=$(tmux show-option -gqv "$TIMER_OPTION")
    if [[ -n "$existing" ]] && (( existing > $(date +%s) )); then
        tmux display-message "Timer already running, cancel first"
        return
    fi

    local seconds
    if ! seconds=$(parse_duration "$input"); then
        tmux display-message "Invalid duration: $input"
        return
    fi

    local end=$(( $(date +%s) + seconds ))
    tmux set -g "$TIMER_OPTION" "$end"
    tmux refresh-client -S
}

parse_duration() {
    local input="$1"

    if [[ ! "$input" =~ ^([0-9]+h)?([0-9]+m)?([0-9]+s)?$ ]]; then
        return 1
    fi

    local hours="${BASH_REMATCH[1]%h}"
    local minutes="${BASH_REMATCH[2]%m}"
    local seconds="${BASH_REMATCH[3]%s}"

    if [[ -z "$hours" && -z "$minutes" && -z "$seconds" ]]; then
        return 1
    fi

    echo $(( ${hours:-0} * 3600 + ${minutes:-0} * 60 + ${seconds:-0} ))
}

format_remaining() {
    local total=$1

    if (( total >= 3600 )); then
        printf '%d:%02d:%02d' $(( total / 3600 )) $(( total % 3600 / 60 )) $(( total % 60 ))
    else
        printf '%d:%02d' $(( total / 60 )) $(( total % 60 ))
    fi
}

fire_expiry() {
    tmux display-message -d 3000 "Timer done"

    printf '\a' >/dev/tty 2>/dev/null

    if command -v terminal-notifier &>/dev/null; then
        terminal-notifier -title "tmux" -message "Timer done" -sound default &>/dev/null
    elif command -v osascript &>/dev/null; then
        osascript -e 'display notification "Timer done" with title "tmux"' &>/dev/null
    fi
}

main "$@"
