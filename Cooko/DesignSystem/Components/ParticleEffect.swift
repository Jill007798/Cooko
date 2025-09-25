import SwiftUI

struct ParticleEffect: View {
    let emoji: String
    let isActive: Bool
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(particle.emoji)
                    .font(.title2)
                    .opacity(particle.opacity)
                    .offset(x: particle.x, y: particle.y)
                    .scaleEffect(particle.scale)
                    .animation(.easeOut(duration: particle.duration), value: particle.y)
                    .animation(.easeOut(duration: particle.duration), value: particle.opacity)
                    .animation(.easeOut(duration: particle.duration), value: particle.scale)
            }
        }
        .onChange(of: isActive) { active in
            if active {
                createParticles()
            }
        }
    }
    
    private func createParticles() {
        particles.removeAll()
        
        for i in 0..<8 {
            let particle = Particle(
                id: UUID(),
                emoji: emoji,
                x: CGFloat.random(in: -30...30),
                y: CGFloat.random(in: -50...50),
                opacity: 1.0,
                scale: CGFloat.random(in: 0.5...1.2),
                duration: Double.random(in: 0.8...1.5)
            )
            
            particles.append(particle)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(i)) {
                withAnimation(.easeOut(duration: particle.duration)) {
                    if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                        particles[index].y -= 100
                        particles[index].opacity = 0
                        particles[index].scale = 0.1
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            particles.removeAll()
        }
    }
}

struct Particle: Identifiable {
    let id: UUID
    let emoji: String
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    var scale: CGFloat
    let duration: Double
}

struct FloatingEmoji: View {
    let emoji: String
    @State private var isFloating = false
    @State private var rotation: Double = 0
    
    var body: some View {
        Text(emoji)
            .font(.title)
            .scaleEffect(isFloating ? 1.1 : 1.0)
            .rotationEffect(.degrees(rotation))
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isFloating)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: rotation)
            .onAppear {
                isFloating = true
                rotation = 360
            }
    }
}

struct PulseRing: View {
    let color: Color
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Circle()
            .stroke(color, lineWidth: 2)
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: scale)
            .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: opacity)
            .onAppear {
                scale = 2.0
                opacity = 0.0
            }
    }
}
