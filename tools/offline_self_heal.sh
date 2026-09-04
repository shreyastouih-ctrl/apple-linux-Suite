#!/usr/bin/env bash
# Offline Self-Healing Engine & Background Systemd Auto-Updater Daemon
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BOLD}${CYAN}"
echo "================================================================="
echo "   🍏 APPLE-LINUX OFFLINE SELF-HEALING & BACKGROUND DAEMON ⚙️"
echo "================================================================="
echo -e "${RESET}"

# Check online vs offline connectivity
echo -n "Checking network status... "
if ping -c 1 8.8.8.8 &>/dev/null || ping -c 1 github.com &>/dev/null; then
    ONLINE=true
    echo -e "${GREEN}ONLINE${RESET}"
else
    ONLINE=false
    echo -e "${YELLOW}OFFLINE${RESET}"
fi

if [ "$ONLINE" = true ]; then
    echo -e "${GREEN}[Online Mode] Fetching latest updates from GitHub...${RESET}"
    cd "$ROOT_DIR"
    if [ -d ".git" ] && command -v git &>/dev/null; then
        git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
    fi
    bash "$ROOT_DIR/install.sh"
else
    echo -e "${YELLOW}[Offline Mode] Running local self-healing engine...${RESET}"
    
    # 1. Re-build DKMS Drivers after kernel updates offline
    if command -v dkms &>/dev/null; then
        echo -e "${GREEN}Rebuilding DKMS modules for current kernel ($(uname -r))...${RESET}"
        sudo dkms autoinstall 2>/dev/null || true
    fi

    # 2. Reload Broadcom Wi-Fi & FaceTime HD modules if present
    echo -e "${GREEN}Re-activating kernel modules offline...${RESET}"
    sudo modprobe wl 2>/dev/null || true
    sudo modprobe facetimehd 2>/dev/null || true

    # 3. Re-apply hid-apple sysfs parameters
    if [ -d /sys/module/hid_apple/parameters ]; then
        echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode >/dev/null 2>&1 || true
        echo 1 | sudo tee /sys/module/hid_apple/parameters/swap_opt_cmd >/dev/null 2>&1 || true
    fi

    # 4. Restart mbpfan thermal daemon
    if command -v systemctl &>/dev/null; then
        sudo systemctl restart mbpfan 2>/dev/null || true
        sudo systemctl restart usbmuxd 2>/dev/null || true
    fi

    echo -e "${BOLD}${GREEN}Offline self-healing complete! Driver configurations restored.${RESET}"
fi

# Enable Systemd Auto-Update Daemon (Runs on boot and daily)
if [ "$1" == "--enable-daemon" ] && command -v systemctl &>/dev/null && [ "$EUID" -eq 0 ]; then
    echo -e "\n${GREEN}Setting up background systemd auto-update service...${RESET}"
    
    cat << EOF > /etc/systemd/system/apple-linux-autoupdate.service
[Unit]
Description=Apple-Linux-Suite Auto-Update & Self-Healing Service
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash $ROOT_DIR/tools/offline_self_heal.sh

[Install]
WantedBy=multi-user.target
EOF

    cat << EOF > /etc/systemd/system/apple-linux-autoupdate.timer
[Unit]
Description=Run Apple-Linux-Suite Auto-Update Daily

[Timer]
OnBootSec=5min
OnUnitActiveSec=1d

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now apple-linux-autoupdate.timer 2>/dev/null || true
    echo -e "${BOLD}${GREEN}Background auto-update timer active! Suite will self-heal daily even offline.${RESET}"
fi
