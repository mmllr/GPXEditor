import Dependencies
import DependenciesMacros
import Foundation
import GPXKit
import URLRouting

@DependencyClient
public struct ElevationClient: Sendable {
    public var update: ([Coordinate]) async throws -> [Coordinate]
}

extension ElevationClient: TestDependencyKey {
    public static var testValue: Self = .init()
    public static var previewValue: Self = .init()
}

public extension DependencyValues {
    var elevationClient: ElevationClient {
        get {
            self[ElevationClient.self]
        }
        set {
            self[ElevationClient.self] = newValue
        }
    }
}
