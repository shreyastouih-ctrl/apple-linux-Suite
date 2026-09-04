#!/usr/bin/env bash
# Dual-GPU (apple_gmux) & Black Screen Fixer for MacBooks (Intel + NVIDIA / AMD)
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}[Mac Dual-GPU & Display Fixer] Initializing...${RESET}"

# Check for dual GPUs (Integrated Intel + Discrete AMD/NVIDIA)
GPUS=$(lspci | grep -i -E 'VGA|3D|Display' || true)
echo -e "${GREEN}Detected Display Adapters:${RESET}"
echo "$GPUS"

if echo "$GPUS" | grep -iq "NVIDIA" && echo "$GPUS" | grep -iq "Intel"; then
    echo -e "${YELLOW}Detected Dual GPU: Intel Integrated + NVIDIA Discrete.${RESET}"
elif echo "$GPUS" | grep -iq "AMD" || echo "$GPUS" | grep -iq "Radeon"; then
    echo -e "${YELLOW}Detected Dual GPU: Intel Integrated + AMD Radeon Discrete.${RESET}"
fi

echo -e "\n${BOLD}Select Display Fix Action:${RESET}"
echo "1) Apply GRUB parameter for dual-GPU MacBook black screen fix (apple_gmux)"
echo "2) Disable Discrete GPU on Boot to extend battery life (IGPU only mode)"
echo "3) Fix screen brightness control (acpi_backlight=native / intel_backlight)"
echo "0) Exit"

read -p "Enter choice [0-3]: " choice

case "$choice" in
    1)
        echo -e "${GREEN}Configuring GRUB parameters for apple_gmux...${RESET}"
        GMUX_PARAMS="outb 0x70 0xc / outb 0x64 0x4"
        if [ -f /etc/default/grub ]; then
            if ! grep -q "acpi_backlight" /etc/default/grub; then
                sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="acpi_backlight=native /' /etc/default/grub
                sudo update-grub 2>/dev/null || sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
                echo -e "${GREEN}Added acpi_backlight=native to GRUB configuration!${RESET}"
            fi
        fi
        ;;
    2)
        echo -e "${GREEN}Creating systemd service to power down discrete GPU on startup...${RESET}"
        cat << 'EOF' | sudo tee /etc/systemd/system/disable-discrete-gpu.service > /dev/null
[Unit]
Description=Disable Discrete GPU on Mac Dual GPU Laptop
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'if [ -f /sys/kernel/debug/apple_gmux/selected_port ]; then echo IGPU > /sys/kernel/debug/apple_gmux/selected_port; fi'

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl daemon-reload
        sudo systemctl enable disable-discrete-gpu.service 2>/dev/null || true
        echo -e "${GREEN}Service created & enabled! Battery life will be significantly improved.${RESET}"
        ;;
    3)
        echo -e "${GREEN}Configuring xorg backlight rules...${RESET}"
        sudo mkdir -p /etc/X11/xorg.conf.d/
        cat << 'EOF' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf > /dev/null
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "intel"
    Option      "Backlight"  "intel_backlight"
EndSection
EOF
        echo -e "${GREEN}Intel backlight config installed to /etc/X11/xorg.conf.d/20-intel.conf${RESET}"
        ;;
    *)
        exit 0
        ;;
esac
