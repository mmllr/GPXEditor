import Charts
import GPXKit
import SwiftUI

struct ElevationGraphView: View {
    var graph: TrackGraph
    var heightMapOverlay: [DistanceHeight]?
    @Binding var selectedID: GradeSegment.ID?

    var body: some View {
        Chart {
            ForEach(graph.gradeSegments) { grade in
                AreaMark(
                    x: .value("Distance", grade.start),
                    yStart: .value("Altitude", 0),
                    yEnd: .value("Altitude", grade.elevationAtStart),
                    series: .value("id", grade.id)
                )
                .foregroundStyle(by: .value("Grade", grade.grade * 100))

                AreaMark(
                    x: .value("Distance", grade.end),
                    yStart: .value("Altitude", grade.elevationAtEnd),
                    yEnd: .value("Altitude", 0),
                    series: .value("id", grade.id)
                )
                .foregroundStyle(by: .value("Grade", grade.grade * 100))
            }
            .interpolationMethod(.linear)

            if let segment = graph.gradeSegments.last(where: { $0.start == selectedID }) {
                Plot {
                    LineMark(
                        x: .value("Distance", segment.start),
                        y: .value("Altitude", 0)
                    )
                    LineMark(
                        x: .value("Distance", segment.start),
                        y: .value("Altitude", segment.elevationAtStart)
                    )
                    LineMark(
                        x: .value("Distance", segment.end),
                        y: .value("Altitude", segment.elevationAtEnd)
                    )
                    LineMark(
                        x: .value("Distance", segment.end),
                        y: .value("Altitude", 0)
                    )
                }
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                .foregroundStyle(Color.white)
            }
            if let heightMapOverlay, selectedID == nil {
                ForEach(heightMapOverlay) { hm in
                    LineMark(
                        x: .value("Distance", hm.distance),
                        y: .value("Altitude", hm.elevation)
                    )
                }
                .zIndex(1)
                .foregroundStyle(Color.blue)
            }
        }
        .chartGesture { proxy in
            SpatialTapGesture().onEnded {
                guard
                    let valueAtX = proxy.value(atX: $0.location.x, as: GradeSegment.ID.self),
                    let valueAtY = proxy.value(atY: $0.location.y, as: Double.self),
                    let height = graph.elevation(at: valueAtX),
                    height > valueAtY
                else {
                    self.selectedID = nil
                    return
                }
                selectedID = valueAtX
            }
        }
        .chartOverlay(alignment: .top) { proxy in
            if
                let distance = selectedID,
                let segment = graph.segment(at: distance)
            {
                VStack {
                    Text(segment.length.meters.formatted())
                    Text(segment.grade.formatted(.percent))
                }
            }
        }
        .chartForegroundStyleScale { (value: Double) -> Color in
            value.gradeColor
        }
    }
}

#Preview {
    ElevationGraphView(
        graph: GPXTrack.raceAgainstSunset.graph,
        selectedID: .constant(GPXTrack.raceAgainstSunset.graph.gradeSegments[100].id)
    )
}
