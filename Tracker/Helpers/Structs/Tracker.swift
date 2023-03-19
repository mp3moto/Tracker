import Foundation

struct TrackersStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

struct Tracker: Codable {
    let id: Int32
    let title: String
    let emoji: String
    let color: String
    let category: String
    let schedule: Schedule?
    let doneCount: Int
    let done: Bool
}

struct TrackerCategory {
    let category: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let trackerId: Int32
    let doneAt: Date
}
