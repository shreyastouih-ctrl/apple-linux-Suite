#!/usr/bin/env bash
# Universal Mobile Phone & Tablet Sync (KDE Connect / GSConnect / LocalSend)
# Part of Apple-Linux-Suite (Universal Mobile & Tablet Extension)

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

echo -e "${BOLD}${CYAN}"
echo "================================================================="
echo "   📲 UNIVERSAL PHONE & TABLET SYNC (KDE CONNECT & LOCALSEND) 🔗"
echo "================================================================="
echo -e "${RESET}"

if [ -f /etc/os-release ]; then . /etc/os-release; fi

echo -e "${GREEN}Installing KDE Connect / GSConnect integration for all devices...${RESET}"
case "${ID:-debian}" in
    ubuntu|debian|pop|linuxmint|elementary)
        sudo apt update && sudo apt install -y kdeconnect || true
        ;;
    arch|manjaro|endeavouros)
        sudo pacman -Sy --needed --noconfirm kdeconnect || true
        ;;
    fedora|nobara)
        sudo dnf install -y kdeconnect || true
        ;;
    opensuse*)
        sudo zypper install -y kdeconnect-kde || true
        ;;
esac

echo -e "\n${BOLD}KDE Connect Features Available for iPhone, iPad & Android:${RESET}"
echo -e " • ${GREEN}Shared Clipboard${RESET}: Copy text on phone, paste instantly on Linux."
echo -e " • ${GREEN}Notification Sync${RESET}: See incoming phone calls & app alerts on desktop."
echo -e " • ${GREEN}Ring Phone${RESET}: Find your misplaced phone by ringing it from desktop."
echo -e " • ${GREEN}Remote Control${RESET}: Use phone screen as a trackpad/keyboard for Linux."

echo -e "\n${GREEN}Launching KDE Connect Indicator...${RESET}"
kdeconnect-indicator &>/dev/null & disown || kdeconnect-app &>/dev/null & disown || true

echo -e "${BOLD}${GREEN}KDE Connect launched! Download the 'KDE Connect' app on your iPhone, iPad, or Android device to pair.${RESET}"
