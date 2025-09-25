import SwiftUI

struct DynamicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct BounceButtonStyle: ButtonStyle {
    @State private var isAnimating = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : (isAnimating ? 1.05 : 1.0))
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: configuration.isPressed)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

struct PulseButtonStyle: ButtonStyle {
    @State private var pulseScale: CGFloat = 1.0
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : pulseScale)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseScale)
            .onAppear {
                pulseScale = 1.02
            }
    }
}

struct FloatingButtonStyle: ButtonStyle {
    @State private var isFloating = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .offset(y: isFloating ? -2 : 0)
            .shadow(color: .black.opacity(0.1), radius: isFloating ? 8 : 4, x: 0, y: isFloating ? 4 : 2)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isFloating)
            .onAppear {
                isFloating = true
            }
    }
}
