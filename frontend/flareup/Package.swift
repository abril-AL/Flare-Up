// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FlareUp",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FlareUp",
            targets: ["FlareUp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.3.1"),
    ],
    targets: [
        .target(
            name: "FlareUp",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ]),
        .testTarget(
            name: "FlareUpTests",
            dependencies: ["FlareUp"]),
    ]
) 