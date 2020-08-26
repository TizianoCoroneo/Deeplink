//
//  InvalidDeeplinkTests.swift
//  
//
//  Created by Tiziano Coroneo on 28/02/2020.
//

import XCTest
@testable import Deeplink

fileprivate struct TestData {
    var arg1: String = ""
    var arg2: String = ""
}

class InvalidDeeplinkTests: XCTestCase {

    func testNotMatchingPath() {
        let deeplink = try! "/test#\(\.arg1)" as Deeplink<TestData>

        var result = TestData()

        XCTAssertThrowsError(
            try deeplink.parse(
                "apple:///test?a=1&b=2",
                into: &result),
            "Expected error",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                    else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    .pathDoesntMatchWithLiteralDeepLink(
                        path: "/test?a=1&b=2",
                        deepLink: "/test#"),
                    deeplinkError)
        })

        XCTAssertEqual("", result.arg1)
        XCTAssertEqual("", result.arg2)
    }

    func testDoubleArgumentError() {

        XCTAssertThrowsError(
            try "/\(\.arg1)#\(\.arg1)" as Deeplink<TestData>,
            "Cannot declare same keypath twice",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                    else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.argumentRepeated(
                        argument: \TestData.arg1),
                    deeplinkError)
        })
    }

    func testConsecutiveArgumentError() {

        XCTAssertThrowsError(
            try "/\(\.arg1)\(\.arg2)" as Deeplink<TestData>,
            "Cannot declare two keypath consecutively",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                    else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.cannotSetTwoArgumentsConsecutively(
                        argument1: \TestData.arg1,
                        argument2: \TestData.arg2),
                    deeplinkError)
        })
    }

    func testInterpolationDoesntMatchExtraPrefixes() {
        let deeplink = try! "/sync/\(\.arg1)" as Deeplink<TestData>

        var result = TestData()

        XCTAssertThrowsError(
            try deeplink.parse(
                "https://apple.com/ouch/sync/test",
                into: &result),
            "Cannot match paths with different prefixes",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                    else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.pathDoesntMatchWithLiteralDeepLink(
                        path: "/ouch",
                        deepLink: "/sync/{{ argument }}"),
                    deeplinkError)
        })
    }

    func testLiteralDoesntMatchExtraPrefixes() {
        let deeplink = "/sync/test" as Deeplink<Void>

        XCTAssertThrowsError(
            try deeplink.parse(
                "https://apple.com/ouch/sync/test"),
            "Cannot match paths with different prefixes",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                    else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.pathDoesntMatchWithLiteralDeepLink(
                        path: "/ouch",
                        deepLink: "/sync/test"),
                    deeplinkError)
        })
    }
}
