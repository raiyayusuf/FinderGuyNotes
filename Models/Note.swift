/* ============================================
   Models/Note.swift
   SWIFTDATA NOTE MODEL AND HELPERS
   ============================================ */

import Foundation
import SwiftData

/* ============================================
   NOTE MODEL
   ============================================ */
@Model
final class Note {
    var id: UUID
    var title: String
    var content: String
    var type: String // "StudyTask" or "Developer"
    var date: Date
    var isPinned: Bool
    
    init(title: String, content: String, type: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.type = type
        self.date = Date()
        self.isPinned = false
    }
}

/* ============================================
   NOTE TYPE CONSTANTS
   ============================================ */
enum NoteType {
    static let studyTask = "StudyTask"
    static let developer = "Developer"
}

/* ============================================
   COMPUTED HELPERS
   ============================================ */
extension Note {
    var isStudyTask: Bool { type == NoteType.studyTask }
    var isDeveloper: Bool { type == NoteType.developer }
    
    // Formatted: "14 Jun 2026 at 15:54"
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: date)) at \(timeFormatter.string(from: date))"
    }
    
    // Short: "14 Jun"
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}
import Foundation
import SwiftData

// MARK: - Note Model
@Model
final class Note {
    var id: UUID
    var title: String
    var content: String
    var type: String // "StudyTask" or "Developer"
    var date: Date
    var isPinned: Bool
    
    init(title: String, content: String, type: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.type = type
        self.date = Date()
        self.isPinned = false
    }
}

// MARK: - Note Type Constants
enum NoteType {
    static let studyTask = "StudyTask"
    static let developer = "Developer"
}

// MARK: - Computed Helpers
extension Note {
    var isStudyTask: Bool { type == NoteType.studyTask }
    var isDeveloper: Bool { type == NoteType.developer }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: date)) at \(timeFormatter.string(from: date))"
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}
