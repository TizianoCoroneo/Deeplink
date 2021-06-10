import Deeplink

struct TestData: DefaultInitializable {
    var arg1: String?
    var arg2: String?
}

struct TestData2 {
    var arg1: String?
    var arg2: String?
}

let link1 = "/test/1" as Deeplink<Void>
let link2 = try "/test/\(\.arg1)/\(\.arg2)" as Deeplink<TestData>
let link3 = try "/test2/\(\.arg1)/\(\.arg2)" as Deeplink<TestData2>

let center = DeeplinksCenter {

    link1 { url in
        XCTAssertEqual(url.absoluteString, "https://apple.com/test/1")
        return true
    }

    link2 { url, value in
        XCTAssertEqual(url.absoluteString, "https://apple.com/test/a/b")
        XCTAssertEqual(value.arg1, "a")
        XCTAssertEqual(value.arg2, "b")
        return true
    }

    link3(
        assigningTo: .init(arg1: "default", arg2: "default")
    ) { (url, value) -> Bool in
        XCTAssertEqual(url.absoluteString, "https://apple.com/test2/a/b")
        XCTAssertEqual(value.arg1, "a")
        XCTAssertEqual(value.arg2, "b")
        return true
    }
}

try center.parse(url: URL(string: "https://apple.com/test/1")!)
try center.parse(url: URL(string: "https://apple.com/test/a/b")!)
try center.parse(url: URL(string: "https://apple.com/test2/a/b")!)
