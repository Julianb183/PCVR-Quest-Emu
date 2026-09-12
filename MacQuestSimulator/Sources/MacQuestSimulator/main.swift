import SwiftUI
import AppKit

@main
struct VirtualComputerLabApp: App {
    var body: some Scene {
        WindowGroup("Virtual Computer Lab") { LabView() }
            .windowStyle(.titleBar)
            .defaultSize(width: 1280, height: 820)
    }
}

struct LabMachine: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let symbol: String
    let color: Color
    let status: String
    let qemuTarget: String?
}

struct LabView: View {
    @State private var selected = 0
    @State private var running = false
    @State private var log = "Select a machine to view its simulated console"
    @State private var cpu = 24.0
    @State private var memory = 4096.0
    @State private var isDownloading = false
    @State private var selectedISO: URL?
    @State private var selectedIPSW: URL?

    private let machines = [
        LabMachine(name: "Mac", subtitle: "macOS ARM host", symbol: "desktopcomputer", color: .blue, status: "Host online", qemuTarget: nil),
        LabMachine(name: "Windows 11 ARM", subtitle: "Windows 11 ARM64 via QEMU", symbol: "window.vertical.closed", color: .cyan, status: "QEMU profile ready", qemuTarget: "aarch64"),
        LabMachine(name: "Ubuntu ARM", subtitle: "Ubuntu ARM64 via QEMU", symbol: "terminal", color: .orange, status: "QEMU profile ready", qemuTarget: "aarch64"),
        LabMachine(name: "Android / LineageOS", subtitle: "LineageOS ARM64 via QEMU", symbol: "apps.iphone", color: .green, status: "QEMU profile ready", qemuTarget: "aarch64"),
        LabMachine(name: "macOS ARM", subtitle: "macOS guest profile — unsupported by generic QEMU", symbol: "apple.logo", color: .gray, status: "Profile only", qemuTarget: nil),
        LabMachine(name: "Quest", subtitle: "Quest 3 development simulator", symbol: "visionpro", color: .purple, status: "Simulator ready", qemuTarget: nil)
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            HStack(spacing: 0) {
                sidebar
                Divider()
                workspace
            }
        }
        .frame(minWidth: 1100, minHeight: 740)
        .focusable()
        .focusEffectDisabled()
    }

    private var header: some View {
        HStack {
            Image(systemName: "square.3.layers.3d.top.filled").foregroundStyle(.cyan).font(.title2)
            Text("VIRTUAL COMPUTER LAB").font(.system(.title2, design: .monospaced))
            Spacer()
            Text("PRIVATE DEVELOPMENT SIMULATOR").font(.caption).foregroundStyle(.secondary)
        }.padding(20).background(.ultraThinMaterial)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MACHINES").font(.caption).foregroundStyle(.secondary).padding(.horizontal, 14)
            ForEach(Array(machines.enumerated()), id: \.element.id) { index, machine in
                Button {
                    selected = index
                    running = false
                    log = "Selected \(machine.name)"
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: machine.symbol).font(.title3).foregroundStyle(machine.color).frame(width: 28)
                        VStack(alignment: .leading) {
                            Text(machine.name).font(.headline)
                            Text(machine.subtitle).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }.padding(10)
                }
                .buttonStyle(.plain)
                .background(selected == index ? machine.color.opacity(0.16) : .clear, in: RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
            Text("This lab uses original simulator UI. It does not bundle operating systems, firmware, or copyrighted applications.")
                .font(.caption2).foregroundStyle(.secondary).padding(14)
        }.padding(12).frame(width: 270)
    }

    private var workspace: some View {
        let machine = machines[selected]
        return VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(machine.name).font(.system(size: 30, weight: .bold))
                    Text(machine.subtitle).foregroundStyle(.secondary)
                }
                Spacer()
                Label(machine.status, systemImage: running ? "circle.fill" : "circle")
                    .foregroundStyle(running ? .green : .secondary)
            }
            HStack(spacing: 12) {
                Button(running ? "Stop" : "Start") {
                    if running {
                        stopQEMU()
                    } else {
                        startQEMU(for: machine)
                    }
                }.buttonStyle(.borderedProminent)
                Button("Reset") { running = false; log = "Reset \(machine.name) profile" }
                Button("Open Console") { openConsole(for: machine) }
                Button("Upload ISO") { chooseImage(kind: "ISO", for: machine) }
                if machine.name == "macOS ARM" {
                    Button("Upload IPSW") { chooseImage(kind: "IPSW", for: machine) }
                }
                if machine.name != "Quest" {
                    Button(isDownloading ? "Preparing…" : "Download Files") {
                        downloadComponents(for: machine)
                    }
                    .disabled(isDownloading)
                }
            }
            if let selectedISO {
                Text("ISO: \(selectedISO.lastPathComponent)").font(.caption).foregroundStyle(.green)
            }
            if let selectedIPSW {
                Text("IPSW: \(selectedIPSW.lastPathComponent)").font(.caption).foregroundStyle(.green)
            }
            if machine.name != "Quest" {
                Text("Download Files prepares a VM-manager workspace for legal/open-source components. Upload only images you obtained legally.")
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                Text("Quest downloads are disabled for this lab profile.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            simulatedScreen(machine: machine)
            HStack(spacing: 16) {
                statCard("CPU", "\(Int(cpu))%", .blue)
                statCard("Memory", "\(Int(memory)) MB", .purple)
                statCard("Display", machine.name == "Quest" ? "Quest 3" : "1920×1080", .orange)
            }
            Text(log).font(.system(.body, design: .monospaced)).foregroundStyle(.secondary)
        }.padding(28).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func simulatedScreen(machine: LabMachine) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("SIMULATED DISPLAY").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text(running ? "RUNNING" : "STOPPED").font(.caption).foregroundStyle(running ? .green : .secondary)
            }
            Spacer()
            Image(systemName: machine.symbol).font(.system(size: 70)).foregroundStyle(machine.color)
            Text(running ? "\(machine.name) session active" : "\(machine.name) profile ready")
                .font(.title2).foregroundStyle(.white)
            Text(running ? "Input, display, storage, and app integration can be added to this profile." : "Press Start to launch the simulated session.")
                .foregroundStyle(.white.opacity(0.65))
            Spacer()
        }
        .padding(24).frame(maxWidth: .infinity, minHeight: 260, alignment: .leading)
        .background(LinearGradient(colors: [.black, machine.color.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 16))
    }

    private func chooseImage(kind: String, for machine: LabMachine) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = kind == "ISO" ? [.diskImage] : [.data]
        panel.title = "Upload \(kind) for \(machine.name)"
        guard panel.runModal() == .OK, let source = panel.url else { return }
        let workspace = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Virtual Computer Lab")
            .appendingPathComponent(machine.name)
        do {
            try FileManager.default.createDirectory(at: workspace, withIntermediateDirectories: true)
            let destination = workspace.appendingPathComponent(source.lastPathComponent)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: source, to: destination)
            if kind == "ISO" { selectedISO = destination } else { selectedIPSW = destination }
            log = "Uploaded \(kind) to ~/Virtual Computer Lab/\(machine.name)/"
        } catch {
            log = "Could not upload \(kind): \(error.localizedDescription)"
        }
    }

    private func startQEMU(for machine: LabMachine) {
        guard let target = machine.qemuTarget else {
            running = true
            log = "Started profile-only simulation for \(machine.name). A guest image is required."
            return
        }
        let qemu = "/opt/homebrew/bin/qemu-system-\(target)"
        guard FileManager.default.isExecutableFile(atPath: qemu) else {
            log = "QEMU executable not found at \(qemu)."
            return
        }
        running = true
        log = "QEMU profile ready for \(machine.name). Add a disk image in ~/Virtual Computer Lab/\(machine.name)/."
    }

    private func stopQEMU() {
        running = false
        log = "Stopped the selected QEMU/profile session"
    }

    private func openConsole(for machine: LabMachine) {
        let terminalURL = URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app")
        if NSWorkspace.shared.open(terminalURL) {
            log = "Opened Terminal for \(machine.name). Type commands manually in the new window."
        } else {
            log = "Could not open Terminal.app"
        }
    }

    private func downloadComponents(for machine: LabMachine) {
        isDownloading = true
        let folder = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Virtual Computer Lab")
            .appendingPathComponent(machine.name)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let readme = "\(machine.name) VM workspace\n\nProfile: \(machine.subtitle)\n\nAdd only legally obtained installers or disk images. This manager does not download operating systems, firmware, or proprietary apps.\n"
            try readme.write(to: folder.appendingPathComponent("README.txt"), atomically: true, encoding: .utf8)
            isDownloading = false
            log = "VM workspace prepared at ~/Virtual Computer Lab/\(machine.name). Add your licensed image there."
            NSWorkspace.shared.open(folder)
        } catch {
            isDownloading = false
            log = "Could not prepare VM workspace: \(error.localizedDescription)"
        }
    }

    private func statCard(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.bold()).foregroundStyle(color)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(14).background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }
}
