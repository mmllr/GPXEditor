import Dependencies
import Foundation
import GPXKit
import URLRouting

extension ElevationClient {
    static func live(baseURL url: URL = .openElevation) -> Self {
        let client = URLRoutingClient.live(router: locationsRouter.baseURL(url.absoluteString))
        return ElevationClient(update: { coordinates in
            let result: LocationsResponse = try await client
                .decodedResponse(for: LocationsRoute.locations(.init(locations: coordinates.map {
                    .init(latitude: $0.latitude, longitude: $0.longitude)
                }))).0
            var copy = coordinates
            for (idx, c) in result.results.enumerated() {
                guard c.elevation != .zero else { continue }
                copy[idx].elevation = c.elevation
            }
            return copy
        })
    }
}

extension ElevationClient: DependencyKey {
    public static var liveValue: ElevationClient = .live(baseURL: .openElevation)
}

extension URL {
    static let openElevation: Self = URL(string: "https://api.open-elevation.com")!
}
