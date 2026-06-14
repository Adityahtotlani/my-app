import Foundation

struct Session: Codable, Identifiable {
    let id: Int
    let type: String
    let durationSeconds: Int
    let moodScore: Int?
    let completedAt: String
    let note: String?

    enum CodingKeys: String, CodingKey {
        case id, type, note
        case durationSeconds = "duration_seconds"
        case moodScore = "mood_score"
        case completedAt = "completed_at"
    }
}

struct LocalSession: Codable {
    let date: String            // "yyyy-MM-dd"
    let type: String            // "full" | "short"
    let durationSeconds: Int
    let moodScore: Int?
    let note: String?
}

struct MoodPoint: Identifiable {
    let id: Int
    let day: Int
    let mood: Double
}

struct StreakCalendarResponse: Codable {
    let dates: [String]
}

struct LogSessionResponse: Codable {
    let success: Bool
}
