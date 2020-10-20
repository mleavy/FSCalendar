// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "FSCalendar",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "FSCalendar", targets: ["FSCalendar"])
    ],
    targets: [
        .target(name: "FSCalendar",
                path: "FSCalendar",
                cSettings: [
                        .headerSearchPath("FSCalendar"),
                    ]
                )
    ]
)