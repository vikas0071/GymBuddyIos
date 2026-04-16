import Foundation

class SchedulerService {
    static let shared = SchedulerService()
    
    private init() {}
    
    /// Returns 1 for Monday, 7 for Sunday
    func getCurrentDayIndex() -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // Sunday is 1 in Calendar, but we want Monday=1, Sunday=7
        let adjusted = (weekday + 5) % 7 + 1
        return adjusted
    }
    
    func getWeekdayName(for index: Int) -> String {
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        guard index >= 1 && index <= 7 else { return "Unknown" }
        return weekdays[index - 1]
    }
    
    func getRestDayMessage() -> String {
        let messages = [
            "Your muscles grow while you rest. Enjoy your recovery!",
            "Rest is just as important as the workout. Recharge for tomorrow.",
            "Recovery mode: ON. Stay hydrated and eat well.",
            "Don't neglect your sleep. It's the ultimate performance enhancer.",
            "Take a deep breath. Your body has earned this break."
        ]
        return messages.randomElement() ?? "Enjoy your rest day!"
    }
    
    /// Pre-populates a default PPL-style split
    static func generateDefaultSplit() -> WorkoutSplit {
        let ppl = WorkoutSplit(name: "GymBuddy PPL", isActive: false, difficulty: "Advanced")
        ppl.days = [
            WorkoutDay(dayIndex: 1, targetMuscles: ["chest", "shoulders", "triceps"]), // Mon: Push
            WorkoutDay(dayIndex: 2, targetMuscles: ["middle back", "lats", "biceps"]), // Tue: Pull
            WorkoutDay(dayIndex: 3, targetMuscles: ["quadriceps", "hamstrings", "calves"]), // Wed: Legs
            WorkoutDay(dayIndex: 4, isRestDay: true), // Thu: Rest
            WorkoutDay(dayIndex: 5, targetMuscles: ["chest", "middle back", "biceps", "triceps"]), // Fri: Upper
            WorkoutDay(dayIndex: 6, targetMuscles: ["quadriceps", "glutes", "lower back"]), // Sat: Lower
            WorkoutDay(dayIndex: 7, isRestDay: true) // Sun: Rest
        ]
        return ppl
    }
    
    static func generateFullBodyBeginner() -> WorkoutSplit {
        let fb = WorkoutSplit(name: "Full Body Foundation", isActive: false, difficulty: "Beginner")
        fb.days = [
            WorkoutDay(dayIndex: 1, targetMuscles: ["chest", "middle back", "quadriceps", "abdominals"]), // Mon
            WorkoutDay(dayIndex: 2, isRestDay: true), // Tue
            WorkoutDay(dayIndex: 3, targetMuscles: ["shoulders", "lats", "glutes", "hamstrings"]), // Wed
            WorkoutDay(dayIndex: 4, isRestDay: true), // Thu
            WorkoutDay(dayIndex: 5, targetMuscles: ["chest", "middle back", "quadriceps", "biceps", "triceps"]), // Fri
            WorkoutDay(dayIndex: 6, isRestDay: true), // Sat
            WorkoutDay(dayIndex: 7, isRestDay: true) // Sun
        ]
        return fb
    }
    
    static func generateUpperLower() -> WorkoutSplit {
        let ul = WorkoutSplit(name: "Upper Lower Pro", isActive: false, difficulty: "Intermediate")
        ul.days = [
            WorkoutDay(dayIndex: 1, targetMuscles: ["chest", "middle back", "shoulders", "biceps", "triceps"]), // Mon: Upper
            WorkoutDay(dayIndex: 2, targetMuscles: ["quadriceps", "hamstrings", "glutes", "calves"]), // Tue: Lower
            WorkoutDay(dayIndex: 3, isRestDay: true), // Wed
            WorkoutDay(dayIndex: 4, targetMuscles: ["chest", "lats", "shoulders", "biceps", "triceps"]), // Thu: Upper
            WorkoutDay(dayIndex: 5, targetMuscles: ["quadriceps", "hamstrings", "glutes", "calves"]), // Fri: Lower
            WorkoutDay(dayIndex: 6, isRestDay: true), // Sat
            WorkoutDay(dayIndex: 7, isRestDay: true) // Sun
        ]
        return ul
    }
    
    static func generateBroSplit() -> WorkoutSplit {
        let bro = WorkoutSplit(name: "Classic Bro Split", isActive: false, difficulty: "Intermediate")
        bro.days = [
            WorkoutDay(dayIndex: 1, targetMuscles: ["chest"]), // Mon
            WorkoutDay(dayIndex: 2, targetMuscles: ["middle back", "lats"]), // Tue
            WorkoutDay(dayIndex: 3, targetMuscles: ["shoulders"]), // Wed
            WorkoutDay(dayIndex: 4, targetMuscles: ["quadriceps", "hamstrings", "glutes"]), // Thu
            WorkoutDay(dayIndex: 5, targetMuscles: ["biceps", "triceps"]), // Fri
            WorkoutDay(dayIndex: 6, isRestDay: true), // Sat
            WorkoutDay(dayIndex: 7, isRestDay: true) // Sun
        ]
        return bro
    }
}
