import SwiftUI

struct ToolCard: View {
    let tool: CookingTool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            ZStack {
                // iOS 16 強烈玻璃質感背景
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(GlassEffect.cardMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .glassShadow, radius: 4, x: 0, y: 2)
                    .shadow(color: .glassShadow.opacity(0.2), radius: 8, x: 0, y: 4)
                
                VStack(spacing: 4) {
                    Text(tool.emoji)
                        .font(.title)
                        .grayscale(tool.isAvailable ? 0 : 1) // 灰階效果
                        .opacity(tool.isAvailable ? 1 : 0.6)
                    
                    VStack(spacing: 1) {
                        Text(tool.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(tool.isAvailable ? Color.charcoal : Color.warmGray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Text(tool.englishName)
                            .font(.subheadline)
                            .foregroundStyle(tool.isAvailable ? Color.warmGray : Color.warmGray.opacity(0.6))
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(8)
            }
            .frame(width: 60, height: 65)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        ToolCard(tool: CookingTool(emoji: "🍚", name: "電鍋", englishName: "Rice Cooker", isAvailable: true)) {
            // Preview action
        }
        
        ToolCard(tool: CookingTool(emoji: "🍳", name: "炒鍋", englishName: "Wok", isAvailable: false)) {
            // Preview action
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
