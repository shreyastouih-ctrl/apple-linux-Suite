#!/usr/bin/env bash
# Apple Keyboard hid-apple Kernel Module Configurator
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

CONF_FILE="/etc/modprobe.d/hid_apple.conf"
SOURCE_CONF="$(dirname "$0")/../config/hid_apple.conf"

echo -e "${BOLD}${GREEN}[Apple Keyboard Configurator]${RESET}"

if [ "$1" == "--apply" ]; then
    echo -e "${GREEN}Applying hid-apple configuration to system...${RESET}"
    if [ -f "$SOURCE_CONF" ]; then
        sudo cp "$SOURCE_CONF" "$CONF_FILE"
    else
        cat << 'EOF' | sudo tee "$CONF_FILE" > /dev/null
options hid_apple fnmode=2
options hid_apple swap_opt_cmd=1
options hid_apple swap_fn_leftctrl=0
options hid_apple iso_layout=1
EOF
    fi

    # Update initramfs / initrd
    echo -e "${GREEN}Updating initramfs / initrd...${RESET}"
    if command -v update-initramfs &>/dev/null; then
        sudo update-initramfs -u
    elif command -v dracut &>/dev/null; then
        sudo dracut --force
    elif command -v mkinitcpio &>/dev/null; then
        sudo mkinitcpio -P
    fi

    # Apply live settings via sysfs
    if [ -d /sys/module/hid_apple/parameters ]; then
        echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode > /dev/null || true
        echo 1 | sudo tee /sys/module/hid_apple/parameters/swap_opt_cmd > /dev/null || true
        echo -e "${GREEN}Live hid-apple sysfs parameters updated successfully!${RESET}"
    fi

    echo -e "${BOLD}${GREEN}Apple keyboard settings saved permanently!${RESET}"
    exit 0
fi

echo -e "Current Live Parameters:"
if [ -d /sys/module/hid_apple/parameters ]; then
    echo -n "  fnmode: " && cat /sys/module/hid_apple/parameters/fnmode 2>/dev/null || echo "N/A"
    echo -n "  swap_opt_cmd: " && cat /sys/module/hid_apple/parameters/swap_opt_cmd 2>/dev/null || echo "N/A"
    echo -n "  swap_fn_leftctrl: " && cat /sys/module/hid_apple/parameters/swap_fn_leftctrl 2>/dev/null || echo "N/A"
else
    echo "  hid-apple kernel module is not currently loaded."
fi

echo -e "\nTo permanently set F1-F12 as default keys and swap Option/Cmd keys:"
echo -e "  ${YELLOW}sudo $0 --apply${RESET}"
