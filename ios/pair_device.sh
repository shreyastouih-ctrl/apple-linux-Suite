#!/usr/bin/env bash
# iOS / iPadOS Device Pairing & Trust Assistant
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BOLD}${GREEN}[iOS Device Pairing Tool] Searching for connected iPhone/iPad...${RESET}"

if ! command -v usbmuxd &>/dev/null; then
    echo -e "${RED}usbmuxd is not installed. Please run: sudo $SCRIPT_DIR/../install.sh${RESET}"
    exit 1
fi

# Ensure usbmuxd daemon is running
if command -v systemctl &>/dev/null; then
    sudo systemctl start usbmuxd 2>/dev/null || true
fi

echo -e "${YELLOW}Please connect your iPhone / iPad / iPod via USB cable.${RESET}"
echo -e "${YELLOW}Unlock the screen of your Apple device and accept 'Trust This Computer' when prompted.${RESET}"

echo -n "Checking device status..."
for i in {1..10}; do
    if ideviceinfo > /dev/null 2>&1; then
        echo -e "\n${GREEN}Device detected!${RESET}"
        break
    fi
    echo -n "."
    sleep 1
done

echo -e "\n${GREEN}Attempting pairing with device...${RESET}"
if idevicepair pair; then
    echo -e "${BOLD}${GREEN}Successfully paired with iOS device!${RESET}"
    echo -e "Device Details:"
    ideviceinfo | grep -E "DeviceName|ProductType|ProductVersion|SerialNumber|UniqueDeviceID" || true
else
    echo -e "${RED}Pairing failed.${RESET}"
    echo -e "Make sure:"
    echo " 1) Screen is unlocked on iPhone/iPad"
    echo " 2) You tapped 'Trust' on the device prompt"
    echo " 3) Original USB Lightning/USB-C cable is connected"
fi
