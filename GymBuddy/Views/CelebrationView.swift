import SwiftUI

struct CelebrationView: View {
    let duration: TimeInterval
    let exerciseCount: Int
    var onFinish: () -> Void
    
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Trophy Icon
                ZStack {
                    Circle()
                        .fill(Theme.accent.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.accent)
                }
                .scaleEffect(showConfetti ? 1.0 : 0.5)
                .opacity(showConfetti ? 1.0 : 0.0)
                
                VStack(spacing: 12) {
                    Text("Session Complete!")
                        .roundedFont(size: 32, weight: .bold)
                        .foregroundColor(.white)
                    Text("You're one step closer to your goal.")
                        .roundedFont(size: 16)
                        .foregroundColor(.gray)
                }
                
                // Summary Stats
                HStack(spacing: 24) {
                    SummaryStat(title: "Duration", value: formatDuration(duration))
                    SummaryStat(title: "Exercises", value: "\(exerciseCount)")
                    SummaryStat(title: "Est. Volume", value: "\(exerciseCount * 450)kg")
                }
                .padding()
                .background(Theme.surface)
                .cornerRadius(24)
                
                Spacer()
                
                PremiumButton(title: "Finish", icon: "house.fill") {
                    onFinish()
                }
                .padding()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                showConfetti = true
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)m"
    }
}

struct SummaryStat: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .roundedFont(size: 20, weight: .bold)
                .foregroundColor(.white)
            Text(title)
                .roundedFont(size: 12)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
