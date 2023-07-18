//
//  File.swift
//  
//
//  Created by Tiziano Coroneo on 22/01/2021.
//

import Foundation
import XCTest
import Deeplink

fileprivate struct TestData: DefaultInitializable {
    var arg1: String?
    var arg2: String?
}

fileprivate struct TestData2 {
    var arg1: String?
    var arg2: String?
}

@MainActor
class DeeplinkBuilderTests: XCTestCase {

    func testFunctionBuilder() throws {

        let link1 = "/test/1" as Deeplink<Void>
        let link2 = try "/test/\(\.arg1)/\(\.arg2)" as Deeplink<TestData>
        let link3 = try "/test2/\(\.arg1)/\(\.arg2)" as Deeplink<TestData2>

        let expectSimpleLink = expectation(description: "Should call the simple deeplink registration")

        let expectInitializableDataLink = expectation(description: "Should call the initializable value deeplink registration")

        let expectDataLink = expectation(description: "Should call the value deeplink registration")

        let center = DeeplinksCenter {

            link1 { url in
                XCTAssertEqual(url.absoluteString, "https://apple.com/test/1")
                expectSimpleLink.fulfill()
                return true
            }

            link2 { url, value in
                XCTAssertEqual(url.absoluteString, "https://apple.com/test/a/b")
                XCTAssertEqual(value.arg1, "a")
                XCTAssertEqual(value.arg2, "b")
                expectInitializableDataLink.fulfill()
                return true
            }

            link3(
                assigningTo: .init(arg1: "default", arg2: "default")
            ) { (url, value) -> Bool in
                XCTAssertEqual(url.absoluteString, "https://apple.com/test2/a/b")
                XCTAssertEqual(value.arg1, "a")
                XCTAssertEqual(value.arg2, "b")
                expectDataLink.fulfill()
                return true
            }
        }

        try center.parse(url: URL(string: "https://apple.com/test/1")!)
        try center.parse(url: URL(string: "https://apple.com/test/a/b")!)
        try center.parse(url: URL(string: "https://apple.com/test2/a/b")!)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFunctionBuilderConditionalLink() throws {
        let link1 = "/test/1" as Deeplink<Void>

        let expectSimpleLink = expectation(description: "Should call the simple deeplink registration")

        let falseCondition = false
        let trueCondition = true

        let center = DeeplinksCenter {
            if falseCondition {
                link1 { _ in
                    XCTFail()
                    return true
                }
            }

            if trueCondition {
                link1 { url in
                    XCTAssertEqual(url.absoluteString, "https://apple.com/test/1")
                    expectSimpleLink.fulfill()
                    return true
                }
            }
        }

        try center.parse(url: URL(string: "https://apple.com/test/1")!)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFunctionBuilderOptionalLink() throws {
        let link1 = "/test/1" as Deeplink<Void>

        let expectSimpleLink = expectation(description: "Should call the simple deeplink registration")

        let optionalInt: Optional<Int> = 3
        let optionalNone: Optional<Int> = .none

        let center = DeeplinksCenter {
            if let value = optionalNone {
                link1 { _ in
                    print(value)
                    XCTFail()
                    return true
                }
            }

            if optionalNone != nil {
                link1 { _ in
                    XCTFail()
                    return true
                }
            }

            if let value = optionalInt {
                link1 { url in
                    print(value)
                    XCTAssertEqual(url.absoluteString, "https://apple.com/test/1")
                    expectSimpleLink.fulfill()
                    return true
                }
            }
        }

        try center.parse(url: URL(string: "https://apple.com/test/1")!)

        waitForExpectations(timeout: 1, handler: nil)
    }
}
