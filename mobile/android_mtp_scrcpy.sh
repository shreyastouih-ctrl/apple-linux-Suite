#!/usr/bin/env bash
# Android Phone & Tablet Management, MTP Mount & scrcpy Screen Mirroring
# Part of Apple-Linux-Suite (Universal Mobile & Tablet Extension)

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${CYAN}"
echo "================================================================="
echo "   🤖 ANDROID PHONE & TABLET MANAGER (MTP + SCRCPY) 📱"
echo "================================================================="
echo -e "${RESET}"

if [ -f /etc/os-release ]; then . /etc/os-release; fi

echo -e "${GREEN}Installing Android MTP & scrcpy screen mirroring tools...${RESET}"
case "${ID:-debian}" in
    ubuntu|debian|pop|linuxmint|elementary)
        sudo apt update && sudo apt install -y android-tools-adb android-tools-fastboot scrcpy simple-mtpfs gvfs-backends
        ;;
    arch|manjaro|endeavouros)
        sudo pacman -Sy --needed --noconfirm android-tools scrcpy simple-mtpfs gvfs-mtp
        ;;
    fedora|nobara)
        sudo dnf install -y android-tools scrcpy simple-mtpfs gvfs-mtp
        ;;
    opensuse*)
        sudo zypper install -y android-tools scrcpy gvfs-backend-mtp
        ;;
esac

echo -e "\n${BOLD}Select Android Action:${RESET}"
echo "1) Launch scrcpy (Low-Latency 60fps Android Screen Mirroring & Control)"
echo "2) Mount Android Phone/Tablet Storage via MTP"
echo "3) Unmount MTP Storage"
echo "4) Connect Android Device wirelessly via ADB Wi-Fi"
echo "0) Exit"

read -p "Enter choice [0-4]: " choice

case "$choice" in
    1)
        echo -e "${GREEN}Starting scrcpy screen mirror... Make sure USB Debugging is enabled in Android Developer Options.${RESET}"
        scrcpy --max-size 1920 --stay-awake || true
        ;;
    2)
        MOUNT_DIR="$HOME/Android_Phone"
        mkdir -p "$MOUNT_DIR"
        echo -e "${GREEN}Mounting Android storage to $MOUNT_DIR...${RESET}"
        simple-mtpfs "$MOUNT_DIR" 2>/dev/null || jmtpfs "$MOUNT_DIR" 2>/dev/null || true
        echo -e "${BOLD}${GREEN}Android device mounted at $MOUNT_DIR!${RESET}"
        if command -v xdg-open &>/dev/null && [ -n "$DISPLAY" ]; then
            xdg-open "$MOUNT_DIR" &
        fi
        ;;
    3)
        MOUNT_DIR="$HOME/Android_Phone"
        fusermount -u "$MOUNT_DIR" 2>/dev/null || sudo umount "$MOUNT_DIR" 2>/dev/null || true
        echo -e "${GREEN}Unmounted $MOUNT_DIR.${RESET}"
        ;;
    4)
        read -p "Enter Android Device IP Address (e.g. 192.168.1.50): " ip_addr
        adb connect "$ip_addr:5555"
        scrcpy || true
        ;;
    *)
        exit 0
        ;;
esac
