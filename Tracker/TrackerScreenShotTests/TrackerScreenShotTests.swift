import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackViewControllerTests: XCTestCase {

    // MARK: - Properties
    var sut: TrackViewController!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = TrackViewController()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    // Тест для СВЕТЛОЙ темы
    func testTrackViewControllerLightMode() {
        sut.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        _ = sut.view
        sut.view.layoutIfNeeded()
        assertSnapshot(of: sut.view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    // Тест для ТЕМНОЙ темы 
    func testTrackViewControllerDarkMode() {
        sut.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        _ = sut.view
        sut.view.layoutIfNeeded()
        assertSnapshot(of: sut.view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
