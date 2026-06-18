/* ============================================
   Views/FinderGuyView.swift
   MASCOT PLACEHOLDER VIEW
   ============================================ */

import SwiftUI

/* ============================================
   FINDER GUY VIEW
   ============================================ */
struct FinderGuyView: View {
    var body: some View {
        VStack(spacing: 4) {
            // Mascot placeholder icon
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primaryBlue, .navy],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Drag hint arrows
            Image(systemName: "arrow.left.and.right")
                .font(.system(size: 8))
                .foregroundColor(.navy.opacity(0.3))
        }
    }
}
import SwiftUI

struct FinderGuyView: View {
    var body: some View {
        VStack(spacing: 4) {
            // Finder Guy mascot placeholder using SF Symbol
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primaryBlue, .navy],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Small indicator arrows
            Image(systemName: "arrow.left.and.right")
                .font(.system(size: 8))
                .foregroundColor(.navy.opacity(0.3))
        }
    }
}
