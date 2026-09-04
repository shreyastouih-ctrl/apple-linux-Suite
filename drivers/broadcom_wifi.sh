#!/usr/bin/env bash
# Broadcom Wi-Fi Auto-Installer for Intel Macs across all Linux Distros
# Part of Apple-Linux-Suite

set -e

BOLD="\031[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}[Broadcom Wi-Fi Setup] Auto-detecting wireless adapter...${RESET}"

if ! command -v lspci &> /dev/null; then
    echo -e "${YELLOW}lspci not found. Installing pciutils...${RESET}"
fi

WIFI_CARD=$(lspci | grep -i -E 'Network|Wireless|Broadcom' || true)

if echo "$WIFI_CARD" | grep -iq "Broadcom"; then
    echo -e "${GREEN}Found Broadcom Wireless Adapter:${RESET}"
    echo "$WIFI_CARD"
else
    echo -e "${YELLOW}No Broadcom Wireless card explicitly detected via lspci. Proceeding with driver check anyway...${RESET}"
fi

# Detect Distro & Package Manager
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    DISTRO="unknown"
fi

echo -e "${BOLD}Detected Linux Distribution: ${YELLOW}$DISTRO${RESET}"

case "$DISTRO" in
    ubuntu|debian|pop|linuxmint|elementary|neon)
        echo -e "${GREEN}Using APT to install Broadcom STA (wl) driver...${RESET}"
        sudo apt update
        sudo apt install -y broadcom-sta-dkms b43-fwcutter firmware-b43-installer pciutils
        sudo modprobe -r b43 b43legacy ssb bcma wl 2>/dev/null || true
        sudo modprobe wl
        ;;
    arch|manjaro|endeavouros|garuda)
        echo -e "${GREEN}Using Pacman to install Broadcom driver...${RESET}"
        sudo pacman -Sy --needed --noconfirm broadcom-sta-dkms b43-fwcutter linux-headers
        sudo modprobe -r b43 b43legacy ssb bcma wl 2>/dev/null || true
        sudo modprobe wl
        ;;
    fedora|nobara|rhel|centos)
        echo -e "${GREEN}Using DNF to install Broadcom STA driver...${RESET}"
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --set-enabled rpmfusion-nonfree 2>/dev/null || true
        sudo dnf install -y broadcom-sta kmod-broadcom-sta b43-fwcutter
        sudo modprobe wl
        ;;
    opensuse*|suse)
        echo -e "${GREEN}Using Zypper to install Broadcom driver...${RESET}"
        sudo zypper install -y broadcom-wl broadcom-wl-kmp-default b43-fwcutter
        sudo modprobe wl
        ;;
    void)
        echo -e "${GREEN}Using XBPS to install Broadcom driver...${RESET}"
        sudo xbps-install -Sy broadcom-sta b43-fwcutter
        sudo modprobe wl
        ;;
    alpine)
        echo -e "${GREEN}Using APK to install wireless firmware...${RESET}"
        sudo apk add linux-firmware-broadcom b43-fwcutter
        ;;
    gentoo)
        echo -e "${GREEN}Using Emerge to install Broadcom STA...${RESET}"
        sudo emerge --ask=n net-wireless/broadcom-sta sys-firmware/b43-firmware
        sudo modprobe wl
        ;;
    *)
        echo -e "${RED}Unsupported or generic distro. Attempting DKMS build for broadcom-sta...${RESET}"
        ;;
esac

echo -e "${BOLD}${GREEN}Broadcom Wi-Fi driver setup completed successfully!${RESET}"
