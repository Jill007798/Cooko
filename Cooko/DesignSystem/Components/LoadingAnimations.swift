import SwiftUI

struct ChatGPTLoadingView: View {
    @State private var isAnimating = false
    @State private var dotOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.olive)
                    .frame(width: 8, height: 8)
                    .offset(y: dotOffset)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: dotOffset
                    )
            }
        }
        .onAppear {
            dotOffset = -8
        }
    }
}

struct ThinkingBubble: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.6
    
    var body: some View {
        HStack(spacing: 8) {
            Text("🤔")
                .font(.title2)
                .scaleEffect(scale)
                .opacity(opacity)
            
            Text("AI 正在思考...")
                .font(.subheadline)
                .foregroundStyle(Color.olive)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.white.opacity(0.9))
                .overlay(
                    Capsule()
                        .stroke(Color.olive.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .glassShadow, radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: scale)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: opacity)
        .onAppear {
            scale = 1.2
            opacity = 1.0
        }
    }
}

struct RecipeGeneratingView: View {
    @State private var progress: CGFloat = 0
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(Color.olive)
                    .rotationEffect(.degrees(isVisible ? 360 : 0))
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isVisible)
                
                Text("正在生成個性化食譜...")
                    .font(.headline)
                    .foregroundStyle(Color.charcoal)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.olive))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.olive.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .glassShadow, radius: 8, x: 0, y: 4)
        .onAppear {
            isVisible = true
            
            withAnimation(.easeInOut(duration: 2.0)) {
                progress = 1.0
            }
        }
    }
}

struct MagicSparkle: View {
    @State private var sparkles: [Sparkle] = []
    
    var body: some View {
        ZStack {
            ForEach(sparkles) { sparkle in
                Text("✨")
                    .font(.caption)
                    .opacity(sparkle.opacity)
                    .offset(x: sparkle.x, y: sparkle.y)
                    .scaleEffect(sparkle.scale)
                    .rotationEffect(.degrees(sparkle.rotation))
                    .animation(.easeOut(duration: sparkle.duration), value: sparkle.y)
                    .animation(.easeOut(duration: sparkle.duration), value: sparkle.opacity)
            }
        }
        .onAppear {
            createSparkles()
        }
    }
    
    private func createSparkles() {
        for i in 0..<6 {
            let sparkle = Sparkle(
                id: UUID(),
                x: CGFloat.random(in: -20...20),
                y: CGFloat.random(in: -20...20),
                opacity: 1.0,
                scale: CGFloat.random(in: 0.5...1.0),
                rotation: Double.random(in: 0...360),
                duration: Double.random(in: 1.0...2.0)
            )
            
            sparkles.append(sparkle)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 * Double(i)) {
                withAnimation(.easeOut(duration: sparkle.duration)) {
                    if let index = sparkles.firstIndex(where: { $0.id == sparkle.id }) {
                        sparkles[index].y -= 30
                        sparkles[index].opacity = 0
                        sparkles[index].scale = 0.1
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            sparkles.removeAll()
        }
    }
}

struct Sparkle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    var scale: CGFloat
    var rotation: Double
    let duration: Double
}
