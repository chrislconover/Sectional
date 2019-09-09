import XCTest

import SectionalTests

var tests = [XCTestCaseEntry]()
tests += SectionalTests.allTests()
XCTMain(tests)
