# 🛡️ Legal, Safety & Open-Source Compliance Guide

**Apple-Linux-Suite** is developed strictly under open-source software licenses (MIT License) and operates completely within legal boundaries, fair use doctrines, and international software interoperability regulations.

---

## ⚖️ Legal Principles & Compliance

### 1. Reverse Engineering & Interoperability
Under Section 1201(f) of the US Digital Millennium Copyright Act (DMCA), the EU Computer Programs Directive (2009/24/EC), and equivalent international laws, reverse engineering of protocols for the sole purpose of achieving **interoperability between computer programs** (such as Linux and iOS/macOS devices) is explicitly legal.

### 2. No Proprietary Code Redistribution
* **Zero Copyrighted Apple Code**: This repository contains **NO copyrighted Apple source code, binaries, keys, or proprietary macOS files**.
* **Legitimate Firmware Fetching**: Firmware extraction scripts (such as `facetime_hd_camera.sh`) compile open-source kernel drivers (`bcwc_pcie`) and download firmware files directly from official Apple update mirrors or extract them locally on the user's machine.

### 3. No Security Bypasses or Exploits
* **No iCloud / Activation Lock Bypasses**: This tool **does not** bypass iCloud Activation Lock, passcode security, MDM locks, or Apple ID authentication.
* **No DRM Cracking**: This tool **does not** decrypt or crack FairPlay DRM, Apple Music DRM, or Widevine DRM.
* **No Jailbreaking Required**: All iOS/iPadOS interaction functions using standard, user-authorized Apple protocols via `libimobiledevice` and `usbmuxd` (the same protocols used by Apple iTunes/Finder).

---

## 🔒 User Privacy & Safety

1. **Local Data Only**: All backup, mounting, and pairing operations execute **locally on your computer**. No telemetry, credentials, or personal device data is collected or transmitted to external servers.
2. **Safe Device Mounting**: Drive mounting utilities (`ifuse`, `apfs-fuse`) run in user-space using FUSE, preventing kernel crashes or data corruption.
