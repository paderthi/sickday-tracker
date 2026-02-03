import Foundation
import SwiftData

struct SampleDataService {
    static func loadSampleData(into modelContext: ModelContext) {
        // Create sample daily logs for the past 30 days
        for daysAgo in 0..<30 {
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
            let log = DailyLog(
                date: date,
                sleepHours: Double.random(in: 5.5...8.5),
                sleepQuality: Int.random(in: 2...5),
                stress: Int.random(in: 1...4),
                exerciseMinutes: Int.random(in: 0...60),
                exerciseType: ExerciseType.allCases.randomElement()!,
                sugarIntake: SugarLevel.allCases.randomElement()!,
                alcohol: AlcoholConsumption.allCases.randomElement()!,
                fruitsServings: Int.random(in: 0...5),
                proteinGrams: Int.random(in: 40...120),
                supplements: Bool.random() ? ["Vitamin D3", "Multivitamin"] : ["Vitamin B12"],
                officeDay: Bool.random(),
                sickContactExposure: daysAgo < 5 ? Bool.random() : false,
                humidifierUsed: Bool.random(),
                notes: ""
            )
            modelContext.insert(log)
        }

        // Create sample episodes
        let episode1 = SicknessEpisode(
            startDate: Calendar.current.date(byAdding: .day, value: -20, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -15, to: Date())!,
            type: .cold,
            symptoms: [.cough, .runnyNose, .sneezing, .fatigue],
            mucusColor: .clear,
            severity: 3,
            worstTime: .morning,
            medications: ["Ibuprofen", "Cough syrup"],
            doctorVisit: false,
            testResults: "",
            notes: "Mild cold, recovered quickly"
        )
        modelContext.insert(episode1)

        let episode2 = SicknessEpisode(
            startDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -38, to: Date())!,
            type: .sinus,
            symptoms: [.headache, .fatigue, .runnyNose],
            mucusColor: .yellow,
            severity: 4,
            worstTime: .night,
            medications: ["Decongestant", "Pain reliever"],
            doctorVisit: true,
            testResults: "Acute sinusitis, antibiotics prescribed",
            notes: "Took antibiotics for 7 days"
        )
        modelContext.insert(episode2)

        let episode3 = SicknessEpisode(
            startDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            endDate: nil,
            type: .cough,
            symptoms: [.cough, .soreThroat],
            mucusColor: .none,
            severity: 2,
            worstTime: .night,
            medications: ["Cough drops"],
            doctorVisit: false,
            testResults: "",
            notes: "Dry cough, still recovering"
        )
        modelContext.insert(episode3)

        do {
            try modelContext.save()
        } catch {
            print("Error loading sample data: \(error)")
        }
    }

    static func deleteAllData(from modelContext: ModelContext) {
        do {
            try modelContext.delete(model: DailyLog.self)
            try modelContext.delete(model: SicknessEpisode.self)
            try modelContext.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
}
