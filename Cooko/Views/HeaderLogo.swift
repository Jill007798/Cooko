import SwiftUI

struct HeaderLogo: View {
    var body: some View {
        Text("Cooko")
            .font(.system(size: 28, weight: .black, design: .rounded))
            .foregroundStyle(Color(hex: "#4A5A2A"))
            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            .accessibilityAddTraits(.isHeader)
    }
}
