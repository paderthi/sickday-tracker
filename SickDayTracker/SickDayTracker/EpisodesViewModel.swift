import Foundation
import SwiftData

@Observable
class EpisodesViewModel {
    var modelContext: ModelContext?

    func saveOrUpdateEpisode(_ episode: SicknessEpisode) {
        guard let modelContext = modelContext else { return }

        episode.updatedAt = Date()

        do {
            try modelContext.save()
        } catch {
            print("Error saving episode: \(error)")
        }
    }

    func createEpisode() -> SicknessEpisode {
        let episode = SicknessEpisode(startDate: Date())
        modelContext?.insert(episode)
        return episode
    }

    func deleteEpisode(_ episode: SicknessEpisode) {
        guard let modelContext = modelContext else { return }

        modelContext.delete(episode)

        do {
            try modelContext.save()
        } catch {
            print("Error deleting episode: \(error)")
        }
    }

    func checkOverlap(for episode: SicknessEpisode) -> [SicknessEpisode] {
        guard let modelContext = modelContext else { return [] }

        let descriptor = FetchDescriptor<SicknessEpisode>()

        do {
            let allEpisodes = try modelContext.fetch(descriptor)
            var overlapping: [SicknessEpisode] = []

            for other in allEpisodes {
                if other == episode { continue }

                let startDate = episode.startDate
                let endDate = episode.endDate ?? Date()
                let otherStart = other.startDate
                let otherEnd = other.endDate ?? Date()

                if startDate <= otherEnd && endDate >= otherStart {
                    overlapping.append(other)
                }
            }

            return overlapping
        } catch {
            print("Error checking overlap: \(error)")
            return []
        }
    }

    func getEpisodeDuration(_ episode: SicknessEpisode) -> String {
        guard let endDate = episode.endDate else {
            let days = Calendar.current.dateComponents([.day], from: episode.startDate, to: Date()).day ?? 0
            return "Active (\(days) days)"
        }

        let days = Calendar.current.dateComponents([.day], from: episode.startDate, to: endDate).day ?? 0
        return "\(days) days"
    }
}
