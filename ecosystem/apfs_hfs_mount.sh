#!/usr/bin/env bash
# macOS APFS & HFS+ File System Mounter for Linux
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

PARTITION="$1"
MOUNT_POINT="${2:-/mnt/mac_drive}"

if [ -z "$PARTITION" ]; then
    echo -e "${BOLD}${GREEN}[macOS Drive Mounter]${RESET}"
    echo -e "Usage: sudo $0 /dev/sdXn [mount_point]"
    echo ""
    echo -e "Available macOS Partitions:"
    sudo lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT | grep -i -E 'apfs|hfs' || true
    exit 1
fi

sudo mkdir -p "$MOUNT_POINT"

echo -e "${GREEN}Detecting filesystem type for $PARTITION...${RESET}"
FSTYPE=$(sudo blkid -s TYPE -o value "$PARTITION" 2>/dev/null || true)

if [ "$FSTYPE" == "apfs" ] || [[ "$PARTITION" == *"apfs"* ]]; then
    echo -e "${GREEN}Mounting APFS drive using apfs-fuse...${RESET}"
    if ! command -v apfs-fuse &>/dev/null; then
        echo -e "${YELLOW}apfs-fuse not found. Installing...${RESET}"
        if [ -f /etc/os-release ]; then . /etc/os-release; fi
        case "${ID:-debian}" in
            ubuntu|debian|pop|linuxmint)
                sudo apt update && sudo apt install -y apfs-fuse apfs-util
                ;;
            arch|manjaro)
                sudo pacman -Sy --needed --noconfirm apfs-fuse-git 2>/dev/null || yay -S apfs-fuse-git || true
                ;;
        esac
    fi
    sudo apfs-fuse -o allow_other "$PARTITION" "$MOUNT_POINT"
    echo -e "${BOLD}${GREEN}APFS partition mounted at $MOUNT_POINT (Read-Only)${RESET}"

elif [ "$FSTYPE" == "hfsplus" ] || [ "$FSTYPE" == "hfs" ]; then
    echo -e "${GREEN}Mounting HFS+ drive with read/write support...${RESET}"
    if [ -f /etc/os-release ]; then . /etc/os-release; fi
    case "${ID:-debian}" in
        ubuntu|debian|pop|linuxmint)
            sudo apt update && sudo apt install -y hfsprogs hfsplus
            ;;
        arch|manjaro)
            sudo pacman -Sy --needed --noconfirm hfsutils
            ;;
    esac
    sudo mount -t hfsplus -o force,rw "$PARTITION" "$MOUNT_POINT" || sudo mount -t hfsplus "$PARTITION" "$MOUNT_POINT"
    echo -e "${BOLD}${GREEN}HFS+ partition mounted at $MOUNT_POINT${RESET}"
else
    echo -e "${YELLOW}Attempting auto mount...${RESET}"
    sudo mount "$PARTITION" "$MOUNT_POINT"
    echo -e "${BOLD}${GREEN}Mounted $PARTITION at $MOUNT_POINT${RESET}"
fi
