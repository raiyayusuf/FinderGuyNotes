import SwiftUI
import SwiftData

struct BoardView: View {
    @Query(sort: \Note.date, order: .reverse) private var allNotes: [Note]
    @Bindable var viewModel: NotesViewModel
    
    var body: some View {
        let pairs = viewModel.zigzagPairs(from: allNotes)
        
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Brainstorm Board")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.navy)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)
                
                if pairs.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 48))
                            .foregroundColor(.navy.opacity(0.12))
                        Text("No notes on the board")
                            .font(.headline)
                            .foregroundColor(.navy.opacity(0.3))
                        Text("Add some notes first to see them here")
                            .font(.subheadline)
                            .foregroundColor(.navy.opacity(0.2))
                        Spacer()
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(pairs.enumerated()), id: \.offset) { index, pair in
                                boardRow(left: pair.0, right: pair.1)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(item: $viewModel.selectedNote) { note in
            NoteDetailSheet(note: note)
        }
    }
    
    // MARK: - Board Row (2 columns)
    @ViewBuilder
    private func boardRow(left: Note?, right: Note?) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Left column
            if let note = left {
                NoteCardView(note: note, showTypeBadge: true)
                    .onTapGesture {
                        viewModel.selectedNote = note
                    }
            } else {
                Color.clear
                    .frame(maxWidth: .infinity, minHeight: 1)
            }
            
            // Right column
            if let note = right {
                NoteCardView(note: note, showTypeBadge: true)
                    .onTapGesture {
                        viewModel.selectedNote = note
                    }
            } else {
                Color.clear
                    .frame(maxWidth: .infinity, minHeight: 1)
            }
        }
    }
}
