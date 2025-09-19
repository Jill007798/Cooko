import SwiftUI

struct FoodCard: View {
    let item: FoodItem
    let isEditing: Bool
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    let onDelete: () -> Void
    let onEnterEditMode: () -> Void
    var onUse: (() -> Void)?

    var body: some View {
        ZStack {
            // iOS 16 強烈玻璃質感背景
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(GlassEffect.cardMaterial)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white.opacity(0.1))
                        
                        // 即將過期指示器 - 融入背景的橘色暈染
                        if item.isExpiringSoon {
                            VStack {
                                HStack {
                                    Spacer()
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#FF8C00").opacity(0.6),
                                            Color(hex: "#FF8C00").opacity(0.4),
                                            Color(hex: "#FF8C00").opacity(0.2),
                                            Color.clear
                                        ],
                                        startPoint: .topTrailing,
                                        endPoint: .bottomLeading
                                    )
                                    .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.width * 0.12)
                                    .cornerRadius(20)
                                }
                                Spacer()
                            }
                        }
                    }
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
            
            // 內容區域
            if isEditing {
                // 編輯模式：顯示操作按鈕
                HStack {
                    Button(action: onDecrease) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    
                    Text(String(item.name.prefix(4)))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.charcoal)
                        .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                    
                    Spacer()
                    
                    Button(action: onIncrease) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                }
                .padding(12)
            } else {
                // 正常模式：顯示食材信息
                HStack {
                    // 優先顯示 emoji，沒有則顯示圖片（3字以上不顯示emoji）
                    if let emoji = item.emoji, item.name.count <= 3 {
                        Text(emoji)
                            .font(.title2)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    } else {
                        // TODO: 之後補進專案圖片
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.warmGray.opacity(0.6))
                    }
                    
                    Text(String(item.name.prefix(4)))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.charcoal)
                        .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                    
                    Spacer()
                    
                    Text("\(item.quantity) \(item.unit)")
                        .font(.subheadline)
                        .foregroundStyle(Color.charcoal.opacity(0.8))
                }
                .padding(12)
            }
        }
        .frame(height: 50)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                onUse?()
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            if !isEditing {
                onEnterEditMode()
            }
        }
    }
}

#Preview {
    FoodCard(
        item: FoodItem(
            name: "雞蛋",
            emoji: "🥚",
            quantity: 8,
            unit: "顆",
            location: .fridge,
            expiry: Date().addingTimeInterval(60*60*24*2)
        ),
        isEditing: false,
        onIncrease: {},
        onDecrease: {},
        onDelete: {},
        onEnterEditMode: {}
    )
    .padding()
}