import Foundation
import SwiftData

@Observable
class InsightsViewModel {
    var modelContext: ModelContext?

    func getEpisodeCount(days: Int) -> Int {
        guard let modelContext = modelContext else { return 0 }

        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let predicate = #Predicate<SicknessEpisode> { episode in
            episode.startDate >= startDate
        }

        let descriptor = FetchDescriptor<SicknessEpisode>(predicate: predicate)

        do {
            let episodes = try modelContext.fetch(descriptor)
            return episodes.count
        } catch {
            print("Error fetching episode count: \(error)")
            return 0
        }
    }

    func getAverageDuration() -> Double? {
        guard let modelContext = modelContext else { return nil }

        let predicate = #Predicate<SicknessEpisode> { episode in
            episode.endDate != nil
        }

        let descriptor = FetchDescriptor<SicknessEpisode>(predicate: predicate)

        do {
            let completedEpisodes = try modelContext.fetch(descriptor)
            guard !completedEpisodes.isEmpty else { return nil }

            let totalDays = completedEpisodes.compactMap { $0.duration }.reduce(0, +)
            return Double(totalDays) / Double(completedEpisodes.count)
        } catch {
            print("Error calculating average duration: \(error)")
            return nil
        }
    }

    func getSymptomFrequency() -> [(symptom: Symptom, count: Int)] {
        guard let modelContext = modelContext else { return [] }

        let descriptor = FetchDescriptor<SicknessEpisode>()

        do {
            let episodes = try modelContext.fetch(descriptor)
            var symptomCounts: [Symptom: Int] = [:]

            for episode in episodes {
                for symptom in episode.symptoms {
                    symptomCounts[symptom, default: 0] += 1
                }
            }

            return symptomCounts.map { ($0.key, $0.value) }.sorted { $0.count > $1.count }
        } catch {
            print("Error calculating symptom frequency: \(error)")
            return []
        }
    }

    func getTriggerAnalysis(for episode: SicknessEpisode) -> TriggerAnalysis? {
        guard let modelContext = modelContext else { return nil }

        let sevenDaysBefore = Calendar.current.date(byAdding: .day, value: -7, to: episode.startDate)!
        let preEpisodeLogs = getDailyLogs(from: sevenDaysBefore, to: episode.startDate)

        guard !preEpisodeLogs.isEmpty else { return nil }

        let preEpisodeStats = calculateStats(from: preEpisodeLogs)

        let baselineLogs = getBaselineLogs(excluding: getAllEpisodes())
        guard !baselineLogs.isEmpty else { return nil }

        let baselineStats = calculateStats(from: baselineLogs)

        return TriggerAnalysis(
            preEpisode: preEpisodeStats,
            baseline: baselineStats
        )
    }

    private func getDailyLogs(from startDate: Date, to endDate: Date) -> [DailyLog] {
        guard let modelContext = modelContext else { return [] }

        let predicate = #Predicate<DailyLog> { log in
            log.date >= startDate && log.date <= endDate
        }

        let descriptor = FetchDescriptor<DailyLog>(predicate: predicate)

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching daily logs: \(error)")
            return []
        }
    }

    private func getBaselineLogs(excluding episodes: [SicknessEpisode]) -> [DailyLog] {
        guard let modelContext = modelContext else { return [] }

        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: Date())!
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { log in log.date >= sixtyDaysAgo },
            sortBy: [SortDescriptor(\.date)]
        )

        do {
            var logs = try modelContext.fetch(descriptor)

            for episode in episodes {
                let sevenDaysBefore = Calendar.current.date(byAdding: .day, value: -7, to: episode.startDate)!
                let episodeEnd = episode.endDate ?? Date()

                logs.removeAll { log in
                    log.date >= sevenDaysBefore && log.date <= episodeEnd
                }
            }

            return logs
        } catch {
            print("Error fetching baseline logs: \(error)")
            return []
        }
    }

    private func getAllEpisodes() -> [SicknessEpisode] {
        guard let modelContext = modelContext else { return [] }

        let descriptor = FetchDescriptor<SicknessEpisode>()

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching episodes: \(error)")
            return []
        }
    }

    private func calculateStats(from logs: [DailyLog]) -> HealthStats {
        guard !logs.isEmpty else {
            return HealthStats(avgSleepHours: 0, avgStress: 0, officeDays: 0, sickContactDays: 0, humidifierDays: 0)
        }

        let totalSleep = logs.reduce(0.0) { $0 + $1.sleepHours }
        let totalStress = logs.reduce(0) { $0 + $1.stress }
        let officeDays = logs.filter { $0.officeDay }.count
        let sickContactDays = logs.filter { $0.sickContactExposure }.count
        let humidifierDays = logs.filter { $0.humidifierUsed }.count

        return HealthStats(
            avgSleepHours: totalSleep / Double(logs.count),
            avgStress: Double(totalStress) / Double(logs.count),
            officeDays: officeDays,
            sickContactDays: sickContactDays,
            humidifierDays: humidifierDays
        )
    }
}

struct HealthStats {
    let avgSleepHours: Double
    let avgStress: Double
    let officeDays: Int
    let sickContactDays: Int
    let humidifierDays: Int
}

struct TriggerAnalysis {
    let preEpisode: HealthStats
    let baseline: HealthStats
}
