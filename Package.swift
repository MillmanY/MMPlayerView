// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "MMPlayerView",
    products: [
        .library(name: "MMPlayerView", targets: ["MMPlayerView"]),
    ],
    targets: [
         .target(
            name: "MMPlayerView",
            path: "Sources",
            exclude: [
            ]
         )
    ]
)
