import SwiftUI

struct TagChip: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(.white.opacity(0.3), lineWidth: 0.5)
                    )
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            )
            .accessibilityLabel(Text(text))
    }
}
