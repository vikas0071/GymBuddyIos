import SwiftUI
import SwiftData

struct SplitSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutSplit.name) private var splits: [WorkoutSplit]
    @Query(sort: \WorkoutLog.completedAt, order: .reverse) private var logs: [WorkoutLog]
    
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingSettings = false
    @State private var selectedSplit: WorkoutSplit?
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                    // Header with Stats
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("GymBuddy")
                                    .roundedFont(size: 28, weight: .bold)
                                    .foregroundColor(.white)
                                Text(activeSplit == nil ? "Ready to start your journey?" : "Welcome back, Athlete")
                                    .roundedFont(size: 14)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: { showingSettings = true }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Theme.accent)
                            }
                        }
                        
                        // Weekly Activity Tracker
                        WeeklyActivityBar(logs: logs)
                            .padding(.top, 8)
                        
                        HStack(spacing: 16) {
                            StatCard(title: "Total Workouts", value: "\(viewModel.totalWorkouts)", icon: "figure.strengthtraining.traditional")
                            StatCard(title: "Avg Duration", value: "\(viewModel.totalHours)h", icon: "clock.fill")
                        }
                    }
                    .padding(.horizontal)
                    
                    if let activeSplit = activeSplit {
                        // DASHBOARD MODE: Show today's suggestion for the ACTIVE split
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Current Program")
                                .roundedFont(size: 14, weight: .bold)
                                .foregroundColor(Theme.accent)
                                .padding(.horizontal)
                            
                            TodaySuggestionCard(split: activeSplit)
                                .padding(.horizontal)
                            
                            Button(action: { switchToSelectionMode() }) {
                                HStack {
                                    Image(systemName: "arrow.left.arrow.right")
                                    Text("Switch to another program")
                                        .roundedFont(size: 14, weight: .bold)
                                }
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.surface)
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        // SELECTION MODE: Show all training programs for the user to pick
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Choose Your Path")
                                    .roundedFont(size: 22, weight: .bold)
                                    .foregroundColor(.white)
                                Text("Select a training split to activate your dashboard")
                                    .roundedFont(size: 14)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            if splits.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(splits) { split in
                                    Button(action: { activateSplit(split) }) {
                                        SplitCard(split: split, isActive: false)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    QuoteCard()
                        .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .navigationDestination(item: $selectedSplit) { split in
                TodayWorkoutView(split: split)
            }
            .onAppear {
                checkAndInitializeData()
                viewModel.update(from: splits, logs: logs)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private var activeSplit: WorkoutSplit? {
        splits.first(where: { $0.isActive })
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(Theme.accent.opacity(0.5))
            Text("Building your programs...")
                .roundedFont(size: 14)
                .foregroundColor(.gray)
            ProgressView()
                .tint(Theme.accent)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Theme.surface)
        .cornerRadius(24)
        .padding(.horizontal)
    }
    
    private func checkAndInitializeData() {
        if splits.isEmpty {
            modelContext.insert(SchedulerService.generateDefaultSplit())
            modelContext.insert(SchedulerService.generateFullBodyBeginner())
            modelContext.insert(SchedulerService.generateUpperLower())
            modelContext.insert(SchedulerService.generateBroSplit())
            try? modelContext.save()
        }
    }
    
    private func activateSplit(_ split: WorkoutSplit) {
        withAnimation {
            for s in splits {
                s.isActive = (s.id == split.id)
            }
            try? modelContext.save()
        }
    }
    
    private func switchToSelectionMode() {
        withAnimation {
            for s in splits {
                s.isActive = false
            }
            try? modelContext.save()
        }
    }
    
    private func selectAndNavigate(_ split: WorkoutSplit) {
        withAnimation {
            activateSplit(split)
            selectedSplit = split
        }
    }
}

struct TodaySuggestionCard: View {
    let split: WorkoutSplit
    let dayIndex = SchedulerService.shared.getCurrentDayIndex()
    
    var body: some View {
        let today = split.days.first(where: { $0.dayIndex == dayIndex })
        let isRestDay = today?.isRestDay ?? true
        
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("TODAY'S SUGGESTION")
                    .roundedFont(size: 12, weight: .bold)
                    .foregroundColor(Theme.accent)
                Spacer()
                Image(systemName: isRestDay ? "bed.double.fill" : "flame.fill")
                    .foregroundColor(isRestDay ? .blue : .orange)
            }
            
            if isRestDay {
                Text("Rest & Recovery")
                    .roundedFont(size: 24, weight: .bold)
                    .foregroundColor(.white)
                Text(SchedulerService.shared.getRestDayMessage())
                    .roundedFont(size: 14)
                    .foregroundColor(.gray)
            } else {
                Text(today?.targetMuscles.map { $0.capitalized }.joined(separator: " & ") ?? "Full Body")
                    .roundedFont(size: 24, weight: .bold)
                    .foregroundColor(.white)
                Text("Crush your \(split.name) session today!")
                    .roundedFont(size: 14)
                    .foregroundColor(.gray)
            }
        }
        .padding(24)
        .background(Theme.surface)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            if !isRestDay {
                NavigationLink(destination: TodayWorkoutView(split: split)) {
                    Text("Start")
                        .roundedFont(size: 12, weight: .bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(16)
                }
            }
        }
    }
}

struct SplitCard: View {
    let split: WorkoutSplit
    let isActive: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(split.name)
                        .roundedFont(size: 20, weight: .bold)
                        .foregroundColor(.white)
                    if isActive {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.accent)
                    }
                }
                
                HStack(spacing: 8) {
                    BadgeView(text: "\(split.days.filter { !$0.isRestDay }.count) Days/Week", color: .gray)
                    BadgeView(text: split.safeDifficulty, color: split.safeDifficulty == "Advanced" ? .orange : .green)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 20))
                .foregroundColor(.gray)
        }
        .padding(24)
        .background(isActive ? Theme.accent.opacity(0.1) : Theme.surface)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isActive ? Theme.accent : Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .roundedFont(size: 10, weight: .bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}
