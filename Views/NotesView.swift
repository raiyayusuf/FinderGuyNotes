/* ============================================
   Views/NotesView.swift
   SPLIT VIEW WITH FINDER GUY DRAG GESTURE
   ============================================ */

import SwiftUI
import SwiftData

/* ============================================
   NOTES VIEW
   ============================================ */
struct NotesView: View {
    @Query(sort: \Note.date, order: .reverse) private var allNotes: [Note]
    @Bindable var viewModel: NotesViewModel
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            
            ZStack {
                // Background color
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                HStack(spacing: 0) {
                    /* ============================================
                       LEFT PANEL — STUDY TASK
                       ============================================ */
                    if viewModel.leftFraction > 0.05 {
                        sidePanel(
                            type: NoteType.studyTask,
                            notes: viewModel.studyTaskNotes(from: allNotes),
                            isAddSheet: $viewModel.showAddStudyTask
                        )
                        .frame(width: totalWidth * viewModel.leftFraction)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    
                    /* ============================================
                       FINDER GUY DIVIDER
                       ============================================ */
                    finderGuyDivider(screenWidth: totalWidth)
                    
                    /* ============================================
                       RIGHT PANEL — DEVELOPER
                       ============================================ */
                    if viewModel.rightFraction > 0.05 {
                        sidePanel(
                            type: NoteType.developer,
                            notes: viewModel.developerNotes(from: allNotes),
                            isAddSheet: $viewModel.showAddDeveloper
                        )
                        .frame(width: totalWidth * viewModel.rightFraction)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.splitMode)
            }
        }
        // Add note sheets
        .sheet(isPresented: $viewModel.showAddStudyTask) {
            AddNoteView(noteType: NoteType.studyTask)
        }
        .sheet(isPresented: $viewModel.showAddDeveloper) {
            AddNoteView(noteType: NoteType.developer)
        }
        // Note detail sheet
        .sheet(item: $viewModel.selectedNote) { note in
            NoteDetailSheet(note: note)
        }
    }
    
    /* ============================================
       SIDE PANEL
       ============================================ */
    @ViewBuilder
    private func sidePanel(type: String, notes: [Note], isAddSheet: Binding<Bool>) -> some View {
        VStack(spacing: 0) {
            // Panel header
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(type == NoteType.studyTask ? Color.studyTaskBadge : Color.developerBadge)
                        .frame(width: 8, height: 8)
                    Text(type == NoteType.studyTask ? "Study Task" : "Developer")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.navy)
                    Text(type == NoteType.studyTask ? "ideas · tasks · notes" : "logic · tech · code")
                        .font(.caption)
                        .foregroundColor(.navy.opacity(0.5))
                }
                
                Spacer()
                
                // Add button
                Button {
                    isAddSheet.wrappedValue = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.primaryBlue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Notes list or empty state
            if notes.isEmpty {
                emptyStateView(type: type)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(notes) { note in
                            NoteCardView(note: note)
                                .onTapGesture {
                                    viewModel.selectedNote = note
                                }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    /* ============================================
       FINDER GUY DIVIDER
       ============================================ */
    @ViewBuilder
    private func finderGuyDivider(screenWidth: CGFloat) -> some View {
        VStack {
            Spacer()
            
            FinderGuyView()
                .padding(.horizontal, 4)
                .offset(x: viewModel.dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewModel.dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            viewModel.handleDragEnd(totalWidth: screenWidth)
                        }
                )
            
            Spacer()
        }
        .frame(width: 56)
        // Subtle gradient divider
        .background(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.primaryBlue.opacity(0.03),
                            Color.navy.opacity(0.05),
                            Color.primaryBlue.opacity(0.03)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
    
    /* ============================================
       EMPTY STATE
       ============================================ */
    @ViewBuilder
    private func emptyStateView(type: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: type == NoteType.studyTask ? "book.closed" : "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 40))
                .foregroundColor(.navy.opacity(0.15))
            
            Text("No notes yet")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.navy.opacity(0.3))
            
            Text("Tap + to add your first \(type == NoteType.studyTask ? "study" : "dev") note")
                .font(.caption)
                .foregroundColor(.navy.opacity(0.2))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

/* ============================================
   NOTE DETAIL SHEET
   ============================================ */
struct NoteDetailSheet: View {
    let note: Note
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Type badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(note.isStudyTask ? Color.studyTaskBadge : Color.developerBadge)
                            .frame(width: 8, height: 8)
                        Text(note.isStudyTask ? "Study Task" : "Developer")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(note.isStudyTask ? .studyTaskBadge : .developerBadge)
                    }
                    
                    // Note title
                    Text(note.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.navy)
                    
                    // Date label
                    Text(note.formattedDate)
                        .font(.caption)
                        .foregroundColor(.navy.opacity(0.4))
                    
                    Divider()
                    
                    // Note content
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.body)
                            .foregroundColor(.navy.opacity(0.8))
                            .lineSpacing(4)
                    } else {
                        Text("No content")
                            .font(.body)
                            .italic()
                            .foregroundColor(.navy.opacity(0.3))
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .background(Color.appWhite)
            .navigationTitle("Note Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.primaryBlue)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
import SwiftUI
import SwiftData

struct NotesView: View {
    @Query(sort: \Note.date, order: .reverse) private var allNotes: [Note]
    @Bindable var viewModel: NotesViewModel
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                HStack(spacing: 0) {
                    // LEFT: Study Task Side
                    if viewModel.leftFraction > 0.05 {
                        sidePanel(
                            type: NoteType.studyTask,
                            notes: viewModel.studyTaskNotes(from: allNotes),
                            isAddSheet: $viewModel.showAddStudyTask
                        )
                        .frame(width: totalWidth * viewModel.leftFraction)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    
                    // CENTER: Finder Guy (draggable divider)
                    finderGuyDivider(screenWidth: totalWidth)
                    
                    // RIGHT: Developer Side
                    if viewModel.rightFraction > 0.05 {
                        sidePanel(
                            type: NoteType.developer,
                            notes: viewModel.developerNotes(from: allNotes),
                            isAddSheet: $viewModel.showAddDeveloper
                        )
                        .frame(width: totalWidth * viewModel.rightFraction)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.splitMode)
            }
        }
        // Add Note Sheets
        .sheet(isPresented: $viewModel.showAddStudyTask) {
            AddNoteView(noteType: NoteType.studyTask)
        }
        .sheet(isPresented: $viewModel.showAddDeveloper) {
            AddNoteView(noteType: NoteType.developer)
        }
        // Note Detail Sheet
        .sheet(item: $viewModel.selectedNote) { note in
            NoteDetailSheet(note: note)
        }
    }
    
    // MARK: - Side Panel
    @ViewBuilder
    private func sidePanel(type: String, notes: [Note], isAddSheet: Binding<Bool>) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(type == NoteType.studyTask ? Color.studyTaskBadge : Color.developerBadge)
                        .frame(width: 8, height: 8)
                    Text(type == NoteType.studyTask ? "Study Task" : "Developer")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.navy)
                    Text(type == NoteType.studyTask ? "ideas · tasks · notes" : "logic · tech · code")
                        .font(.caption)
                        .foregroundColor(.navy.opacity(0.5))
                }
                
                Spacer()
                
                Button {
                    isAddSheet.wrappedValue = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.primaryBlue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Notes list or empty state
            if notes.isEmpty {
                emptyStateView(type: type)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(notes) { note in
                            NoteCardView(note: note)
                                .onTapGesture {
                                    viewModel.selectedNote = note
                                }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    // MARK: - Finder Guy Divider
    @ViewBuilder
    private func finderGuyDivider(screenWidth: CGFloat) -> some View {
        VStack {
            Spacer()
            
            FinderGuyView()
                .padding(.horizontal, 4)
                .offset(x: viewModel.dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewModel.dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            viewModel.handleDragEnd(totalWidth: screenWidth)
                        }
                )
            
            Spacer()
        }
        .frame(width: 56)
        .background(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.primaryBlue.opacity(0.03),
                            Color.navy.opacity(0.05),
                            Color.primaryBlue.opacity(0.03)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
    
    // MARK: - Empty State
    @ViewBuilder
    private func emptyStateView(type: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: type == NoteType.studyTask ? "book.closed" : "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 40))
                .foregroundColor(.navy.opacity(0.15))
            
            Text("No notes yet")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.navy.opacity(0.3))
            
            Text("Tap + to add your first \(type == NoteType.studyTask ? "study" : "dev") note")
                .font(.caption)
                .foregroundColor(.navy.opacity(0.2))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Note Detail Sheet
struct NoteDetailSheet: View {
    let note: Note
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Type badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(note.isStudyTask ? Color.studyTaskBadge : Color.developerBadge)
                            .frame(width: 8, height: 8)
                        Text(note.isStudyTask ? "Study Task" : "Developer")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(note.isStudyTask ? .studyTaskBadge : .developerBadge)
                    }
                    
                    // Title
                    Text(note.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.navy)
                    
                    // Date
                    Text(note.formattedDate)
                        .font(.caption)
                        .foregroundColor(.navy.opacity(0.4))
                    
                    Divider()
                    
                    // Content
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.body)
                            .foregroundColor(.navy.opacity(0.8))
                            .lineSpacing(4)
                    } else {
                        Text("No content")
                            .font(.body)
                            .italic()
                            .foregroundColor(.navy.opacity(0.3))
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .background(Color.appWhite)
            .navigationTitle("Note Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.primaryBlue)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
