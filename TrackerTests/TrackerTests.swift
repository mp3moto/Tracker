import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testHomeViewController() {
        //isRecording = true
        let vc = UINavigationController(rootViewController: TrackerListViewController(store: DataStore()))
        assertSnapshots(matching: vc, as: [.image])
    }

}
