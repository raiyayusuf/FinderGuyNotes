/* ============================================
   Views/ContentView.swift
   ROOT VIEW WITH BOTTOM NAVIGATION
   ============================================ */

import SwiftUI

/* ============================================
   CONTENT VIEW
   ============================================ */
struct ContentView: View {
    @State private var viewModel = NotesViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area
            Group {
                switch viewModel.selectedTab {
                case 0:
                    NotesView(viewModel: viewModel)
                case 1:
                    BoardView(viewModel: viewModel)
                case 2:
                    HistoryView(viewModel: viewModel)
                default:
                    NotesView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.25), value: viewModel.selectedTab)
            
            // Custom bottom navigation
            bottomNavBar
        }
        .ignoresSafeArea(.keyboard)
    }
    
    /* ============================================
       BOTTOM NAVIGATION BAR
       ============================================ */
    private var bottomNavBar: some View {
        HStack(spacing: 0) {
            navItem(
                title: "Notes",
                icon: "note.text",
                tab: 0
            )
            
            navItem(
                title: "Board",
                icon: "square.grid.2x2",
                tab: 1
            )
            
            navItem(
                title: "History",
                icon: "clock.arrow.circlepath",
                tab: 2
            )
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .cardShadow, radius: 12, x: 0, y: -4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    /* ============================================
       NAVIGATION ITEM
       ============================================ */
    @ViewBuilder
    private func navItem(title: String, icon: String, tab: Int) -> some View {
        let isActive = viewModel.selectedTab == tab
        
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                viewModel.selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                // Tab icon
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? .primaryBlue : .navy.opacity(0.35))
                    .scaleEffect(isActive ? 1.1 : 1.0)
                
                // Tab label
                Text(title)
                    .font(.caption2)
                    .fontWeight(isActive ? .semibold : .regular)
                    .foregroundColor(isActive ? .primaryBlue : .navy.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
        }
    }
}
import SwiftUI

struct ContentView: View {
    @State private var viewModel = NotesViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area
            Group {
                switch viewModel.selectedTab {
                case 0:
                    NotesView(viewModel: viewModel)
                case 1:
                    BoardView(viewModel: viewModel)
                case 2:
                    HistoryView(viewModel: viewModel)
                default:
                    NotesView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.25), value: viewModel.selectedTab)
            
            // Custom bottom navigation
            bottomNavBar
        }
        .ignoresSafeArea(.keyboard)
    }
    
    // MARK: - Bottom Navigation Bar
    private var bottomNavBar: some View {
        HStack(spacing: 0) {
            navItem(
                title: "Notes",
                icon: "note.text",
                tab: 0
            )
            
            navItem(
                title: "Board",
                icon: "square.grid.2x2",
                tab: 1
            )
            
            navItem(
                title: "History",
                icon: "clock.arrow.circlepath",
                tab: 2
            )
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .cardShadow, radius: 12, x: 0, y: -4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Nav Item
    @ViewBuilder
    private func navItem(title: String, icon: String, tab: Int) -> some View {
        let isActive = viewModel.selectedTab == tab
        
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                viewModel.selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? .primaryBlue : .navy.opacity(0.35))
                    .scaleEffect(isActive ? 1.1 : 1.0)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(isActive ? .semibold : .regular)
                    .foregroundColor(isActive ? .primaryBlue : .navy.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
        }
    }
}
