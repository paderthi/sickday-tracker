import Foundation
import SwiftData

@Model
final class DailyLog {
    @Attribute(.unique) var date: Date
    var sleepHours: Double
    var sleepQuality: Int // 1-5
    var stress: Int // 1-5
    var exerciseMinutes: Int // 0-300
    var exerciseType: ExerciseType
    var sugarIntake: SugarLevel
    var alcohol: AlcoholConsumption
    var officeDay: Bool
    var sickContactExposure: Bool
    var humidifierUsed: Bool
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    init(
        date: Date = Date(),
        sleepHours: Double = 7.0,
        sleepQuality: Int = 3,
        stress: Int = 3,
        exerciseMinutes: Int = 0,
        exerciseType: ExerciseType = .none,
        sugarIntake: SugarLevel = .low,
        alcohol: AlcoholConsumption = .none,
        officeDay: Bool = false,
        sickContactExposure: Bool = false,
        humidifierUsed: Bool = false,
        notes: String = ""
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.sleepHours = sleepHours
        self.sleepQuality = sleepQuality
        self.stress = stress
        self.exerciseMinutes = exerciseMinutes
        self.exerciseType = exerciseType
        self.sugarIntake = sugarIntake
        self.alcohol = alcohol
        self.officeDay = officeDay
        self.sickContactExposure = sickContactExposure
        self.humidifierUsed = humidifierUsed
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Supporting Enums

enum ExerciseType: String, Codable, CaseIterable {
    case none = "None"
    case walk = "Walk"
    case gym = "Gym"
    case yoga = "Yoga"
    case other = "Other"
}

enum SugarLevel: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum AlcoholConsumption: String, Codable, CaseIterable {
    case none = "None"
    case some = "Some"
}
