/* ============================================
   App/FinderGuyNotesApp.swift
   APP ENTRY POINT WITH SWIFTDATA CONTAINER
   ============================================ */

import SwiftUI
import SwiftData

/* ============================================
   APP ENTRY POINT
   ============================================ */
@main
struct FinderGuyNotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // SwiftData model container
        .modelContainer(for: Note.self)
    }
}
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
