import Foundation
import GPXKit

extension GPXEditor.State {
    mutating func update() throws {
        graph = try TrackGraph(
            coords: track.trackPoints.map(\.coordinate),
            smoothingSampleCount: Int(threshold),
            allowedGradeDelta: maxGrade
        )
        maxGrade = graph.gradeSegments.max(by: { $0.grade < $1.grade })?.grade ?? .zero
    }
}
