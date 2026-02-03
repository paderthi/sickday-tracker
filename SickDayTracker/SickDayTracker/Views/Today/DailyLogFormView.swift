import SwiftUI

struct DailyLogFormView: View {
    @Bindable var log: DailyLog
    @Environment(\.dismiss) private var dismiss
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Sleep") {
                    HStack {
                        Text("Hours")
                        Spacer()
                        Stepper(String(format: "%.2f", log.sleepHours), value: $log.sleepHours, in: 0...12, step: 0.25)
                    }

                    Picker("Quality", selection: $log.sleepQuality) {
                        ForEach(1...5, id: \.self) { rating in
                            Text(String(repeating: "⭐️", count: rating)).tag(rating)
                        }
                    }
                }

                Section("Stress") {
                    Picker("Level", selection: $log.stress) {
                        ForEach(1...5, id: \.self) { level in
                            Text("\(level)").tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Exercise") {
                    HStack {
                        Text("Minutes")
                        Spacer()
                        Stepper("\(log.exerciseMinutes)", value: $log.exerciseMinutes, in: 0...300, step: 5)
                    }

                    Picker("Type", selection: $log.exerciseType) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }

                Section("Diet") {
                    Picker("Sugar Intake", selection: $log.sugarIntake) {
                        ForEach(SugarLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }

                    Picker("Alcohol", selection: $log.alcohol) {
                        ForEach(AlcoholConsumption.allCases, id: \.self) { consumption in
                            Text(consumption.rawValue).tag(consumption)
                        }
                    }
                }

                Section("Environment") {
                    Toggle("Office Day", isOn: $log.officeDay)
                    Toggle("Sick Contact Exposure", isOn: $log.sickContactExposure)
                    Toggle("Humidifier Used", isOn: $log.humidifierUsed)
                }

                Section("Notes") {
                    TextEditor(text: $log.notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Daily Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DailyLogFormView(log: DailyLog()) {
        print("Saved")
    }
}
