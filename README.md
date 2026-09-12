# Quest Terminal

A native Kotlin Android terminal-style app for Meta Quest.

## Current version

The starter app provides a VR-friendly landscape console with an on-screen keyboard and safe, app-sandbox commands:

- `help`
- `pwd`
- `ls`
- `clear`
- `echo TEXT`

It does **not** execute arbitrary Android shell commands or access the Quest system. Android apps are sandboxed, so a full device terminal would require a separate computer connection or a carefully designed native command layer.

## Build

Open this folder in Android Studio, let Gradle sync, then build and install the APK with a Quest connected through developer mode. The project uses Android SDK 35 and Java 21. A reproducible Gradle wrapper is included.

## Install the debug APK

Connect a Quest with Developer Mode enabled, allow USB debugging in the headset, then run:

```sh
adb install -r app-debug.apk
```

The built APK is attached to the latest GitHub release.
