import Foundation
import HealthKit

@MainActor
final class HealthKitService {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()
    private let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// Requests HealthKit write authorization for mindful sessions.
    /// Returns true if the user granted access (or if previously granted).
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await healthStore.requestAuthorization(toShare: [mindfulType], read: [])
            return true
        } catch {
            return false
        }
    }

    /// Writes a mindful session ending now with the given duration to Apple Health.
    func writeMindfulSession(durationSeconds: Int) async {
        guard isAvailable else { return }
        let end = Date()
        guard let start = Calendar.current.date(byAdding: .second, value: -durationSeconds, to: end) else { return }
        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )
        try? await healthStore.save(sample)
    }
}
