import Foundation
import GPXKit
import SwiftUI

struct GradeSegmentTable: View {
    var segments: [GradeSegment]
    @Binding var selection: GradeSegment.ID?

    var body: some View {
        ScrollViewReader { proxy in
            Table(of: GradeSegment.self, selection: $selection) {
                TableColumn("Start") {
                    Text($0.start.meters.formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .asProvided,
                            numberFormatStyle: .number.rounded(increment: 1)
                        )
                    ))
                }
                TableColumn("End") {
                    Text($0.end.meters.formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .asProvided,
                            numberFormatStyle: .number.rounded(increment: 1)
                        )
                    ))
                }
                TableColumn("Elevation at start") {
                    Text($0.elevationAtStart.meters.formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .asProvided,
                            numberFormatStyle: .number.rounded(increment: 1)
                        )
                    ))
                }
                TableColumn("Elevation at end") {
                    Text($0.elevationAtEnd.meters.formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .asProvided,
                            numberFormatStyle: .number.rounded(increment: 1)
                        )
                    ))
                }
                TableColumn("%") {
                    Text($0.grade.formatted(.percent))
                }
                TableColumn("Length") {
                    Text($0.length.meters.formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .asProvided,
                            numberFormatStyle: .number.rounded(increment: 1)
                        )
                    ))
                }
                TableColumn("Gain") {
                    Text(($0.elevationAtEnd - $0.elevationAtStart).meters.formatted())
                }
            } rows: {
                ForEach(segments) {
                    TableRow($0)
                }
            }
            .onChange(of: selection) {
                proxy.scrollTo(selection)
            }
//            .scrollPosition(id: $selection)
        }
    }
}
