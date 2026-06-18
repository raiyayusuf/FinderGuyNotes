import SwiftUI
import SwiftData

// MARK: - Split Mode
enum SplitMode {
    case balanced       // 50:50 default
    case studyTaskFull  // Study Task full screen (Finder Guy dragged right)
    case developerFull  // Developer full screen (Finder Guy dragged left)
}

// MARK: - History Filter
enum HistoryFilter: String, CaseIterable {
    case all = "All"
    case studyTask = "Study Task"
    case developer = "Developer"
    case merged = "Merged"
}

// MARK: - Notes ViewModel
@Observable
final class NotesViewModel {
    
    // MARK: - UI State
    var splitMode: SplitMode = .balanced
    var dragOffset: CGFloat = 0
    var selectedTab: Int = 0 // 0 = Notes, 1 = Board, 2 = History
    var historyFilter: HistoryFilter = .all
    
    // MARK: - Sheet State
    var showAddStudyTask: Bool = false
    var showAddDeveloper: Bool = false
    var selectedNote: Note?
    
    // MARK: - Split Ratio (0.0 = all left, 0.5 = balanced, 1.0 = all right)
    var splitRatio: CGFloat {
        switch splitMode {
        case .balanced: return 0.5
        case .studyTaskFull: return 1.0
        case .developerFull: return 0.0
        }
    }
    
    // MARK: - Left Panel Width Fraction (for the HStack)
    var leftFraction: CGFloat {
        let base: CGFloat = splitRatio
        let dragInfluence = dragOffset / 800 // Dampen drag effect
        return max(0.0, min(1.0, base + dragInfluence))
    }
    
    var rightFraction: CGFloat {
        1.0 - leftFraction
    }
    
    // MARK: - Drag Gesture Handling
    func handleDragEnd(totalWidth: CGFloat) {
        let threshold = totalWidth * 0.3
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if dragOffset > threshold {
                // Dragged right → Study Task full screen
                splitMode = .studyTaskFull
            } else if dragOffset < -threshold {
                // Dragged left → Developer full screen
                splitMode = .developerFull
            } else {
                // Snap back to balanced
                splitMode = .balanced
            }
            dragOffset = 0
        }
    }
    
    func resetToSplit() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            splitMode = .balanced
            dragOffset = 0
        }
    }
    
    // MARK: - Note Filtering
    func studyTaskNotes(from notes: [Note]) -> [Note] {
        notes
            .filter { $0.isStudyTask }
            .sorted { $0.date > $1.date }
    }
    
    func developerNotes(from notes: [Note]) -> [Note] {
        notes
            .filter { $0.isDeveloper }
            .sorted { $0.date > $1.date }
    }
    
    func filteredHistoryNotes(from notes: [Note]) -> [Note] {
        switch historyFilter {
        case .all:
            return notes.sorted { $0.date > $1.date }
        case .studyTask:
            return studyTaskNotes(from: notes)
        case .developer:
            return developerNotes(from: notes)
        case .merged:
            // Merged = all notes, newest first (same as All, timeline chronological)
            return notes.sorted { $0.date > $1.date }
        }
    }
    
    // MARK: - Board Zigzag Layout
    /// Returns notes in zigzag pairs: [(StudyTask, Developer), (Developer, StudyTask), ...]
    func zigzagPairs(from notes: [Note]) -> [(Note?, Note?)] {
        let study = studyTaskNotes(from: notes)
        let dev = developerNotes(from: notes)
        
        let maxCount = max(study.count, dev.count)
        guard maxCount > 0 else { return [] }
        
        var pairs: [(Note?, Note?)] = []
        
        for i in 0..<maxCount {
            let s = i < study.count ? study[i] : nil
            let d = i < dev.count ? dev[i] : nil
            
            if i % 2 == 0 {
                // Even row: StudyTask left, Developer right
                pairs.append((s, d))
            } else {
                // Odd row: Developer left, StudyTask right
                pairs.append((d, s))
            }
        }
        
        return pairs
    }
}
