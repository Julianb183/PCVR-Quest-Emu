# Windows and Linux ports

The portable port is written in Python with Tkinter and uses QEMU's `qemu-system-aarch64` executable.

## Windows

1. Install Python 3.10+ and QEMU for Windows.
2. Put `qemu-system-aarch64.exe` on `PATH`.
3. Run `run-windows.bat`.

## Linux

Install Python 3 and Tkinter, then QEMU:

```sh
sudo apt install python3 python3-tk qemu-system-aarch64
./run-linux.sh
```

The app supports ISO, IMG, QCOW2, VHDX, and VMDK selection. IPSW upload is available only for the macOS ARM profile. Operating systems, firmware, Steam, and other proprietary software are never bundled or downloaded.

The generic `virt` machine is suitable for many ARM Linux guests. Windows ARM, Android, LineageOS, and macOS may require additional firmware, kernels, drivers, or platform-specific setup; the manager does not claim every image will boot.
