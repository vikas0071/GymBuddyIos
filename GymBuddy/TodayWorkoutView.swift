import SwiftUI

struct TodayWorkoutView: View {
    let split: WorkoutSplit
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ExerciseListViewModel()
    @State private var selectedExercise: Exercise?
    
    let dayIndex = SchedulerService.shared.getCurrentDayIndex()
    
    var body: some View {
        let today = split.days.first(where: { $0.dayIndex == effectiveDayIndex })
        
        VStack(spacing: 0) {
            // Header with Muscle Focus
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(split.name)
                            .roundedFont(size: 12, weight: .bold)
                            .foregroundColor(Theme.accent)
                        Text(SchedulerService.shared.getWeekdayName(for: effectiveDayIndex))
                            .roundedFont(size: 14, weight: .bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Theme.accent.opacity(0.2))
                            .foregroundColor(Theme.accent)
                            .cornerRadius(10)
                    }
                    Spacer()
                    if today?.isRestDay ?? true {
                        Text("Active Recovery")
                            .roundedFont(size: 12)
                            .foregroundColor(.gray)
                    }
                }
                
                if let today = today, !today.isRestDay {
                    Text("Today's Plan")
                        .roundedFont(size: 28, weight: .bold)
                        .foregroundColor(.white)
                    Text(today.targetMuscles.map { $0.capitalized }.joined(separator: " • "))
                        .roundedFont(size: 16)
                        .foregroundColor(.gray)
                } else {
                    Text("Rest Day")
                        .roundedFont(size: 28, weight: .bold)
                        .foregroundColor(Theme.accent)
                    Text(SchedulerService.shared.getRestDayMessage())
                        .roundedFont(size: 16)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(Theme.background)
            
            // Exercise List
            if let today = today, !today.isRestDay {
                if viewModel.exercises.isEmpty && viewModel.isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView().tint(Theme.accent)
                        Text("Curating exercises...")
                            .roundedFont(size: 14)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else if viewModel.exercises.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No exercises found for these muscles")
                            .roundedFont(size: 14)
                            .foregroundColor(.gray)
                        Button("Reload Exercises") {
                            viewModel.fetchExercises(for: today.targetMuscles)
                        }
                        .foregroundColor(Theme.accent)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.exercises) { exercise in
                                Button(action: { selectedExercise = exercise }) {
                                    ExerciseRow(exercise: exercise)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    
                    // Start Button
                    NavigationLink(destination: WorkoutTimerView(exercises: viewModel.exercises, splitId: split.id, dayIndex: effectiveDayIndex)) {
                        PremiumLabel(title: "Start Workout", icon: "timer")
                            .padding()
                    }
                }
            } else {
                // Rest Day UI
                Spacer()
                VStack(spacing: 24) {
                    Image(systemName: "figure.mind.and.body")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.accent.opacity(0.3))
                    Text("Time to Recover")
                        .roundedFont(size: 20, weight: .bold)
                        .foregroundColor(.white)
                    Text("Muscle recovery is essential for growth. Enjoy your day off or preview tomorrow's session below.")
                        .roundedFont(size: 14)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    NavigationLink(destination: TodayWorkoutView(split: split, forceDayIndex: (effectiveDayIndex % 7) + 1)) {
                        Text("Preview Tomorrow's Plan")
                            .roundedFont(size: 14, weight: .semibold)
                            .foregroundColor(Theme.accent)
                            .padding()
                            .background(Theme.accent.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                Spacer()
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left.arrow.right")
                        Text("Switch Program")
                            .roundedFont(size: 14, weight: .bold)
                    }
                    .foregroundColor(Theme.accent)
                }
            }
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            loadExercises(for: today)
        }
    }
    
    // Allow forcing a different day for preview
    var forceDayIndex: Int? = nil
    
    private var effectiveDayIndex: Int {
        forceDayIndex ?? dayIndex
    }
    
    private func loadExercises(for day: WorkoutDay?) {
        if let targetMuscles = day?.targetMuscles, !day!.isRestDay {
            viewModel.fetchExercises(for: targetMuscles)
        }
    }
}
