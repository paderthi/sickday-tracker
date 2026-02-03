# SickDay Tracker

A privacy-focused iOS app for tracking daily health factors and sickness episodes to help identify patterns and triggers.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Overview

SickDay Tracker helps you log daily health metrics, track illness episodes, and gain insights into patterns that may affect your health. All data stays private on your device with no cloud sync or data collection.

**Important:** This app is for personal health tracking only and does not provide medical advice. Always consult with a healthcare provider for medical concerns.

## Features

### Daily Health Logging
- Track sleep hours and quality
- Monitor stress levels (1-5 scale)
- Log exercise minutes and type
- Record sugar intake and alcohol consumption
- Note environmental factors (office days, sick contacts, humidifier use)
- Add custom notes

### Episode Tracking
- Log sickness episodes with start/end dates
- Record episode type (cold, cough, fever, sinus, allergy, other)
- Track symptoms (cough, sore throat, runny nose, sneezing, fever, fatigue, body aches, headache)
- Note severity, worst time of day, medications used
- Support for active (ongoing) episodes
- Overlap detection to prevent conflicting episodes

### Insights & Analytics
- Episode counts for 30/90/365 day periods
- Average episode duration
- Symptom frequency analysis with charts
- Episodes timeline visualization
- **Trigger Analysis**: Compare 7 days before each episode to your 60-day baseline
  - Average sleep patterns
  - Stress levels
  - Office days and sick contact exposure
  - Humidifier usage
- All insights include clear disclaimers about non-medical nature

### Data Export
- **PDF Summary**: Generate a doctor-friendly report for the last 90 days
  - Episode list with dates and durations
  - Symptom summary
  - Health averages
- **CSV Export**: Export daily logs and episodes for your own analysis

### Privacy First
- All data stored locally using SwiftData
- No cloud sync, no servers, no analytics
- No network calls whatsoever
- Complete data ownership
- Option to reset all data at any time

## Technical Stack

- **Platform**: iOS 17.0+
- **Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Persistence**: SwiftData (local only)
- **Charts**: Swift Charts
- **PDF Export**: UIGraphicsPDFRenderer
- **Testing**: XCTest (unit & UI tests)
- **CI/CD**: GitHub Actions

## Setup & Build

### Requirements
- Xcode 15.0 or later
- iOS 17.0+ target device or simulator
- macOS for development

### Build Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/sickday-tracker.git
   cd sickday-tracker
   ```

2. **Open the project**
   ```bash
   open SickDayTracker/SickDayTracker.xcodeproj
   ```

3. **Accept Xcode license** (if needed)
   ```bash
   sudo xcodebuild -license
   ```

4. **Build and run**
   - Select a simulator or device target (iOS 17+)
   - Press Cmd+R to build and run

### Running Tests

```bash
# All tests
xcodebuild test -scheme SickDayTracker -destination 'platform=iOS Simulator,name=iPhone 15'

# Unit tests only
xcodebuild test -scheme SickDayTracker -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SickDayTrackerTests

# UI tests only
xcodebuild test -scheme SickDayTracker -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SickDayTrackerUITests

# Specific test
xcodebuild test -scheme SickDayTracker -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SickDayTrackerTests/EpisodeTests/testEpisodeDurationCalculation
```

### Development Features

In DEBUG builds, the Settings tab includes a "Load Sample Data" button that generates:
- 30 days of sample daily logs
- 3 sample episodes (2 completed, 1 active)

This helps with UI development and testing without manual data entry.

## Project Structure

```
SickDayTracker/
├── Models/
│   ├── DailyLog.swift          # SwiftData model for daily health logs
│   └── SicknessEpisode.swift   # SwiftData model for illness episodes
├── Views/
│   ├── Today/                  # Today tab views
│   ├── Episodes/               # Episodes tab views
│   ├── Insights/               # Insights tab views
│   ├── Settings/               # Settings tab views
│   └── OnboardingView.swift    # First-launch onboarding
├── ViewModels/                 # MVVM view models
├── Services/
│   ├── ExportService.swift     # PDF & CSV export logic
│   └── SampleDataService.swift # DEBUG sample data generation
├── Utilities/
│   └── AccessibilityIdentifiers.swift
└── Assets.xcassets/            # App icons and colors
```

## Privacy & Disclaimer

### Privacy
All health data is stored locally on your device using SwiftData. The app:
- Does not connect to any servers
- Does not collect or transmit any data
- Does not include analytics or tracking
- Does not sync to iCloud or any cloud service

You have complete control over your data and can delete it at any time from the Settings tab.

### Medical Disclaimer
This app is designed for personal health tracking purposes only and does not provide medical advice, diagnosis, or treatment. The insights and patterns identified are for informational purposes only.

Always consult with a qualified healthcare provider for medical concerns. If you experience severe symptoms or a medical emergency, seek immediate medical attention.

Mucus color observations are noted but are not diagnostic. Discuss any concerns with your healthcare provider.

## Accessibility

SickDay Tracker is built with accessibility in mind:
- VoiceOver labels for all interactive elements
- Dynamic Type support throughout the app
- High contrast UI elements
- Semantic accessibility hints

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Development Guidelines
- Follow Swift API Design Guidelines
- Maintain MVVM architecture
- Add unit tests for business logic
- Add UI tests for critical user flows
- Ensure accessibility labels are descriptive

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Swift and SwiftUI
- Charts powered by Swift Charts
- Icons from SF Symbols

## Screenshots

_Screenshots will be added here_

---

**Remember:** This app is not a substitute for professional medical advice. Always consult with healthcare providers for medical concerns.
