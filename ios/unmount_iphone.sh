#!/usr/bin/env bash
# Safely Unmount iOS Device Mountpoint
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

MOUNT_DIR="${1:-$HOME/iPhone}"

echo -e "${BOLD}${GREEN}[iOS Unmount Utility] Unmounting $MOUNT_DIR...${RESET}"

if mountpoint -q "$MOUNT_DIR"; then
    if fusermount -u "$MOUNT_DIR" 2>/dev/null || sudo umount "$MOUNT_DIR" 2>/dev/null; then
        echo -e "${BOLD}${GREEN}Successfully unmounted $MOUNT_DIR.${RESET}"
    else
        echo -e "${YELLOW}Failed to unmount cleanly. Forcing unmount...${RESET}"
        fusermount -z -u "$MOUNT_DIR" 2>/dev/null || true
    fi
else
    echo -e "${YELLOW}$MOUNT_DIR is not currently mounted.${RESET}"
fi
