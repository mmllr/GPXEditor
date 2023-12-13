import EditorFeature
import GPXKit
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let gpx = UTType(filenameExtension: "gpx")!
}

extension GPXEditor.State: FileDocument {
    public static var readableContentTypes: [UTType] { [.gpx] }

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let parser = GPXFileParser(data: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let track = try parser.parse(elevationSmoothing: .none).get()
        self.init(track: track)
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = GPXExporter(track: track).xmlString.data(using: .utf8)
        else { throw CocoaError(.fileWriteUnknown) }
        return .init(regularFileWithContents: data)
    }
}
