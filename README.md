# PCVR Quest Emu

A native Meta Quest app focused on an experimental Windows ARM64 PCVR emulator—not WebUSB or a website launcher.

## Current app

- Boots directly into the PCVR Quest Emu screen
- Configures 1–4 GB guest RAM, with 4 GB default
- Describes a software/emulated GPU configuration
- Provides start and stop emulator controls
- Keeps the WebView activity in the source for later integration, but it is not the launcher

## Important status

This release contains the emulator UI and configuration layer. It does not yet contain a working Windows virtual-machine backend, Windows image, Steam, SteamVR, or games. Add a legally obtained Windows 11 ARM64 VHDX and a compatible emulator backend before a real guest can boot. Steam and SteamVR must be installed by the user from official sources.

With 4 GB Quest memory and an emulated GPU, Windows and PCVR performance will be extremely slow and SteamVR is unlikely to be usable. This is an experimental ARM64 emulation project.

## Build

Run `./gradlew assembleDebug` with Android SDK 35 and Java 21, then install the APK with ADB.
