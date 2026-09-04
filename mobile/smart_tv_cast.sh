#!/usr/bin/env bash
# Smart TV, Apple TV, Chromecast & Streaming Device Media Cast Helper
# Part of Apple-Linux-Suite (Universal Mobile & Tablet Extension)

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

echo -e "${BOLD}${CYAN}"
echo "================================================================="
echo "   📺 SMART TV, APPLE TV & CHROMECAST MEDIA CASTING HELPER 📡"
echo "================================================================="
echo -e "${RESET}"

if ! command -v pip3 &>/dev/null && ! command -v pip &>/dev/null; then
    echo -e "${YELLOW}Installing python3-pip...${RESET}"
    if [ -f /etc/os-release ]; then . /etc/os-release; fi
    case "${ID:-debian}" in
        ubuntu|debian|pop|linuxmint) sudo apt update && sudo apt install -y python3-pip ;;
        arch|manjaro) sudo pacman -Sy --needed --noconfirm python-pip ;;
        fedora) sudo dnf install -y python3-pip ;;
    esac
fi

echo -e "${GREEN}Installing Cast-All-The-Things (catt) tool for Smart TV / Chromecast casting...${RESET}"
pip3 install catt --user 2>/dev/null || pip install catt 2>/dev/null || true

echo -e "\n${BOLD}Scanning local network for Smart TVs, Apple TV & Chromecast devices...${RESET}"
catt scan 2>/dev/null || true

echo -e "\nTo cast a video or URL to your Smart TV / Chromecast:"
echo -e "  ${YELLOW}catt cast /path/to/video.mp4${RESET}"
echo -e "  ${YELLOW}catt cast https://www.youtube.com/watch?v=XXXXX${RESET}"
