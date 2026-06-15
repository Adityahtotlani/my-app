import Foundation
import HealthKit

@MainActor
final class HealthKitService {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()
    private let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    private let hrType = HKQuantityType(.heartRate)

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await healthStore.requestAuthorization(toShare: [mindfulType], read: [hrType])
            return true
        } catch {
            return false
        }
    }

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

    /// Returns the most recent HR reading from the last 5 minutes (any device writing to HealthKit).
    func fetchLatestHeartRate() async -> Double? {
        guard isAvailable else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-300), end: Date())
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let store = healthStore
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: hrType, predicate: predicate, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                if let sample = samples?.first as? HKQuantitySample {
                    continuation.resume(returning: sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            store.execute(query)
        }
    }

    /// Returns avg/min/max BPM and reading count for all HR samples in the given window.
    func fetchSessionHeartRateSummary(start: Date, end: Date) async -> (avg: Double, min: Double, max: Double, count: Int)? {
        guard isAvailable else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let store = healthStore
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: hrType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let hrSamples = samples as? [HKQuantitySample], !hrSamples.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }
                let unit = HKUnit(from: "count/min")
                let values = hrSamples.map { $0.quantity.doubleValue(for: unit) }
                let avg = values.reduce(0, +) / Double(values.count)
                continuation.resume(returning: (avg: avg, min: values.min()!, max: values.max()!, count: values.count))
            }
            store.execute(query)
        }
    }
}
