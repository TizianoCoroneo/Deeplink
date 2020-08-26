//
//  ValidDeeplinkTests.swift
//
//
//  Created by Tiziano Coroneo on 28/02/2020.
//

import XCTest
@testable import Deeplink

// MARK: - Mocks

let universalLink: URL = "https://apple.com/sell/ticket/1"
let appschemeLink: URL = "apple:///sell/ticket/1"

fileprivate struct TestData {
    var arg1: String = ""
    var arg2: String = ""
}

let validSellLinksList: [URL] = [
    "https://www.apple.com/sell/ticket/1",
    "https://apple.com/sell/ticket/1",
    "http://apple.com/sell/ticket/1",
    "ftp://apple.com/sell/ticket/1",
    "ftp://apple.com/sell/ticket/1?whatever",
    "ftp://apple.com/sell/ticket/1#help",
    "ftp://apple.com/sell/ticket/1?whatever=something",
    "ftp://apple.com/sell/ticket/1?whatever=something#help",
    "ftp://apple.com/sell/ticket/1?sell/ticket/2",
    "apple:///sell/ticket/1",
    "/sell/ticket/1",
]

let emptySellLinksList1: [URL] = [
    "https://apple.com/sell/ticket/",
    "apple:///sell/ticket/",
    "/sell/ticket/",
]

let emptySellLinksList2: [URL] = [
    "https://apple.com/sell//1",
    "apple:///sell//1",
    "/sell//1",
]

let emptySellLinksList3: [URL] = [
    "https://apple.com/sell//",
    "apple:///sell//",
    "/sell//",
]


let validLongLinksList: [URL] = [
    "https://apple.com/sell/complex/ticket/test/1",
    "http://www.apple.com/sell/complex/ticket/test/1",
    "http://www.apple.com/sell/complex/ticket/test/1",
    "ftp://www.apple.com/sell/complex/ticket/test/1",
    "ftp://apple.com/sell/complex/ticket/test/1",
    "ftp://apple.com/sell/complex/ticket/test/1#help",
    "ftp://apple.com/sell/complex/ticket/test/1?whatever",
    "ftp://apple.com/sell/complex/ticket/test/1?whatever=something",
    "ftp://apple.com/sell/complex/ticket/test/1?whatever=something#help",
    "ftp://apple.com/sell/complex/ticket/test/1?sell/ticket/2",
    "apple:///sell/complex/ticket/test/1",
    "/sell/complex/ticket/test/1",
]

let queryItemsLinksList: [URL] = [
    "https://apple.com/test?a=1&b=2&c=3",
    "http://www.apple.com/test?a=1&b=2&c=3",
    "http://www.apple.com/test?a=1&b=2&c=3",
    "ftp://www.apple.com/test?a=1&b=2&c=3",
    "ftp://apple.com/test?a=1&b=2&c=3",
    "ftp://apple.com/test?a=1&b=2&c=3#help",
    "ftp://apple.com/test?a=1&b=2&c=3?whatever",
    "ftp://apple.com/test?a=1&b=2&c=3?whatever=something",
    "ftp://apple.com/test?a=1&b=2&c=3?whatever=something#help",
    "ftp://apple.com/test?a=1&b=2&c=3?sell/ticket/2",
    "apple:///test?a=1&b=2&c=3",
    "/test?a=1&b=2&c=3",
]

let fragmentsLinksList: [URL] = [
    "https://apple.com/test#test",
    "http://www.apple.com/test#test?a=1&b=2&c=3",
    "http://www.apple.com/test#test?a=1&b=2&c=3",
    "ftp://www.apple.com/test#test?a=1&b=2&c=3",
    "ftp://apple.com/test#test?a=1&b=2&c=3",
    "ftp://apple.com/test#test?a=1&b=2&c=3?whatever",
    "ftp://apple.com/test#test?a=1&b=2&c=3?whatever=something",
    "ftp://apple.com/test#test?a=1&b=2&c=3?sell/ticket/2",
    "apple:///test#test?a=1&b=2&c=3",
    "/test#test?a=1&b=2&c=3",
]

// MARK: - Test case list

let testCaseList: [MatchTestCase] = [

    validSellLinksList.map {
        MatchTestCase(
            url: $0,
            deeplink: try! "/sell/\(\.arg1)/\(\.arg2)" as Deeplink<TestData>,
            initialInstance: TestData(),
            verify: {
                XCTAssertEqual("ticket", $0.arg1)
                XCTAssertEqual("1", $0.arg2)
        })
    },

    emptySellLinksList1.map {
        MatchTestCase(
            url: $0,
            deeplink: try! "/sell/\(\.arg1)/\(\.arg2)" as Deeplink<TestData>,
            initialInstance: TestData(),
            verify: {
                XCTAssertEqual("ticket", $0.arg1)
                XCTAssertEqual("", $0.arg2)
        })
    },

    emptySellLinksList2.map {
        MatchTestCase(
            url: $0,
            deeplink: try! "/sell/\(\.arg1)/\(\.arg2)" as Deeplink<TestData>,
            initialInstance: TestData(),
            verify: {
                XCTAssertEqual("", $0.arg1)
                XCTAssertEqual("1", $0.arg2)
        })
    },

    emptySellLinksList3.map {
        MatchTestCase(
            url: $0,
            deeplink: try! "/sell/\(\.arg1)/\(\.arg2)" as Deeplink<TestData>,
            initialInstance: TestData(),
            verify: {
                XCTAssertEqual("", $0.arg1)
                XCTAssertEqual("", $0.arg2)
        })
    },

    validSellLinksList.map {
        MatchTestCase(
            url: $0,
            deeplink: "/sell/ticket/1" as Deeplink<Void>)
    },

    validLongLinksList.map {
        MatchTestCase(
            url: $0,
            deeplink: try! "/sell/complex/\(\.arg1)/test/\(\.arg2)" as Deeplink<TestData>,
            initialInstance: TestData(),
            verify: {
                XCTAssertEqual("ticket", $0.arg1)
                XCTAssertEqual("1", $0.arg2)
        })
    },

    queryItemsLinksList.map {
        MatchTestCase(
            url: $0,
            deeplink: try! "/test?a=\(\.arg1)&\(\.arg2)=2&c=3" as Deeplink<TestData>,
            initialInstance: TestData(),
            verify: {
                XCTAssertEqual("1", $0.arg1)
                XCTAssertEqual("b", $0.arg2)
        })
    },

    fragmentsLinksList.map { url in
        MatchTestCase(
            url: url,
            deeplink: try! "/test#\(\.arg1)" as Deeplink<TestData>,
            initialInstance: TestData(),
            verify: {
                XCTAssertEqual("test", $0.arg1)
                XCTAssertEqual("", $0.arg2)
        })
    },

    [
        // Test if query items names match no value
        MatchTestCase(
            url: "https://apple.com/test?a=1&=test",
            deeplink: try! "/test?a=1&\(\.arg1)=" as Deeplink<TestData>,
            initialInstance: TestData(),
            verify: {
                XCTAssertEqual("", $0.arg1)
                XCTAssertEqual("", $0.arg2)
        }),

        // Test if query items arguments match no value
        MatchTestCase(
            url: "https://apple.com/test?a=1&b=",
            deeplink: try! "/test?a=1&b=\(\.arg1)" as Deeplink<TestData>,
            initialInstance: TestData(),
            verify: {
                XCTAssertEqual("", $0.arg1)
                XCTAssertEqual("", $0.arg2)
        }),
    ]

].flatMap { $0 }

// MARK: - Test case container

struct MatchTestCase {

    let run: () throws -> Void
    let url: URL
    let deeplinkDescription: String

    init<T>(
        url: URL,
        deeplink getDeeplink: @escaping @autoclosure () throws -> Deeplink<T>,
        initialInstance: @escaping @autoclosure () -> T,
        verify: @escaping (T) throws -> Void = { _ in }
    ) {

        self.url = url
        self.deeplinkDescription = String(describing: Result { try getDeeplink() })
        self.run = {
            let deeplink = try getDeeplink()

            var result = initialInstance()
            try deeplink.parse(url, into: &result)
            try verify(result)
        }
    }

    init(
        url: URL,
        deeplink getDeeplink: @escaping @autoclosure () throws -> Deeplink<Void>,
        verify: @escaping () throws -> Void = { }
    ) {
        self.init(
            url: url,
            deeplink: try getDeeplink(),
            initialInstance: (),
            verify: verify)
    }
}

// MARK: - Test runner

class ValidDeeplinkTests: XCTestCase {

    var testCase: MatchTestCase?

    override class var defaultTestSuite: XCTestSuite {
        let suite = XCTestSuite(forTestCaseClass: ValidDeeplinkTests.self)

        testCaseList.forEach {
            let test = ValidDeeplinkTests(selector: #selector(runTestCase))
            test.testCase = $0
            suite.addTest(test)
        }

        return suite
    }

    @objc func runTestCase() {
        assert(testCase != nil)

        do {
            try testCase!.run()
        } catch {

            let attachment = XCTAttachment(
                string: """
                URL: \(testCase!.url)
                Deeplink: \(testCase!.deeplinkDescription)
                Error: \(error)
                """)

            attachment.lifetime = .keepAlways
            self.add(attachment)

            XCTFail(error.localizedDescription)
        }
    }
}
