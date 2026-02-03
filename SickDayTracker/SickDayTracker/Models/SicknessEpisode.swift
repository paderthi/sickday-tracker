import Foundation
import SwiftData

@Model
final class SicknessEpisode {
    var startDate: Date
    var endDate: Date?
    var type: EpisodeType
    var symptoms: [Symptom]
    var mucusColor: MucusColor
    var severity: Int // 1-5
    var worstTime: WorstTime
    var medications: [String]
    var doctorVisit: Bool
    var testResults: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    init(
        startDate: Date,
        endDate: Date? = nil,
        type: EpisodeType = .cold,
        symptoms: [Symptom] = [],
        mucusColor: MucusColor = .none,
        severity: Int = 3,
        worstTime: WorstTime = .allDay,
        medications: [String] = [],
        doctorVisit: Bool = false,
        testResults: String = "",
        notes: String = ""
    ) {
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.endDate = endDate.map { Calendar.current.startOfDay(for: $0) }
        self.type = type
        self.symptoms = symptoms
        self.mucusColor = mucusColor
        self.severity = severity
        self.worstTime = worstTime
        self.medications = medications
        self.doctorVisit = doctorVisit
        self.testResults = testResults
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var isActive: Bool {
        endDate == nil
    }

    var duration: Int? {
        guard let endDate = endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day
    }
}

// MARK: - Supporting Enums

enum EpisodeType: String, Codable, CaseIterable {
    case cold = "Cold"
    case cough = "Cough"
    case fever = "Fever"
    case sinus = "Sinus"
    case allergy = "Allergy"
    case other = "Other"
}

enum Symptom: String, Codable, CaseIterable {
    case cough = "Cough"
    case soreThroat = "Sore Throat"
    case runnyNose = "Runny Nose"
    case sneezing = "Sneezing"
    case fever = "Fever"
    case fatigue = "Fatigue"
    case bodyAches = "Body Aches"
    case headache = "Headache"
}

enum MucusColor: String, Codable, CaseIterable {
    case none = "None"
    case clear = "Clear"
    case yellow = "Yellow"
    case green = "Green"
}

enum WorstTime: String, Codable, CaseIterable {
    case morning = "Morning"
    case night = "Night"
    case allDay = "All Day"
}
