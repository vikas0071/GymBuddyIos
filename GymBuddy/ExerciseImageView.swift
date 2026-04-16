import SwiftUI

struct ExerciseImageView: View {
    let imagePath: String?
    let contentMode: ContentMode
    
    // CDN Base URL for the free-exercise-db repository
    private let cdnBaseURL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/master/exercises/"
    
    init(imagePath: String?, contentMode: ContentMode = .fill) {
        self.imagePath = imagePath
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let path = imagePath, !path.isEmpty {
                // 1. Try to load from Bundle first
                if let bundleImage = UIImage(named: path) {
                    Image(uiImage: bundleImage)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                } else {
                    // 2. Fallback to GitHub CDN
                    AsyncImage(url: cdnURL(for: path)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Theme.surface)
                                .shimmer()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: contentMode)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case .failure:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                }
            } else {
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Rectangle()
                .fill(Theme.surface)
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 30))
                .foregroundColor(Theme.accent.opacity(0.3))
        }
    }
    
    private func cdnURL(for path: String) -> URL? {
        // Ensure path is correctly encoded for URL (e.g. handling spaces)
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        return URL(string: cdnBaseURL + encodedPath)
    }
}

#Preview {
    VStack {
        ExerciseImageView(imagePath: "3_4_Sit-Up/0.jpg")
            .frame(width: 200, height: 200)
            .cornerRadius(20)
        
        ExerciseImageView(imagePath: nil)
            .frame(width: 200, height: 200)
            .cornerRadius(20)
    }
    .padding()
    .background(Color.black)
}
