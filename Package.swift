// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "QuickTodo",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "QuickTodo", targets: ["QuickTodo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", revision: "1b92b9bbb4e03d61c5ff2571cbc85e09144e935d"),
    ],
    targets: [
        .executableTarget(
            name: "QuickTodo",
            dependencies: [
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts"),
            ],
            path: "Sources/QuickTodo"
        ),
    ]
)
