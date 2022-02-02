//
//  CatchAllDeeplinkTests.swift
//  
//
//  Created by Tiziano Coroneo on 02/02/2022.
//

import XCTest
@testable import Deeplink

class CatchAllDeeplinkTests: XCTestCase {

    func testMatchesPath() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple:///test"))
    }

    func testMatchesEmptyPath() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple://"))
    }

    func testEverythingMatchesEmptyPath() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple://"))
    }

    func testMatchesSlashPath() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple:///"))
    }

    func testMatchesPathIgnoringNextPath() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple:///test/again"))
    }

    func testMatchesPathIgnoringQueryItems() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1"))
    }

    func testMatchesPathIgnoringFragments() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple:///test#fragment"))
    }

    func testMatchesPathIgnoringEverything() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1&b=2#fragment"))
    }

    func testMatchesPathAndQueryItems() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1"))
    }

    func testMatchesPathAndQueryItemsIgnoringNextQueryItems() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1&b=2"))
    }

    func testMatchesPathAndQueryItemsIgnoringFragments() {
        let deeplink = Deeplink<Void>.catchAll
        XCTAssertNoThrow(try deeplink.parse("apple:///test?a=1#fragment"))
    }
}
