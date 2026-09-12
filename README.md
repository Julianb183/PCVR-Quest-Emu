# Virtual Computer Lab and PCVR Quest Emu

Private experimental tools for Apple Silicon Mac and Meta Quest development.

## Virtual Computer Lab

`MacQuestSimulator/` builds a native macOS app that manages clean-room profiles for:

- Windows 11 ARM64 through QEMU
- Ubuntu ARM64 through QEMU
- LineageOS ARM64 through QEMU
- macOS ARM profile-only entry (generic QEMU cannot boot a normal macOS guest)
- Mac host
- Quest 3 simulator profile

Build and open it with:

```sh
cd MacQuestSimulator
swift build -c release
```

The app is a manager UI. It does not bundle operating systems, firmware, proprietary applications, Windows, macOS, Android, or Quest system files. Add legally obtained guest images to the workspace created under `~/Virtual Computer Lab/`.

QEMU is expected at `/opt/homebrew/bin/qemu-system-aarch64` on Apple Silicon. The current app validates the profile and prepares its workspace; full guest boot configuration remains experimental.

## Android PCVR Quest Emu

The Android project contains the Quest launcher/configuration UI, an Android NDK JNI runner, and a guest-image picker. It does not include Windows, Steam, SteamVR, or games.

```sh
./gradlew assembleDebug
```

Use only legally obtained images and software.
