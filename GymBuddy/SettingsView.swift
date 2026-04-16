import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \WorkoutSplit.name) private var splits: [WorkoutSplit]
    @Query(sort: \WorkoutLog.completedAt, order: .reverse) private var logs: [WorkoutLog]
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("useMetric") private var useMetric = true
    
    @State private var quote = "The only bad workout is the one that didn't happen."
    
    let quotes = [
        "The only bad workout is the one that didn't happen.",
        "Motivation is what gets you started. Habit is what keeps you going.",
        "Your body can stand almost anything. It’s your mind that you have to convince.",
        "Focus on progress, not perfection.",
        "Discipline is doing what needs to be done, even if you don't want to do it.",
        "Success starts with self-discipline.",
        "Don't stop when you're tired. Stop when you're done.",
        "Strength does not come from winning. Your struggles develop your strengths."
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Preferences Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("App Preferences")
                                .roundedFont(size: 14, weight: .bold)
                                .foregroundColor(Theme.accent)
                            
                            VStack(spacing: 12) {
                                Toggle(isOn: $isDarkMode) {
                                    Label("Dark Mode", systemImage: "moon.fill")
                                        .roundedFont(size: 16)
                                        .foregroundColor(.white)
                                }
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                Toggle(isOn: $useMetric) {
                                    Label(useMetric ? "Metric (KG)" : "Imperial (LBS)", systemImage: "scalemass.fill")
                                        .roundedFont(size: 16)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(Theme.surface)
                            .cornerRadius(20)
                        }
                        
                        // History Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Workout History")
                                .roundedFont(size: 14, weight: .bold)
                                .foregroundColor(Theme.accent)
                            
                            if logs.isEmpty {
                                Text("No workouts logged yet. Time to crush one!")
                                    .roundedFont(size: 14)
                                    .foregroundColor(.gray)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Theme.surface)
                                    .cornerRadius(20)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(Array(logs.prefix(5))) { log in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(log.completedAt.formatted(date: .abbreviated, time: .omitted))
                                                    .roundedFont(size: 16, weight: .bold)
                                                    .foregroundColor(.white)
                                                Text("\(log.exerciseCount) exercises • \(Int(log.duration / 60)) min")
                                                    .roundedFont(size: 12)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Theme.surface)
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }

                        // Splits Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Workout Programs")
                                    .roundedFont(size: 14, weight: .bold)
                                    .foregroundColor(Theme.accent)
                                Spacer()
                                Button(action: resetToDefault) {
                                    Text("Reset Programs")
                                        .roundedFont(size: 12)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            ForEach(splits) { split in
                                Button(action: { selectSplit(split) }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(split.name)
                                                .roundedFont(size: 16, weight: .bold)
                                                .foregroundColor(.white)
                                            Text("\(split.safeDifficulty) • \(split.days.count) Days")
                                                .roundedFont(size: 12)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        if split.isActive {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Theme.accent)
                                        }
                                    }
                                    .padding()
                                    .background(Theme.surface)
                                    .cornerRadius(20)
                                }
                            }
                        }
                        
                        // Quote Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Daily Motivation")
                                .roundedFont(size: 14, weight: .bold)
                                .foregroundColor(Theme.accent)
                            
                            Text("\"\(quote)\"")
                                .roundedFont(size: 16, weight: .medium)
                                .italic()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Theme.surface)
                                .cornerRadius(20)
                                .onTapGesture {
                                    withAnimation { quote = quotes.randomElement() ?? quote }
                                }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings & Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.accent)
                        .roundedFont(size: 16, weight: .bold)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    
    private func selectSplit(_ selectedSplit: WorkoutSplit) {
        withAnimation {
            for split in splits {
                split.isActive = (split.id == selectedSplit.id)
            }
            try? modelContext.save()
        }
    }
    
    private func resetToDefault() {
        withAnimation {
            for split in splits { modelContext.delete(split) }
            modelContext.insert(SchedulerService.generateDefaultSplit())
            modelContext.insert(SchedulerService.generateFullBodyBeginner())
            try? modelContext.save()
        }
    }
}
