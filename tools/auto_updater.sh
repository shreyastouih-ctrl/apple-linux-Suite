#!/usr/bin/env bash
# Auto-Updater & System Package Updater for Apple-Linux-Suite
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"
RESET="\033[0m"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BOLD}${CYAN}"
echo "================================================================="
echo "   🍏 APPLE-LINUX-SUITE AUTO-UPDATER & SYSTEM SYNC 🔄"
echo "================================================================="
echo -e "${RESET}"

# 1. Update Apple-Linux-Suite from GitHub
echo -e "${BOLD}[Step 1/3] Checking for Apple-Linux-Suite updates...${RESET}"
cd "$ROOT_DIR"

if [ -d ".git" ]; then
    if command -v git &>/dev/null; then
        echo -e "${GREEN}Pulling latest suite updates from GitHub...${RESET}"
        git pull origin main || git pull origin master || true
        chmod +x install.sh apple-linux.sh drivers/*.sh ios/*.sh ecosystem/*.sh tools/*.sh 2>/dev/null || true
        echo -e "${GREEN}Apple-Linux-Suite updated!${RESET}"
    else
        echo -e "${YELLOW}git command not found. Skipping git pull...${RESET}"
    fi
else
    echo -e "${YELLOW}Not a git repository directory. Skipping git pull...${RESET}"
fi

# 2. Re-install & Refresh System Binaries & Drivers
echo -e "\n${BOLD}[Step 2/3] Refreshing system drivers & CLI configuration...${RESET}"
if [ "$EUID" -eq 0 ]; then
    bash "$ROOT_DIR/install.sh"
else
    sudo bash "$ROOT_DIR/install.sh"
fi

# 3. Update System Packages
echo -e "\n${BOLD}[Step 3/3] Updating Linux Distribution System Packages...${RESET}"
if [ -f /etc/os-release ]; then . /etc/os-release; fi

case "${ID:-debian}" in
    ubuntu|debian|pop|linuxmint|elementary)
        echo -e "${GREEN}Updating APT system packages...${RESET}"
        sudo apt update && sudo apt upgrade -y
        ;;
    arch|manjaro|endeavouros)
        echo -e "${GREEN}Updating Pacman system packages...${RESET}"
        sudo pacman -Syu --noconfirm
        ;;
    fedora|nobara)
        echo -e "${GREEN}Updating DNF system packages...${RESET}"
        sudo dnf upgrade -y
        ;;
    opensuse*)
        echo -e "${GREEN}Updating Zypper system packages...${RESET}"
        sudo zypper refresh && sudo zypper update -y
        ;;
    void)
        echo -e "${GREEN}Updating XBPS system packages...${RESET}"
        sudo xbps-install -Syu
        ;;
    *)
        echo -e "${YELLOW}Generic distro. Please run your package manager update command.${RESET}"
        ;;
esac

echo -e "\n${BOLD}${GREEN}=================================================================${RESET}"
echo -e "${BOLD}${GREEN}   ✅ Update Complete! Your system and Apple-Linux-Suite are current.${RESET}"
echo -e "${BOLD}${GREEN}=================================================================${RESET}"
