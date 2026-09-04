#!/usr/bin/env bash
# T2 Security Chip Intel Mac Installer & Fix Helper (2018-2020 Intel Macs)
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}[Apple T2 Mac Assistant] Initializing T2 Mac Configuration...${RESET}"

# Check for Apple T2 Security Chip in lspci / lsusb
if lspci | grep -iq "Apple.*T2\|Apple Security Chip" || lsusb | grep -iq "Apple.*T2"; then
    echo -e "${GREEN}Apple T2 Security Chip detected!${RESET}"
else
    echo -e "${YELLOW}Notice: Apple T2 chip not explicitly found in PCI/USB bus.${RESET}"
    echo -e "T2 Macs include: MacBook Pro (2018-2020), MacBook Air (2018-2020), Mac mini (2018), Mac Pro (2019), iMac Pro (2017)."
fi

echo -e "\n${BOLD}Select T2 Setup Action:${RESET}"
echo "1) Apply Audio Fixes (Cirrus Logic T2 Audio driver & PipeWire topology)"
echo "2) Apply Touch Bar Drivers & Keyboard Backlight (apple-ib-tb)"
echo "3) Configure Kernel Command Line Arguments (NVMe & Power Tweak)"
echo "4) Show full T2 Linux distro installation guide (Fedora/Arch/Ubuntu T2 kernels)"
echo "0) Exit"

read -p "Enter choice [0-4]: " choice

case "$choice" in
    1)
        echo -e "${GREEN}Setting up T2 Audio & PipeWire configuration...${RESET}"
        sudo mkdir -p /etc/pipewire/pipewire.conf.d/
        sudo mkdir -p /usr/share/alsa/ucm2/conf.d/
        echo -e "${GREEN}Downloading Apple T2 ALSA UCM profile...${RESET}"
        sudo curl -fsSL https://raw.githubusercontent.com/t2linux/alsa-ucm-conf/master/ucm2/T2/T2.conf -o /usr/share/alsa/ucm2/conf.d/T2.conf 2>/dev/null || true
        sudo systemctl restart pipewire wireplumber 2>/dev/null || true
        echo -e "${GREEN}T2 Audio rules applied! Reboot recommended.${RESET}"
        ;;
    2)
        echo -e "${GREEN}Installing Touch Bar & Keyboard Backlight utilities...${RESET}"
        if [ -f /etc/os-release ]; then . /etc/os-release; fi
        if [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
            echo -e "${GREEN}Installing apple-ib-driver-git from AUR...${RESET}"
            yay -S --needed --noconfirm apple-ib-driver-git 2>/dev/null || paru -S --needed --noconfirm apple-ib-driver-git 2>/dev/null || true
        else
            echo -e "${YELLOW}Please install apple-ib-tb driver from github.com/t2linux/apple-ib-tb${RESET}"
        fi
        ;;
    3)
        echo -e "${GREEN}Configuring GRUB / Kernel boot parameters for T2 Macs...${RESET}"
        T2_CMDLINE="intel_iommu=on iommu=pt pcie_ports=compat"
        echo -e "${YELLOW}Recommended GRUB parameters for T2 Mac stability:${RESET}"
        echo "  $T2_CMDLINE"
        if [ -f /etc/default/grub ]; then
            echo -e "${GREEN}Updating /etc/default/grub...${RESET}"
            if ! grep -q "intel_iommu=on" /etc/default/grub; then
                sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$T2_CMDLINE /" /etc/default/grub
                echo -e "${GREEN}Running update-grub or grub-mkconfig...${RESET}"
                sudo update-grub 2>/dev/null || sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
            else
                echo -e "${GREEN}Parameters already present in GRUB!${RESET}"
            fi
        fi
        ;;
    4)
        echo -e "${BOLD}${GREEN}=== T2 LINUX DISTRIBUTION GUIDE ===${RESET}"
        echo -e "For full T2 Mac support (Audio, TouchBar, Wi-Fi, Bluetooth, Internal NVMe SSD):"
        echo -e "1. Visit the T2 Linux wiki: ${YELLOW}https://wiki.t2linux.org${RESET}"
        echo -e "2. Use a T2-patched ISO for your preferred distribution:"
        echo -e "   - Arch Linux (T2 ISO): https://wiki.t2linux.org/distributions/arch/installation/"
        echo -e "   - Ubuntu / Linux Mint (T2 Kernel): https://wiki.t2linux.org/distributions/ubuntu/installation/"
        echo -e "   - Fedora (T2 Kernel): https://wiki.t2linux.org/distributions/fedora/installation/"
        ;;
    *)
        exit 0
        ;;
esac
