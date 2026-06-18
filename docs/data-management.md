# Data Management

> How Finder Guy Notes handles data persistence, queries, and state with SwiftData.

---

## Why SwiftData?

| Criteria | SwiftData | CoreData |
|----------|-----------|----------|
| Learning curve | Low (modern API) | High (legacy API) |
| Code verbosity | Minimal | Verbose |
| SwiftUI integration | Native (`@Query`) | Requires `@FetchRequest` |
| iOS minimum | 17.0+ | 3.0+ |
| Migration | Automatic | Manual |
| Macro support | `@Model` | N/A |

**Decision**: SwiftData, because the project targets iOS 17+ and prioritizes clean, modern code.

---

## Model Definition

### The Note Model (`Models/Note.swift`)

```swift
@Model
final class Note {
    var id: UUID
    var title: String
    var content: String
    var type: String      // "StudyTask" or "Developer"
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
```

### Key Points

1. **`@Model` macro**: Automatically makes the class a SwiftData persistent model. No need for `.xcdatamodeld` files.

2. **`final class`**: Required by SwiftData — models must be final.

3. **No `@Attribute` needed**: All properties are stored by default. Use `@Attribute(.unique)` only when needed.

4. **String for type**: Using String instead of enum avoids migration complexity. Constants in `NoteType` prevent typos.

---

## Setting Up the Container

### In `FinderGuyNotesApp.swift`:

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

**What this does:**
- Creates an in-memory or on-disk SQLite database
- Registers `Note` as a managed model type
- Makes `modelContext` available via `@Environment` throughout the view tree

---

## Reading Data (Queries)

### Basic Query

```swift
@Query(sort: \Note.date, order: .reverse) private var allNotes: [Note]
```

This fetches ALL notes, sorted by date descending. `@Query` is reactive — it auto-updates when data changes.

### Where Queries Are Used

| View | Query | Purpose |
|------|-------|---------|
| `NotesView` | `@Query(sort: \Note.date, order: .reverse)` | All notes for split panels |
| `BoardView` | `@Query(sort: \Note.date, order: .reverse)` | All notes for zigzag layout |
| `HistoryView` | `@Query(sort: \Note.date, order: .reverse)` | All notes for timeline |

### Filtering Strategy

Instead of using `@Query` predicates, filtering happens in the ViewModel:

```swift
// In NotesViewModel
func studyTaskNotes(from notes: [Note]) -> [Note] {
    notes.filter { $0.isStudyTask }.sorted { $0.date > $1.date }
}
```

**Why**: Keeps queries simple and lets the ViewModel handle presentation logic. For a notes app with hundreds (not millions) of items, in-memory filtering is fine.

### Alternative: Predicate-based Query

If performance becomes an issue with many notes, you can use predicates:

```swift
@Query(filter: #Predicate<Note> { $0.type == "StudyTask" },
       sort: \Note.date, order: .reverse)
private var studyTaskNotes: [Note]
```

---

## Writing Data (Insert)

### In `AddNoteView.swift`:

```swift
@Environment(\.modelContext) private var modelContext

private func saveNote() {
    let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
    guard !trimmedTitle.isEmpty else { return }
    
    let note = Note(
        title: trimmedTitle,
        content: content.trimmingCharacters(in: .whitespaces),
        type: noteType
    )
    
    modelContext.insert(note)
    dismiss()
}
```

**Flow:**
1. Validate title is not empty
2. Create `Note` instance (not yet persisted)
3. `modelContext.insert(note)` — saves to SwiftData store
4. `@Query` in parent views auto-triggers re-render
5. Dismiss the sheet

---

## Deleting Data

Currently not implemented (roadmap feature). When added:

```swift
@Environment(\.modelContext) private var modelContext

func deleteNote(_ note: Note) {
    modelContext.delete(note)
    // @Query auto-updates
}
```

For swipe-to-delete in lists:

```swift
.onSwipeActions(edge: .trailing) {
    Button(role: .destructive) {
        modelContext.delete(note)
    } label: {
        Label("Delete", systemImage: "trash")
    }
}
```

---

## Updating Data

SwiftData tracks changes automatically. Just modify the property:

```swift
note.title = "Updated Title"
// SwiftData auto-saves on context change
```

No explicit `save()` call needed — SwiftData auto-persists changes to managed objects.

---

## Data Schema Evolution

### Adding New Fields

When adding a new property to `Note`:

```swift
@Model
final class Note {
    // ... existing fields ...
    var tags: [String] = []  // NEW: default value required
}
```

**Rules:**
- New properties MUST have a default value
- SwiftData handles lightweight migration automatically
- No migration code needed for simple additions

### Renaming Fields

**Warning**: Renaming a property will lose existing data. Use `@Attribute(originalName:)` to preserve:

```swift
@Attribute(originalName: "title")
var noteTitle: String
```

### Deleting Fields

Simply remove the property. SwiftData ignores the old column in the database.

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────┐
│                    User Actions                      │
│                                                      │
│  Tap "+" → AddNoteView → modelContext.insert(note)  │
│  Tap card → NoteDetailSheet (read-only)              │
│  (future) Swipe → modelContext.delete(note)          │
│  (future) Edit → note.title = "new" (auto-save)     │
│                                                      │
├─────────────────────────────────────────────────────┤
│                  SwiftData Store                     │
│                                                      │
│  ┌──────────────────────────────────────────┐       │
│  │  SQLite Database                          │       │
│  │  ┌─────────────────────────────────────┐  │       │
│  │  │  Note Table                          │  │       │
│  │  │  id | title | content | type | date  │  │       │
│  │  │  ─────────────────────────────────── │  │       │
│  │  │  ... | ... | ... | StudyTask | ...   │  │       │
│  │  │  ... | ... | ... | Developer | ...   │  │       │
│  │  └─────────────────────────────────────┘  │       │
│  └──────────────────────────────────────────┘       │
│                                                      │
├─────────────────────────────────────────────────────┤
│                  Reactive Queries                    │
│                                                      │
│  @Query → NotesView (filters by type)               │
│  @Query → BoardView (zigzag pairs)                  │
│  @Query → HistoryView (filter + sort)               │
│                                                      │
│  All views auto-update when data changes!           │
└─────────────────────────────────────────────────────┘
```

---

## Best Practices

1. **Always validate before insert** — check title is not empty
2. **Trim whitespace** — `title.trimmingCharacters(in: .whitespaces)`
3. **Use constants for type** — `NoteType.studyTask`, not `"StudyTask"`
4. **Don't query in ViewModel** — use `@Query` in views, pass to VM methods
5. **Let SwiftData auto-save** — no manual `try context.save()` needed for simple CRUD
6. **Use `@Environment(\.modelContext)`** — never create your own context
