#!/usr/bin/env bash

main() {
    local os_name=$(uname -s)

    case "$os_name" in
        "Darwin")
            mac_battery_percentage
            ;;
        "Linux")
            linux_battery_percentage
            ;;
        *)
            echo "Unsupported OS"
            ;;
    esac

}

mac_battery_percentage() {
    local percentage=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)

    print_percentage $percentage
}

linux_battery_percentage() {
    local battery="/sys/class/power_supply/BAT0"

    local percentage=$(cat "$battery/capacity")

    print_percentage $percentage
}

print_percentage() {
    local percentage=$1
    if [[ $percentage -gt 75 ]]; then
        echo -n " ${percentage}"
    elif [[ $percentage -gt 50 ]]; then
        echo -n " ${percentage}"
    elif [[ $percentage -gt 25 ]]; then
        echo -n " ${percentage}"
    else
        echo -n " ${percentage}"
    fi
}

main
