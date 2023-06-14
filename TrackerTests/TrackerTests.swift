import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    private let dataStore = DataStore()

    func testHomeViewControllerLight() {
        //isRecording = true
        let vc = UINavigationController(
            rootViewController: TrackerListViewController(
                trackerStore: TrackerStore(dataStore: dataStore),
                categoryStore: CategoryStore(dataStore: dataStore),
                trackerRecordStore: TrackerRecordStore(dataStore: dataStore)
            )
        )
        
        assertSnapshots(matching: vc, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }

    func testHomeViewControllerDark() {
        //isRecording = true
        let vc = UINavigationController(
            rootViewController: TrackerListViewController(
                trackerStore: TrackerStore(dataStore: dataStore),
                categoryStore: CategoryStore(dataStore: dataStore),
                trackerRecordStore: TrackerRecordStore(dataStore: dataStore)
            )
        )
        
        assertSnapshots(matching: vc, as: [.image(traits: .init(userInterfaceStyle: .dark))])
    }
}
