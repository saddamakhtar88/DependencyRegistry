import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(DependencyRegistryTests.allTests),
    ]
}
#endif
