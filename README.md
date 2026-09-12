# Quest Web ADB

A native Kotlin Android app for Meta Quest that displays trusted HTTPS websites in a VR-friendly WebView.

## Current version

The MVP provides:

- Landscape Quest interface
- HTTPS URL entry
- Trusted-site WebView
- JavaScript and DOM storage for compatible web apps
- Navigation restricted to HTTPS URLs
- Status showing that the native ADB bridge is not connected

This build does **not** provide unrestricted ADB access. A website cannot control the headset merely because it is loaded in a WebView. A future bridge must explicitly authorize individual operations such as device status, APK installation, or approved commands.

## Build

Open this folder in Android Studio, let Gradle sync, then build and install the APK with a Quest connected through developer mode. The project uses Android SDK 35 and Java 21. A reproducible Gradle wrapper is included.

## Install the debug APK

Connect a Quest with Developer Mode enabled, allow USB debugging in the headset, then run:

```sh
adb install -r app-debug.apk
```

The built APK is attached to the latest GitHub release.
