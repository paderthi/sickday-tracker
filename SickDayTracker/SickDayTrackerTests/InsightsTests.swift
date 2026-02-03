import XCTest
import SwiftData
@testable import SickDayTracker

final class InsightsTests: XCTestCase {
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

    // MARK: - 7-Day Trigger Window Tests

    func testSevenDayTriggerWindowAggregation() throws {
        let viewModel = InsightsViewModel()
        viewModel.modelContext = modelContext

        let calendar = Calendar.current
        let episodeStart = calendar.date(byAdding: .day, value: -10, to: Date())!

        for daysAgo in 11...17 {
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let log = DailyLog(
                date: date,
                sleepHours: 6.0,
                sleepQuality: 3,
                stress: 4,
                officeDay: true,
                sickContactExposure: true,
                humidifierUsed: false
            )
            modelContext.insert(log)
        }

        let episode = SicknessEpisode(
            startDate: episodeStart,
            endDate: calendar.date(byAdding: .day, value: -5, to: Date())!,
            type: .cold
        )
        modelContext.insert(episode)
        try modelContext.save()

        let analysis = viewModel.getTriggerAnalysis(for: episode)

        XCTAssertNotNil(analysis, "Trigger analysis should be available")
        XCTAssertEqual(analysis?.preEpisode.avgSleepHours, 6.0, accuracy: 0.1, "Average sleep should be 6.0")
        XCTAssertEqual(analysis?.preEpisode.avgStress, 4.0, accuracy: 0.1, "Average stress should be 4.0")
        XCTAssertEqual(analysis?.preEpisode.officeDays, 7, "Should count all 7 office days")
        XCTAssertEqual(analysis?.preEpisode.sickContactDays, 7, "Should count all 7 sick contact days")
    }

    func testTriggerWindowWithPartialData() throws {
        let viewModel = InsightsViewModel()
        viewModel.modelContext = modelContext

        let calendar = Calendar.current
        let episodeStart = calendar.date(byAdding: .day, value: -10, to: Date())!

        for daysAgo in 14...17 {
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let log = DailyLog(
                date: date,
                sleepHours: 7.0,
                sleepQuality: 4,
                stress: 2
            )
            modelContext.insert(log)
        }

        let episode = SicknessEpisode(
            startDate: episodeStart,
            endDate: calendar.date(byAdding: .day, value: -5, to: Date())!,
            type: .cold
        )
        modelContext.insert(episode)
        try modelContext.save()

        let analysis = viewModel.getTriggerAnalysis(for: episode)

        XCTAssertNotNil(analysis, "Should handle partial data gracefully")
        XCTAssertGreaterThan(analysis?.preEpisode.avgSleepHours ?? 0, 0, "Should calculate from available data")
    }

    // MARK: - Baseline Computation Tests

    func testBaselineExcludesEpisodeWindows() throws {
        let viewModel = InsightsViewModel()
        viewModel.modelContext = modelContext

        let calendar = Calendar.current

        for daysAgo in 1...60 {
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let log = DailyLog(
                date: date,
                sleepHours: 7.0,
                sleepQuality: 4,
                stress: 2
            )
            modelContext.insert(log)
        }

        let episodeStart = calendar.date(byAdding: .day, value: -20, to: Date())!
        let episodeEnd = calendar.date(byAdding: .day, value: -15, to: Date())!
        let episode = SicknessEpisode(
            startDate: episodeStart,
            endDate: episodeEnd,
            type: .cold
        )
        modelContext.insert(episode)
        try modelContext.save()

        let testEpisode = SicknessEpisode(
            startDate: calendar.date(byAdding: .day, value: -5, to: Date())!,
            endDate: Date(),
            type: .cough
        )
        modelContext.insert(testEpisode)
        try modelContext.save()

        let analysis = viewModel.getTriggerAnalysis(for: testEpisode)

        XCTAssertNotNil(analysis, "Baseline should be computed")
    }

    func testBaselineWithMultipleEpisodes() throws {
        let viewModel = InsightsViewModel()
        viewModel.modelContext = modelContext

        let calendar = Calendar.current

        for daysAgo in 1...60 {
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let log = DailyLog(
                date: date,
                sleepHours: 8.0,
                sleepQuality: 5,
                stress: 1,
                officeDay: false,
                sickContactExposure: false,
                humidifierUsed: true
            )
            modelContext.insert(log)
        }

        let episode1 = SicknessEpisode(
            startDate: calendar.date(byAdding: .day, value: -50, to: Date())!,
            endDate: calendar.date(byAdding: .day, value: -45, to: Date())!,
            type: .cold
        )
        modelContext.insert(episode1)

        let episode2 = SicknessEpisode(
            startDate: calendar.date(byAdding: .day, value: -30, to: Date())!,
            endDate: calendar.date(byAdding: .day, value: -25, to: Date())!,
            type: .sinus
        )
        modelContext.insert(episode2)

        try modelContext.save()

        let testEpisode = SicknessEpisode(
            startDate: calendar.date(byAdding: .day, value: -10, to: Date())!,
            endDate: calendar.date(byAdding: .day, value: -5, to: Date())!,
            type: .fever
        )

        let analysis = viewModel.getTriggerAnalysis(for: testEpisode)

        XCTAssertNotNil(analysis, "Should compute baseline excluding multiple episodes")
        XCTAssertGreaterThan(analysis?.baseline.avgSleepHours ?? 0, 0, "Baseline should have valid sleep data")
    }

    // MARK: - Average Duration Tests

    func testAverageDurationExcludesActiveEpisodes() throws {
        let viewModel = InsightsViewModel()
        viewModel.modelContext = modelContext

        let calendar = Calendar.current

        let episode1 = SicknessEpisode(
            startDate: calendar.date(byAdding: .day, value: -20, to: Date())!,
            endDate: calendar.date(byAdding: .day, value: -15, to: Date())!,
            type: .cold
        )
        modelContext.insert(episode1)

        let episode2 = SicknessEpisode(
            startDate: calendar.date(byAdding: .day, value: -30, to: Date())!,
            endDate: calendar.date(byAdding: .day, value: -23, to: Date())!,
            type: .sinus
        )
        modelContext.insert(episode2)

        let activeEpisode = SicknessEpisode(
            startDate: calendar.date(byAdding: .day, value: -5, to: Date())!,
            endDate: nil,
            type: .cough
        )
        modelContext.insert(activeEpisode)

        try modelContext.save()

        let avgDuration = viewModel.getAverageDuration()

        XCTAssertNotNil(avgDuration, "Average duration should be calculated")
        XCTAssertEqual(avgDuration, 6.0, accuracy: 0.1, "Average should be (5 + 7) / 2 = 6.0")
    }

    func testAverageDurationWithNoCompletedEpisodes() throws {
        let viewModel = InsightsViewModel()
        viewModel.modelContext = modelContext

        let activeEpisode = SicknessEpisode(
            startDate: Date(),
            endDate: nil,
            type: .cold
        )
        modelContext.insert(activeEpisode)
        try modelContext.save()

        let avgDuration = viewModel.getAverageDuration()

        XCTAssertNil(avgDuration, "Should return nil when no completed episodes exist")
    }
}
