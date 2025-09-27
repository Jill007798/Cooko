import SwiftUI

struct AddFoodCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 玻璃質感背景
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white.opacity(0.1))
                    )
                    .overlay(
                        // 虛線邊框
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                style: StrokeStyle(lineWidth: 1.2, dash: [6, 4])
                            )
                            .foregroundStyle(.white.opacity(0.5))
                    )
                    .shadow(color: .glassShadow, radius: 4, x: 0, y: 2)
                    .shadow(color: .glassShadow.opacity(0.2), radius: 8, x: 0, y: 4)
                
                HStack(spacing: 12) {
                    Image(systemName: "camera")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.olive)
                        .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                    
                    Text("新增食材")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.charcoal.opacity(0.7))
                        .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                    
                    Image(systemName: "plus.circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.olive)
                        .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                }
            }
            .frame(height: 50) // 原本高度的 1/3 (150/3 = 50)
            .frame(maxWidth: .infinity) // 自己占一行，橫向填滿
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .accessibilityLabel("新增食材")
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                // 輕微的點擊反饋
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AddFoodCard {
            print("Add food tapped")
        }
        
        // 對比一般食材卡片
        FoodCard(
            item: FoodItem(
                name: "雞蛋",
                emoji: "🥚",
                location: .fridge,
                expiry: Date().addingTimeInterval(86400 * 3)
            ),
            isEditing: false,
            onDelete: { },
            onEnterEditMode: { },
            onUse: {
                print("Food tapped")
            }
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
