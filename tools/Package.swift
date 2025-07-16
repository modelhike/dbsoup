// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DBSoupTools",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "DBSoupParser",
            targets: ["DBSoupParser"]
        ),
        .executable(
            name: "dbsoup",
            targets: ["DBSoupCLI"]
        )
    ],
    targets: [
        .target(
            name: "DBSoupParser",
            dependencies: [],
            path: "Sources/DBSoupParser",
            sources: [
                "DBSoupParser.swift",
                "DBSoupValidator.swift",
                "DBSoupGenerator.swift",
                "DBSoupSVGGenerator.swift",
                "DBSoupMermaidGenerator.swift"
            ]
        ),
        .executableTarget(
            name: "DBSoupCLI",
            dependencies: ["DBSoupParser"],
            path: "Sources/DBSoupCLI",
            sources: [
                "DBSoupCLI.swift",
                "main.swift"
            ]
        ),
        .testTarget(
            name: "DBSoupParserTests",
            dependencies: ["DBSoupParser"],
            path: "Tests/DBSoupParserTests",
            sources: [
                "DBSoupTest.swift"
            ]
        )
    ]
) 