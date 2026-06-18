# AGENTS.md — Finder Guy Notes

> Instructions and conventions for AI coding agents (Qoder, Copilot, Cursor, Claude, etc.) working on this repository.

---

## Project Overview

**Finder Guy Notes** is a SwiftUI + SwiftData iOS 17+ notes app with a dual-panel split view:
- **Study Task** (left) — ideas, college tasks, personal notes
- **Developer** (right) — coding, tech stack, debugging, Xcode notes

The app has 3 main views: **Notes** (split view), **Board** (zigzag layout), and **History** (timeline with filters).

---

## Tech Stack

- **SwiftUI** — all UI is declarative SwiftUI
- **SwiftData** — persistence via `@Model` and `@Query` (NOT CoreData)
- **`@Observable` macro** — state management (NOT `ObservableObject`/`@Published`)
- **`@Bindable`** — for passing `@Observable` VM to child views
- **iOS 17+** minimum deployment target
- **SF Symbols** for all icons (no custom icon assets yet)

---

## Architecture & Patterns

### Pattern: MVVM
```
Views → ViewModel (@Observable) → SwiftData (@Query, modelContext)
```

### Key Rules
1. **Do NOT use `ObservableObject` or `@Published`** — this project uses the modern `@Observable` macro
2. **Do NOT use `@ObservedObject`** — use `@Bindable` for passing VM to child views
3. **Do NOT use CoreData** — all persistence is SwiftData (`@Model`, `@Query`, `modelContext`)
4. **Use `@Environment(\.modelContext)`** for database operations inside views
5. **Use `@Query`** at the view level for reactive data fetching

### File Organization
```
App/              → Entry point only (@main)
Models/           → SwiftData @Model classes
ViewModels/       → @Observable classes (shared state + logic)
Views/            → SwiftUI view structs
Extensions/       → Swift extensions (Color, etc.)
Resources/        → Assets.xcassets and other resources
```

---

## Naming Conventions

### Files
- Models: PascalCase (`Note.swift`, `Tag.swift`)
- ViewModels: PascalCase + "ViewModel" suffix (`NotesViewModel.swift`)
- Views: PascalCase + descriptive (`NotesView.swift`, `NoteCardView.swift`)
- Extensions: Type + "+Extensions" (`Color+Extensions.swift`)

### Types
- Note types are **String constants**, not enums: `"StudyTask"` and `"Developer"`
- Use `NoteType.studyTask` and `NoteType.developer` constants (defined in `Note.swift`)
- Check type with computed properties: `note.isStudyTask`, `note.isDeveloper`

### Colors
- Use semantic color names from `Color+Extensions.swift`:
  - `Color.primaryBlue` (#318AEB)
  - `Color.navy` (#0C2957)
  - `Color.lightBlue` (#9EC8EC)
  - `Color.appWhite` (#FFFFFF)
- Use semantic aliases: `Color.studyTaskBadge`, `Color.developerBadge`, `Color.cardShadow`
- **Do NOT hardcode hex values** in views — always use the defined constants

---

## Code Style

### Formatting
- 4 spaces for indentation
- `// MARK: -` comments to separate sections
- Trailing closures for SwiftUI modifiers
- Group related modifiers together

### SwiftUI Conventions
- Use `some View` return types (not explicit types)
- Use `@ViewBuilder` for complex view builders
- Prefer `.padding(.horizontal, 16)` over `.padding([.leading, .trailing], 16)`
- Use `.foregroundColor()` (project uses this style, not `.foregroundStyle()` except for gradients)

### SwiftData Conventions
- Insert: `modelContext.insert(note)`
- Delete: `modelContext.delete(note)`
- Query: `@Query(sort: \Note.date, order: .reverse) private var notes: [Note]`
- Always use `@Query` at the **View** level, not in ViewModel

---

## Gesture Implementation

### Finder Guy DragGesture
The split view uses `DragGesture` (NOT swipe or tap) for the Finder Guy mascot:
- `dragOffset` tracks real-time finger position (dampened by /800)
- `handleDragEnd()` decides snap behavior based on 30% screen width threshold
- Animation: `.spring(response: 0.4, dampingFraction: 0.8)`
- Three states: `.balanced` (50:50), `.studyTaskFull`, `.developerFull`

**Do NOT change** the gesture type — DragGesture is intentional for real-time visual feedback.

---

## Color Palette

| Name | Hex | Constant |
|------|-----|----------|
| Primary Blue | `#318AEB` | `Color.primaryBlue` |
| Navy | `#0C2957` | `Color.navy` |
| Light Blue | `#9EC8EC` | `Color.lightBlue` |
| White | `#FFFFFF` | `Color.appWhite` |

All colors are defined in `Extensions/Color+Extensions.swift`.

---

## Adding New Features

### New View
1. Create file in `Views/` folder
2. Use `@Bindable var viewModel: NotesViewModel` if VM access is needed
3. Use `@Query` directly in the view for SwiftData queries
4. Follow existing card styling patterns (`NoteCardView` as reference)

### New Model Field
1. Add property to `@Model final class Note` in `Models/Note.swift`
2. Update `init()` with default value
3. SwiftData handles migration automatically for new optional fields

### New Tab/View
1. Add case to `selectedTab` logic in `ContentView.swift`
2. Create new view file in `Views/`
3. Add nav item in `bottomNavBar` with appropriate SF Symbol

---

## Do NOT

- Do NOT add external dependencies without discussion
- Do NOT change the split view gesture mechanism
- Do NOT rename `StudyTask` or `Developer` type strings (breaking change for persisted data)
- Do NOT use UIKit components unless absolutely necessary
- Do NOT add CoreData alongside SwiftData
- Do NOT modify the bottom nav structure without updating `ContentView.swift`

---

## Testing

Currently no unit tests are set up. When adding tests:
- Test ViewModel logic (filtering, zigzag pairs, drag threshold)
- Test Note model computed properties (date formatting, type checks)
- Place test files in a `Tests/` folder

---

## Git Conventions

- Commit messages: `type: description` (e.g., `feat: add search`, `fix: drag gesture snap`)
- Branch naming: `feature/feature-name`, `fix/issue-description`
- Keep commits atomic — one logical change per commit

---

## Questions?

If you're an AI agent and unsure about something:
1. Check existing code patterns first
2. Follow the naming and style conventions above
3. When in doubt, ask the user for clarification
4. Prefer consistency with existing code over "better" alternatives
