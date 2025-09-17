import SwiftUI

struct FoodCard: View {
    let item: FoodItem
    var onUse: (() -> Void)?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)   // 玻璃質感
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.4), lineWidth: 1)
                )
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.emoji ?? "🍽️")
                        .font(.title3)
                    Spacer()
                    if item.isExpiringSoon {
                        TagChip(text: "快過期", color: .warnOrange)
                    } else {
                        TagChip(text: "新鮮", color: .olive)
                    }
                }
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(Color.charcoal)
                Text("\(item.quantity) \(item.unit)")
                    .font(.subheadline)
                    .foregroundStyle(Color.charcoal.opacity(0.8))
                Spacer(minLength: 0)
                Button {
                    onUse?()
                } label: {
                    Label("煮掉了", systemImage: "checkmark.circle")
                }
                .buttonStyle(.borderedProminent)
                .tint(.olive)
                .font(.caption)
            }
            .padding(12)
        }
        .frame(height: 150)
    }
}
