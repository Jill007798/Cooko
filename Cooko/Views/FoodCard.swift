import SwiftUI

struct FoodCard: View {
    let item: FoodItem
    var onUse: (() -> Void)?

    var body: some View {
        ZStack {
            // iOS 16 強烈玻璃質感背景
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(GlassEffect.cardMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .glassShadow, radius: 8, x: 0, y: 4)
                .shadow(color: .glassShadow.opacity(0.3), radius: 20, x: 0, y: 8)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // 優先顯示 emoji，沒有則顯示圖片
                    if let emoji = item.emoji {
                        Text(emoji)
                            .font(.title2)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    } else {
                        // TODO: 之後補進專案圖片
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.warmGray.opacity(0.6))
                    }
                    
                    Spacer()
                    if item.isExpiringSoon {
                        TagChip(text: "快過期", color: .warnOrange)
                    } else {
                        TagChip(text: "新鮮", color: .olive)
                    }
                }
                
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.charcoal)
                    .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                
                Text("\(item.quantity) \(item.unit)")
                    .font(.subheadline)
                    .foregroundStyle(Color.charcoal.opacity(0.8))
                
                Spacer(minLength: 0)
                
                Button {
                    onUse?()
                } label: {
                    Label("煮掉了", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .tint(.olive)
                .controlSize(.small)
                .shadow(color: .olive.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(16)
        }
        .frame(height: 140)
    }
}
