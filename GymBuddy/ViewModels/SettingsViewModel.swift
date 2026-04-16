import SwiftUI
import SwiftData
import Combine

class SettingsViewModel: ObservableObject {
    func resetToDefault(splits: [WorkoutSplit], context: ModelContext) {
        withAnimation {
            for split in splits {
                context.delete(split)
            }
            context.insert(SchedulerService.generateDefaultSplit())
            context.insert(SchedulerService.generateFullBodyBeginner())
            context.insert(SchedulerService.generateUpperLower())
            context.insert(SchedulerService.generateBroSplit())
            try? context.save()
        }
    }
    
    func selectSplit(_ split: WorkoutSplit, in splits: [WorkoutSplit], context: ModelContext) {
        withAnimation {
            for s in splits {
                s.isActive = (s.id == split.id)
            }
            try? context.save()
        }
    }
}
