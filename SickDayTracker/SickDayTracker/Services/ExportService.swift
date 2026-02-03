import Foundation
import UIKit
import SwiftData

struct ExportService {
    // MARK: - PDF Export

    static func generatePDFSummary(episodes: [SicknessEpisode], dailyLogs: [DailyLog]) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "SickDay Tracker",
            kCGPDFContextAuthor: "SickDay Tracker App",
            kCGPDFContextTitle: "Health Summary Report"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 40

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()

            var yPosition: CGFloat = margin

            yPosition = drawTitle("SickDay Tracker - 90 Day Summary", at: yPosition, in: pageRect, margin: margin, context: context)
            yPosition += 20

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateString = "Generated: \(dateFormatter.string(from: Date()))"
            yPosition = drawText(dateString, at: yPosition, in: pageRect, margin: margin, fontSize: 12, bold: false)
            yPosition += 30

            yPosition = drawSectionHeader("Disclaimer", at: yPosition, in: pageRect, margin: margin)
            yPosition = drawText("This report is for informational purposes only and does not constitute medical advice. Please consult with a healthcare provider for medical concerns.", at: yPosition, in: pageRect, margin: margin, fontSize: 11, bold: false)
            yPosition += 30

            let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
            let recentEpisodes = episodes.filter { $0.startDate >= ninetyDaysAgo }

            yPosition = drawSectionHeader("Episodes (Last 90 Days)", at: yPosition, in: pageRect, margin: margin)
            yPosition += 10

            if recentEpisodes.isEmpty {
                yPosition = drawText("No episodes in the last 90 days", at: yPosition, in: pageRect, margin: margin, fontSize: 12, bold: false)
            } else {
                for episode in recentEpisodes.prefix(10) {
                    if yPosition > pageHeight - 100 {
                        context.beginPage()
                        yPosition = margin
                    }

                    let startStr = dateFormatter.string(from: episode.startDate)
                    let endStr = episode.endDate != nil ? dateFormatter.string(from: episode.endDate!) : "Present"
                    let duration = episode.endDate != nil ? "\(episode.duration ?? 0) days" : "Active"

                    yPosition = drawText("• \(episode.type.rawValue) - \(startStr) to \(endStr) (\(duration))", at: yPosition, in: pageRect, margin: margin, fontSize: 11, bold: true)

                    if !episode.symptoms.isEmpty {
                        let symptomsStr = "  Symptoms: \(episode.symptoms.map { $0.rawValue }.joined(separator: ", "))"
                        yPosition = drawText(symptomsStr, at: yPosition, in: pageRect, margin: margin, fontSize: 10, bold: false)
                    }

                    yPosition = drawText("  Severity: \(String(repeating: "★", count: episode.severity))", at: yPosition, in: pageRect, margin: margin, fontSize: 10, bold: false)
                    yPosition += 15
                }
            }

            if yPosition > pageHeight - 200 {
                context.beginPage()
                yPosition = margin
            }

            yPosition += 20
            yPosition = drawSectionHeader("Symptom Summary", at: yPosition, in: pageRect, margin: margin)
            yPosition += 10

            var symptomCounts: [Symptom: Int] = [:]
            for episode in recentEpisodes {
                for symptom in episode.symptoms {
                    symptomCounts[symptom, default: 0] += 1
                }
            }

            if symptomCounts.isEmpty {
                yPosition = drawText("No symptom data available", at: yPosition, in: pageRect, margin: margin, fontSize: 12, bold: false)
            } else {
                let sortedSymptoms = symptomCounts.sorted { $0.value > $1.value }
                for (symptom, count) in sortedSymptoms.prefix(8) {
                    yPosition = drawText("• \(symptom.rawValue): \(count) times", at: yPosition, in: pageRect, margin: margin, fontSize: 11, bold: false)
                }
            }

            if yPosition > pageHeight - 200 {
                context.beginPage()
                yPosition = margin
            }

            yPosition += 20
            yPosition = drawSectionHeader("Health Averages (Last 90 Days)", at: yPosition, in: pageRect, margin: margin)
            yPosition += 10

            let recentLogs = dailyLogs.filter { $0.date >= ninetyDaysAgo }

            if recentLogs.isEmpty {
                yPosition = drawText("No daily log data available", at: yPosition, in: pageRect, margin: margin, fontSize: 12, bold: false)
            } else {
                let avgSleep = recentLogs.reduce(0.0) { $0 + $1.sleepHours } / Double(recentLogs.count)
                let avgStress = Double(recentLogs.reduce(0) { $0 + $1.stress }) / Double(recentLogs.count)
                let avgExercise = Double(recentLogs.reduce(0) { $0 + $1.exerciseMinutes }) / Double(recentLogs.count)

                let sugarCounts = Dictionary(grouping: recentLogs, by: { $0.sugarIntake })
                let sugarDistribution = sugarCounts.mapValues { $0.count }

                yPosition = drawText("• Average Sleep: \(String(format: "%.1f", avgSleep)) hours", at: yPosition, in: pageRect, margin: margin, fontSize: 11, bold: false)
                yPosition = drawText("• Average Stress: \(String(format: "%.1f", avgStress))/5", at: yPosition, in: pageRect, margin: margin, fontSize: 11, bold: false)
                yPosition = drawText("• Average Exercise: \(String(format: "%.0f", avgExercise)) minutes", at: yPosition, in: pageRect, margin: margin, fontSize: 11, bold: false)
                yPosition += 10

                yPosition = drawText("Sugar Intake Distribution:", at: yPosition, in: pageRect, margin: margin, fontSize: 11, bold: true)
                for level in SugarLevel.allCases {
                    let count = sugarDistribution[level] ?? 0
                    yPosition = drawText("  \(level.rawValue): \(count) days", at: yPosition, in: pageRect, margin: margin, fontSize: 10, bold: false)
                }
            }
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SickDayTracker_Summary_\(Date().timeIntervalSince1970).pdf")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }

    private static func drawTitle(_ text: String, at yPosition: CGFloat, in pageRect: CGRect, margin: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textRect = CGRect(x: margin, y: yPosition, width: pageRect.width - 2 * margin, height: 30)
        attributedText.draw(in: textRect)
        return yPosition + 30
    }

    private static func drawSectionHeader(_ text: String, at yPosition: CGFloat, in pageRect: CGRect, margin: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14)
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textRect = CGRect(x: margin, y: yPosition, width: pageRect.width - 2 * margin, height: 20)
        attributedText.draw(in: textRect)
        return yPosition + 25
    }

    private static func drawText(_ text: String, at yPosition: CGFloat, in pageRect: CGRect, margin: CGFloat, fontSize: CGFloat, bold: Bool) -> CGFloat {
        let font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textRect = CGRect(x: margin, y: yPosition, width: pageRect.width - 2 * margin, height: 1000)
        let boundingRect = attributedText.boundingRect(with: textRect.size, options: [.usesLineFragmentOrigin], context: nil)

        attributedText.draw(in: CGRect(x: margin, y: yPosition, width: pageRect.width - 2 * margin, height: boundingRect.height))

        return yPosition + boundingRect.height + 5
    }

    // MARK: - CSV Export

    static func generateDailyLogsCSV(logs: [DailyLog]) -> URL? {
        var csvString = "Date,Sleep Hours,Sleep Quality,Stress,Exercise Minutes,Exercise Type,Sugar,Alcohol,Office Day,Sick Contact,Humidifier,Notes\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        for log in logs.sorted(by: { $0.date < $1.date }) {
            let row = [
                dateFormatter.string(from: log.date),
                String(format: "%.2f", log.sleepHours),
                "\(log.sleepQuality)",
                "\(log.stress)",
                "\(log.exerciseMinutes)",
                log.exerciseType.rawValue,
                log.sugarIntake.rawValue,
                log.alcohol.rawValue,
                log.officeDay ? "Yes" : "No",
                log.sickContactExposure ? "Yes" : "No",
                log.humidifierUsed ? "Yes" : "No",
                "\"\(log.notes.replacingOccurrences(of: "\"", with: "\"\""))\""
            ].joined(separator: ",")

            csvString.append(row + "\n")
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SickDayTracker_DailyLogs_\(Date().timeIntervalSince1970).csv")
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("Error saving daily logs CSV: \(error)")
            return nil
        }
    }

    static func generateEpisodesCSV(episodes: [SicknessEpisode]) -> URL? {
        var csvString = "Start Date,End Date,Type,Duration,Severity,Symptoms,Mucus Color,Worst Time,Medications,Doctor Visit,Test Results,Notes\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        for episode in episodes.sorted(by: { $0.startDate < $1.startDate }) {
            let endDateStr = episode.endDate != nil ? dateFormatter.string(from: episode.endDate!) : "Active"
            let durationStr = episode.duration != nil ? "\(episode.duration!) days" : "Active"
            let symptomsStr = episode.symptoms.map { $0.rawValue }.joined(separator: "; ")
            let medicationsStr = episode.medications.joined(separator: "; ")

            let row = [
                dateFormatter.string(from: episode.startDate),
                endDateStr,
                episode.type.rawValue,
                durationStr,
                "\(episode.severity)",
                "\"\(symptomsStr)\"",
                episode.mucusColor.rawValue,
                episode.worstTime.rawValue,
                "\"\(medicationsStr)\"",
                episode.doctorVisit ? "Yes" : "No",
                "\"\(episode.testResults.replacingOccurrences(of: "\"", with: "\"\""))\"",
                "\"\(episode.notes.replacingOccurrences(of: "\"", with: "\"\""))\""
            ].joined(separator: ",")

            csvString.append(row + "\n")
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SickDayTracker_Episodes_\(Date().timeIntervalSince1970).csv")
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("Error saving episodes CSV: \(error)")
            return nil
        }
    }
}
