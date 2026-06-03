import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    var currentStreak: Int
    var maxStreak: Int
    var totalXP: Int
    var level: Int

    enum CodingKeys: String, CodingKey {
        case id, email
        case currentStreak = "current_streak"
        case maxStreak = "max_streak"
        case totalXP = "total_xp"
        case level
    }

    var levelName: String {
        let names = ["", "Seeker", "Practitioner", "Steady Breather", "Inner Circle", "SKY Guide", "Luminous"]
        return names.indices.contains(level) ? names[level] : "Seeker"
    }

    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}
