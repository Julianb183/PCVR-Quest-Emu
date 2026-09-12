// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacQuestSimulator",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "MacQuestSimulator", targets: ["MacQuestSimulator"])],
    targets: [.executableTarget(name: "MacQuestSimulator")]
)
