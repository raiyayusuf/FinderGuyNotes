# Core Components

> Detailed breakdown of every source file — what it does, how it works, and how the pieces connect.

---

## App Entry Point

### `App/FinderGuyNotesApp.swift`

The `@main` entry point of the application.

**Responsibilities:**
- Declares the app as a SwiftUI `App`
- Sets up the SwiftData `modelContainer` for the `Note` model
- Renders `ContentView` as the root view

**Key Code:**
```swift
@main
struct FinderGuyNotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Note.self)
    }
}
```

**How it connects:** The `.modelContainer` makes SwiftData available throughout the entire view hierarchy via `@Environment(\.modelContext)` and `@Query`.

---

## Data Model

### `Models/Note.swift`

The single data model for the entire app.

**Properties:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | `UUID` | Unique identifier, auto-generated |
| `title` | `String` | Note title (required) |
| `content` | `String` | Note body text |
| `type` | `String` | `"StudyTask"` or `"Developer"` |
| `date` | `Date` | Creation timestamp, auto-set to `Date()` |
| `isPinned` | `Bool` | Reserved for future pin feature |

**Computed Properties:**
- `isStudyTask` — shortcut for `type == NoteType.studyTask`
- `isDeveloper` — shortcut for `type == NoteType.developer`
- `formattedDate` — "14 Jun 2026 at 15:54"
- `shortDate` — "14 Jun"

**NoteType Constants:**
```swift
enum NoteType {
    static let studyTask = "StudyTask"
    static let developer = "Developer"
}
```
Prevents typos when creating or filtering notes.

---

## ViewModel

### `ViewModels/NotesViewModel.swift`

The brain of the app. Manages all shared UI state and business logic.

**State Properties:**
| Property | Purpose |
|----------|---------|
| `splitMode` | Controls split layout: `.balanced`, `.studyTaskFull`, `.developerFull` |
| `dragOffset` | Tracks Finder Guy drag position in real-time |
| `selectedTab` | Active bottom nav tab (0, 1, or 2) |
| `historyFilter` | Active filter in History view |
| `showAddStudyTask` | Toggle for Study Task add sheet |
| `showAddDeveloper` | Toggle for Developer add sheet |
| `selectedNote` | Note for detail sheet (nil = no sheet) |

**Key Methods:**

| Method | What It Does |
|--------|-------------|
| `handleDragEnd(totalWidth:)` | Decides snap behavior after drag. Threshold = 30% of screen width |
| `resetToSplit()` | Animates back to 50:50 balanced split |
| `studyTaskNotes(from:)` | Filters and sorts notes by StudyTask type |
| `developerNotes(from:)` | Filters and sorts notes by Developer type |
| `filteredHistoryNotes(from:)` | Applies current `historyFilter` to note array |
| `zigzagPairs(from:)` | Creates zigzag layout pairs for Board view |

**How `zigzagPairs` works:**
```
Input:  Study = [S1, S2, S3], Developer = [D1, D2]
Output:
  Row 0 (even): (S1, D1)  → StudyTask left, Developer right
  Row 1 (odd):  (D2, S2)  → Developer left, StudyTask right
  Row 2 (even): (S3, nil) → StudyTask left, empty right
```

---

## Views

### `Views/ContentView.swift`

The root view that manages tab switching and the bottom navigation bar.

**How it works:**
1. Holds `@State private var viewModel = NotesViewModel()` — single source of truth
2. Uses a `switch` on `viewModel.selectedTab` to show the correct view
3. Overlays a custom bottom nav bar with `.ultraThinMaterial` background

**Bottom Nav Animation:**
- Active tab icon scales up (1.1x) with `.spring` animation
- Colors switch between `Color.primaryBlue` (active) and `Color.navy.opacity(0.35)` (inactive)

---

### `Views/NotesView.swift`

The main split view — the most complex view in the app.

**Layout:**
```
HStack(spacing: 0) {
    SidePanel (Study Task)    → width = totalWidth × leftFraction
    FinderGuyDivider          → width = 56pt fixed
    SidePanel (Developer)     → width = totalWidth × rightFraction
}
```

**Side Panel Structure:**
Each panel has:
- Header with type label + "+" button
- `ScrollView` with `LazyVStack` of `NoteCardView`
- Empty state when no notes exist

**Finder Guy Divider:**
- Fixed 56pt wide strip between panels
- Contains `FinderGuyView` mascot
- Attached `DragGesture` for horizontal drag tracking
- Subtle gradient background

**DragGesture Logic:**
```swift
DragGesture()
    .onChanged { value in
        viewModel.dragOffset = value.translation.width
    }
    .onEnded { value in
        viewModel.handleDragEnd(totalWidth: screenWidth)
    }
```

**Panels hide** when their fraction drops below 0.05 (5%), creating the full-screen effect with transitions.

---

### `Views/BoardView.swift`

The zigzag board layout — shows all notes in alternating 2-column rows.

**How it works:**
1. Calls `viewModel.zigzagPairs(from: allNotes)` to get layout pairs
2. Renders each pair as an `HStack` of two `NoteCardView`s
3. Cards show type badge (`showTypeBadge: true`)
4. Tappable cards open `NoteDetailSheet`

---

### `Views/HistoryView.swift`

The timeline view with filter chips.

**Layout:**
```
VStack {
    Header ("History")
    Filter Chips Row (horizontal scroll)
    Divider
    Timeline List (vertical scroll)
}
```

**Filter Chips:**
- Rendered as `Capsule()` buttons
- Active chip: filled `Color.primaryBlue` with white text
- Inactive: `Color.navy.opacity(0.06)` background

**Timeline Rows:**
Each row has:
- Colored dot indicator (blue for StudyTask, navy for Developer)
- Title + type icon
- Formatted date ("14 Jun 2026 at 15:54")
- Content preview (2 lines max)
- Separator line between items

---

### `Views/NoteCardView.swift`

Reusable card component used in all three views.

**Parameters:**
| Parameter | Default | Purpose |
|-----------|---------|---------|
| `note` | (required) | The note to display |
| `showTypeBadge` | `false` | Show type indicator dot + label |
| `compact` | `false` | Smaller fonts and padding |

**Styling:**
- White background with `cornerRadius: 14` (continuous)
- Shadow: `Color.navy.opacity(0.1)`, radius 6, y-offset 3
- Border: subtle stroke matching note type color
- Title in `.headline`, content in `.subheadline`

---

### `Views/FinderGuyView.swift`

The mascot placeholder view.

**Current Implementation:**
- SF Symbol `person.circle.fill` with gradient fill (blue → navy)
- Small `arrow.left.and.right` icon below as drag hint
- ~48pt size with shadow

**Future:** Replace with actual Finder Guy image asset.

---

### `Views/AddNoteView.swift`

Modal sheet for creating new notes.

**Flow:**
1. Receives `noteType` parameter ("StudyTask" or "Developer")
2. Shows type indicator in header
3. Title `TextField` auto-focuses on appear
4. Content `TextEditor` with placeholder overlay
5. Save button disabled when title is empty
6. On save: creates `Note` → `modelContext.insert()` → dismisses sheet

**Sheet Configuration:**
- `.presentationDetents([.medium, .large])` — resizable sheet
- `.presentationDragIndicator(.visible)` — drag handle shown

---

## Extensions

### `Extensions/Color+Extensions.swift`

Custom color system with hex support.

**Hex Initializer:**
Supports 3-digit (RGB), 6-digit (RGB), and 8-digit (ARGB) hex strings.

**Color Palette:**
| Constant | Hex | Usage |
|----------|-----|-------|
| `primaryBlue` | `#318AEB` | Active states, accents, buttons |
| `navy` | `#0C2957` | Text, dark elements |
| `lightBlue` | `#9EC8EC` | Subtle backgrounds |
| `appWhite` | `#FFFFFF` | Cards, main background |

**Semantic Colors:**
| Constant | Derived From | Usage |
|----------|-------------|-------|
| `studyTaskBackground` | `lightBlue` @ 25% | Study Task card backgrounds |
| `developerBackground` | `navy` @ 8% | Developer card backgrounds |
| `studyTaskBadge` | `primaryBlue` | Study Task type indicators |
| `developerBadge` | `navy` | Developer type indicators |
| `bottomNavBackground` | `white` @ 92% | Bottom nav (fallback) |
| `cardShadow` | `navy` @ 10% | Card shadows |
