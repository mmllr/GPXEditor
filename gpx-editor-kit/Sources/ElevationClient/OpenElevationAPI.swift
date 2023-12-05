import Foundation
import URLRouting

enum LocationsRoute {
    case locations(LocationsRequest)
}

struct CoordinateRequest: Codable {
    var latitude: Double
    var longitude: Double
}

struct LocationsRequest: Codable {
    var locations: [CoordinateRequest]
}

struct LocationsResponse: Codable {
    var results: [CoordinateResponse]
}

struct CoordinateResponse: Codable {
    var latitude: Double
    var longitude: Double
    var elevation: Double
}

// /api/v1/lookup
let locationsRouter = Route(.case(LocationsRoute.locations)) {
    Method.post
    Path {
        "api"
        "v1"
        "lookup"
    }
    Headers { Field("Content-Type") { "application/json" } }
    Body(.json(LocationsRequest.self))
}
