import ComposableArchitecture
import ElevationClient
import Foundation
import GPXKit
import LoggerDependency

@Reducer
public struct GPXEditor {
    @ObservableState
    public struct State: Equatable {
        public var track: GPXTrack
        public var segmentationLength: Double
        public var selectedGradeSegment: GradeSegment.ID?
        public var threshold: Double
        public var maxSlope: Double
        public var graph: TrackGraph
        public var showsOriginal: Bool
        public var maxGrade: Double

        public init(
            track: GPXTrack,
            segmentationLength: Double = 100,
            selectedGradeSegment: GradeSegment.ID? = nil,
            threshold: Double = 30,
            maxSlope: Double = 0.01,
            showsOriginal: Bool = true
        ) {
            self.track = track
            self.graph = track.graph
            self.segmentationLength = segmentationLength
            self.threshold = threshold
            self.maxSlope = maxSlope
            self.selectedGradeSegment = selectedGradeSegment
            self.showsOriginal = showsOriginal
            self.maxGrade = track.graph.gradeSegments.max(by: { $0.grade < $1.grade })?.grade ?? .zero
        }
    }

    public enum Action: BindableAction {
        case correctElevationButtonTapped
        case updateResult(Result<[Coordinate], Error>)
        case binding(_ action: BindingAction<State>)
        case selectMaxGradeTapped
        case resetButtonTapped
        case flattenButtonTapped
        case smoothButtonTapped
        case combineButtonTapped
    }

    @Dependency(\.elevationClient.update) private var updateLocations
    @Dependency(\.logger["GPXEditor"]) private var log

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.segmentationLength) { old, new in
                Reduce { state, action in
                    let coords = state.track.trackPoints.map(\.coordinate)
                    if let new = try? TrackGraph(
                        coords: coords.smoothedElevation(sampleCount: Int(state.threshold)),
                        elevationSmoothing: .segmentation(new)
                    ) {
                        state.graph = new
                    }
                    state.maxGrade = state.graph.gradeSegments.max(by: { $0.grade < $1.grade })?.grade ?? .zero
                    return .none
                }
            }
            .onChange(of: \.selectedGradeSegment) { old, new in
                Reduce { state, action in
                    if let new {
                        state.selectedGradeSegment = state.graph.gradeSegments.last(where: { segment in
                            let r = segment.start ... segment.end
                            return r.contains(new)
                        })?.id
                    }
                    return .none
                }
            }

        Reduce { state, action in
            switch action {
            case .correctElevationButtonTapped:
                let locs = state.track.trackPoints.map(\.coordinate)
                return .run { [locs] send in
                    await send(.updateResult(Result {
                        try await updateLocations(locs)
                    }))
                }
            case let .updateResult(.success(coordinates)):
                state.graph = .init(coords: coordinates)
                state.maxGrade = state.graph.gradeSegments.max(by: { $0.grade < $1.grade })?.grade ?? .zero
                return .none
            case let .updateResult(.failure(error)):
                return .run { _ in
                    log.error("Error fetching locations, \(error, privacy: .public)")
                }
            case .selectMaxGradeTapped:
                state.selectedGradeSegment = state.graph.gradeSegments.max(by: { lhs, rhs in
                    lhs.grade < rhs.grade
                })?.id
                return .none
            case .resetButtonTapped:
                state.graph = state.track.graph
                state.maxSlope = 0.01
                state.threshold = 30
                state.showsOriginal = true
                state.selectedGradeSegment = nil
                state.maxGrade = state.track.graph.gradeSegments.max(by: { $0.grade < $1.grade })?.grade ?? .zero
                return .none
            case .flattenButtonTapped:
                let coords = state.track.trackPoints.map(\.coordinate)
                state.graph = .init(coords: coords)
                if let new = try? state.graph.gradeSegments.flatten(maxDelta: state.maxSlope) {
                    state.graph.gradeSegments = new
                }
                state.selectedGradeSegment = nil
                state.maxGrade = state.graph.gradeSegments.max(by: { $0.grade < $1.grade })?.grade ?? .zero
                return .none
            case .smoothButtonTapped:
                let coords = state.track.trackPoints.map(\.coordinate)
                    .smoothedElevation(sampleCount: Int(state.threshold))
                state.graph = .init(coords: coords)
                state.selectedGradeSegment = nil
                state.maxGrade = state.graph.gradeSegments.max(by: { $0.grade < $1.grade })?.grade ?? .zero
                return .none
            case .combineButtonTapped:
                let coords = state.track.trackPoints.map(\.coordinate)
                if let new = try? TrackGraph(
                    coords: coords,
                    elevationSmoothing: .combined(
                        smoothingSampleCount: Int(state.threshold),
                        maxGradeDelta: state.maxSlope
                    )
                ) {
                    state.graph = new
                }
                state.selectedGradeSegment = nil
                state.maxGrade = state.graph.gradeSegments.max(by: { $0.grade < $1.grade })?.grade ?? .zero
                return .none
            case .binding:
                return .none
            }
        }
    }
}

import Charts
import SwiftUI

public struct GPXEditorView: View {
    @State var store: StoreOf<GPXEditor>

    public init(store: StoreOf<GPXEditor>) {
        self.store = store
    }

    public var body: some View {
        Form {
            Text(store.track.title)
            LabeledContent("Distance", value: store.graph.distance.meters.formatted())
            LabeledContent("Elevation gain", value: store.graph.elevationGain.meters.formatted())
            LabeledContent("# segments", value: store.graph.gradeSegments.count.formatted())
            Button("Select max grade (\(store.maxGrade.formatted(.percent))") {
                store.send(.selectMaxGradeTapped)
            }
            Toggle("Shows original heightmap", isOn: $store.showsOriginal).disabled(store.selectedGradeSegment != nil)
            Button("Reset") {
                store.send(.resetButtonTapped)
            }
            Slider(value: $store.segmentationLength, in: 10 ... 1_000, step: 25) {
                LabeledContent("Segment length", value: store.segmentationLength.meters.formatted())
            }
            Slider(value: $store.threshold, in: 3 ... 200, step: 10) {
                LabeledContent("Threshold", value: store.threshold.formatted())
            }
            Slider(value: $store.maxSlope, in: 0.005 ... 0.16, step: 0.005) {
                LabeledContent("Max slope", value: store.maxSlope.formatted(.percent))
            }
            HStack {
                Button("Flatten elevation") {
                    store.send(.flattenButtonTapped)
                }
                Button("Smooth elevation") {
                    store.send(.smoothButtonTapped)
                }
                Button("Combined") {
                    store.send(.combineButtonTapped)
                }
                Spacer()
                Button("Download from open-elevation.com") {
                    store.send(.correctElevationButtonTapped)
                }
            }

            ElevationGraphView(
                graph: store.graph,
                heightMapOverlay: store.showsOriginal ? store.track.graph.heightMap : nil,
                selectedID: $store.selectedGradeSegment
            )

            GradeSegmentTable(segments: store.graph.gradeSegments, selection: $store.selectedGradeSegment)
        }
        .padding()
    }
}

#Preview {
    GPXEditorView(store: .init(initialState: GPXEditor.State(track: .raceAgainstSunset)) { GPXEditor() })
        .frame(width: 1_000, height: 800)
}
