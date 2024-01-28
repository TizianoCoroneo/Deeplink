//
//  EncodingDeeplinkTests.swift
//
//
//  Created by Dmitry Lobanov on 28.01.2024.
//

import Foundation
import XCTest
@testable import Deeplink

@MainActor
class EncodingDeeplinkTests: XCTestCase {

    struct Artist: Equatable {
        var id: String?
        var slug: String?
    }

    struct Event: Equatable {
        var id: String?
        var slug: String?
    }

    struct EventType: Equatable {
        var id: String?
        var slug: String?
        var event = Event()
    }

    struct Search: Equatable {
        var query: String?
    }

    struct CustomData: Equatable {
        var testData: Int?

        var testDataString: String? {
            get { testData.map { "\($0)" } }
            set { testData = newValue.flatMap(Int.init) }
        }
    }

    struct Restaurants: Equatable {
        var ids: [String]?
    }

    func testEncoding_Artist() {
        let deeplink = try! "/artist/\(\.slug)/\(\.id)" as Deeplink<Artist>

        let url = "/artist/123/1"

        var object = Artist()
        object.slug = "123"
        object.id = "1"
        XCTAssertEqual(url, deeplink.encode(object))
    }

    func testEncoding_EventType() {
        let deeplink = try! "/event/\(\.event.slug)/\(\.slug)/\(\.event.id)/\(\.id)" as Deeplink<EventType>

        let url = "/event/food/restaurants/123/1"

        var object = EventType()
        var event = Event()

        event.slug = "food"
        object.slug = "restaurants"
        event.id = "123"
        object.id = "1"
        object.event = event

        XCTAssertEqual(url, deeplink.encode(object))
    }

    func testEncoding_Search() {
        let deeplink = try! "/search?query=\(\.query)" as Deeplink<Search>

        let url = "/search?query=food"

        var object = Search()
        object.query = "food"
        XCTAssertEqual(url, deeplink.encode(object))
    }

    func testEncoding_CustomData() {
        let deeplink = try! "/test/\(\.testDataString)" as Deeplink<CustomData>

        let url = "/test/123"

        var object = CustomData()
        object.testData = 123

        XCTAssertEqual(url, deeplink.encode(object))
    }

    func testEncoding_Restaurants() {
        let deeplink = try! "/restaurants/ids=\(\.ids, separator: ",")" as Deeplink<Restaurants>

        let url = "/restaurants/ids=123,456,789"

        var object = Restaurants()
        object.ids = ["123", "456", "789"]

        XCTAssertEqual(url, deeplink.encode(object))
    }
}
