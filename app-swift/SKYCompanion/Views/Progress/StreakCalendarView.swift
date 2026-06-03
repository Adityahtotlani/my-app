import SwiftUI

struct StreakCalendarView: View {
    let practicedDates: Set<String>

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    private var last70Days: [Date] {
        let cal = Calendar.current
        return (0..<70).compactMap { cal.date(byAdding: .day, value: -$0, to: Date()) }.reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Practice Streak")
                .font(.system(size: 16, weight: .bold)).foregroundColor(.skySub)

            HStack {
                ForEach(dayLabels, id: \.self) { d in
                    Text(d).font(.caption2).foregroundColor(.skyMuted)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(last70Days, id: \.self) { date in
                    let key = isoDate(date)
                    let practiced = practicedDates.contains(key)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(practiced ? Color.skyIndigo : Color(UIColor.systemGray5))
                        .frame(height: 16)
                }
            }
        }
    }

    private func isoDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
