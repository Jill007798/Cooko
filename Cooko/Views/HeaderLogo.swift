import SwiftUI

struct HeaderLogo: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("Cooko")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.olive)
            Text("可可廚師")
                .font(.footnote)
                .foregroundStyle(Color.warmGray)
        }
        .padding(.top, 4)
        .accessibilityAddTraits(.isHeader)
    }
}
