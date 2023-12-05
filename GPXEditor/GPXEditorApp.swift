import EditorFeature
import SwiftUI

@main
struct GPXEditorApp: App {
    var body: some Scene {
        DocumentGroup(viewing: GPXEditor.State.self) { config in
            GPXEditorView(store: .init(initialState: config.document, reducer: { GPXEditor() }))
        }
    }
}
