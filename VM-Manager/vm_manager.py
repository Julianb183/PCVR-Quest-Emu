#!/usr/bin/env python3
"""Cross-platform QEMU VM Manager for Windows and Linux.

This manager does not include operating systems or proprietary firmware.
Users provide legally obtained ISO, IMG, VHDX, or IPSW files.
"""
from pathlib import Path
import os
import platform
import shutil
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

ROOT = Path.home() / "Virtual Computer Lab"
PROFILES = {
    "Windows 11 ARM": ("Windows 11 ARM64 via QEMU", True),
    "Ubuntu ARM": ("Ubuntu ARM64 via QEMU", True),
    "Android ARM": ("Android ARM64 via QEMU", True),
    "LineageOS ARM": ("LineageOS ARM64 via QEMU", True),
    "macOS ARM": ("Profile only; generic QEMU support is not promised", False),
    "Quest": ("Quest development profile; downloads disabled", False),
}

class VMManager(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Virtual Computer Manager")
        self.geometry("900x600")
        self.process = None
        self.image = None
        self.iso = None
        self.ipsw = None
        self.profile = tk.StringVar(value="Windows 11 ARM")
        self.status = tk.StringVar(value="Select a profile and upload a guest image.")
        self._build()

    def _build(self):
        ttk.Label(self, text="VIRTUAL COMPUTER MANAGER", font=("TkDefaultFont", 18, "bold")).pack(pady=14)
        main = ttk.Frame(self); main.pack(fill="both", expand=True, padx=18, pady=8)
        left = ttk.Frame(main, width=230); left.pack(side="left", fill="y", padx=(0, 16))
        ttk.Label(left, text="PROFILES").pack(anchor="w")
        self.listbox = tk.Listbox(left, height=12, exportselection=False)
        for name in PROFILES: self.listbox.insert("end", name)
        self.listbox.pack(fill="x", pady=8); self.listbox.selection_set(0); self.listbox.bind("<<ListboxSelect>>", self._profile_changed)
        right = ttk.Frame(main); right.pack(side="left", fill="both", expand=True)
        self.profile_label = ttk.Label(right, text="Windows 11 ARM", font=("TkDefaultFont", 16, "bold")); self.profile_label.pack(anchor="w")
        self.description = ttk.Label(right, text=PROFILES["Windows 11 ARM"][0]); self.description.pack(anchor="w", pady=(3, 14))
        controls = ttk.Frame(right); controls.pack(anchor="w", pady=5)
        self.start_button = ttk.Button(controls, text="Start", command=self.start); self.start_button.grid(row=0, column=0, padx=(0, 8))
        ttk.Button(controls, text="Stop", command=self.stop).grid(row=0, column=1, padx=8)
        ttk.Button(controls, text="Upload ISO / Disk Image", command=self.upload_image).grid(row=0, column=2, padx=8)
        self.ipsw_button = ttk.Button(controls, text="Upload IPSW", command=self.upload_ipsw); self.ipsw_button.grid(row=1, column=2, padx=8, pady=8)
        ttk.Button(controls, text="Open Console", command=self.open_console).grid(row=1, column=0, pady=8)
        ttk.Button(controls, text="Prepare Workspace", command=self.prepare_workspace).grid(row=1, column=1, pady=8)
        self.image_label = ttk.Label(right, text="No image selected"); self.image_label.pack(anchor="w", pady=12)
        self.screen = tk.Text(right, height=14, state="disabled", background="#111827", foreground="#e5e7eb")
        self.screen.pack(fill="both", expand=True)
        ttk.Label(right, textvariable=self.status, wraplength=700).pack(anchor="w", pady=10)
        self._profile_changed()

    def current_profile(self):
        selection = self.listbox.curselection()
        return self.listbox.get(selection[0]) if selection else self.profile.get()

    def _profile_changed(self, *_):
        name = self.current_profile(); self.profile.set(name)
        self.profile_label.config(text=name); self.description.config(text=PROFILES[name][0])
        self.ipsw_button.config(state="normal" if name == "macOS ARM" else "disabled")
        self.image = None; self.image_label.config(text="No image selected")
        self.status.set("Select an image, then press Start.")

    def workspace(self):
        folder = ROOT / self.current_profile()
        folder.mkdir(parents=True, exist_ok=True); return folder

    def copy_into_workspace(self, source, kind):
        destination = self.workspace() / Path(source).name
        shutil.copy2(source, destination)
        if kind == "IPSW": self.ipsw = destination
        else: self.image = destination
        self.image_label.config(text=f"{kind}: {destination}")
        self.status.set(f"Copied {kind} into {self.workspace()}")

    def upload_image(self):
        source = filedialog.askopenfilename(title="Choose ISO or disk image", filetypes=[("Images", "*.iso *.img *.qcow2 *.raw *.vhdx *.vmdk"), ("All files", "*.*")])
        if source: self.copy_into_workspace(source, "IMAGE")

    def upload_ipsw(self):
        source = filedialog.askopenfilename(title="Choose macOS IPSW", filetypes=[("IPSW", "*.ipsw"), ("All files", "*.*")])
        if source: self.copy_into_workspace(source, "IPSW")

    def qemu(self):
        names = ["qemu-system-aarch64.exe", "qemu-system-aarch64"] if os.name == "nt" else ["qemu-system-aarch64"]
        for name in names:
            found = shutil.which(name)
            if found: return found
        return None

    def start(self):
        if self.process and self.process.poll() is None: return
        name = self.current_profile()
        if not PROFILES[name][1]:
            self.status.set(f"{name} is a profile-only entry and was not started."); return
        qemu = self.qemu()
        if not qemu:
            messagebox.showerror("QEMU not found", "Install QEMU and ensure qemu-system-aarch64 is in PATH."); return
        image = self.image
        if not image:
            candidates = list(self.workspace().glob("*.iso")) + list(self.workspace().glob("*.img")) + list(self.workspace().glob("*.qcow2")) + list(self.workspace().glob("*.vhdx"))
            image = candidates[0] if candidates else None
        if not image:
            messagebox.showinfo("Guest image needed", "Upload a legally obtained ARM64 image first."); return
        args = [qemu, "-M", "virt", "-cpu", "max", "-m", "4096", "-smp", "4", "-display", "gtk", "-drive", f"file={image},if=virtio,format=raw"]
        if image.suffix.lower() == ".iso": args += ["-cdrom", str(image), "-boot", "d"]
        self.process = subprocess.Popen(args)
        self.status.set(f"Started QEMU for {name} using {image.name}")

    def stop(self):
        if self.process and self.process.poll() is None:
            self.process.terminate(); self.process = None; self.status.set("QEMU stopped.")
        else: self.status.set("No QEMU session is running.")

    def prepare_workspace(self):
        folder = self.workspace(); (folder / "README.txt").write_text("Add a legally obtained ARM64 guest image here. This manager does not download operating systems or firmware.\n")
        self.status.set(f"Workspace ready: {folder}")

    def open_console(self):
        if os.name == "nt": subprocess.Popen(["cmd.exe", "/K", f"cd /d {self.workspace()}"])
        elif platform.system() == "Linux":
            for terminal in [("x-terminal-emulator",), ("gnome-terminal",), ("konsole",)]:
                if shutil.which(terminal[0]): subprocess.Popen(list(terminal) + ["--working-directory", str(self.workspace())]); return
            subprocess.Popen(["xterm", "-e", "bash", "-lc", f"cd '{self.workspace()}'; exec bash"])
        self.status.set("Opened a terminal for this workspace.")

if __name__ == "__main__": VMManager().mainloop()
