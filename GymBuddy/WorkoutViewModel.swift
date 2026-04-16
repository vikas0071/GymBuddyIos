import SwiftUI
import SwiftData
import AVFoundation
import Combine

class WorkoutViewModel: ObservableObject {
    enum WorkoutTimerState {
        case preparation
        case active
        case rest
    }
    
    // Dependencies
    private let exercises: [Exercise]
    private let splitId: UUID
    private let dayIndex: Int
    private var modelContext: ModelContext?
    
    // Published State
    @Published var currentExerciseIndex = 0
    @Published var currentSet = 1
    @Published var totalSets = 3
    @Published var workoutState: WorkoutTimerState = .preparation
    @Published var timeRemaining: Int = 5
    @Published var elapsedTime: Int = 0
    @Published var totalWorkoutDuration: Int = 0
    @Published var isCompleted = false
    
    // Internal
    private var timer: AnyCancellable?
    
    init(exercises: [Exercise], splitId: UUID, dayIndex: Int, modelContext: ModelContext?) {
        self.exercises = exercises
        self.splitId = splitId
        self.dayIndex = dayIndex
        self.modelContext = modelContext
    }
    
    var currentExercise: Exercise {
        exercises[currentExerciseIndex]
    }
    
    var totalExercisesCount: Int {
        exercises.count
    }
    
    var nextExerciseName: String? {
        guard currentExerciseIndex + 1 < exercises.count else { return nil }
        return exercises[currentExerciseIndex + 1].name
    }
    
    func startWorkout() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    private func updateTimer() {
        totalWorkoutDuration += 1
        
        switch workoutState {
        case .preparation:
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                startActive()
            }
        case .active:
            elapsedTime += 1
        case .rest:
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining <= 3 && timeRemaining > 0 {
                    playBeep()
                }
            } else {
                startNextSet()
            }
        }
    }
    
    func startActive() {
        hapticFeedback(style: .medium)
        workoutState = .active
        elapsedTime = 0
    }
    
    func completeSet() {
        hapticFeedback(type: .success)
        playSuccessSound()
        
        if currentSet < totalSets {
            workoutState = .rest
            timeRemaining = 60
        } else {
            if currentExerciseIndex < exercises.count - 1 {
                workoutState = .rest
                timeRemaining = 90
            } else {
                finishWorkout()
            }
        }
    }
    
    func skipRest() {
        startNextSet()
    }
    
    private func startNextSet() {
        hapticFeedback(style: .medium)
        if currentSet < totalSets {
            currentSet += 1
        } else {
            currentSet = 1
            currentExerciseIndex += 1
        }
        workoutState = .active
        elapsedTime = 0
    }
    
    private func finishWorkout() {
        timer?.cancel()
        saveWorkout()
        withAnimation {
            isCompleted = true
        }
    }
    
    private func saveWorkout() {
        guard let modelContext = modelContext else { return }
        let log = WorkoutLog(
            completedAt: Date(),
            duration: TimeInterval(totalWorkoutDuration),
            splitId: splitId,
            dayIndex: dayIndex,
            exerciseCount: exercises.count,
            caloriesBurned: exercises.count * 45
        )
        modelContext.insert(log)
    }
    
    // MARK: - Helpers
    
    func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    func progressValue() -> Double {
        switch workoutState {
        case .preparation: return Double(timeRemaining) / 5.0
        case .active: return 1.0
        case .rest: return Double(timeRemaining) / (currentSet == totalSets ? 90.0 : 60.0)
        }
    }
    
    private func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    private func hapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    private func playBeep() {
        AudioServicesPlaySystemSound(1052)
    }
    
    private func playSuccessSound() {
        AudioServicesPlaySystemSound(1054)
    }
    
    func updateModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    deinit {
        timer?.cancel()
    }
}
