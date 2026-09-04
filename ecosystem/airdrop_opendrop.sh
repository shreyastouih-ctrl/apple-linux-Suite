#!/usr/bin/env bash
# AirDrop Compatibility & Wireless File Sharing (OpenDrop / LocalSend Setup)
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}[AirDrop & Wireless Ecosystem Setup]${RESET}"
echo "1) OpenDrop (Apple AWDL Protocol AirDrop implementation for Linux)"
echo "2) LocalSend (Cross-Platform AirDrop Alternative for iOS/macOS/Linux)"
echo "0) Exit"

read -p "Select option [0-2]: " choice

case "$choice" in
    1)
        echo -e "${GREEN}Installing OpenDrop prerequisites (Python3, OpenSSL, libarchive)...${RESET}"
        if [ -f /etc/os-release ]; then . /etc/os-release; fi
        case "${ID:-debian}" in
            ubuntu|debian|pop|linuxmint)
                sudo apt update && sudo apt install -y python3-pip python3-dev libarchive-dev libssl-dev
                ;;
            arch|manjaro)
                sudo pacman -Sy --needed --noconfirm python-pip libarchive openssl
                ;;
        esac
        pip3 install opendrop --user 2>/dev/null || pip install opendrop 2>/dev/null || true
        echo -e "${GREEN}OpenDrop installed! Run 'opendrop receive' or 'opendrop find' to share files.${RESET}"
        ;;
    2)
        echo -e "${GREEN}LocalSend recommended for zero-config AirDrop functionality between iOS, Mac, and Linux.${RESET}"
        echo -e "Install LocalSend from Flatpak:"
        echo -e "  ${YELLOW}flatpak install flathub org.localsend.localsend_app${RESET}"
        ;;
    *)
        exit 0
        ;;
esac
