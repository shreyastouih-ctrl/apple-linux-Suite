#!/usr/bin/env bash
# FaceTime HD Camera Firmware Extractor & Kernel Driver Setup for Intel Macs
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}[FaceTime HD Camera Setup] Initializing...${RESET}"

# Check if FaceTime HD camera PCIe device exists
if ! lspci | grep -iq "Broadcom.*FaceTime HD"; then
    echo -e "${YELLOW}Warning: Broadcom FaceTime HD PCIe camera not detected in lspci.${RESET}"
    echo -e "If your Mac uses standard UVC USB camera, no driver installation is required."
    read -p "Do you still want to proceed with FaceTime HD driver build? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Install dependencies based on package manager
if [ -f /etc/os-release ]; then
    . /etc/os-release
fi

echo -e "${GREEN}Installing build prerequisites...${RESET}"
case "${ID:-debian}" in
    ubuntu|debian|pop|linuxmint)
        sudo apt update
        sudo apt install -y git build-essential dkms cpio curl kmod xz-utils libssl-dev linux-headers-$(uname -r)
        ;;
    arch|manjaro|endeavouros)
        sudo pacman -Sy --needed --noconfirm git base-devel dkms cpio curl linux-headers
        ;;
    fedora|nobara)
        sudo dnf install -y git gcc make dkms cpio curl kernel-devel
        ;;
    opensuse*)
        sudo zypper install -y git gcc make dkms cpio curl kernel-default-devel
        ;;
    *)
        echo -e "${YELLOW}Please ensure git, gcc, make, dkms, cpio, and kernel headers are installed.${RESET}"
        ;;
esac

WORKDIR="/tmp/facetimehd_build"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo -e "${GREEN}1. Downloading & extracting FaceTime HD Camera Firmware...${RESET}"
if [ ! -d "facetimehd-firmware" ]; then
    git clone https://github.com/patjak/facetimehd-firmware.git
fi
cd facetimehd-firmware
make
sudo make install
cd ..

echo -e "${GREEN}2. Downloading & building FaceTime HD Kernel Module (bcwc_pcie)...${RESET}"
if [ ! -d "bcwc_pcie" ]; then
    git clone https://github.com/patjak/bcwc_pcie.git
fi
cd bcwc_pcie
make
sudo make install
sudo depmod -a
sudo modprobe facetimehd

echo -e "${BOLD}${GREEN}FaceTime HD Camera driver installed and loaded!${RESET}"
echo -e "You can test the camera using cheese, vlc, or mpv (mpv /dev/video0)."
