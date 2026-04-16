import Foundation
import Combine

class ExerciseManager: ObservableObject {
    static let shared = ExerciseManager()
    
    @Published var allExercises: [Exercise] = []
    @Published var isLoading = false
    
    private init() {
        loadExercises()
    }
    
    func loadExercises() {
        isLoading = true
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("❌ exercises.json not found in bundle")
            self.isLoading = false
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let exercises = try decoder.decode([Exercise].self, from: data)
                
                DispatchQueue.main.async {
                    self.allExercises = exercises
                    self.isLoading = false
                    print("✅ Successfully loaded \(exercises.count) exercises from bundle")
                }
            } catch {
                print("❌ Failed to decode exercises.json: \(error)")
                self.loadMockExercises()
            }
        }
    }
    
    private func loadMockExercises() {
        print("⚠️ Loading mock exercises as fallback")
        let mocks = [
            Exercise(id: "push_up", name: "Push Up", force: "push", level: "beginner", mechanic: "compound", equipment: "body only", primaryMuscles: ["chest", "triceps", "shoulders"], secondaryMuscles: [], instructions: ["Lower your body until your chest almost touches the floor.", "Push yourself back up."], category: "strength", images: []),
            Exercise(id: "pull_up", name: "Pull Up", force: "pull", level: "intermediate", mechanic: "compound", equipment: "other", primaryMuscles: ["middle back", "lats", "biceps"], secondaryMuscles: [], instructions: ["Pull your body up until your chin is over the bar.", "Lower yourself back down."], category: "strength", images: []),
            Exercise(id: "squat", name: "Bodyweight Squat", force: "push", level: "beginner", mechanic: "compound", equipment: "body only", primaryMuscles: ["quadriceps", "hamstrings", "glutes"], secondaryMuscles: ["calves"], instructions: ["Lower your hips as if sitting in a chair.", "Stand back up."], category: "strength", images: []),
            Exercise(id: "plank", name: "Plank", force: "static", level: "beginner", mechanic: "isolation", equipment: "body only", primaryMuscles: ["abdominals"], secondaryMuscles: ["shoulders"], instructions: ["Hold a push-up position on your elbows.", "Keep your body straight."], category: "strength", images: [])
        ]
        
        DispatchQueue.main.async {
            self.allExercises = mocks
            self.isLoading = false
            print("✅ Loaded \(mocks.count) mock exercises")
        }
    }
    
    func getRandomExercises(for muscles: [String], count: Int = 10) -> [Exercise] {
        if allExercises.isEmpty {
            print("⚠️ allExercises is empty, cannot filter")
            return []
        }
        
        let filtered = allExercises.filter { exercise in
            exercise.primaryMuscles.contains { muscle in
                muscles.contains { $0.lowercased() == muscle.lowercased() }
            }
        }
        
        print("🔍 Found \(filtered.count) exercises for muscles: \(muscles)")
        
        if filtered.isEmpty {
            // Fallback: return a few random ones if no match found for specific muscles
            print("⚠️ No exact muscle match found, returning random selection")
            return Array(allExercises.shuffled().prefix(count))
        }
        
        return Array(filtered.shuffled().prefix(count))
    }
}
