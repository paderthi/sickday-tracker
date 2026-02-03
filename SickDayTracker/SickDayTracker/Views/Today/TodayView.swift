import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date, order: .reverse) private var dailyLogs: [DailyLog]
    @Query private var episodes: [SicknessEpisode]

    @State private var viewModel = TodayViewModel()
    @State private var showingLogForm = false
    @State private var editingLog: DailyLog?

    private var todayLog: DailyLog? {
        viewModel.getDailyLog(for: Date())
    }

    private var streak: Int {
        viewModel.getCurrentStreak()
    }

    private var activeEpisode: SicknessEpisode? {
        viewModel.getActiveEpisode()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCards

                    if let log = todayLog {
                        logSummaryCard(log)
                    }
                }
                .padding()
            }
            .navigationTitle("Today")
            .onAppear {
                viewModel.modelContext = modelContext
            }
            .sheet(isPresented: $showingLogForm) {
                if let log = editingLog {
                    DailyLogFormView(log: log) {
                        viewModel.saveOrUpdateDailyLog(log)
                    }
                }
            }
        }
    }

    private var summaryCards: some View {
        VStack(spacing: 16) {
            if todayLog == nil {
                Button(action: {
                    let newLog = viewModel.createDailyLog(for: Date())
                    editingLog = newLog
                    showingLogForm = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Log Today")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .accessibilityLabel("Log Today")
                .accessibilityHint("Create a new daily health log for today")
                .accessibilityIdentifier(AccessibilityIdentifiers.logTodayButton)
            }

            HStack(spacing: 12) {
                streakCard
                if let episode = activeEpisode {
                    activeEpisodeCard(episode)
                }
            }
        }
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Streak")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text("\(streak)")
                .font(.system(size: 36, weight: .bold))
            Text(streak == 1 ? "day" : "days")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current logging streak: \(streak) \(streak == 1 ? "day" : "days")")
        .accessibilityIdentifier(AccessibilityIdentifiers.streakCard)
    }

    private func activeEpisodeCard(_ episode: SicknessEpisode) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundColor(.red)
                Text("Active")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text(episode.type.rawValue)
                .font(.headline)
            Text("Day \(daysActive(episode))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func logSummaryCard(_ log: DailyLog) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Log")
                    .font(.headline)
                Spacer()
                Button(action: {
                    editingLog = log
                    showingLogForm = true
                }) {
                    Text("Edit")
                        .font(.subheadline)
                }
                .accessibilityLabel("Edit today's log")
                .accessibilityHint("Opens form to edit your daily health log")
                .accessibilityIdentifier(AccessibilityIdentifiers.editLogButton)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                logRow(icon: "bed.double.fill", label: "Sleep", value: "\(log.sleepHours, specifier: "%.1f")h", detail: "Quality: \(log.sleepQuality)/5")
                logRow(icon: "brain.head.profile", label: "Stress", value: "\(log.stress)/5", detail: nil)
                if log.exerciseMinutes > 0 {
                    logRow(icon: "figure.run", label: "Exercise", value: "\(log.exerciseMinutes) min", detail: log.exerciseType.rawValue)
                }
                logRow(icon: "fork.knife", label: "Sugar", value: log.sugarIntake.rawValue, detail: nil)

                if log.officeDay || log.sickContactExposure || log.humidifierUsed {
                    Divider()
                    HStack(spacing: 12) {
                        if log.officeDay {
                            Label("Office", systemImage: "building.2")
                                .font(.caption)
                        }
                        if log.sickContactExposure {
                            Label("Exposure", systemImage: "person.2")
                                .font(.caption)
                        }
                        if log.humidifierUsed {
                            Label("Humidifier", systemImage: "humidity")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.secondary)
                }

                if !log.notes.isEmpty {
                    Divider()
                    Text(log.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func logRow(icon: String, label: String, value: String, detail: String?) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let detail = detail {
                    Text(detail)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func daysActive(_ episode: SicknessEpisode) -> Int {
        Calendar.current.dateComponents([.day], from: episode.startDate, to: Date()).day ?? 0
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [DailyLog.self, SicknessEpisode.self])
}
