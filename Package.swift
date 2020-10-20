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
        .target(
           name: "FSCalendar-ObjC", // 1
           dependencies: [], // 2
           path: "FSCalendar/", // 3
           exclude: ["Swift"], // 4
           cSettings: [
              .headerSearchPath("Internal"), // 5
           ]
        ),
        .target(
           name: "FSCalendar", // 6
           dependencies: ["FSCalendar-ObjC"], // 7
           path: "Swift" // 8
        )
    ]
)