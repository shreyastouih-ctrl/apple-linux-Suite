#!/usr/bin/env bash
# MacBook Battery Optimization & Power Management Setup
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}[Battery & Power Saver Setup] Initializing TLP power management...${RESET}"

if [ -f /etc/os-release ]; then . /etc/os-release; fi

case "${ID:-debian}" in
    ubuntu|debian|pop|linuxmint)
        sudo apt update && sudo apt install -y tlp tlp-rdw powertop
        ;;
    arch|manjaro|endeavouros)
        sudo pacman -Sy --needed --noconfirm tlp tlp-rdw powertop
        ;;
    fedora|nobara)
        sudo dnf install -y tlp tlp-rdw powertop
        ;;
    opensuse*)
        sudo zypper install -y tlp powertop
        ;;
    *)
        echo -e "${YELLOW}Please install tlp and powertop using your distro's package manager.${RESET}"
        ;;
esac

echo -e "${GREEN}Configuring TLP for Mac battery efficiency...${RESET}"
if command -v tlp &>/dev/null; then
    sudo tlp start
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable tlp
        sudo systemctl restart tlp
    fi
    echo -e "${BOLD}${GREEN}TLP power optimization active! Battery life extended.${RESET}"
fi
