#!/usr/bin/env bash
# Universal Apple-Linux-Suite Installer for ANY Linux Distribution
# Supported Distros: Ubuntu, Debian, Arch, Fedora, openSUSE, Void, Alpine, Gentoo

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}"
echo "================================================================="
echo "   🍏 APPLE-LINUX-SUITE UNIVERSAL INSTALLER 🐧"
echo "   Intel Mac Drivers, iPhones, Android & Smart Device Integration"
echo "================================================================="
echo -e "${RESET}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run as root or with sudo: sudo ./install.sh${RESET}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect Distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID=${ID}
    DISTRO_LIKE=${ID_LIKE:-$ID}
else
    DISTRO_ID="unknown"
    DISTRO_LIKE="unknown"
fi

echo -e "${BOLD}Detected Linux System: ${YELLOW}${NAME:-Linux} (${DISTRO_ID})${RESET}"

# Package Manager Installation
install_packages() {
    case "$DISTRO_ID" in
        ubuntu|debian|pop|linuxmint|elementary|neon|kali)
            echo -e "${GREEN}Installing packages via APT...${RESET}"
            apt-get update
            apt-get install -y \
                libimobiledevice6 libimobiledevice-utils usbmuxd ifuse idevicerestore \
                android-tools-adb android-tools-fastboot scrcpy simple-mtpfs \
                pciutils lshw git build-essential dkms cpio curl xz-utils \
                mbpfan hfsprogs hfsplus apfs-fuse uxplay \
                avahi-daemon alsa-utils pipewire-audio-client-libraries || true
            ;;
        arch|manjaro|endeavouros|garuda|artix)
            echo -e "${GREEN}Installing packages via Pacman...${RESET}"
            pacman -Sy --needed --noconfirm \
                libimobiledevice usbmuxd ifuse idevicerestore \
                android-tools scrcpy simple-mtpfs \
                pciutils lshw git base-devel dkms cpio curl \
                mbpfan hfsutils uxplay avahi pipewire-alsa || true
            ;;
        fedora|nobara|rhel|centos)
            echo -e "${GREEN}Installing packages via DNF...${RESET}"
            dnf install -y \
                libimobiledevice libimobiledevice-utils usbmuxd ifuse idevicerestore \
                android-tools scrcpy simple-mtpfs \
                pciutils lshw git gcc make dkms cpio curl \
                mbpfan uxplay avahi || true
            ;;
        opensuse*|suse)
            echo -e "${GREEN}Installing packages via Zypper...${RESET}"
            zypper install -y \
                libimobiledevice6 libimobiledevice-tools usbmuxd ifuse \
                android-tools scrcpy \
                pciutils lshw git gcc make dkms cpio curl \
                mbpfan hfsutils uxplay avahi || true
            ;;
        void)
            echo -e "${GREEN}Installing packages via XBPS...${RESET}"
            xbps-install -Sy \
                libimobiledevice usbmuxd ifuse \
                pciutils lshw git make gcc dkms cpio curl \
                mbpfan avahi || true
            ;;
        alpine)
            echo -e "${GREEN}Installing packages via APK...${RESET}"
            apk add \
                libimobiledevice usbmuxd ifuse \
                pciutils git make gcc cpio curl avahi || true
            ;;
        gentoo)
            echo -e "${GREEN}Installing packages via Emerge...${RESET}"
            emerge --ask=n app-pda/libimobiledevice app-pda/usbmuxd sys-apps/pciutils net-dns/avahi || true
            ;;
        *)
            echo -e "${YELLOW}Generic distribution detected. Please ensure libimobiledevice, usbmuxd, and ifuse are installed.${RESET}"
            ;;
    esac
}

echo -e "\n${BOLD}[Step 1/5] Installing dependencies...${RESET}"
install_packages

echo -e "\n${BOLD}[Step 2/5] Installing Apple udev rules...${RESET}"
if [ -f "$SCRIPT_DIR/config/99-apple-devices.rules" ]; then
    cp "$SCRIPT_DIR/config/99-apple-devices.rules" /etc/udev/rules.d/
    udevadm control --reload-rules 2>/dev/null || true
    udevadm trigger 2>/dev/null || true
    echo -e "${GREEN}udev rules installed!${RESET}"
fi

echo -e "\n${BOLD}[Step 3/5] Installing Apple Keyboard (hid-apple) config...${RESET}"
if [ -f "$SCRIPT_DIR/config/hid_apple.conf" ]; then
    cp "$SCRIPT_DIR/config/hid_apple.conf" /etc/modprobe.d/
    echo -e "${GREEN}hid_apple.conf installed!${RESET}"
fi

echo -e "\n${BOLD}[Step 4/5] Enabling background services (usbmuxd, avahi)...${RESET}"
if command -v systemctl &>/dev/null; then
    systemctl enable usbmuxd 2>/dev/null || true
    systemctl start usbmuxd 2>/dev/null || true
    systemctl enable avahi-daemon 2>/dev/null || true
    systemctl start avahi-daemon 2>/dev/null || true
    echo -e "${GREEN}Services enabled!${RESET}"
fi

echo -e "\n${BOLD}[Step 5/5] Deploying suite files & installing 'apple-linux' CLI executable...${RESET}"
TARGET_DIR="/usr/local/share/apple-linux-suite"
mkdir -p "$TARGET_DIR"
cp -r "$SCRIPT_DIR/drivers" "$SCRIPT_DIR/ios" "$SCRIPT_DIR/mobile" "$SCRIPT_DIR/ecosystem" "$SCRIPT_DIR/tools" "$SCRIPT_DIR/config" "$TARGET_DIR/" 2>/dev/null || true
chmod +x "$TARGET_DIR"/drivers/*.sh "$TARGET_DIR"/ios/*.sh "$TARGET_DIR"/mobile/*.sh "$TARGET_DIR"/ecosystem/*.sh "$TARGET_DIR"/tools/*.sh 2>/dev/null || true

if [ -f "$SCRIPT_DIR/apple-linux.sh" ]; then
    cp "$SCRIPT_DIR/apple-linux.sh" /usr/local/bin/apple-linux
    chmod +x /usr/local/bin/apple-linux
    echo -e "${GREEN}Executable installed to /usr/local/bin/apple-linux${RESET}"
fi

echo -e "\n${BOLD}${GREEN}=================================================================${RESET}"
echo -e "${BOLD}${GREEN}   ✅ Apple-Linux-Suite Universal Installation Complete!${RESET}"
echo -e "${BOLD}${GREEN}=================================================================${RESET}"
echo -e "You can now run '${YELLOW}apple-linux${RESET}' from any terminal to launch the Management Wizard."
