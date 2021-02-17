import XCTest
@testable import BatteryLevel

final class BatteryLevelTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BatteryLevel().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
