import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(DiscreteIntervalEncodingTreeTests.allTests),
    ]
}
#endif
