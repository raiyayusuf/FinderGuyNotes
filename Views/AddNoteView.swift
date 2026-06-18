/* ============================================
   Views/AddNoteView.swift
   ADD NOTE MODAL SHEET
   ============================================ */

import SwiftUI
import SwiftData

/* ============================================
   ADD NOTE VIEW
   ============================================ */
struct AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let noteType: String
    
    @State private var title: String = ""
    @State private var content: String = ""
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Type header
                HStack {
                    Circle()
                        .fill(noteType == NoteType.studyTask ? Color.studyTaskBadge : Color.developerBadge)
                        .frame(width: 8, height: 8)
                    Text(noteType == NoteType.studyTask ? "Study Task Note" : "Developer Note")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.navy.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                Divider()
                
                // Input fields
                VStack(spacing: 16) {
                    // Title field
                    TextField("Note title...", text: $title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.navy)
                        .focused($isTitleFocused)
                        .submitLabel(.next)
                        .onSubmit {}
                    
                    // Content editor
                    TextEditor(text: $content)
                        .font(.body)
                        .foregroundColor(.navy.opacity(0.8))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 150)
                        .overlay(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("Write your note here...")
                                    .font(.body)
                                    .foregroundColor(.navy.opacity(0.3))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                    
                    Spacer()
                }
                .padding(20)
            }
            .background(Color.appWhite)
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.navy.opacity(0.6))
                }
                
                // Save button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .primaryBlue)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            isTitleFocused = true
        }
    }
    
    /* ============================================
       SAVE LOGIC
       ============================================ */
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
}
import SwiftUI
import SwiftData

struct AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let noteType: String // "StudyTask" or "Developer"
    
    @State private var title: String = ""
    @State private var content: String = ""
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Type header
                HStack {
                    Circle()
                        .fill(noteType == NoteType.studyTask ? Color.studyTaskBadge : Color.developerBadge)
                        .frame(width: 8, height: 8)
                    Text(noteType == NoteType.studyTask ? "Study Task Note" : "Developer Note")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.navy.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                Divider()
                
                // Input fields
                VStack(spacing: 16) {
                    // Title field
                    TextField("Note title...", text: $title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.navy)
                        .focused($isTitleFocused)
                        .submitLabel(.next)
                        .onSubmit {
                            // Move focus to content when done
                        }
                    
                    // Content field
                    TextEditor(text: $content)
                        .font(.body)
                        .foregroundColor(.navy.opacity(0.8))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 150)
                        .overlay(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("Write your note here...")
                                    .font(.body)
                                    .foregroundColor(.navy.opacity(0.3))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                    
                    Spacer()
                }
                .padding(20)
            }
            .background(Color.appWhite)
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.navy.opacity(0.6))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .primaryBlue)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            isTitleFocused = true
        }
    }
    
    // MARK: - Save Logic
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
}
