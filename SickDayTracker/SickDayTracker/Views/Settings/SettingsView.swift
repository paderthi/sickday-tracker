import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date, order: .reverse) private var dailyLogs: [DailyLog]
    @Query(sort: \SicknessEpisode.startDate, order: .reverse) private var episodes: [SicknessEpisode]

    @State private var showingResetConfirmation = false
    @State private var shareItem: ShareItem?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Privacy")
                                .font(.headline)
                            Text("All data stays on your device")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Disclaimer")
                                .font(.headline)
                            Text("This app is not medical advice")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("App Info")
                }

                Section {
                    Button(action: exportPDF) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.red)
                            Text("Export PDF Summary")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: exportDailyLogsCSV) {
                        HStack {
                            Image(systemName: "tablecells.fill")
                                .foregroundColor(.green)
                            Text("Export Daily Logs CSV")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: exportEpisodesCSV) {
                        HStack {
                            Image(systemName: "tablecells.fill")
                                .foregroundColor(.blue)
                            Text("Export Episodes CSV")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Export")
                } footer: {
                    Text("Export your data for medical consultations or personal records")
                }

                #if DEBUG
                Section {
                    Button(action: {
                        SampleDataService.loadSampleData(into: modelContext)
                    }) {
                        HStack {
                            Image(systemName: "tray.and.arrow.down.fill")
                                .foregroundColor(.blue)
                            Text("Load Sample Data")
                        }
                    }
                } header: {
                    Text("Development")
                } footer: {
                    Text("DEBUG ONLY: Loads sample daily logs and episodes for testing")
                }
                #endif

                Section {
                    Button(role: .destructive, action: {
                        showingResetConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Reset All Data")
                        }
                    }
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("This will permanently delete all your logs and episodes")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All Data", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All", role: .destructive) {
                    SampleDataService.deleteAllData(from: modelContext)
                }
            } message: {
                Text("This will permanently delete all your daily logs and episodes. This action cannot be undone.")
            }
            .sheet(item: $shareItem) { item in
                ShareSheet(activityItems: [item.url])
            }
        }
    }

    private func exportPDF() {
        guard let url = ExportService.generatePDFSummary(episodes: Array(episodes), dailyLogs: Array(dailyLogs)) else {
            print("Failed to generate PDF")
            return
        }
        shareItem = ShareItem(url: url, type: .pdf)
    }

    private func exportDailyLogsCSV() {
        guard let url = ExportService.generateDailyLogsCSV(logs: Array(dailyLogs)) else {
            print("Failed to generate daily logs CSV")
            return
        }
        shareItem = ShareItem(url: url, type: .csv)
    }

    private func exportEpisodesCSV() {
        guard let url = ExportService.generateEpisodesCSV(episodes: Array(episodes)) else {
            print("Failed to generate episodes CSV")
            return
        }
        shareItem = ShareItem(url: url, type: .csv)
    }
}

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
    let type: FileType

    enum FileType {
        case pdf, csv
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .modelContainer(for: [DailyLog.self, SicknessEpisode.self])
}
