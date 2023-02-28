import Foundation

struct Tracker: Codable {
    let id: Int32
    let title: String
    let emoji: String
    let color: String
    let categoryId: Int
    let schedule: Schedule?
}

struct TrackerCategory {
    let categoryId: Int
    let trackers: [Tracker]
}

struct TrackerRecord {
    let trackerId: Int
    let doneAt: Date
}
