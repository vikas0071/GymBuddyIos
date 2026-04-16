import SwiftUI
import Combine

class ExerciseListViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var isLoading: Bool = false
    
    private let exerciseManager = ExerciseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        exerciseManager.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
    }
    
    func fetchExercises(for muscles: [String]) {
        if exercises.isEmpty {
            self.exercises = exerciseManager.getRandomExercises(for: muscles)
        }
    }
}
