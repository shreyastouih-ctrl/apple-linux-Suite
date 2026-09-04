#!/usr/bin/env bash
# Cirrus Logic Audio Codec Fixer for Intel Macs & Mac Mini
# Part of Apple-Linux-Suite

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}[Cirrus Logic Audio Fixer] Initializing...${RESET}"

# Check ALSA audio devices
SOUND_DEVS=$(aplay -l 2>/dev/null || true)
echo -e "${GREEN}Detected Audio Devices:${RESET}"
echo "$SOUND_DEVS"

# Create modprobe quirk for Cirrus Logic / HD-Audio on Apple hardware
SOUND_CONF="/etc/modprobe.d/alsa-apple-audio.conf"

echo -e "${GREEN}Creating ALSA modprobe quirks for Apple Audio codecs...${RESET}"

cat << 'EOF' | sudo tee "$SOUND_CONF" > /dev/null
# Apple Mac Cirrus Logic / HD-Audio options
options snd-hda-intel model=macbook-pro-hda
options snd-hda-intel index=0
options snd-hda-codec-cirrus position_fix=1
EOF

echo -e "${GREEN}Wrote ALSA options to $SOUND_CONF${RESET}"

# Unmute all ALSA channels
if command -v amixer &>/dev/null; then
    echo -e "${GREEN}Unmuting ALSA volume controls...${RESET}"
    amixer sset Master 100% unmute 2>/dev/null || true
    amixer sset Headphone 100% unmute 2>/dev/null || true
    amixer sset Speaker 100% unmute 2>/dev/null || true
    amixer sset Front 100% unmute 2>/dev/null || true
fi

# Restart PulseAudio or PipeWire
if systemctl --user status pipewire &>/dev/null; then
    echo -e "${GREEN}Restarting PipeWire audio service...${RESET}"
    systemctl --user restart pipewire wireplumber
elif command -v pulseaudio &>/dev/null; then
    echo -e "${GREEN}Restarting PulseAudio service...${RESET}"
    pulseaudio -k 2>/dev/null || true
    pulseaudio --start 2>/dev/null || true
fi

echo -e "${BOLD}${GREEN}Audio configuration completed! If sound is still quiet/missing, please reboot.${RESET}"
