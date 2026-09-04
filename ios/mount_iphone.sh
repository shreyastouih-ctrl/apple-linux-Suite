#!/usr/bin/env bash
# One-Click iPhone / iPad Native Mount for Linux File Managers
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOUNT_DIR="${1:-$HOME/iPhone}"

echo -e "${BOLD}${GREEN}[iOS Mount Utility] Mounting iPhone/iPad at: $MOUNT_DIR${RESET}"

if ! command -v ifuse &>/dev/null; then
    echo -e "${RED}ifuse is not installed. Please run: sudo $SCRIPT_DIR/../install.sh${RESET}"
    exit 1
fi

mkdir -p "$MOUNT_DIR"

if mountpoint -q "$MOUNT_DIR"; then
    echo -e "${YELLOW}$MOUNT_DIR is already mounted!${RESET}"
    exit 0
fi

# Check pairing
if ! idevicepair validate > /dev/null 2>&1; then
    echo -e "${YELLOW}Device is not paired or trusted yet. Attempting pairing...${RESET}"
    bash "$SCRIPT_DIR/pair_device.sh"
fi

echo -e "${GREEN}Mounting iOS filesystem...${RESET}"
if ifuse "$MOUNT_DIR"; then
    echo -e "${BOLD}${GREEN}Successfully mounted iOS device!${RESET}"
    echo -e "You can now open ${YELLOW}$MOUNT_DIR${RESET} in Nautilus, Dolphin, Thunar, or terminal."
    
    # Try opening file manager if available
    if command -v xdg-open &>/dev/null && [ -n "$DISPLAY" ]; then
        xdg-open "$MOUNT_DIR" &
    fi
else
    echo -e "${RED}Failed to mount iOS device.${RESET}"
    echo "Common fixes:"
    echo " 1) Re-plug USB cable and unlock device screen."
    echo " 2) Run: idevicepair pair"
fi
