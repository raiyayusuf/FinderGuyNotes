/* ============================================
   Views/NoteCardView.swift
   REUSABLE NOTE CARD COMPONENT
   ============================================ */

import SwiftUI

/* ============================================
   NOTE CARD VIEW
   ============================================ */
struct NoteCardView: View {
    let note: Note
    var showTypeBadge: Bool = false
    var compact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 10) {
            // Type badge header
            if showTypeBadge {
                HStack(spacing: 6) {
                    Circle()
                        .fill(note.isStudyTask ? Color.studyTaskBadge : Color.developerBadge)
                        .frame(width: 6, height: 6)
                    Text(note.isStudyTask ? "Study Task" : "Developer")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(note.isStudyTask ? .studyTaskBadge : .developerBadge)
                    Spacer()
                }
            }
            
            // Card title
            Text(note.title)
                .font(compact ? .subheadline : .headline)
                .fontWeight(.semibold)
                .foregroundColor(.navy)
                .lineLimit(compact ? 2 : 3)
            
            // Card content
            if !note.content.isEmpty {
                Text(note.content)
                    .font(compact ? .caption : .subheadline)
                    .foregroundColor(.navy.opacity(0.7))
                    .lineLimit(compact ? 4 : 8)
                    .multilineTextAlignment(.leading)
            }
            
            // Date footer
            HStack {
                Spacer()
                Text(note.shortDate)
                    .font(.caption2)
                    .foregroundColor(.navy.opacity(0.4))
            }
        }
        .padding(compact ? 12 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Card background
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appWhite)
                .shadow(color: .cardShadow, radius: 6, x: 0, y: 3)
        )
        // Card border
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    note.isStudyTask
                        ? Color.primaryBlue.opacity(0.15)
                        : Color.navy.opacity(0.1),
                    lineWidth: 1
                )
        )
    }
}
