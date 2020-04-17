import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CSV2KeychainTests.allTests),
    ]
}
#endif
