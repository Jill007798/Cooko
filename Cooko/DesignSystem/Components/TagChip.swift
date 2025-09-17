import SwiftUI

struct TagChip: View {
    let text: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(isSelected ? 1.0 : 0.2))
            .foregroundColor(isSelected ? .white : color)
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(color, lineWidth: 1)
            )
    }
}

#Preview {
    HStack {
        TagChip(text: "Vegetarian", color: .primaryGreen, isSelected: true)
        TagChip(text: "Quick", color: .accentOrange, isSelected: false)
    }
    .padding()
}
