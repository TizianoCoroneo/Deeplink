//
//  URLPathDataTests.swift
//  
//
//  Created by Tiziano Coroneo on 28/02/2020.
//

import XCTest
@testable import Deeplink

class URLPathDataTests: XCTestCase {

    struct TestData {
        var test1: String?
        var test2: String?
        var test3: String?
        var test4: String?
        var test5: String?

        var testList1: [String]?
        var testList2: [String]?
        var testList3: [String]?
        var testList4: [String]?
        var testList5: [String]?
    }

    // MARK: - URLPathData Initializer Tests

    func testParsesComponentsAndQueryItemsAndFragment() {

        let data = try! URLPatternMatcher(url: "https://apple.com/test/something?name=john#help")

        XCTAssertEqual(
            URLPatternMatcher(
                relativeString: "/test/something?name=john#help"),
            data)
    }

    func testParsesComponentsAndQueryItems() {

        let data = try! URLPatternMatcher(url: "https://apple.com/test/something?name=john")

        XCTAssertEqual(
            URLPatternMatcher(
                relativeString: "/test/something?name=john"),
            data)
    }

    func testParsesComponentsAndFragment() {

        let data = try! URLPatternMatcher(url: "https://apple.com/test/something#help")

        XCTAssertEqual(
            URLPatternMatcher(
                relativeString: "/test/something#help"),
            data)
    }

    func testParsesComponents() {

        let data = try! URLPatternMatcher(url: "https://apple.com/test/something")

        XCTAssertEqual(
            URLPatternMatcher(
                relativeString: "/test/something"),
            data)
    }

    func testParsesQueryItems() {

        let data = try! URLPatternMatcher(url: "https://apple.com/?name=john")

        XCTAssertEqual(
            URLPatternMatcher(
                relativeString: "/?name=john"),
            data)
    }

    func testParsesFragment() {

        let data = try! URLPatternMatcher(url: "https://apple.com/#help")

        XCTAssertEqual(
            URLPatternMatcher(
                relativeString: "/#help"),
            data)
    }

    func testParsesSlashOnly() {

        let data = try! URLPatternMatcher(url: "https://apple.com/")

        XCTAssertEqual(
            URLPatternMatcher(
                relativeString: "/"),
            data)
    }

    func testParsesEmpty() {

        let data = try! URLPatternMatcher(url: "https://apple.com")

        XCTAssertEqual(
            URLPatternMatcher(
                relativeString: ""),
            data)
    }

    func testURLPathDataInitializer() {
        let data = try! URLPatternMatcher(
            url: "https://apple.com/sell/complex/tickets?name=john&surname=jack#help")

        XCTAssertEqual(
            URLPatternMatcher(
                relativeString: "/sell/complex/tickets?name=john&surname=jack#help"),
            data)
    }

    func testURLPathDataInitializerThrowsForInvalidComponents() {

        /// `a://@@` conforms to RFC 1808 (passing the URL initializer), but not to RFC 3986, necessary for `URLComponents` to work.
        /// https://stackoverflow.com/questions/55609012/what-kind-of-url-is-not-conforming-to-rfc-3986-but-is-conforming-to-rfc-1808-rf
        let url: URL = "a://@@"

        XCTAssertThrowsError(
            try URLPatternMatcher(url: url),
            "Expected invalid URL components error",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                    else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    .cannotExtractURLComponents(url: "a://@@"),
                    deeplinkError)
        })
    }

    // MARK: - Compute segments tests

    func testComputeSegments() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/\(\.test1)?\(\.test2)=\(\.test3)&surname=\(\.test4)#\(\.test5)"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets?name=john&surname=jack#help")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "tickets",
                "name",
                "john",
                "jack",
                "help"
            ], segments)
            }())
    }

    func testComputeSegmentsIsEmptyForEmptyComponents() {

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets?name=john&surname=jack#help")

        XCTAssertNoThrow(try {
            let segments = try data.findArgumentsSegments(
                forComponents: [DeeplinkInterpolation<TestData>.Component]())

            XCTAssertEqual([], segments)
        }())
    }

    func testComputeSegmentsAlwaysSplitsUpQueryItems() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/\(\.test1)"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets?name=john")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "tickets",
            ], segments)
            }())
    }

    func testComputeSegmentsAlwaysSplitsUpQueryItems_argumentList() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/\(\.testList1, separator: ",")"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets1,tickets2?name=john")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "tickets1,tickets2",
            ], segments)
        }())
    }

    func testComputeSegmentsSupportsEmptyQueryItemNames() {

        let deeplink: Deeplink<TestData> = try! "/test?a=1&\(\.test1)="

        let data = try! URLPatternMatcher(url: "https://apple.com/test?a=1&=test")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "",
            ], segments)
            }())
    }

    func testComputeSegmentsSupportsEmptyQueryItemNames2() {

        let deeplink: Deeplink<TestData> = try! "/test?a=1&\(\.test1)=value&arg=\(\.test2)"

        let data = try! URLPatternMatcher(url: "https://apple.com/test?a=1&=value&arg=b")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "",
                "b",
            ], segments)
            }())
    }

    func testComputeSegmentsAlwaysSplitsUpFragments() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/\(\.test1)"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets#help")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "tickets"
            ], segments)
            }())
    }

    func testComputeSegmentsAlwaysSplitsUpFragments_argumentList() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/\(\.testList1, separator: ",")"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/ticket1,ticket2#help")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "ticket1,ticket2"
            ], segments)
        }())
    }

    func testComputeSegmentsAlwaysSplitsUpQueryItemsAndFragments() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/\(\.test1)"

        let data = try! URLPatternMatcher(url:  "https://apple.com/sell/complex/tickets?name=john#help")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "tickets",
            ], segments)
            }())
    }

    func testComputeSegmentsAlwaysSplitsUpQueryItemsAndFragments_argumentList() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/\(\.testList1, separator: ",")"

        let data = try! URLPatternMatcher(url:  "https://apple.com/sell/complex/ticket1,ticket2?name=john#help")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "ticket1,ticket2",
            ], segments)
        }())
    }

    func testComputeSegmentsAlwaysSplitsPathComponents() {

        let deeplink: Deeplink<TestData> = try! "/\(\.test1)"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "sell"
            ], segments)
            }())
    }

    func testComputeSegmentsWorksWithMixedDuplicates() {

        let deeplink: Deeplink<TestData> = try! "/sell/\(\.test1)/?\(\.test2)=sell&sell=\(\.test3)#\(\.test4)"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/sell/?sell=sell&sell=sell#sell")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "sell",
                "sell",
                "sell",
                "sell"
            ], segments)
            }())
    }

    func testComputeSegmentsWorksWithMixedDuplicates_argumentList() {

        let deeplink: Deeplink<TestData> = try! "/sell/\(\.testList1, separator: ",")/?\(\.testList2, separator: "&")=sell&sell=\(\.testList3, separator: "&")#\(\.testList4, separator: ";")"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/sell,sell/?sell&sell=sell&sell=sell&sell#sell;sell")

        XCTAssertNoThrow(try {
            let segments = try data
                .findArgumentsSegments(forComponents: deeplink.components)

            XCTAssertEqual([
                "sell,sell",
                "sell&sell",
                "sell&sell",
                "sell;sell"
            ], segments)
        }())
    }

    // MARK: - Matches components tests

    func testMatchesComponents() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/\(\.test1)?\(\.test2)=\(\.test3)&surname=\(\.test4)#\(\.test5)"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets?name=john&surname=jack#help")

        do {
            var test = TestData()

            try data.match(components: deeplink.components, into: &test)

            XCTAssertEqual("tickets", test.test1)
            XCTAssertEqual("name", test.test2)
            XCTAssertEqual("john", test.test3)
            XCTAssertEqual("jack", test.test4)
            XCTAssertEqual("help", test.test5)
            XCTAssertNil(test.testList1)
            XCTAssertNil(test.testList2)
            XCTAssertNil(test.testList3)
            XCTAssertNil(test.testList4)
            XCTAssertNil(test.testList5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testSimplePathDeeplinkMatchesNextPathComponent() {

        let deeplink: Deeplink<TestData> = try! "/sell/\(\.test1)/tickets"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets?name=john&surname=jack")

        do {
            var test = TestData()

            try data.match(components: deeplink.components, into: &test)

            XCTAssertEqual("complex", test.test1)
            XCTAssertNil(test.test2)
            XCTAssertNil(test.test3)
            XCTAssertNil(test.test4)
            XCTAssertNil(test.test5)
            XCTAssertNil(test.testList1)
            XCTAssertNil(test.testList2)
            XCTAssertNil(test.testList3)
            XCTAssertNil(test.testList4)
            XCTAssertNil(test.testList5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testSimplePathDeeplinkIgnoresQueryItems() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/\(\.test1)"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets?name=john&surname=jack")

        do {
            var test = TestData()

            try data.match(components: deeplink.components, into: &test)

            XCTAssertEqual("tickets", test.test1)
            XCTAssertNil(test.test2)
            XCTAssertNil(test.test3)
            XCTAssertNil(test.test4)
            XCTAssertNil(test.test5)
            XCTAssertNil(test.testList1)
            XCTAssertNil(test.testList2)
            XCTAssertNil(test.testList3)
            XCTAssertNil(test.testList4)
            XCTAssertNil(test.testList5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testSimplePathDeeplinkIgnoresFragments() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/\(\.test1)"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets#help")

        do {
            var test = TestData()

            try data.match(components: deeplink.components, into: &test)

            XCTAssertEqual("tickets", test.test1)
            XCTAssertNil(test.test2)
            XCTAssertNil(test.test3)
            XCTAssertNil(test.test4)
            XCTAssertNil(test.test5)
            XCTAssertNil(test.testList1)
            XCTAssertNil(test.testList2)
            XCTAssertNil(test.testList3)
            XCTAssertNil(test.testList4)
            XCTAssertNil(test.testList5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testOneQueryItemDeeplinkIgnoresOtherQueryItems() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/tickets?test1=\(\.test1)"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets?test1=a&test2=b")

        do {
            var test = TestData()

            try data.match(components: deeplink.components, into: &test)

            XCTAssertEqual("a", test.test1)
            XCTAssertNil(test.test2)
            XCTAssertNil(test.test3)
            XCTAssertNil(test.test4)
            XCTAssertNil(test.test5)
            XCTAssertNil(test.testList1)
            XCTAssertNil(test.testList2)
            XCTAssertNil(test.testList3)
            XCTAssertNil(test.testList4)
            XCTAssertNil(test.testList5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testOneQueryItemDeeplinkIgnoresOtherQueryItems_argumentList() {

        let deeplink: Deeplink<TestData> = try! "/sell/complex/tickets?test1=\(\.testList1, separator: ",")"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets?test1=a,b,c&test2=b")

        do {
            var test = TestData()

            try data.match(components: deeplink.components, into: &test)

            XCTAssertEqual(["a", "b", "c"], test.testList1)
            XCTAssertNil(test.test2)
            XCTAssertNil(test.test3)
            XCTAssertNil(test.test4)
            XCTAssertNil(test.test5)
            XCTAssertNil(test.testList2)
            XCTAssertNil(test.testList3)
            XCTAssertNil(test.testList4)
            XCTAssertNil(test.testList5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testComplexMatchWithPartialFragmentMatchAndOutOfOrderKeys() {

        let deeplink: Deeplink<TestData> = try! "/sell/\(\.test5)/tickets?\(\.test4)=a&test2=\(\.test3)#he\(\.test2)"

        let data = try! URLPatternMatcher(url: "https://apple.com/sell/complex/tickets?test1=a&test2=b#help")

        do {
            var test = TestData()

            try data.match(components: deeplink.components, into: &test)

            XCTAssertNil(test.test1)
            XCTAssertEqual("lp", test.test2)
            XCTAssertEqual("b", test.test3)
            XCTAssertEqual("test1", test.test4)
            XCTAssertEqual("complex", test.test5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
