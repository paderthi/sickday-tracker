# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SickDay Tracker is an iOS app (iOS 17+) built with Swift and SwiftUI that helps users log daily health factors, track sickness episodes, view insights, and export data for medical consultations. The app is privacy-focused with local-only data storage using SwiftData.

## Architecture

- **Pattern**: MVVM (Model-View-ViewModel)
- **UI Framework**: SwiftUI with TabView (4 tabs: Today, Episodes, Insights, Settings)
- **Persistence**: SwiftData (local only, no cloud sync)
- **Charts**: Swift Charts for visualizations
- **Export**: Native iOS PDF rendering (UIGraphicsPDFRenderer) and CSV

## Core Data Models

- **DailyLog**: One entry per date with health factors (sleep, stress, exercise, sugar, etc.)
- **SicknessEpisode**: Tracks illness periods with start/end dates, type, symptoms, severity
- Enforce unique date constraint for DailyLog entries
- Support active episodes (no end date)
- Prevent overlapping episodes with warnings

## Key Business Logic

### Trigger Analysis
For each episode, analyze 7 days before start date:
- Calculate averages: sleep hours, stress levels
- Count: office days, sick-contact exposure, humidifier usage
- Compare to baseline: last 60 days excluding all episode windows
- Display comparisons without causal claims

### Episode Duration
- Exclude active episodes from average calculations
- Handle ongoing episodes gracefully in insights

### Export Formats
- **PDF**: Last 90 days summary with episodes, symptoms, key averages
- **CSV**: Separate exports for daily logs and episodes

## Commands

### Build and Run
```bash
xcodebuild -scheme SickDayTracker -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Run Tests
```bash
# All tests
xcodebuild test -scheme SickDayTracker -destination 'platform=iOS Simulator,name=iPhone 15'

# Unit tests only
xcodebuild test -scheme SickDayTracker -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SickDayTrackerTests

# Specific test
xcodebuild test -scheme SickDayTracker -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SickDayTrackerTests/EpisodeTests/testDurationCalculation
```

## Critical Requirements

- **Medical Disclaimer**: Include onboarding disclaimer that this is not medical advice
- **Privacy**: All data stays on device, no network calls, no analytics
- **Accessibility**: Support Dynamic Type and VoiceOver
- **Data Constraints**:
  - One DailyLog per date
  - No overlapping episodes (warn with override option)
- **No Medical Advice**: UI text must not suggest diagnosis or treatment

## Testing Requirements

- Unit tests: episode duration, overlap detection, 7-day trigger windows, baseline computation
- UI tests: daily log creation, episode creation, PDF export action
- CI via GitHub Actions on iOS 17+ simulator
