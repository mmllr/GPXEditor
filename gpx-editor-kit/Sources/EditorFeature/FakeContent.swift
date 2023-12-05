import Foundation
import GPXKit

public extension GPXTrack {
    static var secret: GPXTrack = try! GPXFileParser(url: Bundle.module.url(
        forResource: "geheim",
        withExtension: "gpx"
    )!)!.parse().get()
    static var raceAgainstSunset: GPXTrack = try! GPXFileParser(url: Bundle.module.url(
        forResource: "Race_Against_Sunset",
        withExtension: "gpx"
    )!)!.parse().get()
}
