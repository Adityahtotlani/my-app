import Foundation

enum APIError: LocalizedError {
    case badURL
    case unauthorized
    case serverError(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .badURL: return "Invalid URL."
        case .unauthorized: return "Invalid credentials."
        case .serverError(let code): return "Server error (\(code))."
        case .decodingError(let e): return "Could not parse response: \(e.localizedDescription)"
        }
    }
}

struct APIService {
    static let baseURL = "https://octoally.adityatotlani.ch"

    static func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: (any Encodable)? = nil,
        token: String? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + path) else { throw APIError.badURL }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token, !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.badURL }

        if http.statusCode == 401 { throw APIError.unauthorized }
        guard (200...299).contains(http.statusCode) else { throw APIError.serverError(http.statusCode) }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
