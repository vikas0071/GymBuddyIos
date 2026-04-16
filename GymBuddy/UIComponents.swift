import SwiftUI

struct PremiumButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .roundedFont(size: 18, weight: .bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.accent)
            .foregroundColor(.white)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Theme.accent.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

struct SecondaryButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .roundedFont(size: 16, weight: .medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.surface)
            .foregroundColor(.white)
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct CircularProgressView: View {
    var progress: Double
    var color: Color = Theme.accent
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
    }
}

struct WorkoutCard: View {
    var title: String
    var subtitle: String
    var icon: String
    var accentColor: Color = Theme.accent
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .roundedFont(size: 18, weight: .bold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .roundedFont(size: 14)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.accent)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .roundedFont(size: 20, weight: .bold)
                    .foregroundColor(.white)
                Text(title)
                    .roundedFont(size: 14)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Theme.surface)
        .cornerRadius(20)
    }
}

struct QuoteCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MOTIVATION")
                .roundedFont(size: 12, weight: .bold)
                .foregroundColor(Theme.accent)
            
            Text("\"The only bad workout is the one that didn't happen.\"")
                .roundedFont(size: 16, weight: .medium)
                .italic()
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface.opacity(0.5))
        .cornerRadius(20)
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    // Mock sets/reps for visualization
    let sets = Int.random(in: 3...4)
    let reps = Int.random(in: 10...15)
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 80, height: 80)
                
                if let firstImage = exercise.images.first {
                    ExerciseImageView(imagePath: firstImage)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                } else {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundColor(Theme.accent)
                        .font(.title2)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .roundedFont(size: 16, weight: .bold)
                    .foregroundColor(.white)
                Text("\(exercise.primaryMuscles.map { $0.capitalized }.joined(separator: ", "))")
                    .roundedFont(size: 12)
                    .foregroundColor(.gray)
                
                Text("\(sets) Sets × \(reps) Reps")
                    .roundedFont(size: 13, weight: .semibold)
                    .foregroundColor(Theme.accent)
                    .padding(.top, 2)
                
                HStack(spacing: 8) {
                    Label(exercise.level.capitalized, systemImage: "gauge.medium")
                    Label(exercise.equipment?.capitalized ?? "Body", systemImage: "dumbbell.fill")
                }
                .roundedFont(size: 10)
                .foregroundColor(.gray.opacity(0.8))
                .padding(.top, 2)
            }
            
            Spacer()
            
            Image(systemName: "info.circle")
                .foregroundColor(Theme.accent.opacity(0.5))
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
