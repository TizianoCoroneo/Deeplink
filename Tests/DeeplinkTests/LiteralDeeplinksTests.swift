//
//  LiteralDeeplinkTests.swift
//  
//
//  Created by Tiziano Coroneo on 29/02/2020.
//

import Foundation
import XCTest
@testable import Deeplink

fileprivate struct TestData {
    var arg1: String?
    var arg2: String?
}

class LiteralDeeplinkTests: XCTestCase {

    func testMatchesPath() {
        let deeplink = "/test" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple:///test"))
    }

    func testMatchesEmptyPath() {
        let deeplink = "" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple://"))
    }

    func testEverythingMatchesEmptyPath() {
        let deeplink = "" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple:///"))
        XCTAssertNoThrow(try deeplink.parse("apple://test"))
        XCTAssertNoThrow(try deeplink.parse("apple:///test/again"))
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1"))
        XCTAssertNoThrow(try deeplink.parse("apple:///test#fragment"))
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1&b=2#fragment"))
    }

    func testMatchesSlashPath() {
        let deeplink = "/" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple:///"))
    }

    func testMatchesPathIgnoringNextPath() {
        let deeplink = "/test" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple:///test/again"))
    }

    func testMatchesPathIgnoringQueryItems() {
        let deeplink = "/test" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1"))
    }

    func testMatchesPathIgnoringFragments() {
        let deeplink = "/test" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple:///test#fragment"))
    }

    func testMatchesPathIgnoringEverything() {
        let deeplink = "/test" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1&b=2#fragment"))
    }

    func testMatchesPathAndQueryItems() {
        let deeplink = "/test?a=1" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1"))
    }

    func testMatchesPathAndQueryItemsIgnoringNextQueryItems() {
        let deeplink = "/test?a=1" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1&b=2"))
    }

    func testMatchesPathAndQueryItemsIgnoringFragments() {
        let deeplink = "/test?a=1" as Deeplink<Void>
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1#fragment"))
    }

    func testThrowsIfDoesntMatch() {
        let deeplink = "/test?a=1" as Deeplink<Void>

        XCTAssertThrowsError(
            try deeplink.parse("apple:///test/help?a=1#fragment"),
            "Expected non matching path",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                    else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.pathDoesntMatchWithLiteralDeepLink(
                        path: "/test/help?a=1#fragment",
                        deepLink: "/test?a=1"),
                    deeplinkError)
        })
    }
}
