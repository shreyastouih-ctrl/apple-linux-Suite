# Apple-Linux-Suite 🍏🐧

![Apple Linux Suite Header Banner](assets/apple_linux_banner.jpg)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-orange.svg)](https://www.kernel.org/)
[![Distros: Universal](https://img.shields.io/badge/Distros-Debian%20%7C%20Ubuntu%20%7C%20Arch%20%7C%20Fedora%20%7C%20openSUSE%20%7C%20Void%20%7C%20Gentoo-blue)](https://github.com/)

**Apple-Linux-Suite** is a universal toolkit and setup suite designed to solve every major hardware, driver, and ecosystem issue when running **ANY Linux distribution** on **Intel Macs** (MacBook Pro, MacBook Air, iMac, Mac mini, Mac Pro) and connecting **all Apple products and accessories** (iPhone, iPad, iPod, Apple Watch, AirPods, Magic Mouse, Magic Trackpad, Magic Keyboard).

📖 **[Read the Full Step-by-Step Guide: How to Install Any Linux Distro on a Mac](docs/LINUX_ON_MAC_GUIDE.md)**  
🛡️ **[Read the Legal & Open-Source Compliance Guide](docs/LEGAL_AND_SAFETY.md)**

---

## 🛠️ Solved Hardware & Distro Problems

This suite directly solves all common pain points experienced when installing Linux on Mac hardware:

| Mac Hardware Problem | Cause | Apple-Linux-Suite Solution |
|---|---|---|
| 📶 **No Wi-Fi after Linux Install** | Proprietary Broadcom (`bcm43xx`) chips | `broadcom_wifi.sh` auto-detects card and installs `wl` / `b43` drivers across 7+ package managers. |
| 📷 **Webcam Not Detected** | FaceTime HD camera uses PCIe (`bcwc_pcie`), not standard USB UVC | `facetime_hd_camera.sh` automatically extracts macOS firmware and builds kernel module via DKMS. |
| 🔊 **No Sound / Quiet Speakers** | Cirrus Logic CS4208 / CS8409 audio codecs & missing ALSA topology | `cirrus_audio.sh` and `t2_mac_setup.sh` configure ALSA quirks & PipeWire UCM profiles. |
| 💨 **Fans Spinning at 100% / Overheating** | Linux kernel ACPI thermal management doesn't map Mac SMC sensors | `thermal_fans.sh` deploys optimized `mbpfan` daemon configuration. |
| 🖤 **Black Screen on Dual-GPU Macs** | Conflict between Intel IGPU & NVIDIA/AMD Discrete GPU (`apple_gmux`) | `gpu_gmux.sh` fixes brightness controls & powers down discrete GPU on boot. |
| ⌨️ **Wrong Keyboard Keys / Fn Mode** | F1-F12 keys defaulting to media keys; Alt/Cmd swapped | `apple_hid.sh` configures `hid-apple` to default F1-F12 and swap Option/Cmd keys. |
| ⚡ **Poor Battery Life** | Unoptimized power states under Linux | `battery_power.sh` tunes TLP and CPU governors specifically for Mac laptops. |
| 📱 **iPhone / iPad Not Mounting** | Missing `usbmuxd` / `libimobiledevice` trust pairing | `ios/mount_iphone.sh` & `ios/pair_device.sh` provide one-click native file manager mounting. |
| 🖥️ **AirPlay & Screen Mirroring** | Apple proprietary AirPlay protocol | `ecosystem/airplay_uxplay.sh` launches `UxPlay` mDNS mirror receiver daemon. |
| 💾 **Cannot Read macOS Drives** | APFS & HFS+ file system incompatibility | `ecosystem/apfs_hfs_mount.sh` mounts APFS (apfs-fuse) and HFS+ with write support. |
| 🔀 **Dual-Boot Bootloader Issues** | Mac EFI boot screen showing generic icons | `tools/refind_installer.sh` installs rEFInd graphical bootloader. |
| 🔄 **Offline Driver Recovery** | Kernel updates breaking drivers when offline | `tools/offline_self_heal.sh` background daemon auto-rebuilds modules without internet. |

---

## 🚀 Supported Distributions

Apple-Linux-Suite auto-detects package managers and handles dependencies automatically for:

- **Ubuntu / Debian / Pop!_OS / Linux Mint / Elementary** (`apt`)
- **Arch Linux / Manjaro / EndeavourOS / Garuda** (`pacman`)
- **Fedora / Nobara / RHEL / CentOS** (`dnf`)
- **openSUSE Tumbleweed / Leap** (`zypper`)
- **Void Linux** (`xbps`)
- **Gentoo Linux** (`emerge`)
- **Alpine Linux** (`apk`)

---

## 📦 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/shreyastouih-ctrl/apple-linux-Suite.git
cd apple-linux-Suite
chmod +x install.sh apple-linux.sh drivers/*.sh ios/*.sh ecosystem/*.sh tools/*.sh
```

### 2. Run the Universal Installer
```bash
sudo ./install.sh
```

### 3. Run Hardware Diagnostic Scanner
```bash
apple-linux
```
*(Select Option 1 to inspect hardware and get OS recommendations, or Option 2 to perform a 1-click auto-fix scan).*

---

## 💻 Hardware Compatibility & Architecture Note

- **Intel Macs (2006 – 2020)**: Fully supported by this suite across all Linux distros.
- **Apple Silicon Macs (M1 / M2 / M3 / M4)**: Requires [Asahi Linux](https://asahilinux.org/) due to Apple's custom ARM architecture.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for details.
