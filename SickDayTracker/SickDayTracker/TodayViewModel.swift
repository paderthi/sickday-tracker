import Foundation
import SwiftData

@Observable
class TodayViewModel {
    var selectedDate: Date = Date()
    var modelContext: ModelContext?

    func getDailyLog(for date: Date) -> DailyLog? {
        guard let modelContext = modelContext else { return nil }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<DailyLog> { log in
            log.date == startOfDay
        }

        let descriptor = FetchDescriptor<DailyLog>(predicate: predicate)

        do {
            let logs = try modelContext.fetch(descriptor)
            return logs.first
        } catch {
            print("Error fetching daily log: \(error)")
            return nil
        }
    }

    func saveOrUpdateDailyLog(_ log: DailyLog) {
        guard let modelContext = modelContext else { return }

        log.updatedAt = Date()

        do {
            try modelContext.save()
        } catch {
            print("Error saving daily log: \(error)")
        }
    }

    func createDailyLog(for date: Date) -> DailyLog {
        let log = DailyLog(date: date)
        modelContext?.insert(log)
        return log
    }

    func getCurrentStreak() -> Int {
        guard let modelContext = modelContext else { return 0 }

        let descriptor = FetchDescriptor<DailyLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            let logs = try modelContext.fetch(descriptor)
            var streak = 0
            var currentDate = Calendar.current.startOfDay(for: Date())

            for log in logs {
                let logDate = Calendar.current.startOfDay(for: log.date)
                if logDate == currentDate {
                    streak += 1
                    currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
                } else {
                    break
                }
            }

            return streak
        } catch {
            print("Error calculating streak: \(error)")
            return 0
        }
    }

    func getActiveEpisode() -> SicknessEpisode? {
        guard let modelContext = modelContext else { return nil }

        let predicate = #Predicate<SicknessEpisode> { episode in
            episode.endDate == nil
        }

        let descriptor = FetchDescriptor<SicknessEpisode>(predicate: predicate)

        do {
            let episodes = try modelContext.fetch(descriptor)
            return episodes.first
        } catch {
            print("Error fetching active episode: \(error)")
            return nil
        }
    }
}
