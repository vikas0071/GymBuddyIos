import SwiftUI

enum Theme {
    static let background = Color(hex: "000000")
    static let surface = Color(hex: "121212")
    static let accent = Color(hex: "3B5BFC")
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
    static let cornerRadius: CGFloat = 24
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

extension View {
    func glassStyle() -> some View {
        self.modifier(GlassModifier())
    }
    
    func cardStyle() -> some View {
        self
            .padding()
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadius)
    }
}

struct RoundedSystemFont: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight = .regular
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: .rounded))
    }
}

extension View {
    func roundedFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.modifier(RoundedSystemFont(size: size, weight: weight))
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    ZStack {
                        Color.white.opacity(0.1)
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.3),
                                .init(color: .white.opacity(0.2), location: 0.5),
                                .init(color: .clear, location: 0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .rotationEffect(.degrees(30))
                        .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                    }
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}
