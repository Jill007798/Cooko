import SwiftUI

struct BackgroundIconView: View {
    var body: some View {
        ZStack {
            // 左上角 - 溫暖米色
            RadialGradient(
                colors: [
                    Color(hex: "#FFEECB").opacity(0.6),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 250
            )
            
            // 右上角 - 清新綠色
            RadialGradient(
                colors: [
                    Color(hex: "#A8E6CF").opacity(0.8),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 220
            )
            
            // 左下角 - 柔和藍色
            RadialGradient(
                colors: [
                    Color(hex: "#87CEEB").opacity(0.7),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 200
            )
            
            // 右下角 - 溫馨粉色
            RadialGradient(
                colors: [
                    Color(hex: "#FFB6C1").opacity(0.8),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 230
            )
            
            // 整體基礎色調
            Color(hex: "#F8F9FA").opacity(0.2)
        }
        .ignoresSafeArea()
        .frame(width: 400, height: 400) // Default size for preview/export
    }
}

#Preview {
    BackgroundIconView()
}