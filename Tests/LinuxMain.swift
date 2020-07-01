import XCTest

import DependencyRegistryTests

var tests = [XCTestCaseEntry]()
tests += DependencyRegistryTests.allTests()
XCTMain(tests)
