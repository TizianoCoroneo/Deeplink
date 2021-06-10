import Deeplink

let link1 = "/test/1" as Deeplink<Void>

let center = DeeplinksCenter {

    link1 { url in
        XCTAssertEqual(url.absoluteString, "https://apple.com/test/1")
        return true
    }
}

try center.parse(url: URL(string: "https://apple.com/test/1")!)
