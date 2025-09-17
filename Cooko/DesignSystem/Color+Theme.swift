import SwiftUI

extension Color {
    // 品牌色
    static let olive      = Color(hex: "#8A9A5B")
    static let cream      = Color(hex: "#FDF8F4")
    static let warmGray   = Color(hex: "#B0A99F")
    static let charcoal   = Color(hex: "#424242")
    static let warnOrange = Color(hex: "#E69A63")
    
    // iOS 16 玻璃質感色系
    static let glassWhite = Color.white.opacity(0.25)
    static let glassOlive  = Color(hex: "#8A9A5B").opacity(0.3)
    static let glassCream  = Color(hex: "#FDF8F4").opacity(0.8)
    static let glassShadow = Color.black.opacity(0.1)
}

extension Color {
    init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r, g, b: Double
        switch h.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
        default:
            r = 1; g = 1; b = 1
        }
        self = Color(red: r, green: g, blue: b)
    }
}

// iOS 16 玻璃質感效果
struct GlassEffect {
    static let cardMaterial = Material.ultraThinMaterial
    static let backgroundMaterial = Material.thinMaterial
    static let overlayMaterial = Material.thickMaterial
    
    static let cardBlur: CGFloat = 20
    static let backgroundBlur: CGFloat = 30
    static let overlayBlur: CGFloat = 50
}
