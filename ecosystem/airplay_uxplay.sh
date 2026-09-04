#!/usr/bin/env bash
# AirPlay Screen Mirroring & Audio Receiver Setup (UxPlay)
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}[AirPlay UxPlay Receiver] Initializing...${RESET}"

if ! command -v uxplay &>/dev/null; then
    echo -e "${YELLOW}UxPlay is not installed. Installing dependencies...${RESET}"
    if [ -f /etc/os-release ]; then . /etc/os-release; fi
    case "${ID:-debian}" in
        ubuntu|debian|pop|linuxmint)
            sudo apt update && sudo apt install -y uxplay gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav libavahi-compat-libdnssd-dev
            ;;
        arch|manjaro|endeavouros)
            sudo pacman -Sy --needed --noconfirm uxplay gstreamer gst-plugins-bad gst-plugins-ugly gst-libav
            ;;
        fedora|nobara)
            sudo dnf install -y uxplay gstreamer1-plugins-bad-free gstreamer1-plugin-openh264
            ;;
        *)
            echo -e "${YELLOW}Please install UxPlay using your distribution's package manager.${RESET}"
            ;;
    esac
fi

# Ensure Avahi (mDNS/Bonjour) service is running for network discovery
if command -v systemctl &>/dev/null; then
    sudo systemctl start avahi-daemon 2>/dev/null || true
fi

SERVER_NAME="Linux-MacBook-AirPlay"

echo -e "${BOLD}${GREEN}Starting AirPlay Receiver as '$SERVER_NAME'...${RESET}"
echo -e "${YELLOW}On your iPhone, iPad, or Mac, open Control Center -> Screen Mirroring -> Select '$SERVER_NAME'${RESET}"
echo -e "Press Ctrl+C to stop the AirPlay server."

uxplay -n "$SERVER_NAME" -p
