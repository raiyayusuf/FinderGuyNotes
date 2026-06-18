import SwiftUI
import SwiftData

@main
struct FinderGuyNotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Note.self)
    }
}
