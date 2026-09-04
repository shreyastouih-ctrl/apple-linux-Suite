#!/usr/bin/env bash
# Universal Apple Product & Hardware Inspector Tool
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${CYAN}"
echo "================================================================="
echo "   🍏 UNIVERSAL APPLE PRODUCT & HARDWARE INSPECTOR 🐧"
echo "================================================================="
echo -e "${RESET}"

# 1. Inspect Host Mac Computer
ARCH=$(uname -m 2>/dev/null || echo "x86_64")
CPU_INFO=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d':' -f2 | xargs || echo "Generic CPU")

if [ -f /proc/meminfo ]; then
    RAM_MB=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')
else
    RAM_MB=8192
fi

MAC_MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Mac Hardware")
MAC_VENDOR=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo "Apple Inc.")

T2_PRESENT=false
if lspci 2>/dev/null | grep -iq "Apple.*T2\|Apple Security Chip" || lsusb 2>/dev/null | grep -iq "Apple.*T2"; then
    T2_PRESENT=true
fi

GPUS=$(lspci 2>/dev/null | grep -i -E 'VGA|3D|Display' || echo "Integrated Graphics")

echo -e "${BOLD}1. Host Mac Computer Specs:${RESET}"
echo -e "   • Model: ${YELLOW}$MAC_VENDOR $MAC_MODEL${RESET}"
echo -e "   • Architecture: ${YELLOW}$ARCH${RESET}"
echo -e "   • CPU: ${YELLOW}$CPU_INFO${RESET}"
echo -e "   • Memory: ${YELLOW}${RAM_MB} MB RAM${RESET}"
echo -e "   • T2 Security Chip: ${YELLOW}$([ "$T2_PRESENT" = true ] && echo 'Yes (2018-2020 Mac)' || echo 'No')${RESET}"

# 2. Inspect Connected iOS & Apple Mobile Products
echo -e "\n${BOLD}2. Connected iOS / Mobile Apple Products:${RESET}"
if command -v ideviceinfo &>/dev/null; then
    if ideviceinfo 2>/dev/null | grep -q "DeviceName"; then
        DEV_NAME=$(ideviceinfo 2>/dev/null | grep "DeviceName" | cut -d' ' -f2-)
        DEV_TYPE=$(ideviceinfo 2>/dev/null | grep "ProductType" | cut -d' ' -f2-)
        DEV_VER=$(ideviceinfo 2>/dev/null | grep "ProductVersion" | cut -d' ' -f2-)
        echo -e "   • Device: ${GREEN}$DEV_NAME ($DEV_TYPE, iOS $DEV_VER)${RESET}"
        echo -e "   • Mounting Status: Ready (Run: ./ios/mount_iphone.sh)"
    else
        echo -e "   • Status: ${YELLOW}USB device connected, waiting for trust pairing (Run: ./ios/pair_device.sh)${RESET}"
    fi
else
    USB_APPLE=$(lsusb 2>/dev/null | grep -i "Apple" || true)
    if [ -n "$USB_APPLE" ]; then
        echo -e "   • USB Bus: ${YELLOW}$USB_APPLE${RESET}"
    else
        echo -e "   • Status: No iOS device currently plugged in via USB."
    fi
fi

# 3. Inspect Apple Bluetooth Accessories (AirPods, Magic Mouse, Trackpad, Keyboard)
echo -e "\n${BOLD}3. Apple Bluetooth Accessories:${RESET}"
BT_DEVS=$(bluetoothctl devices 2>/dev/null | grep -i "Apple\|AirPods\|Beats\|Magic" || true)
if [ -n "$BT_DEVS" ]; then
    echo -e "   • Paired Accessories:\n${GREEN}$BT_DEVS${RESET}"
else
    echo -e "   • Status: No Apple Bluetooth accessories currently paired."
fi

# 4. OS Recommendations
echo -e "\n${BOLD}${CYAN}=================================================================${RESET}"
echo -e "${BOLD}${GREEN}🎯 RECOMMENDED LINUX OS FOR YOUR APPLE HARDWARE:${RESET}"
echo -e "${BOLD}${CYAN}=================================================================${RESET}\n"

if [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
    echo -e "🏆 ${BOLD}TOP RECOMMENDATION: Asahi Linux / Fedora Asahi Remix${RESET}"
    echo -e "   • Reason: Your Mac uses an Apple Silicon M1/M2/M3/M4 ARM chip."
    echo -e "   • Website: https://asahilinux.org"

elif [ "$T2_PRESENT" = true ]; then
    echo -e "🏆 ${BOLD}TOP RECOMMENDATION: Fedora T2 Linux / Ubuntu T2 Linux${RESET}"
    echo -e "   • Reason: Your Mac has an Apple T2 Security Chip (2018-2020 model)."
    echo -e "   • Website: https://wiki.t2linux.org"

elif [ "$RAM_MB" -lt 4000 ]; then
    echo -e "🏆 ${BOLD}TOP RECOMMENDATION: Linux Mint XFCE / Zorin OS Lite / Debian 12${RESET}"
    echo -e "   • Reason: Older Intel Mac with < 4GB RAM."

elif echo "$GPUS" | grep -iq "NVIDIA"; then
    echo -e "🏆 ${BOLD}TOP RECOMMENDATION: Pop!_OS (NVIDIA Edition)${RESET}"
    echo -e "   • Reason: Dual-GPU Mac with discrete NVIDIA graphics."

else
    echo -e "🏆 ${BOLD}TOP RECOMMENDATION: Linux Mint Cinnamon / Ubuntu 24.04 LTS${RESET}"
    echo -e "   • Reason: Standard Intel Mac (2012–2017 MacBook Air / Pro / iMac / Mac mini)."
fi

echo -e "\n${BOLD}${CYAN}=================================================================${RESET}"
