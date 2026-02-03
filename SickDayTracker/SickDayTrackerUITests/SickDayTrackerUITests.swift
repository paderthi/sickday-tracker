import XCTest

final class SickDayTrackerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()

        dismissOnboardingIfPresent()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func dismissOnboardingIfPresent() {
        let getStartedButton = app.buttons["Get Started"]
        if getStartedButton.waitForExistence(timeout: 2) {
            getStartedButton.tap()
        }
    }

    // MARK: - Daily Log Tests

    func testCreateDailyLog() throws {
        let todayTab = app.tabBars.buttons["Today"]
        todayTab.tap()

        let logTodayButton = app.buttons["Log Today"]
        XCTAssertTrue(logTodayButton.waitForExistence(timeout: 5), "Log Today button should exist")

        logTodayButton.tap()

        XCTAssertTrue(app.navigationBars["Daily Log"].waitForExistence(timeout: 2), "Daily Log form should appear")

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")

        saveButton.tap()

        XCTAssertTrue(app.staticTexts["Today's Log"].waitForExistence(timeout: 2), "Today's log summary should appear after saving")
    }

    func testEditDailyLog() throws {
        testCreateDailyLog()

        let editButton = app.buttons["Edit"]
        XCTAssertTrue(editButton.exists, "Edit button should exist on daily log summary")

        editButton.tap()

        XCTAssertTrue(app.navigationBars["Daily Log"].waitForExistence(timeout: 2), "Daily Log form should appear for editing")

        let cancelButton = app.navigationBars.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists, "Cancel button should exist")

        cancelButton.tap()
    }

    // MARK: - Episode Tests

    func testCreateEpisode() throws {
        let episodesTab = app.tabBars.buttons["Episodes"]
        episodesTab.tap()

        let addButton = app.navigationBars.buttons.matching(identifier: "plus").firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add button should exist")

        addButton.tap()

        XCTAssertTrue(app.navigationBars["Active Episode"].waitForExistence(timeout: 2) ||
                      app.navigationBars["Episode"].waitForExistence(timeout: 2),
                      "Episode form should appear")

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")

        saveButton.tap()

        sleep(1)
    }

    func testEpisodeListDisplay() throws {
        testCreateEpisode()

        let episodesList = app.tables.firstMatch
        XCTAssertTrue(episodesList.exists, "Episodes list should exist")

        let episodeCells = episodesList.cells
        XCTAssertGreaterThan(episodeCells.count, 0, "Should have at least one episode")
    }

    // MARK: - Export Tests

    func testPDFExportAction() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        let exportPDFButton = app.buttons["Export PDF Summary"]
        XCTAssertTrue(exportPDFButton.waitForExistence(timeout: 5), "Export PDF button should exist")

        exportPDFButton.tap()

        let activityView = app.otherElements["ActivityListView"]
        XCTAssertTrue(activityView.waitForExistence(timeout: 5), "Share sheet should appear")
    }

    func testCSVExportAction() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        let exportCSVButton = app.buttons["Export Daily Logs CSV"]
        XCTAssertTrue(exportCSVButton.waitForExistence(timeout: 5), "Export CSV button should exist")

        exportCSVButton.tap()

        let activityView = app.otherElements["ActivityListView"]
        XCTAssertTrue(activityView.waitForExistence(timeout: 5), "Share sheet should appear")
    }

    // MARK: - Navigation Tests

    func testTabNavigation() throws {
        let todayTab = app.tabBars.buttons["Today"]
        let episodesTab = app.tabBars.buttons["Episodes"]
        let insightsTab = app.tabBars.buttons["Insights"]
        let settingsTab = app.tabBars.buttons["Settings"]

        XCTAssertTrue(todayTab.exists, "Today tab should exist")
        XCTAssertTrue(episodesTab.exists, "Episodes tab should exist")
        XCTAssertTrue(insightsTab.exists, "Insights tab should exist")
        XCTAssertTrue(settingsTab.exists, "Settings tab should exist")

        episodesTab.tap()
        XCTAssertTrue(app.navigationBars["Episodes"].waitForExistence(timeout: 2))

        insightsTab.tap()
        XCTAssertTrue(app.navigationBars["Insights"].waitForExistence(timeout: 2))

        settingsTab.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2))

        todayTab.tap()
        XCTAssertTrue(app.navigationBars["Today"].waitForExistence(timeout: 2))
    }

    // MARK: - Settings Tests

    func testResetDataConfirmation() throws {
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        let resetButton = app.buttons["Reset All Data"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 5), "Reset button should exist")

        resetButton.tap()

        let alert = app.alerts["Reset All Data"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2), "Confirmation alert should appear")

        let cancelButton = alert.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists, "Cancel button should exist in alert")

        cancelButton.tap()
    }
}
