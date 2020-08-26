//
//  StringUtilitiesTests.swift
//  
//
//  Created by Tiziano Coroneo on 29/02/2020.
//

import Foundation
import XCTest
@testable import Deeplink

class StringUtilitiesTests: XCTestCase {

    func testSplitFirstOccurrence() {

        let test = "abcdefabcdefabcdefabcdef"

        let result = test.splitFirstOccurrence(of: "def")

        XCTAssertEqual([
            "abc",
            "abcdefabcdefabcdef"
        ], result)
    }

    func testSplitFirstOccurrenceOnEmptyString() {

        let test = ""

        let result = test.splitFirstOccurrence(of: "def")

        XCTAssertEqual([
            test
        ], result)
    }


    func testSplitFirstOccurrenceOnStringStart() {

        let test = "defabcdefabcdefabcdef"

        let result = test.splitFirstOccurrence(of: "def")

        XCTAssertEqual([
            "",
            "abcdefabcdefabcdef"
        ], result)
    }

    func testSplitFirstOccurrenceOnStringEnd() {

        let test = "abcdef"

        let result = test.splitFirstOccurrence(of: "def")

        XCTAssertEqual([
            "abc",
            ""
        ], result)
    }

    func testRemoveAfterAnyCharacterIn() {

        let test = "abcdefghijklmnopqrstuvwxyz"

        let result = test.removeAfterAnyCharacterIn(string: "yis")

        XCTAssertEqual(
            "abcdefgh",
            result)
    }

    func testRemoveAfterAnyCharacterInOnEmptyString() {

        let test = ""

        let result = test.removeAfterAnyCharacterIn(string: "yis")

        XCTAssertEqual(
            "",
            result)
    }
}
