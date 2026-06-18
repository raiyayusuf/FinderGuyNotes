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
