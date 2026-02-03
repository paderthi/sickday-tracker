import SwiftUI
import SwiftData

struct EpisodesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SicknessEpisode.startDate, order: .reverse) private var episodes: [SicknessEpisode]

    @State private var viewModel = EpisodesViewModel()
    @State private var showingEpisodeForm = false
    @State private var editingEpisode: SicknessEpisode?

    var body: some View {
        NavigationStack {
            List {
                if episodes.isEmpty {
                    ContentUnavailableView(
                        "No Episodes",
                        systemImage: "heart.text.square",
                        description: Text("Track your sickness episodes to identify patterns")
                    )
                } else {
                    ForEach(episodes) { episode in
                        episodeRow(episode)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingEpisode = episode
                                showingEpisodeForm = true
                            }
                    }
                    .onDelete(perform: deleteEpisodes)
                }
            }
            .navigationTitle("Episodes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        let newEpisode = viewModel.createEpisode()
                        editingEpisode = newEpisode
                        showingEpisodeForm = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Episode")
                    .accessibilityHint("Create a new sickness episode")
                    .accessibilityIdentifier(AccessibilityIdentifiers.addEpisodeButton)
                }
            }
            .onAppear {
                viewModel.modelContext = modelContext
            }
            .sheet(isPresented: $showingEpisodeForm) {
                if let episode = editingEpisode {
                    EpisodeFormView(episode: episode, viewModel: viewModel) {
                        viewModel.saveOrUpdateEpisode(episode)
                    }
                }
            }
        }
    }

    private func episodeRow(_ episode: SicknessEpisode) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(episode.type.rawValue)
                    .font(.headline)
                Spacer()
                if episode.isActive {
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                        .accessibilityLabel("Active episode")
                }
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(formatDateRange(episode))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text(viewModel.getEpisodeDuration(episode))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if !episode.symptoms.isEmpty {
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.secondary)
                    Text(episode.symptoms.map { $0.rawValue }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { level in
                    Image(systemName: level <= episode.severity ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundColor(level <= episode.severity ? .orange : .gray)
                }
                Text("Severity")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(episode.type.rawValue) episode, \(formatDateRange(episode)), \(viewModel.getEpisodeDuration(episode))")
        .accessibilityHint("Double tap to view episode details")
        .accessibilityIdentifier(AccessibilityIdentifiers.episodeRow)
    }

    private func formatDateRange(_ episode: SicknessEpisode) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let startStr = formatter.string(from: episode.startDate)

        if let endDate = episode.endDate {
            let endStr = formatter.string(from: endDate)
            return "\(startStr) - \(endStr)"
        } else {
            return "\(startStr) - Present"
        }
    }

    private func deleteEpisodes(at offsets: IndexSet) {
        for index in offsets {
            let episode = episodes[index]
            viewModel.deleteEpisode(episode)
        }
    }
}

#Preview {
    EpisodesView()
        .modelContainer(for: SicknessEpisode.self)
}
