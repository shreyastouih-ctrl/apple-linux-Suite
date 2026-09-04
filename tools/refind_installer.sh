#!/usr/bin/env bash
# rEFInd Dual-Boot Bootloader Installer for Intel Macs & Linux
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}[rEFInd Dual Boot Manager Setup] Initializing...${RESET}"

if [ -f /etc/os-release ]; then . /etc/os-release; fi

case "${ID:-debian}" in
    ubuntu|debian|pop|linuxmint)
        sudo apt update && sudo apt install -y refind
        ;;
    arch|manjaro|endeavouros)
        sudo pacman -Sy --needed --noconfirm refind
        ;;
    fedora|nobara)
        sudo dnf install -y refind
        ;;
    *)
        echo -e "${YELLOW}Please install rEFInd package for your distribution.${RESET}"
        ;;
esac

echo -e "${GREEN}Installing rEFInd to EFI system partition...${RESET}"
if command -v refind-install &>/dev/null; then
    sudo refind-install || true
    echo -e "${BOLD}${GREEN}rEFInd Boot Manager installed successfully!${RESET}"
    echo -e "On reboot, you will see a graphical boot menu to choose between macOS and Linux."
else
    echo -e "${RED}refind-install command not found.${RESET}"
fi
