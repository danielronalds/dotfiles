#!/usr/bin/env bash
# Date:   2026-04-20
# Author: Claude (Opus 4.7)
# Intent: Print the current work week's Google Calendar events as columns,
#         one per workday (Mon-Fri). Rendered inside a tmux popup via the
#         prefix+W binding; companion to next_event.sh in the status bar.

set -euo pipefail

CACHE_PREFIX="/tmp/week_schedule_cache"
CACHE_TTL=300

main() {
    for cmd in gws jq gum; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: required command '$cmd' not found in PATH" >&2
            exit 1
        fi
    done

    local term_width
    term_width=$({ stty size </dev/tty 2>/dev/null | awk '{print $2}' ; } 2>/dev/null) || term_width=""
    if [[ -z "$term_width" || "$term_width" -le 0 ]]; then
        term_width=$(tput cols 2>/dev/null || echo 100)
    fi
    [[ -z "$term_width" || "$term_width" -le 0 ]] && term_width=100

    local dow offset monday_date friday_date
    dow=$(date +%u)
    offset=$((dow - 1))
    monday_date=$(date -v-${offset}d +%Y-%m-%d)
    friday_date=$(date -v-${offset}d -v+4d +%Y-%m-%d)

    local cache_file="${CACHE_PREFIX}_${monday_date}_${term_width}"
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(( $(date +%s) - $(stat -f %m "$cache_file") ))
        if [[ $cache_age -lt $CACHE_TTL ]]; then
            cat "$cache_file"
            return
        fi
    fi

    render_week "$monday_date" "$friday_date" "$offset" "$term_width" | tee "$cache_file"
}

render_week() {
    local monday_date="$1"
    local friday_date="$2"
    local offset="$3"
    local term_width="$4"

    local tz_offset
    tz_offset=$(date +"%z" | sed 's/\(..\)$/:\1/')

    local time_min="${monday_date}T00:00:00${tz_offset}"
    local time_max="${friday_date}T23:59:59${tz_offset}"

    local response
    response=$(gws calendar events list --params "{
        \"calendarId\": \"primary\",
        \"timeMin\": \"${time_min}\",
        \"timeMax\": \"${time_max}\",
        \"orderBy\": \"startTime\",
        \"singleEvents\": true,
        \"maxResults\": 100
    }" 2>/dev/null)

    local budget base remainder
    budget=$((term_width - 20))
    base=$((budget / 5))
    remainder=$((budget % 5))

    local cols=()
    local i day_date heading events content col this_width
    for i in 0 1 2 3 4; do
        if [[ $i -lt $remainder ]]; then
            this_width=$((base + 1))
        else
            this_width=$base
        fi

        day_date=$(date -v-${offset}d -v+${i}d +%Y-%m-%d)
        heading=$(date -jf "%Y-%m-%d" "$day_date" "+%A %-d %b")
        events=$(format_events_for_day "$response" "$day_date")

        content=$(printf '%s\n\n%s' "$(gum style --bold --underline "$heading")" "$events")
        col=$(gum style --border rounded --width "$this_width" --padding "0 2" --margin "0 1" -- "$content")
        cols+=("$col")
    done

    gum join --horizontal --align top "${cols[@]}"
}

format_events_for_day() {
    local response="$1"
    local day_date="$2"

    local events
    events=$(echo "$response" | jq -r --arg d "$day_date" '
        .items[]?
        | select(((.start.dateTime // .start.date) | startswith($d)))
        | "\(.start.dateTime // .start.date)|\(.end.dateTime // .end.date // "")|\(.summary // "(untitled)")"
    ')

    if [[ -z "$events" ]]; then
        echo "(nothing scheduled)"
        return
    fi

    local start end summary time duration out=""
    while IFS='|' read -r start end summary; do
        if [[ "$start" == *"T"* ]]; then
            time=$(date -jf "%Y-%m-%dT%H:%M:%S%z" "${start%:*}${start##*:}" "+%-l:%M %p" 2>/dev/null)
            duration=$(event_duration "$start" "$end")
            out+="${time}  ${summary} (${duration})"$'\n'
        else
            out+="All day  ${summary}"$'\n'
        fi
    done <<< "$events"

    printf '%s' "${out%$'\n'}"
}

event_duration() {
    local start="$1"
    local end="$2"

    local start_epoch end_epoch
    start_epoch=$(date -jf "%Y-%m-%dT%H:%M:%S%z" "${start%:*}${start##*:}" "+%s" 2>/dev/null)
    end_epoch=$(date -jf "%Y-%m-%dT%H:%M:%S%z" "${end%:*}${end##*:}" "+%s" 2>/dev/null)

    if [[ -z "$start_epoch" || -z "$end_epoch" ]]; then
        echo "?"
        return
    fi

    local seconds=$((end_epoch - start_epoch))
    local hours=$((seconds / 3600))
    local minutes=$(( (seconds % 3600) / 60 ))

    if [[ $hours -gt 0 && $minutes -gt 0 ]]; then
        echo "${hours}h${minutes}m"
    elif [[ $hours -gt 0 ]]; then
        echo "${hours}h"
    else
        echo "${minutes}m"
    fi
}

main "$@"
