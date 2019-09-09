import XCTest
@testable import Sectional

final class SectionalTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Sectional().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
