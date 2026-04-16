import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isSplashActive = true
    @State private var opacity = 0.5
    @State private var size = 0.8
    
    var body: some View {
        if isSplashActive {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Theme.accent)
                    
                    Text("GymBuddy")
                        .roundedFont(size: 32, weight: .bold)
                        .foregroundColor(.white)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.8)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        self.isSplashActive = false
                    }
                }
            }
        } else {
            NavigationStack {
                SplitSelectionView()
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
