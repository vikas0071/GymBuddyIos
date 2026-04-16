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
                                Text("Select your training program")
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
                        
                        HStack(spacing: 16) {
                            StatCard(title: "Total Workouts", value: "\(viewModel.totalWorkouts)", icon: "figure.strengthtraining.traditional")
                            StatCard(title: "Avg Duration", value: "\(viewModel.totalHours)h", icon: "clock.fill")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Today's Suggestion Card
                    if let activeSplit = splits.first(where: { $0.isActive }) {
                        TodaySuggestionCard(split: activeSplit)
                            .padding(.horizontal)
                    }

                    // Split Selection List
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Training Programs")
                            .roundedFont(size: 18, weight: .bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        if splits.isEmpty {
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
                        } else {
                            ForEach(splits) { split in
                                Button(action: { 
                                    selectAndNavigate(split)
                                }) {
                                    SplitCard(split: split, isActive: split.isActive)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    QuoteCard()
                        .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
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
    
    private func checkAndInitializeData() {
        if splits.isEmpty {
            modelContext.insert(SchedulerService.generateDefaultSplit())
            modelContext.insert(SchedulerService.generateFullBodyBeginner())
            try? modelContext.save()
        }
    }
    
    private func selectAndNavigate(_ split: WorkoutSplit) {
        withAnimation {
            for s in splits {
                s.isActive = (s.id == split.id)
            }
            try? modelContext.save()
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
