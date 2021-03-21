//
//  TicketSwapDeeplinkTests.swift
//  
//
//  Created by Tiziano Coroneo on 28/02/2020.
//

import XCTest
import Deeplink

class TicketSwapDeeplinkTests: XCTestCase {

    // MARK: - Models

    struct Artist: Equatable {
        var id: String?
        var slug: String?
    }

    struct City: Equatable {
        var id: String?
        var slug: String?
        var period: String?
    }

    struct WantedEvent: Equatable {
        var id: String?
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

    struct Listing: Equatable {
        var id: String?
        var slug: String?
    }

    struct Location: Equatable {
        var id: String?
        var slug: String?
        var period: String?
    }

    struct Search: Equatable {
        var query: String?
    }

    // MARK: - Deeplinks

    let artistDeeplink = try! "/artist/\(\.slug)/\(\.id)"
        as Deeplink<Artist>

    let cityDeeplink = try! "/city/\(\.slug)/\(\.id)"
        as Deeplink<City>

    let locationDeeplink = try! "/location/\(\.slug)/\(\.id)/\(\.period)"
        as Deeplink<Location>

    let eventDeeplink = try! "/event/\(\.slug)/\(\.id)"
        as Deeplink<Event>

    let eventTypeDeeplink = try! "/event/\(\.event.slug)/\(\.slug)/\(\.event.id)/\(\.id)"
        as Deeplink<EventType>

    let searchDeeplink = try! "/search?query=\(\.query)"
        as Deeplink<Search>

    let wantedEventDeeplink = try! "/wanted/\(\.id)"
        as Deeplink<WantedEvent>

    // MARK: - Tests

    func testArtistDeeplink() {
        var artist = Artist()

        XCTAssertNoThrow(try artistDeeplink
            .parse("https://ticketswap.com/artist/metallica/123456", into: &artist))

        XCTAssertEqual(
            Artist(
                id: "123456",
                slug: "metallica"),
            artist)
    }

    func testCityDeeplink() {

        var city = City()

        XCTAssertNoThrow(try cityDeeplink
            .parse("https://ticketswap.com/city/amsterdam/1234567", into: &city))

        XCTAssertEqual(
            City(
                id: "1234567",
                slug: "amsterdam"),
            city)
    }

    func testLocationDeeplink() {

        var location = Location()

        XCTAssertNoThrow(try locationDeeplink
            .parse("https://ticketswap.com/location/amsterdam/1234567/24-06-2019", into: &location))

        XCTAssertEqual(
            Location(
                id: "1234567",
                slug: "amsterdam",
                period: "24-06-2019"),
            location)
    }

    func testEventDeeplink() {

        var event = Event()

        XCTAssertNoThrow(try eventDeeplink
            .parse("https://ticketswap.com/event/awakenings/12345", into: &event))

        XCTAssertEqual(
            Event(
                id: "12345",
                slug: "awakenings"),
            event)
    }

    func testEventTypeDeeplink() {

        var eventType = EventType()

        XCTAssertNoThrow(try eventTypeDeeplink
            .parse("https://ticketswap.com/event/awakenings/regular/123/456", into: &eventType))

        XCTAssertEqual(
            EventType(
                id: "456",
                slug: "regular",
                event: .init(
                    id: "123",
                    slug: "awakenings")),
            eventType)
    }

    func testSearchDeeplink() {

        var search = Search()

        XCTAssertNoThrow(try searchDeeplink
            .parse("https://ticketswap.com/search?query=lets%20try", into: &search))

        XCTAssertEqual(
            Search(query: "lets%20try"),
            search)
    }

    func testWantedEventDeeplink() {

        var wanted = WantedEvent()

        XCTAssertNoThrow(try wantedEventDeeplink
            .parse("https://ticketswap.com/wanted/1234", into: &wanted))

        XCTAssertEqual(
            WantedEvent(id: "1234"),
            wanted)
    }
}

