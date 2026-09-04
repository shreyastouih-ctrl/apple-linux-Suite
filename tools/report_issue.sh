#!/usr/bin/env bash
# Automated Hardware Issue Reporter & Telemetry Log Generator
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"
RESET="\033[0m"

LOG_DIR="/var/log/apple-linux-suite"
REPORT_FILE="$LOG_DIR/hardware_issue_report.md"

if [ "$EUID" -ne 0 ]; then
    sudo mkdir -p "$LOG_DIR" 2>/dev/null || true
    sudo chmod 777 "$LOG_DIR" 2>/dev/null || true
else
    mkdir -p "$LOG_DIR"
fi

echo -e "${BOLD}${CYAN}"
echo "================================================================="
echo "   🍏 APPLE-LINUX HARDWARE ISSUE REPORTER & LOG GENERATOR 📋"
echo "================================================================="
echo -e "${RESET}"

echo -e "${GREEN}Gathering system diagnostics & hardware logs...${RESET}"

cat << EOF > "$REPORT_FILE"
# 🍏 Apple-Linux-Suite Hardware Issue Report

- **Date:** $(date -u)
- **Mac Model:** $(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown Mac")
- **Kernel Version:** $(uname -r) ($(uname -m))
- **Distribution:** $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo "Generic Linux")

---

### 1. PCI Hardware Devices (lspci)
\`\`\`text
$(lspci 2>/dev/null || echo "lspci unavailable")
\`\`\`

### 2. USB Connected Devices (lsusb)
\`\`\`text
$(lsusb 2>/dev/null || echo "lsusb unavailable")
\`\`\`

### 3. Loaded Kernel Drivers (lsmod)
\`\`\`text
$(lsmod | grep -E 'wl|b43|facetimehd|snd_hda_intel|hid_apple|mbpfan|apfs' || echo "No custom Mac modules loaded")
\`\`\`

### 4. Systemd Service Statuses
- **mbpfan (Fan Daemon):** $(systemctl is-active mbpfan 2>/dev/null || echo "inactive")
- **usbmuxd (iOS Daemon):** $(systemctl is-active usbmuxd 2>/dev/null || echo "inactive")
- **avahi-daemon (AirPlay):** $(systemctl is-active avahi-daemon 2>/dev/null || echo "inactive")

### 5. Dmesg Kernel Errors (Hardware & Audio)
\`\`\`text
$(dmesg 2>/dev/null | grep -i -E 'broadcom|facetime|cirrus|hda_intel|t2|applespi' | tail -n 30 || echo "No dmesg errors logged")
\`\`\`
EOF

echo -e "${BOLD}${GREEN}Diagnostic report generated successfully at:${RESET}"
echo -e "  ${YELLOW}$REPORT_FILE${RESET}\n"

if command -v gh &>/dev/null; then
    echo -e "${GREEN}GitHub CLI (gh) detected! Would you like to submit this issue directly?${RESET}"
    read -p "Create GitHub Issue now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh issue create --repo shreyastouih-ctrl/apple-linux-Suite --title "Hardware Issue Report: $(cat /sys/class/dmi/id/product_name 2>/dev/null)" --body-file "$REPORT_FILE"
        echo -e "${BOLD}${GREEN}Issue submitted to GitHub repository!${RESET}"
    fi
else
    echo -e "To submit this issue manually to the repository:"
    echo -e "  1. Copy the contents of: ${YELLOW}$REPORT_FILE${RESET}"
    echo -e "  2. Post to: ${CYAN}https://github.com/shreyastouih-ctrl/apple-linux-Suite/issues/new${RESET}"
fi
