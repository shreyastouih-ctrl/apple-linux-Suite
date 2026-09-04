#!/usr/bin/env bash
# Apple-Linux-Suite Master Interactive CLI Wizard
# Enables any Linux distro to run on Intel Macs and interact with all Apple devices

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -d "$SCRIPT_DIR/drivers" ] && [ -d "/usr/local/share/apple-linux-suite" ]; then
    SCRIPT_DIR="/usr/local/share/apple-linux-suite"
fi

show_banner() {
    clear 2>/dev/null || true
    echo -e "${BOLD}${CYAN}"
    echo "================================================================="
    echo "             🍏 APPLE-LINUX-SUITE 🐧"
    echo "   Universal Apple Hardware & iOS Ecosystem Suite for Linux"
    echo "================================================================="
    echo -e "${RESET}"
}

main_menu() {
    show_banner
    echo -e "${BOLD}Select an action:${RESET}\n"
    echo -e " ${CYAN}1)${RESET} Inspect Mac Hardware & Get Recommended Linux OS"
    echo -e " ${CYAN}2)${RESET} Run Hardware Diagnostic & Auto-Fix Scanner"
    echo -e " ${GREEN}3)${RESET} Auto-Detect & Fix Broadcom Wi-Fi / Bluetooth Drivers"
    echo -e " ${GREEN}4)${RESET} Install FaceTime HD Camera Driver & Firmware"
    echo -e " ${GREEN}5)${RESET} Apple T2 Security Chip Setup Guide & Tweaks (2018-2020 Macs)"
    echo -e " ${GREEN}6)${RESET} Fix Cirrus Logic Audio Codecs (Mac mini, MacBook Air/Pro)"
    echo -e " ${GREEN}7)${RESET} Configure Apple Keyboard (Fn keys default, Swap Option/Cmd)"
    echo -e " ${GREEN}8)${RESET} Thermal & Fan Control Setup (mbpfan daemon)"
    echo -e " ${GREEN}9)${RESET} MacBook Dual-GPU & Black Screen Fix (Intel + NVIDIA/AMD)"
    echo -e " ${GREEN}10)${RESET} MacBook Battery Life Optimization (TLP setup)"
    echo -e " ${GREEN}11)${RESET} Pair / Trust Connected iPhone, iPad, or iPod"
    echo -e " ${GREEN}12)${RESET} Mount iPhone / iPad Filesystem (Native File Manager)"
    echo -e " ${GREEN}13)${RESET} Unmount iOS Device Filesystem"
    echo -e " ${GREEN}14)${RESET} Backup or Restore Connected iOS Device (idevicebackup2)"
    echo -e " ${GREEN}15)${RESET} Launch AirPlay Receiver (UxPlay - Stream iPhone screen to Linux)"
    echo -e " ${GREEN}16)${RESET} AirDrop & Wireless Ecosystem Setup (OpenDrop / LocalSend)"
    echo -e " ${GREEN}17)${RESET} Mount APFS / HFS+ macOS Partition"
    echo -e " ${GREEN}18)${RESET} Install rEFInd Graphical Dual-Boot Manager"
    echo -e " ${CYAN}19)${RESET} Auto-Update Suite & Refresh System Packages"
    echo -e " ${CYAN}20)${RESET} Generate Hardware Issue Report & Telemetry Log"
    echo -e " ${CYAN}21)${RESET} Enable Background Auto-Updater Daemon (Online/Offline Self-Healing)"
    echo -e " ${RED}0) Exit${RESET}"
    echo -e "\n================================================================="
    read -p "Enter choice [0-21]: " choice

    case "$choice" in
        1)
            bash "$SCRIPT_DIR/tools/hardware_os_recommender.sh" || true
            ;;
        2)
            bash "$SCRIPT_DIR/tools/troubleshoot_diagnose.sh" || true
            ;;
        3)
            bash "$SCRIPT_DIR/drivers/broadcom_wifi.sh" || true
            ;;
        4)
            bash "$SCRIPT_DIR/drivers/facetime_hd_camera.sh" || true
            ;;
        5)
            bash "$SCRIPT_DIR/drivers/t2_mac_setup.sh" || true
            ;;
        6)
            bash "$SCRIPT_DIR/drivers/cirrus_audio.sh" || true
            ;;
        7)
            bash "$SCRIPT_DIR/drivers/apple_hid.sh" --apply || true
            ;;
        8)
            bash "$SCRIPT_DIR/drivers/thermal_fans.sh" || true
            ;;
        9)
            bash "$SCRIPT_DIR/drivers/gpu_gmux.sh" || true
            ;;
        10)
            bash "$SCRIPT_DIR/drivers/battery_power.sh" || true
            ;;
        11)
            bash "$SCRIPT_DIR/ios/pair_device.sh" || true
            ;;
        12)
            bash "$SCRIPT_DIR/ios/mount_iphone.sh" || true
            ;;
        13)
            bash "$SCRIPT_DIR/ios/unmount_iphone.sh" || true
            ;;
        14)
            bash "$SCRIPT_DIR/ios/backup_restore.sh" || true
            ;;
        15)
            bash "$SCRIPT_DIR/ecosystem/airplay_uxplay.sh" || true
            ;;
        16)
            bash "$SCRIPT_DIR/ecosystem/airdrop_opendrop.sh" || true
            ;;
        17)
            bash "$SCRIPT_DIR/ecosystem/apfs_hfs_mount.sh" || true
            ;;
        18)
            bash "$SCRIPT_DIR/tools/refind_installer.sh" || true
            ;;
        19)
            bash "$SCRIPT_DIR/tools/auto_updater.sh" || true
            ;;
        20)
            bash "$SCRIPT_DIR/tools/report_issue.sh" || true
            ;;
        21)
            sudo bash "$SCRIPT_DIR/tools/offline_self_heal.sh" --enable-daemon || true
            ;;
        0)
            echo -e "${BOLD}${GREEN}Thank you for using Apple-Linux-Suite! Goodbye. 🍏🐧${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid selection.${RESET}"
            ;;
    esac

    echo ""
    read -p "Press Enter to return to the main menu..." key
    main_menu
}

main_menu
