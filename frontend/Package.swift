// swift-tools-version:5.5
import PackageDescription
import Supabase
import Realtime // for realtime features
import PostgREST // for database operations
import GoTrue // for authentication

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
        .package(
            url: "https://github.com/supabase/supabase-swift.git",
            from: "2.0.0"
        ),    ],
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