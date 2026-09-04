#!/usr/bin/env bash
# Hardware Diagnostic & Auto-Fix Scanner for Linux on Mac
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
echo "   🍏 APPLE-LINUX HARDWARE DIAGNOSTIC & AUTO-FIX REPORT 🐧"
echo "================================================================="
echo -e "${RESET}"

# 1. Mac Model Identification
MAC_MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Generic Hardware")
MAC_VENDOR=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo "Unknown Vendor")

echo -e "${BOLD}1. System & Architecture:${RESET}"
echo -e "   Model: ${YELLOW}$MAC_VENDOR $MAC_MODEL${RESET}"
echo -e "   Kernel: $(uname -r) ($(uname -m))"

if [ "$(uname -m)" == "aarch64" ]; then
    echo -e "   ${YELLOW}Apple Silicon ARM64 detected! (Use Asahi Linux for M1/M2/M3/M4 Macs).${RESET}"
else
    echo -e "   ${GREEN}Intel x86_64 Mac detected.${RESET}"
fi

# 2. Wi-Fi Check
echo -e "\n${BOLD}2. Wireless Adapter (Wi-Fi):${RESET}"
WIFI_DEV=$(lspci 2>/dev/null | grep -i -E 'Network|Wireless|Broadcom' || true)
if [ -n "$WIFI_DEV" ]; then
    echo -e "   Device: $WIFI_DEV"
    if lsmod | grep -q -E 'wl|b43|brcmfmac'; then
        echo -e "   Driver Status: ${GREEN}Active ($(lsmod | grep -o -E 'wl|b43|brcmfmac' | head -n 1))${RESET}"
    else
        echo -e "   Driver Status: ${RED}Missing driver! Run: sudo $ROOT_DIR/drivers/broadcom_wifi.sh${RESET}"
    fi
else
    echo -e "   Status: ${YELLOW}No Broadcom Wireless card found in PCI listing.${RESET}"
fi

# 3. Camera Check
echo -e "\n${BOLD}3. FaceTime HD Camera:${RESET}"
CAM_DEV=$(lspci 2>/dev/null | grep -i 'FaceTime HD' || true)
if [ -n "$CAM_DEV" ]; then
    echo -e "   Device: $CAM_DEV"
    if lsmod | grep -q 'facetimehd'; then
        echo -e "   Driver Status: ${GREEN}Active (facetimehd driver loaded)${RESET}"
    else
        echo -e "   Driver Status: ${RED}Missing driver! Run: sudo $ROOT_DIR/drivers/facetime_hd_camera.sh${RESET}"
    fi
else
    echo -e "   Status: ${GREEN}Standard UVC USB Webcam or Camera not on PCIe bus.${RESET}"
fi

# 4. T2 Security Chip Check
echo -e "\n${BOLD}4. Apple T2 Security Chip:${RESET}"
if lspci 2>/dev/null | grep -iq "Apple.*T2\|Apple Security Chip" || lsusb 2>/dev/null | grep -iq "Apple.*T2"; then
    echo -e "   T2 Chip: ${YELLOW}Detected (MacBook Pro/Air 2018-2020 or Mac mini 2018)${RESET}"
    echo -e "   T2 Tweaks: Run: sudo $ROOT_DIR/drivers/t2_mac_setup.sh"
else
    echo -e "   T2 Chip: ${GREEN}Not present / Pre-2018 Mac${RESET}"
fi

# 5. Audio Codec Check
echo -e "\n${BOLD}5. Audio Subsystem:${RESET}"
if lsmod | grep -q 'snd_hda_intel'; then
    echo -e "   Audio Driver: ${GREEN}snd_hda_intel active${RESET}"
else
    echo -e "   Audio Driver: ${YELLOW}Check Cirrus Logic codec fix: sudo $ROOT_DIR/drivers/cirrus_audio.sh${RESET}"
fi

# 6. Fan Control (mbpfan)
echo -e "\n${BOLD}6. Thermal Fan Daemon (mbpfan):${RESET}"
if systemctl is-active --quiet mbpfan 2>/dev/null; then
    echo -e "   mbpfan Daemon: ${GREEN}Running${RESET}"
else
    echo -e "   mbpfan Daemon: ${YELLOW}Not running. Enable fan control: sudo $ROOT_DIR/drivers/thermal_fans.sh${RESET}"
fi

# 7. iOS Device Check
echo -e "\n${BOLD}7. Connected iOS / iPadOS Devices:${RESET}"
if command -v ideviceinfo &>/dev/null; then
    if ideviceinfo 2>/dev/null | grep -q "DeviceName"; then
        IOS_NAME=$(ideviceinfo 2>/dev/null | grep "DeviceName" | cut -d' ' -f2-)
        IOS_VER=$(ideviceinfo 2>/dev/null | grep "ProductVersion" | cut -d' ' -f2-)
        echo -e "   iOS Device: ${GREEN}$IOS_NAME (iOS $IOS_VER) connected & paired!${RESET}"
    else
        echo -e "   iOS Device: ${YELLOW}USB device connected but not paired. Run: $ROOT_DIR/ios/pair_device.sh${RESET}"
    fi
else
    echo -e "   iOS Tools: ${YELLOW}libimobiledevice not installed. Run: sudo $ROOT_DIR/install.sh${RESET}"
fi

echo -e "\n${BOLD}${CYAN}=================================================================${RESET}"
echo -e "Scan complete! Run '${YELLOW}apple-linux${RESET}' to fix any highlighted issues."
