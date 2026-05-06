// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "ESAudioPlayer",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ESAudioPlayer",
            targets: ["ESAudioPlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0"))
    ],
    targets: [
        .target(
            name: "ESAudioPlayer",
            dependencies: [
                "RxSwift",
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "ESAudioPlayer/Classes"
        ),
        .testTarget(
            name: "ESAudioPlayerTests",
            dependencies: ["ESAudioPlayer", "RxSwift", .product(name: "RxCocoa", package: "RxSwift")],
            path: "Example/Tests",
            exclude: ["Info.plist"],
            resources: [
                .process("../ESAudioPlayer/Resources")
            ]
        )
    ]
)
