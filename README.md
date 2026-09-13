# PCVR Quest Emu

Experimental Android/Meta Quest ARM64 VM frontend. The app selects a legally obtained ARM64 guest disk image and starts a native `qemu-system-aarch64` backend through JNI.

## VM backend

The app uses a dedicated private backend directory:

```text
/files/vm-backend/qemu-system-aarch64
```

Place a QEMU binary built for Android ARM64 at that path and mark it executable. The launcher uses software TCG emulation with configurable 1-4 GB guest RAM, four virtual CPUs, VirtIO storage, GPU, keyboard, and mouse devices, plus headless EGL output for future Quest rendering.

This repository does not include QEMU, guest operating systems, firmware, Steam, SteamVR, or games. A normal macOS/Linux QEMU binary cannot run inside the Quest app; the backend must be cross-compiled for Android ARM64. Guests also require legally obtained images and compatible firmware.

## Build

```sh
./gradlew assembleDebug
```

The experimental UI selects an image, reports backend availability, starts the VM, and stops it. Full VR display streaming and controller integration remain future work.
