#!/usr/bin/env bash
# Apple-Linux-Suite Uninstaller

set -e

BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${RED}[Apple-Linux-Suite Uninstaller]${RESET}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root or with sudo: sudo ./uninstall.sh${RESET}"
    exit 1
fi

rm -f /usr/local/bin/apple-linux
rm -f /etc/udev/rules.d/99-apple-devices.rules
rm -f /etc/modprobe.d/hid_apple.conf
rm -f /etc/modprobe.d/alsa-apple-audio.conf

if command -v udevadm &>/dev/null; then
    udevadm control --reload-rules 2>/dev/null || true
fi

echo -e "${BOLD}${GREEN}Apple-Linux-Suite configuration and CLI removed successfully!${RESET}"
