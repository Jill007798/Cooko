import SwiftUI

struct HeaderLogo: View {
    var body: some View {
        Text("Cooko")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(Color.olive)
            .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 1)
            .padding(.top, 8)
            .accessibilityAddTraits(.isHeader)
    }
}
