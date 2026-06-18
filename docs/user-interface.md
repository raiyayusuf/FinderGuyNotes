# User Interface Guide

> Complete UI/UX documentation — layouts, gestures, animations, color system, and design patterns.

---

## Screen Overview

The app has 3 main screens accessed via bottom navigation:

| Screen | Tab | Purpose |
|--------|-----|---------|
| **Notes** | `note.text` | Split view: Study Task (left) + Developer (right) |
| **Board** | `square.grid.2x2` | Zigzag 2-column layout of all notes |
| **History** | `clock.arrow.circlepath` | Chronological timeline with filters |

---

## Notes View (Split View)

### Layout Structure

```
┌──────────────────────────────────────────┐
│ ┌─────────────┬────┬─────────────┐       │
│ │ Study Task  │ FG │ Developer   │       │
│ │ + [Add]     │    │ + [Add]     │       │
│ │ ┌─────────┐ │    │ ┌─────────┐ │       │
│ │ │ Card 1  │ │    │ │ Card 1  │ │       │
│ │ └─────────┘ │    │ └─────────┘ │       │
│ │ ┌─────────┐ │    │ ┌─────────┐ │       │
│ │ │ Card 2  │ │    │ │ Card 2  │ │       │
│ │ └─────────┘ │    │ └─────────┘ │       │
│ └─────────────┴────┴─────────────┘       │
│        [Notes] [Board] [History]          │
└──────────────────────────────────────────┘
```

### Split Modes

| Mode | Left Width | Right Width | How to Trigger |
|------|-----------|-------------|----------------|
| Balanced (50:50) | 50% | 50% | Default / drag back < 30% |
| Study Task Full | ~100% | 0% | Drag Finder Guy right > 30% |
| Developer Full | 0% | ~100% | Drag Finder Guy left > 30% |

### Finder Guy Drag Gesture

**How it works step-by-step:**

1. **User touches Finder Guy** → `DragGesture` begins
2. **Finger moves** → `.onChanged` fires continuously:
   ```swift
   viewModel.dragOffset = value.translation.width
   ```
3. **Split ratio updates** in real-time:
   ```swift
   leftFraction = splitRatio + (dragOffset / 800)
   ```
   The `/800` dampens the movement so it feels smooth, not jumpy.

4. **Finger lifts** → `.onEnded` fires:
   ```swift
   if dragOffset > screenWidth * 0.3 {
       splitMode = .studyTaskFull    // Snap left to full
   } else if dragOffset < -screenWidth * 0.3 {
       splitMode = .developerFull    // Snap right to full
   } else {
       splitMode = .balanced         // Snap back to 50:50
   }
   dragOffset = 0
   ```

5. **Spring animation** applies:
   ```swift
   .spring(response: 0.4, dampingFraction: 0.8)
   ```

### Side Panels

Each panel (Study Task / Developer) contains:

**Header:**
- Type indicator dot (colored circle)
- Type name + subtitle (e.g., "ideas · tasks · notes")
- "+" button to add new note

**Content Area:**
- `ScrollView` with `LazyVStack`
- `NoteCardView` for each note
- Independent scrolling per side

**Empty State:**
- SF Symbol icon (book or code brackets)
- "No notes yet" message
- Hint to tap "+"

### Panel Visibility

Panels hide when their width fraction drops below 5%:
```swift
if viewModel.leftFraction > 0.05 {
    sidePanel(...)
}
```
Combined with `.transition(.move.combined(with: .opacity))` for smooth show/hide.

---

## Board View (Zigzag Layout)

### Layout Pattern

```
Row 0 (even): ┌──────────┬──────────┐
              │StudyTask │Developer │
              └──────────┴──────────┘
Row 1 (odd):  ┌──────────┬──────────┐
              │Developer │StudyTask │
              └──────────┴──────────┘
Row 2 (even): ┌──────────┬──────────┐
              │StudyTask │Developer │
              └──────────┴──────────┘
```

### How Zigzag Works

The `zigzagPairs(from:)` method in ViewModel:
1. Separates notes into Study Task and Developer arrays
2. Pairs them row by row, alternating positions:
   - Even index (0, 2, 4...): StudyTask left, Developer right
   - Odd index (1, 3, 5...): Developer left, StudyTask right
3. If one side runs out, the other fills the remaining slots

### Card Differences from Notes View

Board cards have:
- `showTypeBadge: true` — shows colored dot + type label
- Full content visible (not truncated as much)
- Independent heights (flexible per note length)

---

## History View (Timeline)

### Filter Chips

```
┌──────┬─────────────┬────────────┬──────────┐
│ All  │ Study Task  │ Developer  │ Merged   │
└──────┴─────────────┴────────────┴──────────┘
```

**Styling:**
- Active: `Color.primaryBlue` fill, white text, `.semibold`
- Inactive: `Color.navy.opacity(0.06)` fill, muted text, `.regular`
- Capsule shape
- Horizontal scroll (in case of overflow)

### Timeline Rows

Each row consists of:

```
●  Title                          [icon]
   14 Jun 2026 at 15:54
   Content preview text...
─────────────────────────────────────────
```

- **Dot**: 8pt circle, colored by note type
- **Title**: `.headline`, navy, max 2 lines
- **Type icon**: book (StudyTask) or code brackets (Developer)
- **Date**: `.caption`, muted, format "d MMM yyyy at HH:mm"
- **Preview**: `.caption`, muted, max 2 lines
- **Separator**: 1pt line between items

---

## Bottom Navigation Bar

### Design

```
╭──────────────────────────────────────────╮
│   📝          ▦           🕐            │
│  Notes       Board       History        │
╰──────────────────────────────────────────╯
```

**Styling:**
- Background: `.ultraThinMaterial` (Liquid Glass effect)
- Shape: `RoundedRectangle(cornerRadius: 20, style: .continuous)`
- Shadow: `cardShadow`, radius 12, y-offset -4
- Padding: 16pt horizontal, 8pt from bottom

### Tab Animation

```swift
.scaleEffect(isActive ? 1.1 : 1.0)
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
```

Active tab:
- Icon scales up 10%
- Color switches to `primaryBlue`
- Font weight becomes `.semibold`

Inactive tab:
- `Color.navy.opacity(0.35)`
- `.regular` weight
- Normal scale

---

## Note Card Design

### Anatomy

```
╭──────────────────────────────────╮
│ ● Study Task                     │  ← Type badge (optional)
│                                  │
│ Note Title Here                  │  ← .headline, navy, bold
│                                  │
│ Note content text goes here      │  ← .subheadline, navy 70%
│ and continues on multiple        │
│ lines...                         │
│                                  │
│                          14 Jun  │  ← .caption2, navy 40%
╰──────────────────────────────────╯
```

### Styling Details

| Element | Value |
|---------|-------|
| Corner radius | 14 (continuous) |
| Background | `Color.appWhite` |
| Shadow | `navy.opacity(0.1)`, radius 6, y: 3 |
| Border (StudyTask) | `primaryBlue.opacity(0.15)` |
| Border (Developer) | `navy.opacity(0.1)` |
| Padding | 16pt (normal), 12pt (compact) |

---

## Add Note Sheet

### Layout

```
╭──────────────────────────────────╮
│ Cancel          New Note    Save │  ← Navigation bar
├──────────────────────────────────┤
│ ● Study Task Note                │  ← Type header
│ ──────────────────────────────── │
│                                  │
│ Note title...                    │  ← .title3, auto-focused
│                                  │
│ Write your note here...          │  ← TextEditor with
│                                  │     placeholder overlay
│                                  │
│                                  │
│                                  │
╰──────────────────────────────────╯
```

### Behavior
- **Presentation**: `.medium` and `.large` detents
- **Drag indicator**: Visible
- **Auto-focus**: Title field focused on appear
- **Save button**: Disabled until title has text
- **Keyboard**: Dismisses automatically when sheet closes (`.ignoresSafeArea(.keyboard)` on root)

---

## Color System

### Primary Palette

| Swatch | Name | Hex | Usage |
|--------|------|-----|-------|
| 🟦 | Primary Blue | `#318AEB` | Active buttons, accents, filter chips |
| 🟫 | Navy | `#0C2957` | Text, dark elements, Developer badge |
| 🩵 | Light Blue | `#9EC8EC` | Subtle backgrounds, Study Task accent |
| ⬜ | White | `#FFFFFF` | Cards, main backgrounds |

### Semantic Colors

| Name | Formula | Usage |
|------|---------|-------|
| `studyTaskBackground` | lightBlue @ 25% | Study Task card subtle bg |
| `developerBackground` | navy @ 8% | Developer card subtle bg |
| `studyTaskBadge` | primaryBlue | Study Task indicators |
| `developerBadge` | navy | Developer indicators |
| `cardShadow` | navy @ 10% | All card shadows |
| `bottomNavBackground` | white @ 92% | Nav fallback |

---

## Animation Reference

| Element | Animation | Parameters |
|---------|-----------|------------|
| Split mode snap | `.spring` | response: 0.4, damping: 0.8 |
| Tab switch | `.easeInOut` | duration: 0.25 |
| Tab icon scale | `.spring` | response: 0.3, damping: 0.7 |
| Filter chip | `.easeInOut` | duration: 0.2 |
| Panel show/hide | `.move + .opacity` | transition combined |
| Tab button tap | `.spring` | response: 0.35, damping: 0.75 |

---

## SF Symbols Used

| Symbol | Location | Purpose |
|--------|----------|---------|
| `person.circle.fill` | FinderGuyView | Mascot placeholder |
| `arrow.left.and.right` | FinderGuyView | Drag hint |
| `plus.circle.fill` | NotesView headers | Add note button |
| `note.text` | ContentView nav | Notes tab icon |
| `square.grid.2x2` | ContentView nav, BoardView empty | Board tab icon |
| `clock.arrow.circlepath` | ContentView nav, HistoryView empty | History tab icon |
| `book.closed` | NotesView empty, HistoryView rows | Study Task icon |
| `chevron.left.forwardslash.chevron.right` | NotesView empty, HistoryView rows | Developer icon |
