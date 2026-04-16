import SwiftUI
import SwiftData

struct WorkoutTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: WorkoutViewModel
    
    init(exercises: [Exercise], splitId: UUID, dayIndex: Int) {
        // We initialize the ViewModel with the parameters
        // Note: modelContext is nil here because we can't access it in init
        // We'll set it in onAppear
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(
            exercises: exercises,
            splitId: splitId,
            dayIndex: dayIndex,
            modelContext: nil
        ))
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            if viewModel.isCompleted {
                CelebrationView(
                    duration: TimeInterval(viewModel.totalWorkoutDuration),
                    exerciseCount: viewModel.totalExercisesCount
                ) {
                    dismiss()
                }
            } else {
                VStack(spacing: 32) {
                    // Progress Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Exercise \(viewModel.currentExerciseIndex + 1) of \(viewModel.totalExercisesCount)")
                                .roundedFont(size: 14)
                                .foregroundColor(.gray)
                            Text(viewModel.currentExercise.name)
                                .roundedFont(size: 24, weight: .bold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text("Set \(viewModel.currentSet)/\(viewModel.totalSets)")
                            .roundedFont(size: 18, weight: .bold)
                            .foregroundColor(Theme.accent)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Main Timer Circle
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.05), lineWidth: 20)
                            .frame(width: 280, height: 280)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.progressValue())
                            .stroke(
                                viewModel.workoutState == .active ? Color.green : Theme.accent,
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 280, height: 280)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: viewModel.timeRemaining)
                        
                        VStack(spacing: 8) {
                            Text(viewModel.workoutState == .active ? "ACTIVE" : (viewModel.workoutState == .rest ? "REST" : "PREP"))
                                .roundedFont(size: 16, weight: .bold)
                                .foregroundColor(.gray)
                                .kerning(2)
                            
                            Text(viewModel.formatTime(viewModel.workoutState == .active ? viewModel.elapsedTime : viewModel.timeRemaining))
                                .roundedFont(size: 64, weight: .bold)
                                .foregroundColor(.white)
                                .monospacedDigit()
                        }
                    }
                    
                    Spacer()
                    
                    // Controls
                    VStack(spacing: 16) {
                        if viewModel.workoutState == .active {
                            PremiumButton(title: "Set Completed", icon: "checkmark.circle.fill") {
                                viewModel.completeSet()
                            }
                        } else if viewModel.workoutState == .rest {
                            SecondaryButton(title: "Skip Rest", icon: "forward.fill") {
                                viewModel.skipRest()
                            }
                            if let nextName = viewModel.nextExerciseName {
                                Text("Next: \(nextName)")
                                    .roundedFont(size: 14)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Text("Get Ready...")
                                .roundedFont(size: 20, weight: .medium)
                                .foregroundColor(Theme.accent)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Set the model context here using a private method or by exposing a property
            // For simplicity, we'll use a hack or just ensure the VM has access to context.
            // In a real app, you might use a Repository pattern.
            // Here we'll just use the context we have in the view.
            // I'll add a helper to update context in VM.
            viewModel.updateModelContext(modelContext)
            viewModel.startWorkout()
        }
    }
}

