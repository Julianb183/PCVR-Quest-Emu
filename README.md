# Quest Web ADB

A native Kotlin Android app for Meta Quest with trusted HTTPS WebView mode and an experimental Windows ARM64 emulator launcher.

## Current features

- Landscape Quest interface
- HTTPS URL entry and trusted-site WebView
- JavaScript and DOM storage for compatible web apps
- Navigation restricted to HTTPS URLs
- Windows ARM64 experiment screen with configurable 1–4 GB guest RAM
- Emulated-GPU configuration placeholder

## Windows ARM64 experiment

This release adds the launcher and configuration UI, but it does not include Windows, Steam, SteamVR, QEMU, or a guest GPU. Add a legally obtained Windows 11 ARM64 VHDX and a licensed emulator backend before attempting a real guest boot. Steam and SteamVR must be installed by the user from official sources and are not redistributed here.

The Quest Android sandbox does not provide a usable Windows hypervisor, so a future backend will be extremely slow with emulated graphics and is not expected to run SteamVR reliably.

## Build

Open this folder in Android Studio or run `./gradlew assembleDebug`. The project uses Android SDK 35 and Java 21. A reproducible Gradle wrapper is included.
