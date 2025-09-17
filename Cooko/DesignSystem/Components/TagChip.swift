import SwiftUI

struct TagChip: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.caption2).bold()
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.9))
            )
            .accessibilityLabel(Text(text))
    }
}
