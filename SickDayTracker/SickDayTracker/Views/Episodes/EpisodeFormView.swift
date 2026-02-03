import SwiftUI

struct EpisodeFormView: View {
    @Bindable var episode: SicknessEpisode
    @Environment(\.dismiss) private var dismiss
    let viewModel: EpisodesViewModel
    let onSave: () -> Void

    @State private var showingEndDatePicker = false
    @State private var showingOverlapWarning = false
    @State private var overlappingEpisodes: [SicknessEpisode] = []
    @State private var medicationInput = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Dates") {
                    DatePicker("Start Date", selection: $episode.startDate, displayedComponents: .date)

                    Toggle("Episode Ended", isOn: $showingEndDatePicker)

                    if showingEndDatePicker {
                        DatePicker("End Date", selection: Binding(
                            get: { episode.endDate ?? Date() },
                            set: { episode.endDate = $0 }
                        ), displayedComponents: .date)
                    } else {
                        Text("Active episode")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .onChange(of: showingEndDatePicker) { _, newValue in
                    if !newValue {
                        episode.endDate = nil
                    } else if episode.endDate == nil {
                        episode.endDate = Date()
                    }
                }

                Section("Type & Severity") {
                    Picker("Type", selection: $episode.type) {
                        ForEach(EpisodeType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    Picker("Severity", selection: $episode.severity) {
                        ForEach(1...5, id: \.self) { level in
                            Text("\(level)").tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Symptoms") {
                    ForEach(Symptom.allCases, id: \.self) { symptom in
                        Toggle(symptom.rawValue, isOn: Binding(
                            get: { episode.symptoms.contains(symptom) },
                            set: { isOn in
                                if isOn {
                                    episode.symptoms.append(symptom)
                                } else {
                                    episode.symptoms.removeAll { $0 == symptom }
                                }
                            }
                        ))
                    }
                }

                Section {
                    Picker("Mucus Color", selection: $episode.mucusColor) {
                        ForEach(MucusColor.allCases, id: \.self) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }

                    Text("Note: Mucus color is not diagnostic and should be discussed with a healthcare provider")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Mucus")
                }

                Section("Worst Time") {
                    Picker("When", selection: $episode.worstTime) {
                        ForEach(WorstTime.allCases, id: \.self) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Medications") {
                    ForEach(episode.medications, id: \.self) { medication in
                        Text(medication)
                    }
                    .onDelete { indexSet in
                        episode.medications.remove(atOffsets: indexSet)
                    }

                    HStack {
                        TextField("Add medication", text: $medicationInput)
                        Button("Add") {
                            if !medicationInput.isEmpty {
                                episode.medications.append(medicationInput)
                                medicationInput = ""
                            }
                        }
                        .disabled(medicationInput.isEmpty)
                    }
                }

                Section("Medical Care") {
                    Toggle("Doctor Visit", isOn: $episode.doctorVisit)

                    if episode.doctorVisit {
                        TextEditor(text: $episode.testResults)
                            .frame(minHeight: 60)
                            .overlay(
                                Group {
                                    if episode.testResults.isEmpty {
                                        Text("Test results or diagnosis")
                                            .foregroundColor(.secondary)
                                            .padding(.top, 8)
                                            .padding(.leading, 4)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                }

                Section("Notes") {
                    TextEditor(text: $episode.notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(episode.isActive ? "Active Episode" : "Episode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        checkOverlapAndSave()
                    }
                }
            }
            .alert("Overlapping Episodes", isPresented: $showingOverlapWarning) {
                Button("Cancel", role: .cancel) { }
                Button("Save Anyway") {
                    onSave()
                    dismiss()
                }
            } message: {
                Text("This episode overlaps with \(overlappingEpisodes.count) other episode(s). Do you want to save anyway?")
            }
            .onAppear {
                showingEndDatePicker = episode.endDate != nil
            }
        }
    }

    private func checkOverlapAndSave() {
        let overlaps = viewModel.checkOverlap(for: episode)
        if !overlaps.isEmpty {
            overlappingEpisodes = overlaps
            showingOverlapWarning = true
        } else {
            onSave()
            dismiss()
        }
    }
}

#Preview {
    EpisodeFormView(episode: SicknessEpisode(startDate: Date()), viewModel: EpisodesViewModel()) {
        print("Saved")
    }
}
