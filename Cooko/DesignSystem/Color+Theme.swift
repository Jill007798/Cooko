import SwiftUI

extension Color {
    // 品牌色
    static let olive      = Color(hex: "#8A9A5B")
    static let cream      = Color(hex: "#FDF8F4")
    static let warmGray   = Color(hex: "#B0A99F")
    static let charcoal   = Color(hex: "#424242")
    static let warnOrange = Color(hex: "#E69A63")
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
