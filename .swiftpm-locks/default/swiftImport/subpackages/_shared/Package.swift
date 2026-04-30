// swift-tools-version: 5.9
import PackageDescription
let package = Package(
  name: "_shared",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .library(
      name: "_shared",
      type: .none,
      targets: ["_shared"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/google/GoogleSignIn-iOS.git",
      from: "7.1.0"
    )
  ],
  targets: [
    .target(
      name: "_shared",
      dependencies: [
        .product(
          name: "GoogleSignIn",
          package: "GoogleSignIn-iOS"
        )
      ]
    )
  ]
)
