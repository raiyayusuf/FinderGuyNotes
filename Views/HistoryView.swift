/* ============================================
   Views/HistoryView.swift
   TIMELINE VIEW WITH FILTERS
   ============================================ */

import SwiftUI
import SwiftData

/* ============================================
   HISTORY VIEW
   ============================================ */
struct HistoryView: View {
    @Query(sort: \Note.date, order: .reverse) private var allNotes: [Note]
    @Bindable var viewModel: NotesViewModel
    
    var body: some View {
        let filteredNotes = viewModel.filteredHistoryNotes(from: allNotes)
        
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // History header
                HStack {
                    Text("History")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.navy)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 12)
                
                // Filter chips row
                filterChipsRow
                
                Divider()
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // Timeline list
                if filteredNotes.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.navy.opacity(0.12))
                        Text("No history yet")
                            .font(.headline)
                            .foregroundColor(.navy.opacity(0.3))
                        Text("Your notes will appear here as a timeline")
                            .font(.subheadline)
                            .foregroundColor(.navy.opacity(0.2))
                        Spacer()
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredNotes) { note in
                                historyRow(note: note)
                                
                                // Item separator
                                Rectangle()
                                    .fill(Color.navy.opacity(0.06))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(item: $viewModel.selectedNote) { note in
            NoteDetailSheet(note: note)
        }
    }
    
    /* ============================================
       FILTER CHIPS ROW
       ============================================ */
    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HistoryFilter.allCases, id: \.self) { filter in
                    filterChip(filter: filter)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    /* ============================================
       FILTER CHIP
       ============================================ */
    @ViewBuilder
    private func filterChip(filter: HistoryFilter) -> some View {
        let isSelected = viewModel.historyFilter == filter
        
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.historyFilter = filter
            }
        } label: {
            Text(filter.rawValue)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .navy.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.primaryBlue : Color.navy.opacity(0.06))
                )
        }
    }
    
    /* ============================================
       HISTORY ROW
       ============================================ */
    @ViewBuilder
    private func historyRow(note: Note) -> some View {
        Button {
            viewModel.selectedNote = note
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Timeline dot
                VStack(spacing: 0) {
                    Circle()
                        .fill(note.isStudyTask ? Color.studyTaskBadge : Color.developerBadge)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                    Spacer()
                }
                .frame(width: 12)
                
                // Row content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(note.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.navy)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Type indicator
                        Image(systemName: note.isStudyTask ? "book.closed" : "chevron.left.forwardslash.chevron.right")
                            .font(.caption)
                            .foregroundColor(note.isStudyTask ? .studyTaskBadge : .developerBadge)
                    }
                    
                    // Date label
                    Text(note.formattedDate)
                        .font(.caption)
                        .foregroundColor(.navy.opacity(0.4))
                    
                    // Content preview
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.caption)
                            .foregroundColor(.navy.opacity(0.5))
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
    }
}
import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Note.date, order: .reverse) private var allNotes: [Note]
    @Bindable var viewModel: NotesViewModel
    
    var body: some View {
        let filteredNotes = viewModel.filteredHistoryNotes(from: allNotes)
        
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("History")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.navy)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 12)
                
                // Filter chips
                filterChipsRow
                
                Divider()
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // Timeline list
                if filteredNotes.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.navy.opacity(0.12))
                        Text("No history yet")
                            .font(.headline)
                            .foregroundColor(.navy.opacity(0.3))
                        Text("Your notes will appear here as a timeline")
                            .font(.subheadline)
                            .foregroundColor(.navy.opacity(0.2))
                        Spacer()
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredNotes) { note in
                                historyRow(note: note)
                                
                                // Divider between items
                                Rectangle()
                                    .fill(Color.navy.opacity(0.06))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(item: $viewModel.selectedNote) { note in
            NoteDetailSheet(note: note)
        }
    }
    
    // MARK: - Filter Chips Row
    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HistoryFilter.allCases, id: \.self) { filter in
                    filterChip(filter: filter)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Filter Chip
    @ViewBuilder
    private func filterChip(filter: HistoryFilter) -> some View {
        let isSelected = viewModel.historyFilter == filter
        
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.historyFilter = filter
            }
        } label: {
            Text(filter.rawValue)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .navy.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.primaryBlue : Color.navy.opacity(0.06))
                )
        }
    }
    
    // MARK: - History Row
    @ViewBuilder
    private func historyRow(note: Note) -> some View {
        Button {
            viewModel.selectedNote = note
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Timeline dot
                VStack(spacing: 0) {
                    Circle()
                        .fill(note.isStudyTask ? Color.studyTaskBadge : Color.developerBadge)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                    Spacer()
                }
                .frame(width: 12)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(note.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.navy)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Type indicator
                        Image(systemName: note.isStudyTask ? "book.closed" : "chevron.left.forwardslash.chevron.right")
                            .font(.caption)
                            .foregroundColor(note.isStudyTask ? .studyTaskBadge : .developerBadge)
                    }
                    
                    Text(note.formattedDate)
                        .font(.caption)
                        .foregroundColor(.navy.opacity(0.4))
                    
                    // Content preview
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.caption)
                            .foregroundColor(.navy.opacity(0.5))
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
    }
}
