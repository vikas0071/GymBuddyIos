import Foundation
import SwiftData

// MARK: - Exercise (JSON Model)
struct Exercise: Identifiable, Codable {
    let id: String
    let name: String
    let force: String?
    let level: String
    let mechanic: String?
    let equipment: String?
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let instructions: [String]
    let category: String
    let images: [String]
}

// MARK: - SwiftData Models

@Model
final class WorkoutSplit {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \WorkoutDay.split)
    var days: [WorkoutDay]
    var isActive: Bool
    var difficulty: String?
    
    var safeDifficulty: String {
        difficulty ?? "Beginner"
    }
    
    init(name: String, days: [WorkoutDay] = [], isActive: Bool = false, difficulty: String = "Beginner") {
        self.id = UUID()
        self.name = name
        self.days = days
        self.isActive = isActive
        self.difficulty = difficulty
    }
}

@Model
final class WorkoutDay {
    @Attribute(.unique) var id: UUID
    var dayIndex: Int // 1 = Monday, 7 = Sunday
    var targetMuscles: [String] = []
    var isRestDay: Bool
    var split: WorkoutSplit?
    
    init(dayIndex: Int, targetMuscles: [String] = [], isRestDay: Bool = false) {
        self.id = UUID()
        self.dayIndex = dayIndex
        self.targetMuscles = targetMuscles
        self.isRestDay = isRestDay
    }
}

@Model
final class WorkoutLog {
    var id: UUID
    var completedAt: Date
    var duration: TimeInterval
    var splitId: UUID
    var dayIndex: Int
    var exerciseCount: Int
    var caloriesBurned: Int // Extra flair
    
    init(completedAt: Date, duration: TimeInterval, splitId: UUID, dayIndex: Int, exerciseCount: Int, caloriesBurned: Int = 0) {
        self.id = UUID()
        self.completedAt = completedAt
        self.duration = duration
        self.splitId = splitId
        self.dayIndex = dayIndex
        self.exerciseCount = exerciseCount
        self.caloriesBurned = caloriesBurned
    }
}
