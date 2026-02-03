import XCTest
import SwiftData
@testable import SickDayTracker

final class EpisodeTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([
            DailyLog.self,
            SicknessEpisode.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Duration Calculation Tests

    func testEpisodeDurationCalculation() throws {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -10, to: Date())!
        let endDate = calendar.date(byAdding: .day, value: -5, to: Date())!

        let episode = SicknessEpisode(
            startDate: startDate,
            endDate: endDate,
            type: .cold
        )

        let duration = episode.duration
        XCTAssertNotNil(duration, "Duration should not be nil for completed episode")
        XCTAssertEqual(duration, 5, "Duration should be 5 days")
    }

    func testActiveEpisodeHasNoDuration() throws {
        let episode = SicknessEpisode(
            startDate: Date(),
            endDate: nil,
            type: .cold
        )

        XCTAssertNil(episode.duration, "Active episode should have nil duration")
        XCTAssertTrue(episode.isActive, "Episode should be marked as active")
    }

    func testEpisodeDurationZeroDays() throws {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = startDate

        let episode = SicknessEpisode(
            startDate: startDate,
            endDate: endDate,
            type: .cold
        )

        let duration = episode.duration
        XCTAssertEqual(duration, 0, "Same-day episode should have 0 duration")
    }

    // MARK: - Overlap Detection Tests

    func testOverlapDetectionWithCompleteOverlap() throws {
        let viewModel = EpisodesViewModel()
        viewModel.modelContext = modelContext

        let calendar = Calendar.current
        let episode1Start = calendar.date(byAdding: .day, value: -10, to: Date())!
        let episode1End = calendar.date(byAdding: .day, value: -5, to: Date())!

        let episode1 = SicknessEpisode(
            startDate: episode1Start,
            endDate: episode1End,
            type: .cold
        )
        modelContext.insert(episode1)
        try modelContext.save()

        let episode2Start = calendar.date(byAdding: .day, value: -8, to: Date())!
        let episode2End = calendar.date(byAdding: .day, value: -6, to: Date())!

        let episode2 = SicknessEpisode(
            startDate: episode2Start,
            endDate: episode2End,
            type: .cough
        )

        let overlaps = viewModel.checkOverlap(for: episode2)
        XCTAssertEqual(overlaps.count, 1, "Should detect one overlapping episode")
        XCTAssertEqual(overlaps.first?.type, .cold, "Should detect the cold episode")
    }

    func testOverlapDetectionWithPartialOverlap() throws {
        let viewModel = EpisodesViewModel()
        viewModel.modelContext = modelContext

        let calendar = Calendar.current
        let episode1Start = calendar.date(byAdding: .day, value: -10, to: Date())!
        let episode1End = calendar.date(byAdding: .day, value: -5, to: Date())!

        let episode1 = SicknessEpisode(
            startDate: episode1Start,
            endDate: episode1End,
            type: .cold
        )
        modelContext.insert(episode1)
        try modelContext.save()

        let episode2Start = calendar.date(byAdding: .day, value: -7, to: Date())!
        let episode2End = calendar.date(byAdding: .day, value: -3, to: Date())!

        let episode2 = SicknessEpisode(
            startDate: episode2Start,
            endDate: episode2End,
            type: .fever
        )

        let overlaps = viewModel.checkOverlap(for: episode2)
        XCTAssertEqual(overlaps.count, 1, "Should detect partial overlap")
    }

    func testNoOverlapDetected() throws {
        let viewModel = EpisodesViewModel()
        viewModel.modelContext = modelContext

        let calendar = Calendar.current
        let episode1Start = calendar.date(byAdding: .day, value: -20, to: Date())!
        let episode1End = calendar.date(byAdding: .day, value: -15, to: Date())!

        let episode1 = SicknessEpisode(
            startDate: episode1Start,
            endDate: episode1End,
            type: .cold
        )
        modelContext.insert(episode1)
        try modelContext.save()

        let episode2Start = calendar.date(byAdding: .day, value: -10, to: Date())!
        let episode2End = calendar.date(byAdding: .day, value: -5, to: Date())!

        let episode2 = SicknessEpisode(
            startDate: episode2Start,
            endDate: episode2End,
            type: .cough
        )

        let overlaps = viewModel.checkOverlap(for: episode2)
        XCTAssertEqual(overlaps.count, 0, "Should not detect overlap for non-overlapping episodes")
    }

    func testOverlapWithActiveEpisode() throws {
        let viewModel = EpisodesViewModel()
        viewModel.modelContext = modelContext

        let calendar = Calendar.current
        let activeStart = calendar.date(byAdding: .day, value: -5, to: Date())!

        let activeEpisode = SicknessEpisode(
            startDate: activeStart,
            endDate: nil,
            type: .cold
        )
        modelContext.insert(activeEpisode)
        try modelContext.save()

        let newEpisodeStart = calendar.date(byAdding: .day, value: -3, to: Date())!
        let newEpisode = SicknessEpisode(
            startDate: newEpisodeStart,
            endDate: nil,
            type: .cough
        )

        let overlaps = viewModel.checkOverlap(for: newEpisode)
        XCTAssertEqual(overlaps.count, 1, "Should detect overlap with active episode")
    }
}
