import SwiftUI
import SwiftData
import Combine

class DashboardViewModel: ObservableObject {
    @Published var activeSplit: WorkoutSplit?
    @Published var totalWorkouts: Int = 0
    @Published var totalHours: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    func update(from splits: [WorkoutSplit], logs: [WorkoutLog]) {
        self.activeSplit = splits.first(where: { $0.isActive })
        self.totalWorkouts = logs.count
        self.totalHours = Int(logs.reduce(0) { $0 + $1.duration } / 3600)
    }
}
