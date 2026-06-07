#!/bin/bash

print_status() {
    if ! command -v bluetoothctl >/dev/null 2>&1; then
        echo ""; return
    fi
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        if bluetoothctl devices Connected 2>/dev/null | grep -q .; then
            echo "󰂱"
        else
            echo ""
        fi
    else
        echo "󰂲"
    fi
}

print_status
dbus-monitor --system "type='signal',sender='org.bluez'" 2>/dev/null | while read -r line; do
    case "$line" in
        *PropertiesChanged*) print_status ;;
    esac
done
