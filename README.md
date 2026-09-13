# PCVR Quest Emu

Android/Quest experimental ARM64 QEMU frontend. It selects a legally obtained guest image and starts a native `qemu-system-aarch64` backend through JNI.

## Build

```sh
./gradlew assembleDebug
```

The backend expects a compatible `qemu-system-aarch64` executable in the app runtime directory. Guest operating systems, firmware, Steam, SteamVR, and games are not bundled.
