import Foundation
import GPXKit

extension DistanceHeight: Identifiable {
    public var id: Double { distance }
}

extension Climb: Identifiable {
    public var id: Double { self.start }
}

extension GradeSegment: Identifiable {
    public var id: Double {
        start
    }
}

extension TrackGraph {
    func segment(at distance: Double) -> GradeSegment? {
        gradeSegments.last { seg in
            (seg.start ... seg.end).contains(distance)
        }
    }

    func heightMap(
        gradeTolerance: Double = 1,
        rate: Double = 0.5
    ) -> [DistanceHeight] {
        heightMap.reduce([DistanceHeight]()) { filtered, el in
            guard let current = filtered.last else {
                return [el]
            }
            let filteredElevation = rate * el.elevation + (1.0 - rate) * current.elevation
            return filtered + [DistanceHeight(distance: el.distance, elevation: filteredElevation)]
        }.simplify(tolerance: gradeTolerance)
    }
}

import SwiftUI

extension Double {
    var gradeColor: Color {
        switch self {
        case ..<(-20): Color(.hcDown)
        case -20 ..< -15: Color(.cat1Down)
        case -15 ..< -10: Color(.cat2Down)
        case -10 ..< -5: Color(.cat3Down)
        case -5 ..< 0: Color(.cat4Down)
        case 0 ..< 3: Color(.cat4)
        case 3 ..< 6: Color(.cat3)
        case 6 ..< 9: Color(.cat2)
        case 9 ..< 12: Color(.cat1)
        case 12...: Color(.HC)
        default:
            Color.clear
        }
    }
}
