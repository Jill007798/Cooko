import SwiftUI

struct HeaderLogo: View {
    var body: some View {
        Text("Cooko")
            .font(.custom("Hind-Bold", size: 26))
            .foregroundStyle(Color(hex: "#6B7A4B"))
            .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 1)
            .accessibilityAddTraits(.isHeader)
    }
}
