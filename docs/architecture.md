# Architecture Overview

> Deep dive into the architectural patterns, data flow, and design decisions of Finder Guy Notes.

---

## Architecture Pattern: MVVM + SwiftData

```
┌─────────────────────────────────────────────────────┐
│                    SwiftUI Views                     │
│  ContentView → NotesView / BoardView / HistoryView   │
│                      │                               │
│              @Query (reactive fetch)                 │
│              @Bindable (VM binding)                  │
│                      │                               │
├──────────────────────┼───────────────────────────────┤
│              NotesViewModel                          │
│              (@Observable)                           │
│                      │                               │
│         UI State  │  Filtering  │  Zigzag Logic      │
│         Split Mode│  Gesture    │  Tab Management    │
│                      │                               │
├──────────────────────┼───────────────────────────────┤
│                  SwiftData                           │
│                                                      │
│         @Model Note  │  modelContext  │  @Query      │
│                                                      │
│         ┌──────────────────────────┐                 │
│         │  SQLite (under the hood) │                 │
│         └──────────────────────────┘                 │
└─────────────────────────────────────────────────────┘
```

### Why MVVM?

- **Separation of concerns**: Views handle UI, ViewModel handles logic, Model handles data
- **Testability**: ViewModel logic can be unit-tested without UI
- **SwiftUI-native**: Works naturally with `@Observable` and property wrappers

### Why NOT ObservableObject/@Published?

This project uses iOS 17+ exclusively, so we use the modern approach:
- `@Observable` macro instead of `ObservableObject`
- `@Bindable` instead of `@ObservedObject`
- `@State` to create observable instances (instead of `@StateObject`)

---

## Data Flow

### 1. Reading Data (Query)

```
SwiftData Store → @Query → View → Render
```

Views use `@Query` directly to fetch notes reactively:

```swift
@Query(sort: \Note.date, order: .reverse) private var allNotes: [Note]
```

When data changes (insert/delete/update), `@Query` automatically re-fetches and the view re-renders.

### 2. Writing Data (Insert)

```
User Action → AddNoteView → modelContext.insert(note) → SwiftData Store → @Query triggers re-render
```

The `AddNoteView` accesses the model context via environment:

```swift
@Environment(\.modelContext) private var modelContext
```

### 3. UI State (ViewModel)

```
User Gesture → ViewModel State Change → View Re-renders
```

Example: Finder Guy drag updates `dragOffset` → split ratio recalculates → layout animates.

---

## View Hierarchy

```
ContentView (root)
├── NotesView (tab 0)
│   ├── SidePanel (Study Task - left)
│   │   ├── Header (+ button)
│   │   ├── ScrollView
│   │   │   └── NoteCardView (× N)
│   │   └── EmptyState (when no notes)
│   ├── FinderGuyView (center divider)
│   │   └── DragGesture
│   └── SidePanel (Developer - right)
│       ├── Header (+ button)
│       ├── ScrollView
│       │   └── NoteCardView (× N)
│       └── EmptyState (when no notes)
│
├── BoardView (tab 1)
│   ├── Header
│   ├── ScrollView
│   │   └── Zigzag Rows
│   │       └── NoteCardView (× N, with type badge)
│   └── EmptyState
│
├── HistoryView (tab 2)
│   ├── Header
│   ├── Filter Chips (All | Study Task | Developer | Merged)
│   ├── ScrollView
│   │   └── History Rows (timeline)
│   └── EmptyState
│
└── Bottom Navigation Bar (ultraThinMaterial)
    ├── Notes tab
    ├── Board tab
    └── History tab

Shared Sheets:
├── AddNoteView (modal for creating notes)
└── NoteDetailSheet (modal for viewing note detail)
```

---

## State Management

### ViewModel State (`NotesViewModel`)

| Property | Type | Purpose |
|----------|------|---------|
| `splitMode` | `SplitMode` enum | Current split state: balanced / studyTaskFull / developerFull |
| `dragOffset` | `CGFloat` | Real-time drag position of Finder Guy |
| `selectedTab` | `Int` | Current bottom nav tab (0/1/2) |
| `historyFilter` | `HistoryFilter` enum | Active history filter |
| `showAddStudyTask` | `Bool` | Toggle AddNote sheet for Study Task |
| `showAddDeveloper` | `Bool` | Toggle AddNote sheet for Developer |
| `selectedNote` | `Note?` | Note tapped for detail view |

### Computed Properties

| Property | Logic |
|----------|-------|
| `splitRatio` | Maps `SplitMode` to CGFloat (0.0, 0.5, or 1.0) |
| `leftFraction` | Base ratio + dampened drag offset, clamped [0, 1] |
| `rightFraction` | `1.0 - leftFraction` |

---

## Key Design Decisions

### 1. DragGesture (not Swipe)

**Why**: Swipe gestures only fire once. We need real-time finger tracking so Finder Guy visually follows the drag, creating a tactile, interactive feel.

**How**: `DragGesture().onChanged` updates `dragOffset` in real-time. `.onEnded` decides snap behavior.

### 2. @Query at View Level (not ViewModel)

**Why**: SwiftData's `@Query` is designed as a property wrapper for SwiftUI views. Putting it in ViewModel breaks reactivity.

**How**: Views fetch data with `@Query`, pass arrays to ViewModel methods for filtering/sorting.

### 3. String-based Note Type (not Enum)

**Why**: SwiftData stores enums as raw values anyway. Using String directly simplifies queries and avoids migration issues.

**How**: `NoteType.studyTask` and `NoteType.developer` constants prevent typos.

### 4. Custom Bottom Nav (not TabView)

**Why**: Apple's `TabView` has limited styling. We wanted a floating, rounded, `.ultraThinMaterial` nav bar inspired by Liquid Glass.

**How**: `ZStack(alignment: .bottom)` overlays a custom HStack with animated tab buttons.

### 5. Single ViewModel Instance

**Why**: The app is small enough that one shared ViewModel works. Multiple VMs would add complexity without benefit.

**How**: `ContentView` creates `@State private var viewModel = NotesViewModel()` and passes it to child views via `@Bindable`.

---

## Enums

### SplitMode

```swift
enum SplitMode {
    case balanced       // 50:50 default split
    case studyTaskFull  // Finder Guy dragged RIGHT → left panel full
    case developerFull  // Finder Guy dragged LEFT → right panel full
}
```

### HistoryFilter

```swift
enum HistoryFilter: String, CaseIterable {
    case all = "All"
    case studyTask = "Study Task"
    case developer = "Developer"
    case merged = "Merged"
}
```

### NoteType

```swift
enum NoteType {
    static let studyTask = "StudyTask"
    static let developer = "Developer"
}
```

---

## File Responsibilities (Quick Map)

| Layer | File | Responsibility |
|-------|------|---------------|
| Entry | `FinderGuyNotesApp.swift` | `@main`, modelContainer setup |
| Model | `Note.swift` | Data model, type constants, date formatting |
| VM | `NotesViewModel.swift` | All shared state, gesture logic, filtering, zigzag |
| Root View | `ContentView.swift` | Tab switching, bottom nav |
| Notes | `NotesView.swift` | Split view, drag gesture, side panels |
| Board | `BoardView.swift` | Zigzag 2-column layout |
| History | `HistoryView.swift` | Timeline, filter chips |
| Components | `NoteCardView.swift` | Reusable card UI |
| Components | `FinderGuyView.swift` | Mascot placeholder |
| Components | `AddNoteView.swift` | Add note modal sheet |
| Extensions | `Color+Extensions.swift` | Hex init, color palette |
