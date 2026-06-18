# Development Guide

> How to extend, modify, and contribute to Finder Guy Notes. Includes step-by-step recipes for common tasks.

---

## Table of Contents

1. [Adding a New Note Field](#adding-a-new-note-field)
2. [Adding a New View/Screen](#adding-a-new-viewscreen)
3. [Adding a New Tab](#adding-a-new-tab)
4. [Implementing Delete Notes](#implementing-delete-notes)
5. [Implementing Edit Notes](#implementing-edit-notes)
6. [Implementing Pin Notes](#implementing-pin-notes)
7. [Implementing Search](#implementing-search)
8. [Adding Tags/Labels](#adding-tagslabels)
9. [Adding Dark Mode](#adding-dark-mode)
10. [Replacing Finder Guy Placeholder](#replacing-finder-guy-placeholder)
11. [Code Conventions Checklist](#code-conventions-checklist)

---

## Adding a New Note Field

**Example**: Add a `category` field (String) to Note.

### Step 1: Update Model

```swift
// Models/Note.swift
@Model
final class Note {
    // ... existing fields ...
    var category: String  // NEW
    
    init(title: String, content: String, type: String) {
        // ... existing init ...
        self.category = ""  // Default value REQUIRED
    }
}
```

**Rules:**
- New fields MUST have a default value
- SwiftData auto-migrates for simple additions
- No version bump needed

### Step 2: Update AddNoteView (if user-facing)

```swift
// Views/AddNoteView.swift
@State private var category: String = ""

// Add a Picker or TextField in the form
Picker("Category", selection: $category) {
    Text("General").tag("")
    Text("Urgent").tag("urgent")
    Text("Idea").tag("idea")
}

// Update saveNote()
let note = Note(
    title: trimmedTitle,
    content: content.trimmingCharacters(in: .whitespaces),
    type: noteType
)
note.category = category  // Set after init
```

### Step 3: Update NoteCardView (if displayable)

```swift
// Views/NoteCardView.swift — show category badge
if !note.category.isEmpty {
    Text(note.category)
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Capsule().fill(Color.lightBlue.opacity(0.3)))
}
```

---

## Adding a New View/Screen

### Step 1: Create the File

Create `Views/MyNewView.swift`:

```swift
import SwiftUI
import SwiftData

struct MyNewView: View {
    @Query(sort: \Note.date, order: .reverse) private var allNotes: [Note]
    @Bindable var viewModel: NotesViewModel
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                // Your content here
            }
        }
    }
}
```

### Step 2: Wire It Up

Add to `ContentView.swift`:

```swift
// In the switch statement:
case 3:
    MyNewView(viewModel: viewModel)

// In bottomNavBar, add another navItem:
navItem(title: "New", icon: "star", tab: 3)
```

---

## Adding a New Tab

### Step 1: Update ViewModel

```swift
// ViewModels/NotesViewModel.swift
// selectedTab now supports 0, 1, 2, 3
```

### Step 2: Update ContentView

```swift
// Views/ContentView.swift

// In switch:
case 3:
    MyNewView(viewModel: viewModel)

// In bottomNavBar HStack, add:
navItem(title: "New Tab", icon: "star.fill", tab: 3)
```

### Step 3: Adjust Nav Bar (if needed)

For 4+ tabs, consider smaller icons or horizontal scroll:

```swift
.frame(height: 56)
// Consider reducing spacing or font size for 4+ tabs
```

---

## Implementing Delete Notes

### Option A: Swipe to Delete

```swift
// In NotesView.swift or HistoryView.swift, add to each card:
.swipeActions(edge: .trailing, allowsFullSwipe: true) {
    Button(role: .destructive) {
        modelContext.delete(note)
    } label: {
        Label("Delete", systemImage: "trash")
    }
}
```

Add `@Environment(\.modelContext) private var modelContext` to the view.

### Option B: Context Menu (Long Press)

```swift
.contextMenu {
    Button(role: .destructive) {
        modelContext.delete(note)
    } label: {
        Label("Delete Note", systemImage: "trash")
    }
}
```

### Option C: Edit Mode

```swift
@State private var editMode: EditMode = .inactive

// In List:
.environment(\.editMode, $editMode)
.onDelete { indexSet in
    for index in indexSet {
        modelContext.delete(notes[index])
    }
}
```

---

## Implementing Edit Notes

### Step 1: Create EditNoteView

Copy `AddNoteView.swift` and modify:

```swift
struct EditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    let note: Note  // Existing note to edit
    
    @State private var title: String
    @State private var content: String
    
    init(note: Note) {
        self.note = note
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.content)
    }
    
    private func saveChanges() {
        note.title = title.trimmingCharacters(in: .whitespaces)
        note.content = content.trimmingCharacters(in: .whitespaces)
        // SwiftData auto-saves
        dismiss()
    }
}
```

### Step 2: Wire Up Navigation

```swift
// In NoteDetailSheet, add an Edit button:
.toolbar {
    ToolbarItem(placement: .confirmationAction) {
        Button("Edit") {
            isEditing = true
        }
    }
}
.sheet(isPresented: $isEditing) {
    EditNoteView(note: note)
}
```

---

## Implementing Pin Notes

### Step 1: Model Already Has `isPinned`

```swift
// Models/Note.swift — already defined:
var isPinned: Bool = false
```

### Step 2: Add Pin Toggle

```swift
// In NoteCardView or context menu:
Button {
    note.isPinned.toggle()
} label: {
    Label(
        note.isPinned ? "Unpin" : "Pin",
        systemImage: note.isPinned ? "pin.slash.fill" : "pin.fill"
    )
}
```

### Step 3: Sort Pinned First

```swift
// In NotesViewModel, update sorting:
func studyTaskNotes(from notes: [Note]) -> [Note] {
    notes
        .filter { $0.isStudyTask }
        .sorted { 
            if $0.isPinned != $1.isPinned { return $0.isPinned }
            return $0.date > $1.date
        }
}
```

### Step 4: Visual Indicator

Add pin icon to `NoteCardView`:

```swift
if note.isPinned {
    Image(systemName: "pin.fill")
        .font(.caption2)
        .foregroundColor(.primaryBlue)
}
```

---

## Implementing Search

### Step 1: Add Search State to ViewModel

```swift
// ViewModels/NotesViewModel.swift
var searchText: String = ""

func searchResults(from notes: [Note]) -> [Note] {
    guard !searchText.isEmpty else { return notes }
    let query = searchText.lowercased()
    return notes.filter {
        $0.title.lowercased().contains(query) ||
        $0.content.lowercased().contains(query)
    }
}
```

### Step 2: Add Search Bar to View

```swift
// In NotesView or ContentView:
.searchable(text: $viewModel.searchText, prompt: "Search notes...")
```

Or custom search bar:

```swift
HStack {
    Image(systemName: "magnifyingglass")
        .foregroundColor(.navy.opacity(0.3))
    TextField("Search notes...", text: $viewModel.searchText)
}
.padding(12)
.background(Capsule().fill(Color.navy.opacity(0.05)))
```

---

## Adding Tags/Labels

### Step 1: Add Tags to Model

```swift
@Model
final class Note {
    // ... existing fields ...
    var tags: [String] = []
}
```

### Step 2: Tag Input in AddNoteView

```swift
@State private var tagInput: String = ""

// Add tag input
HStack {
    TextField("Add tag (e.g., #idea)", text: $tagInput)
    Button("Add") {
        let tag = tagInput.trimmingCharacters(in: .whitespaces)
        if !tag.isEmpty { tags.append(tag) }
        tagInput = ""
    }
}

// Show tags as chips
FlowRow {
    ForEach(tags, id: \.self) { tag in
        Text("#\(tag)")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.lightBlue.opacity(0.3)))
    }
}
```

---

## Adding Dark Mode

### Current State
The app uses hardcoded light colors. To support dark mode:

### Step 1: Use Semantic Colors

Replace hardcoded colors with adaptive ones:

```swift
// Instead of:
Color.appWhite

// Use:
Color(.systemBackground)

// Instead of:
Color.navy

// Use adaptive:
Color.primary  // or define light/dark variants
```

### Step 2: Define Color Variants

```swift
extension Color {
    static let cardBackground = Color("CardBackground") // Asset catalog color with light/dark variants
    static let primaryText = Color("PrimaryText")
}
```

Create these in `Assets.xcassets` with "Any Appearance" and "Dark" variants.

### Step 3: Test

Toggle dark mode in simulator: **Features → Toggle Appearance**

---

## Replacing Finder Guy Placeholder

### Current: SF Symbol

```swift
// Views/FinderGuyView.swift
Image(systemName: "person.circle.fill")
```

### To Use Custom Image

1. Add your `finderGuy.png` (or PDF) to `Assets.xcassets/finderGuy.imageset/`
2. Update the view:

```swift
struct FinderGuyView: View {
    var body: some View {
        Image("finderGuy")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 48, height: 48)
            .shadow(color: .primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
```

### Recommended Asset Specs
- Format: PNG with transparency
- Sizes: 48×48 (@1x), 96×96 (@2x), 144×144 (@3x)
- Style: Should look good at small sizes

---

## Code Conventions Checklist

Before committing changes, verify:

- [ ] Using `@Observable` (NOT `ObservableObject`)
- [ ] Using `@Bindable` (NOT `@ObservedObject`)
- [ ] Using `@Query` at view level (NOT in ViewModel)
- [ ] Using `NoteType.studyTask` / `NoteType.developer` constants
- [ ] Using `Color.primaryBlue` etc. (NOT hardcoded hex)
- [ ] Following file naming: PascalCase + descriptive suffix
- [ ] Adding `// MARK: -` section comments
- [ ] Testing on iOS 17+ simulator
- [ ] No UIKit imports unless absolutely necessary
- [ ] Trimmed whitespace on user input before saving

---

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/add-search

# Make changes, commit
git add .
git commit -m "feat: add search functionality"

# Push and create PR
git push origin feature/add-search
```

### Commit Message Format

| Type | Usage |
|------|-------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `refactor:` | Code restructuring |
| `docs:` | Documentation changes |
| `style:` | Formatting, no logic change |
| `chore:` | Build/config changes |
