#!/usr/bin/env bash
# Thermal & Fan Control Daemon Setup (mbpfan) for Intel Macs
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}[Thermal & Fan Management] Installing mbpfan daemon...${RESET}"

if [ -f /etc/os-release ]; then . /etc/os-release; fi

case "${ID:-debian}" in
    ubuntu|debian|pop|linuxmint)
        sudo apt update && sudo apt install -y mbpfan
        ;;
    arch|manjaro|endeavouros)
        sudo pacman -Sy --needed --noconfirm mbpfan
        ;;
    fedora|nobara)
        sudo dnf install -y mbpfan
        ;;
    opensuse*)
        sudo zypper install -y mbpfan
        ;;
    *)
        echo -e "${YELLOW}Generic distro: Building mbpfan from source...${RESET}"
        git clone https://github.com/dhedlund/mbpfan.bin /tmp/mbpfan_src || true
        cd /tmp/mbpfan_src && make && sudo make install
        ;;
esac

CONF_FILE="/etc/mbpfan.conf"
SOURCE_CONF="$(dirname "$0")/../config/mbpfan.conf"

if [ -f "$SOURCE_CONF" ]; then
    echo -e "${GREEN}Deploying optimized mbpfan configuration...${RESET}"
    sudo cp "$SOURCE_CONF" "$CONF_FILE"
fi

echo -e "${GREEN}Enabling and starting mbpfan systemd service...${RESET}"
if command -v systemctl &>/dev/null; then
    sudo systemctl enable mbpfan
    sudo systemctl restart mbpfan
    echo -e "${GREEN}mbpfan service status:${RESET}"
    sudo systemctl status mbpfan --no-pager || true
fi

echo -e "${BOLD}${GREEN}Thermal management configured successfully!${RESET}"
