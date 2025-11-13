// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RaceNutritionSPM",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RaceNutritionSPM",
            targets: ["RaceNutritionSPM"]),
    ],
    dependencies: [
        .package(path: "../../../Common/DesignSystem"),
        .package(path: "../../../Common/TriGuideDomain"),
        .package(path: "../../../Common/Localization"),
        .package(path: "../../../Common/NavigationKit"),
        .package(path: "../../CarbItems/CarbItemsSPM"),
        .package(path: "../../RaceCalculator/RaceCalculatorSPM"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RaceNutritionSPM",
            dependencies: [
                "DesignSystem",
                "TriGuideDomain",
                "Localization",
                "NavigationKit",
                "CarbItemsSPM",
                "RaceCalculatorSPM"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "RaceNutritionSPMTests",
            dependencies: ["RaceNutritionSPM"]
        ),
    ]
)
