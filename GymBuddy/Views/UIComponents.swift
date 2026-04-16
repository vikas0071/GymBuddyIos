import SwiftUI

struct PremiumButtonStyle: View {
    var title: String
    var icon: String? = nil
    
    var body: some View {
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

struct PremiumButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            PremiumButtonStyle(title: title, icon: icon)
        }
    }
}

struct PremiumLabel: View {
    var title: String
    var icon: String? = nil
    
    var body: some View {
        PremiumButtonStyle(title: title, icon: icon)
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

struct WeeklyActivityBar: View {
    let logs: [WorkoutLog]
    
    private let calendar = Calendar.current
    private let dayNames = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WEEKLY ACTIVITY")
                .roundedFont(size: 12, weight: .bold)
                .foregroundColor(Theme.secondary)
            
            HStack(spacing: 0) {
                ForEach(0..<7) { index in
                    let isCompleted = hasWorkout(forDayIndex: index + 1)
                    
                    VStack(spacing: 8) {
                        Text(dayNames[index])
                            .roundedFont(size: 10, weight: .medium)
                            .foregroundColor(isCompleted ? .white : .gray)
                        
                        ZStack {
                            Circle()
                                .fill(isCompleted ? Theme.accent : Color.white.opacity(0.05))
                                .frame(width: 32, height: 32)
                            
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .transition(.scale)
                            }
                        }
                        .overlay(
                            Circle()
                                .stroke(isCompleted ? Theme.accent.opacity(0.3) : Color.clear, lineWidth: 4)
                                .scaleEffect(isCompleted ? 1.2 : 1.0)
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 16)
            .background(Theme.surface)
            .cornerRadius(20)
        }
    }
    
    private func hasWorkout(forDayIndex dayIndex: Int) -> Bool {
        // Logic to check if any workout log falls on this day of the current week
        // We look at the logs from the current week
        let now = Date()
        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: now)
        
        return logs.contains { log in
            guard let weekRange = currentWeek, weekRange.contains(log.completedAt) else { return false }
            
            // Adjust weekday to match our 1=Mon, 7=Sun logic
            let weekday = calendar.component(.weekday, from: log.completedAt)
            let adjusted = (weekday + 5) % 7 + 1
            return adjusted == dayIndex
        }
    }
}
