import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SicknessEpisode.startDate, order: .reverse) private var episodes: [SicknessEpisode]

    @State private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    disclaimerCard

                    episodeCountsCard

                    if let avgDuration = viewModel.getAverageDuration() {
                        averageDurationCard(avgDuration)
                    }

                    symptomFrequencyCard

                    if !episodes.isEmpty {
                        episodesTimelineCard
                    }

                    if !episodes.isEmpty {
                        triggerAnalysisCard
                    }
                }
                .padding()
            }
            .navigationTitle("Insights")
            .onAppear {
                viewModel.modelContext = modelContext
            }
        }
    }

    private var disclaimerCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
                .font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text("Not Medical Advice")
                    .font(.headline)
                Text("These insights are for tracking purposes only and do not constitute medical advice. Consult a healthcare provider for medical concerns.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    private var episodeCountsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Episode Counts")
                .font(.headline)

            HStack(spacing: 12) {
                countPill(period: "30 Days", count: viewModel.getEpisodeCount(days: 30))
                countPill(period: "90 Days", count: viewModel.getEpisodeCount(days: 90))
                countPill(period: "1 Year", count: viewModel.getEpisodeCount(days: 365))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func countPill(period: String, count: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 28, weight: .bold))
            Text(period)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }

    private func averageDurationCard(_ avgDuration: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Average Duration")
                .font(.headline)

            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text(String(format: "%.1f days", avgDuration))
                    .font(.system(size: 32, weight: .bold))
                Spacer()
            }

            Text("Calculated from completed episodes only")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var symptomFrequencyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Symptom Frequency")
                .font(.headline)

            let symptomData = viewModel.getSymptomFrequency()

            if symptomData.isEmpty {
                Text("No symptom data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart {
                    ForEach(symptomData, id: \.symptom) { item in
                        BarMark(
                            x: .value("Count", item.count),
                            y: .value("Symptom", item.symptom.rawValue)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                }
                .frame(height: CGFloat(max(200, symptomData.count * 30)))
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var episodesTimelineCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Episodes Timeline")
                .font(.headline)

            Chart {
                ForEach(episodes.prefix(10)) { episode in
                    let startDate = episode.startDate
                    let endDate = episode.endDate ?? Date()

                    RectangleMark(
                        xStart: .value("Start", startDate),
                        xEnd: .value("End", endDate),
                        y: .value("Type", episode.type.rawValue)
                    )
                    .foregroundStyle(by: .value("Type", episode.type.rawValue))
                    .opacity(episode.isActive ? 1.0 : 0.6)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }

            if episodes.count > 10 {
                Text("Showing last 10 episodes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var triggerAnalysisCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Potential Triggers")
                .font(.headline)

            Text("Comparing 7 days before each episode to baseline (last 60 days excluding episode windows)")
                .font(.caption)
                .foregroundColor(.secondary)

            if let latestEpisode = episodes.first,
               let analysis = viewModel.getTriggerAnalysis(for: latestEpisode) {
                VStack(spacing: 12) {
                    Text("Latest Episode: \(latestEpisode.type.rawValue)")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    comparisonRow(
                        label: "Sleep",
                        preEpisode: analysis.preEpisode.avgSleepHours,
                        baseline: analysis.baseline.avgSleepHours,
                        format: "%.1f hrs"
                    )

                    comparisonRow(
                        label: "Stress",
                        preEpisode: analysis.preEpisode.avgStress,
                        baseline: analysis.baseline.avgStress,
                        format: "%.1f/5"
                    )

                    comparisonRow(
                        label: "Office Days",
                        preEpisode: Double(analysis.preEpisode.officeDays),
                        baseline: Double(analysis.baseline.officeDays),
                        format: "%.0f days",
                        isCount: true
                    )

                    comparisonRow(
                        label: "Sick Contact",
                        preEpisode: Double(analysis.preEpisode.sickContactDays),
                        baseline: Double(analysis.baseline.sickContactDays),
                        format: "%.0f days",
                        isCount: true
                    )

                    comparisonRow(
                        label: "Humidifier",
                        preEpisode: Double(analysis.preEpisode.humidifierDays),
                        baseline: Double(analysis.baseline.humidifierDays),
                        format: "%.0f days",
                        isCount: true
                    )
                }
            } else {
                Text("Not enough data for trigger analysis")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func comparisonRow(label: String, preEpisode: Double, baseline: Double, format: String, isCount: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 8) {
                    Text("Before:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: format, preEpisode))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                HStack(spacing: 8) {
                    Text("Baseline:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: format, baseline))
                        .font(.subheadline)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: [SicknessEpisode.self, DailyLog.self])
}
