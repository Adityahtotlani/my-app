import SwiftUI

struct StreakCalendarView: View {
    let practicedDates: Set<String>

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private var last70Days: [Date] {
        let cal = Calendar.current
        return (0..<70).compactMap { cal.date(byAdding: .day, value: -$0, to: Date()) }.reversed()
    }

    // Pad the start so column 0 always = Sunday
    private var gridEntries: [Date?] {
        guard let first = last70Days.first else { return [] }
        let weekday = Calendar.current.component(.weekday, from: first) // 1=Sun…7=Sat
        var entries: [Date?] = Array(repeating: nil, count: weekday - 1)
        entries.append(contentsOf: last70Days.map { Optional($0) })
        return entries
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Practice Streak")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.skySub)
                Spacer()
                Text("\(practicedDates.count) day\(practicedDates.count == 1 ? "" : "s") practiced")
                    .font(.system(size: 12)).foregroundColor(.skyMuted)
            }

            HStack {
                ForEach(dayLabels, id: \.self) { d in
                    Text(d).font(.caption2).foregroundColor(.skyMuted)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(gridEntries.enumerated()), id: \.offset) { _, date in
                    if let date {
                        let key = formatter.string(from: date)
                        let practiced = practicedDates.contains(key)
                        let isToday = Calendar.current.isDateInToday(date)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(practiced ? Color.skyIndigo : Color(UIColor.systemGray5))
                            .frame(height: 16)
                            .overlay {
                                if isToday {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(practiced ? Color.white.opacity(0.5) : Color.skyIndigo,
                                                lineWidth: 1.5)
                                }
                            }
                    } else {
                        Color.clear.frame(height: 16)
                    }
                }
            }
        }
    }
}
