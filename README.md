# Finder Guy Notes

> A dual-context notes app for iOS — because sometimes you're confused whether to be in "creative/study" mode or "developer" mode, so why not both?

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![SwiftData](https://img.shields.io/badge/persistence-SwiftData-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## Concept

**Finder Guy Notes** is a notes app with **2 sides in 1 screen** (split view):

| Left Side | Right Side |
|-----------|------------|
| **Study Task** | **Developer** |
| Ideas, college tasks, learning notes, personal notes | Coding, tech stack, logic, debugging, Xcode |

A draggable mascot called **Finder Guy** sits in the center and lets you toggle between split view and full-screen mode.

---

## Features

### Notes View (Split View)
- **50:50 split layout** by default — Study Task on the left, Developer on the right
- Each side has its own scrollable card list with an independent "+" button
- **Drag Finder Guy** horizontally to go full-screen on either side (>30% drag threshold)
- Finder Guy **never disappears** — always visible as a visual divider indicator
- Spring animations for smooth snap-back transitions

### Board View (Zigzag Layout)
- All notes displayed in a **2-column zigzag pattern** (2-2-2)
- Row 1: Study Task | Developer → Row 2: Developer | Study Task → repeat
- Each card shows full note content with flexible height
- Type badge on each card for visual identification

### History View (Timeline)
- Chronological timeline of all notes sorted by date (newest first)
- **4 filter chips**: All, Study Task, Developer, Merged
- Each row shows title, formatted date, and content preview
- Tap any note to view full detail in a sheet

### Add Notes
- Tap "+" on the left side → creates a Study Task note
- Tap "+" on the right side → creates a Developer note
- Modal sheet with title + content fields
- Auto-focuses title field on open

### Finder Guy Interaction
- Uses `DragGesture` (not swipe) for real-time finger tracking
- Smooth position tracking with `.onChanged`
- Snap decision on `.onEnded`: full-screen or back to 50:50
- Threshold: drag > 30% of screen width → full screen

---

## Architecture

```
MVVM + SwiftData
```

### Folder Structure
```
FinderGuyNotes/
├── App/
│   └── FinderGuyNotesApp.swift       # @main entry + modelContainer
├── Models/
│   └── Note.swift                     # @Model (SwiftData)
├── ViewModels/
│   └── NotesViewModel.swift          # @Observable shared state
├── Views/
│   ├── ContentView.swift              # Root + custom bottom nav
│   ├── NotesView.swift                # Split view + DragGesture
│   ├── BoardView.swift                # Zigzag 2-column layout
│   ├── HistoryView.swift              # Timeline + filter chips
│   ├── FinderGuyView.swift            # Mascot (SF Symbol placeholder)
│   ├── AddNoteView.swift              # Modal sheet for new notes
│   └── NoteCardView.swift             # Reusable card component
├── Extensions/
│   └── Color+Extensions.swift        # Hex init + color palette
└── Resources/
    └── Assets.xcassets/               # AccentColor, AppIcon, finderGuy
```

### Data Model

```swift
@Model
final class Note {
    var id: UUID
    var title: String
    var content: String
    var type: String      // "StudyTask" or "Developer"
    var date: Date
    var isPinned: Bool
}
```

### Key Patterns
- **SwiftData** `@Model` for persistence with `@Query` for reactive fetching
- **`@Observable` macro** for ViewModel (modern iOS 17+ approach)
- **`@Bindable`** for passing observable VM to child views
- **`GeometryReader`** for responsive split view sizing
- **`DragGesture`** with damped offset for smooth Finder Guy movement

---

## Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Primary Blue | `#318AEB` | Active buttons, accents, highlights |
| Navy | `#0C2957` | Text, shadows, dark elements |
| Light Blue | `#9EC8EC` | Card backgrounds, subtle accents |
| White | `#FFFFFF` | Main background, cards |

---

## Requirements

- **iOS 17.0+** (SwiftData support)
- **Xcode 15+**
- **Swift 5.9+**

---

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/raiyayusuf/FinderGuyNotes.git
cd FinderGuyNotes
```

### 2. Create Xcode Project
1. Open **Xcode** → File → New → Project
2. Select **iOS → App** → Next
3. Configure:
   - Product Name: `FinderGuyNotes`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData**
4. Save in the parent directory

### 3. Import Source Files
1. **Delete** the default `ContentView.swift` and `FinderGuyNotesApp.swift` from Xcode (Move to Trash)
2. **Drag** the following folders into the Xcode project navigator:
   - `App/`
   - `Models/`
   - `ViewModels/`
   - `Views/`
   - `Extensions/`
3. Choose **"Create groups"** and ensure the **FinderGuyNotes** target is checked
4. Replace the default `Assets.xcassets` contents with `Resources/Assets.xcassets/`

### 4. Configure
- Set **Deployment Target** to **iOS 17.0** in Project Settings → General

### 5. Build & Run
- Press `Cmd + R` or select a simulator and run

---

## Bottom Navigation

| Tab | Icon | Description |
|-----|------|-------------|
| Notes | `note.text` | Main split view (default) |
| Board | `square.grid.2x2` | Zigzag board layout |
| History | `clock.arrow.circlepath` | Timeline with filters |

Styled with `.ultraThinMaterial` background for a Liquid Glass-inspired look.

---

## Documentation

Detailed documentation lives in the [`docs/`](docs/) folder:

| Document | Description |
|----------|-------------|
| [Getting Started](docs/getting-started.md) | Step-by-step setup + first run guide |
| [Architecture Overview](docs/architecture.md) | MVVM pattern, data flow, design decisions |
| [Core Components](docs/core-components.md) | File-by-file breakdown of every source file |
| [Data Management](docs/data-management.md) | SwiftData deep dive: queries, CRUD, migration |
| [User Interface Guide](docs/user-interface.md) | Layouts, gestures, animations, color system |
| [Development Guide](docs/development-guide.md) | How to add features, extend, and contribute |

Also see [AGENTS.md](AGENTS.md) for AI coding agent conventions.

---

## Roadmap (Future Features)

- [ ] Pin Notes (pin icon on cards)
- [ ] Search Notes
- [ ] Edit Notes (tap card to edit)
- [ ] Delete Notes (swipe to delete)
- [ ] Tags / Labels (#study #task #idea)
- [ ] Dark Mode support
- [ ] Export / Share Notes
- [ ] Custom Finder Guy mascot asset (replace SF Symbol placeholder)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | SwiftUI |
| Persistence | SwiftData (@Model, @Query) |
| State Management | @Observable macro |
| Gesture | DragGesture |
| Target | iOS 17+ |
| Icons | SF Symbols |

---

## Inspiration

- **Finder Guy pin** from Apple's macOS — the friendly mascot that sits between views
- **Liquid Glass** layout from iOS 27 — translucent, blurred UI elements
- **WWDC 2026** vibes — modern, clean, colorful

---

## License

This project is open source and available under the [MIT License](LICENSE).

---

## Author

**Raiya Yusuf Priatmojo (Sinchan)** — [@raiyayusuf](https://github.com/raiyayusuf)

First iOS project — learning SwiftUI and SwiftData along the way!
