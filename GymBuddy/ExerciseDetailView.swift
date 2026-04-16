import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Image Header
                    ZStack(alignment: .bottomLeading) {
                        if let firstImage = exercise.images.first {
                            ExerciseImageView(imagePath: firstImage)
                                .frame(height: 240) // Reduced height for sheet
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Theme.surface)
                                .frame(height: 240)
                                .overlay(
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .font(.system(size: 60))
                                        .foregroundColor(Theme.accent.opacity(0.3))
                                )
                        }
                        
                        LinearGradient(
                            colors: [.clear, Theme.background.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .roundedFont(size: 28, weight: .bold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                BadgeView(text: exercise.level.capitalized, color: .orange)
                                BadgeView(text: exercise.category.capitalized, color: Theme.accent)
                            }
                        }
                        .padding()
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Muscle Groups
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Target Muscles")
                                .roundedFont(size: 18, weight: .bold)
                                .foregroundColor(.white)
                            
                            // Using a wrapping HStack alternative
                            WrappedHStack(items: exercise.primaryMuscles) { muscle in
                                Text(muscle.capitalized)
                                    .roundedFont(size: 13, weight: .medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Theme.accent.opacity(0.1))
                                    .foregroundColor(Theme.accent)
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Equipment
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Equipment Used")
                                .roundedFont(size: 18, weight: .bold)
                                .foregroundColor(.white)
                            Text(exercise.equipment?.capitalized ?? "None / Bodyweight")
                                .roundedFont(size: 16)
                                .foregroundColor(.gray)
                        }
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 20) {
                            Text("How to Perform")
                                .roundedFont(size: 18, weight: .bold)
                                .foregroundColor(.white)
                            
                            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 16) {
                                    Text("\(index + 1)")
                                        .roundedFont(size: 12, weight: .bold)
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(Theme.accent)
                                        .clipShape(Circle())
                                    
                                    Text(step)
                                        .roundedFont(size: 15)
                                        .foregroundColor(.gray)
                                        .lineSpacing(4)
                                }
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal)
                }
            }
            .background(Theme.background.ignoresSafeArea())
            
            // Close Button Overlay
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
            }
            .padding(.top, 40) // Adjust for safe area in sheet
        }
    }
}

// Fixed Wrapping layout helper
struct WrappedHStack<Content: View, Item: Hashable>: View {
    let items: [Item]
    let content: (Item) -> Content
    
    var body: some View {
        // Simple adaptive grid for reliable wrapping
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}
