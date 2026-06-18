# Getting Started

> Step-by-step guide to set up and run Finder Guy Notes on your machine.

---

## Prerequisites

| Requirement | Version | Why |
|-------------|---------|-----|
| macOS | 13.0+ (Ventura) | Xcode 15 requires it |
| Xcode | 15.0+ | SwiftData support |
| iOS Simulator | iOS 17.0+ | App deployment target |
| Git | Any | Version control |

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/raiyayusuf/FinderGuyNotes.git
cd FinderGuyNotes
```

---

## Step 2: Create the Xcode Project

Since the repository contains only source files (not the `.xcodeproj`), you need to create a new Xcode project and import them.

### 2.1 Create New Project

1. Open **Xcode**
2. Go to **File → New → Project** (or press `Cmd + Shift + N`)
3. Select **iOS** tab at the top
4. Choose **App** → click **Next**

### 2.2 Configure Project

| Field | Value |
|-------|-------|
| Product Name | `FinderGuyNotes` |
| Team | (select your Apple ID or "None") |
| Organization Identifier | `com.yourname` |
| Interface | **SwiftUI** |
| Language | **Swift** |
| Storage | **SwiftData** |

> **Important**: Select **SwiftData** for Storage. This auto-configures the SwiftData framework. If you accidentally select "None", you can add SwiftData capability later in project settings.

### 2.3 Save Location

Save the project in the **parent directory** of the cloned repo, or anywhere convenient. You'll be copying files from the repo into this project.

---

## Step 3: Import Source Files

### 3.1 Delete Default Files

In the Xcode project navigator, **right-click** and delete these auto-generated files (choose **Move to Trash**):

- `ContentView.swift`
- `FinderGuyNotesApp.swift` (or the `*App.swift` file)

### 3.2 Drag Folders into Xcode

From the cloned repo folder, drag these **folders** into the Xcode project navigator (left sidebar):

```
Drag these folders:
  App/
  Models/
  ViewModels/
  Views/
  Extensions/
```

When the dialog appears:
- Select **"Create groups"** (NOT "Create folder references")
- Ensure **"Copy items if needed"** is checked
- Check the **FinderGuyNotes** target under "Add to targets"

### 3.3 Replace Assets

1. In Xcode, click on `Assets.xcassets` in the navigator
2. Delete the default `AccentColor` colorset
3. From the repo's `Resources/Assets.xcassets/` folder, drag in:
   - `AccentColor.colorset/`
   - `finderGuy.imageset/`
   - `Contents.json` (replace the existing one)

---

## Step 4: Configure Deployment Target

1. Click on the project name **FinderGuyNotes** in the navigator (top of left sidebar)
2. Select the **FinderGuyNotes** target under "Targets"
3. Go to **General** tab
4. Set **Minimum Deployments** to **iOS 17.0**

> SwiftData requires iOS 17+. The app will NOT compile on iOS 16 or below.

---

## Step 5: Verify SwiftData Capability

1. Go to **Signing & Capabilities** tab
2. Check if **SwiftData** is listed under capabilities
3. If not, click **+ Capability** and search for "SwiftData" to add it

> If you selected "SwiftData" as Storage in Step 2.2, this should already be configured.

---

## Step 6: Build and Run

1. Select a simulator (e.g., **iPhone 15 Pro** or **iPhone 16**)
2. Press `Cmd + R` to build and run
3. The app should launch with:
   - Split view showing "Study Task" (left) and "Developer" (right)
   - Empty states on both sides ("No notes yet")
   - Bottom navigation: Notes | Board | History

---

## Step 7: Test the Features

### Add a Note
1. Tap the **+** button on the left side (Study Task)
2. Enter a title (e.g., "iOS learning notes")
3. Enter content
4. Tap **Save**
5. The card should appear in the Study Task column

### Test Finder Guy Drag
1. Press and drag the **Finder Guy icon** (center) to the right
2. If dragged >30% of screen width, Study Task goes full screen
3. Drag back to left past 30% to see Developer full screen
4. Release gently (< 30%) to snap back to 50:50

### Board View
1. Tap **Board** in the bottom nav
2. See notes in zigzag 2-column layout

### History View
1. Tap **History** in the bottom nav
2. Use filter chips: All, Study Task, Developer, Merged
3. Tap any note to see detail

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "No such module 'SwiftData'" | Set deployment target to iOS 17.0+ |
| "Cannot find type 'Note'" | Make sure `Models/Note.swift` is in the target |
| Duplicate ContentView error | Delete the default `ContentView.swift` |
| Build succeeds but black screen | Check that `FinderGuyNotesApp.swift` has `@main` |
| Assets not showing | Re-drag the Assets.xcassets folder properly |

---

## Next Steps

- Read [Architecture Overview](architecture.md) to understand the app structure
- Read [Core Components](core-components.md) for detailed file-by-file breakdown
- Read [User Interface Guide](user-interface.md) for UI/UX patterns
