#!/usr/bin/env bash

CACHE_FILE="/tmp/tmux_next_event_cache"
CACHE_TTL=60

main() {
    if ! command -v gws &>/dev/null || ! command -v jq &>/dev/null; then
        return
    fi

    local time_only=false
    if [[ "$1" == "--time-only" ]]; then
        time_only=true
    elif [[ "$(tmux show-option -gqv @show_next_event_short 2>/dev/null)" == "1" ]]; then
        time_only=true
    fi

    local response=$(fetch_events)

    local name=$(echo "$response" | jq -r '.items[0].summary // empty')

    if [[ -z "$name" ]]; then
        echo -n "  No Meetings "
        return
    fi

    local start_time=$(echo "$response" | jq -r '.items[0].start.dateTime // empty')
    local time=$(date -jf "%Y-%m-%dT%H:%M:%S%z" "${start_time%:*}${start_time##*:}" "+%-l:%M %p" 2>/dev/null)

    if [[ "$time_only" == true ]]; then
        echo -n "  ${time} "
    else
        echo -n "  ${name} - ${time} "
    fi
}

fetch_events() {
    if [[ -f "$CACHE_FILE" ]]; then
        local cache_age=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE") ))
        if [[ $cache_age -lt $CACHE_TTL ]]; then
            cat "$CACHE_FILE"
            return
        fi
    fi

    local tz_offset=$(date +"%z" | sed 's/\(..\)$/:\1/')
    local time_min=$(date +"%Y-%m-%dT%H:%M:%S${tz_offset}")
    local time_max=$(date +"%Y-%m-%dT23:59:59${tz_offset}")

    local response=$(gws calendar events list --params "{
        \"calendarId\": \"primary\",
        \"timeMin\": \"${time_min}\",
        \"timeMax\": \"${time_max}\",
        \"orderBy\": \"startTime\",
        \"singleEvents\": true,
        \"maxResults\": 1
    }" 2>/dev/null)

    echo "$response" > "$CACHE_FILE"
    echo "$response"
}

main "$@"
