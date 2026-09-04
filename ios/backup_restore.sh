#!/usr/bin/env bash
# iOS Device Backup & Restore Helper using idevicebackup2
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

BACKUP_DIR="${1:-$HOME/iOS_Backups}"
mkdir -p "$BACKUP_DIR"

echo -e "${BOLD}${GREEN}[iOS Backup & Restore Utility]${RESET}"
echo "Backup Destination: $BACKUP_DIR"
echo ""
echo "Select Action:"
echo "1) Create Full Backup of connected iOS Device"
echo "2) List existing backups"
echo "3) Restore from existing backup"
echo "0) Exit"

read -p "Enter choice [0-3]: " choice

case "$choice" in
    1)
        echo -e "${GREEN}Starting full device backup...${RESET}"
        idevicebackup2 backup "$BACKUP_DIR"
        echo -e "${BOLD}${GREEN}Backup completed! Files saved in $BACKUP_DIR${RESET}"
        ;;
    2)
        echo -e "${GREEN}Listing backups in $BACKUP_DIR:${RESET}"
        ls -lh "$BACKUP_DIR"
        ;;
    3)
        echo -e "${YELLOW}Enter the UDID folder name to restore:${RESET}"
        read -p "UDID: " udid
        if [ -d "$BACKUP_DIR/$udid" ]; then
            echo -e "${RED}WARNING: This will overwrite data on your connected iOS device!${RESET}"
            read -p "Are you sure? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                idevicebackup2 restore --system --settings "$BACKUP_DIR"
            fi
        else
            echo -e "${RED}Backup directory for $udid not found!${RESET}"
        fi
        ;;
    *)
        exit 0
        ;;
esac
