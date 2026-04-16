import SwiftUI
import SwiftData
import Combine

class DashboardViewModel: ObservableObject {
    @Published var activeSplit: WorkoutSplit?
    @Published var totalWorkouts: Int = 0
    @Published var totalHours: Int = 0
    
    func update(from splits: [WorkoutSplit], logs: [WorkoutLog]) {
        self.activeSplit = splits.first(where: { $0.isActive })
        self.totalWorkouts = logs.count
        self.totalHours = Int(logs.reduce(0) { $0 + $1.duration } / 3600)
    }
    
    func activateSplit(_ split: WorkoutSplit, in splits: [WorkoutSplit], context: ModelContext) {
        withAnimation {
            for s in splits {
                s.isActive = (s.id == split.id)
            }
            try? context.save()
        }
    }
    
    func switchToSelectionMode(in splits: [WorkoutSplit], context: ModelContext) {
        withAnimation {
            for s in splits {
                s.isActive = false
            }
            try? context.save()
        }
    }
    
    func ensureDataInitialized(splits: [WorkoutSplit], context: ModelContext) {
        if splits.isEmpty {
            context.insert(SchedulerService.generateDefaultSplit())
            context.insert(SchedulerService.generateFullBodyBeginner())
            context.insert(SchedulerService.generateUpperLower())
            context.insert(SchedulerService.generateBroSplit())
            try? context.save()
        }
    }
}
