import SwiftUI

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Color Palette
extension Color {
    /// Primary Blue #318AEB - Active buttons, accents, highlights
    static let primaryBlue = Color(hex: "#318AEB")
    
    /// Navy #0C2957 - Text, shadows, dark elements
    static let navy = Color(hex: "#0C2957")
    
    /// Light Blue #9EC8EC - Card backgrounds, subtle accents
    static let lightBlue = Color(hex: "#9EC8EC")
    
    /// App White #FFFFFF - Main background, cards
    static let appWhite = Color(hex: "#FFFFFF")
}

// MARK: - Semantic Colors
extension Color {
    /// Background for Study Task cards
    static let studyTaskBackground = Color.lightBlue.opacity(0.25)
    
    /// Background for Developer cards
    static let developerBackground = Color.navy.opacity(0.08)
    
    /// Badge color for Study Task type
    static let studyTaskBadge = Color.primaryBlue
    
    /// Badge color for Developer type
    static let developerBadge = Color.navy
    
    /// Bottom navigation background (semi-transparent)
    static let bottomNavBackground = Color.white.opacity(0.92)
    
    /// Card shadow color
    static let cardShadow = Color.navy.opacity(0.1)
}
