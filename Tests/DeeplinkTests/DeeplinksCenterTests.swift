//
//  File.swift
//  
//
//  Created by Tiziano Coroneo on 03/03/2020.
//

import Foundation
import XCTest
@testable import Deeplink

class DeeplinksCenterTests: XCTestCase {

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

    struct CustomData: Equatable {
        var testData: Int?

        var testDataString: String? {
            get { testData.map { "\($0)" } }
            set { testData = newValue.flatMap(Int.init) }
        }
    }

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

    let literalDeeplink1 = "/test1"
        as Deeplink<Void>

    let literalDeeplink2 = "/test1/test2"
        as Deeplink<Void>

    let literalDeeplink3 = "/test3/test1"
        as Deeplink<Void>

    let literalDeeplink4 = "/test1/test3"
        as Deeplink<Void>

    let customDataDeeplink = try! "/test/\(\.testDataString)"
        as Deeplink<CustomData>

    func testConsecutiveParsing() {

        let artist = Artist()
        let location = Location()
        let event = Event()
        let eventType = EventType()

        let repo = DeeplinksCenter()

        let artistURL: URL = "https://ticketswap.com/artist/metallica/123456"
        let locationURL: URL = "https://ticketswap.com/location/amsterdam/1234567/24-06-2019"
        let eventTypeURL: URL = "https://ticketswap.com/event/awakenings/regular/123/456"
        let eventURL: URL = "https://ticketswap.com/event/awakenings/123"

        let artistExpectation = expectation(description: "Decode artist")
        let locationExpectation = expectation(description: "Decode location")
        let eventExpectation = expectation(description: "Decode event")
        let eventTypeExpectation = expectation(description: "Decode eventType")

        repo
            .register(
                deeplink: artistDeeplink,
                assigningTo: artist,
                ifMatching: { url, newArtist in

                    XCTAssertEqual(artistURL, url)

                    XCTAssertEqual(
                        Artist(
                            id: "123456",
                            slug: "metallica"),
                        newArtist)

                    artistExpectation.fulfill()

                    return true
            })

            .register(
                deeplink: locationDeeplink,
                assigningTo: location,
                ifMatching: { url, newLocation in

                    XCTAssertEqual(locationURL, url)

                    XCTAssertEqual(
                        Location(
                            id: "1234567",
                            slug: "amsterdam",
                            period: "24-06-2019"),
                        newLocation)

                    locationExpectation.fulfill()

                    return true
            })

            // Must be before the eventDeeplink, to avoid ambiguity.
            .register(
                deeplink: eventTypeDeeplink,
                assigningTo: eventType,
                ifMatching: { url, newEventType in

                    XCTAssertEqual(eventTypeURL, url)

                    XCTAssertEqual(
                        EventType(
                            id: "456",
                            slug: "regular",
                            event: Event(
                                id: "123",
                                slug: "awakenings")),
                        newEventType)

                    eventTypeExpectation.fulfill()

                    return true
            })

            .register(
                deeplink: eventDeeplink,
                assigningTo: event,
                ifMatching: { url, newEvent in

                    XCTAssertEqual(eventURL, url)

                    XCTAssertEqual(
                        Event(
                            id: "123",
                            slug: "awakenings"),
                        newEvent)

                    eventExpectation.fulfill()

                    return true
            })

        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/artist/metallica/123456"))

        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/location/amsterdam/1234567/24-06-2019"))

        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/event/awakenings/regular/123/456"))

        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/event/awakenings/123"))

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testConsecutiveParsingForLiteralDeeplinks() {

        let repo = DeeplinksCenter()

        let url1: URL = "https://ticketswap.com/test1"
        let url2: URL = "https://ticketswap.com/test1/test2"
        let url3: URL = "https://ticketswap.com/test3/test1"
        let url4: URL = "https://ticketswap.com/test1/test3"

        let expectation1 = expectation(description: "Decode literalDeeplink1")
        let expectation2 = expectation(description: "Decode literalDeeplink2")
        let expectation3 = expectation(description: "Decode literalDeeplink3")
        let expectation4 = expectation(description: "Decode literalDeeplink4")

        repo
            .register(
                deeplink: literalDeeplink2,
                ifMatching: { url in

                    XCTAssertEqual(url2, url)
                    expectation2.fulfill()
                    return true
            })

            .register(
                deeplink: literalDeeplink3,
                ifMatching: { url in

                    XCTAssertEqual(url3, url)
                    expectation3.fulfill()
                    return true
            })

            .register(
                deeplink: literalDeeplink4,
                ifMatching: { url in

                    XCTAssertEqual(url4, url)
                    expectation4.fulfill()
                    return true
            })

            // Must be registered last to avoid conflict with literalDeeplink 2 and 4
            .register(
                deeplink: literalDeeplink1,
                ifMatching: { url in

                    XCTAssertEqual(url1, url)
                    expectation1.fulfill()
                    return true
            })


        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/test1"))

        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/test1/test2"))

        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/test3/test1"))

        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/test1/test3"))

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testConsecutiveParsingOverlappingFormatsForLiteralDeeplinks() {

        let repo = DeeplinksCenter()

        let url1: URL = "https://ticketswap.com/test1"
        let url2: URL = "https://ticketswap.com/test1/test2"
        let url3: URL = "https://ticketswap.com/test3/test1"
        let url4: URL = "https://ticketswap.com/test1/test3"

        let expectation1 = expectation(description: "Decode literalDeeplink1")
        let expectation2 = expectation(description: "Decode literalDeeplink2")
        let expectation3 = expectation(description: "Decode literalDeeplink3")
        let expectation4 = expectation(description: "Decode literalDeeplink4")

        expectation1.expectedFulfillmentCount = 3
        expectation2.isInverted = true
        expectation4.isInverted = true

        repo
            // Registered first on purpose to verify overlapping behavior
            .register(
                deeplink: literalDeeplink1,
                ifMatching: { url in

                    XCTAssertTrue([url1, url2, url4].contains(url))
                    expectation1.fulfill()
                    return true
            })

            .register(
                deeplink: literalDeeplink2,
                ifMatching: { url in

                    XCTAssertEqual(url2, url)
                    expectation2.fulfill()
                    return true
            })

            .register(
                deeplink: literalDeeplink3,
                ifMatching: { url in

                    XCTAssertEqual(url3, url)
                    expectation3.fulfill()
                    return true
            })

            .register(
                deeplink: literalDeeplink4,
                ifMatching: { url in

                    XCTAssertEqual(url4, url)
                    expectation4.fulfill()
                    return true
            })


        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/test1"))

        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/test1/test2"))

        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/test3/test1"))

        XCTAssertNoThrow(try repo
            .parse(url: "https://ticketswap.com/test1/test3"))

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testMultipleMatchingLiteralFormatsCallSameClosure() {

        let repo = DeeplinksCenter()

        let myAccountDeeplink: Deeplink<Void> = "/myAccount"
        let accountDeeplink: Deeplink<Void> = "/account"
        let moreDeeplink: Deeplink<Void> = "/more"

        let url1: URL = "https://ticketswap.com/myAccount"
        let url2: URL = "https://ticketswap.com/account"
        let url3: URL = "https://ticketswap.com/more"

        let expectation1 = expectation(description: "Match myAccount, account or more")
        let expectation2 = expectation(description: "Should not match myAccount since it is after the synonim registration")

        expectation1.expectedFulfillmentCount = 3
        expectation2.isInverted = true

        repo
            .register(
                deeplinks: [myAccountDeeplink, accountDeeplink, moreDeeplink],
                ifMatching: { url in

                    XCTAssertTrue([url1, url2, url3].contains(url))
                    expectation1.fulfill()
                    return true
            })

            .register(
                deeplink: accountDeeplink,
                ifMatching: { url in

                    expectation2.fulfill()
                    return true
            })

        XCTAssertNoThrow(try repo
            .parse(url: url1))

        XCTAssertNoThrow(try repo
            .parse(url: url2))

        XCTAssertNoThrow(try repo
            .parse(url: url3))

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testMultipleMatchingInterpolatedFormatsCallSameClosure() throws {

        let repo = DeeplinksCenter()

        let myAccountDeeplink: Deeplink<Artist> = try "/myAccount/\(\.id)/\(\.slug)"
        let accountDeeplink: Deeplink<Artist> = try "/account/\(\.id)/\(\.slug)"
        let moreDeeplink: Deeplink<Artist> = try "/more/\(\.slug)/\(\.id)"

        let url1: URL = "https://ticketswap.com/myAccount/123/abc"
        let url2: URL = "https://ticketswap.com/account/123/abc"
        let url3: URL = "https://ticketswap.com/more/abc/123"

        let expectation1 = expectation(description: "Match myAccount, account or more")
        let expectation2 = expectation(description: "Should not match myAccount since it is after the synonim registration")

        expectation1.expectedFulfillmentCount = 3
        expectation2.isInverted = true

        repo
            .register(
                deeplinks: [myAccountDeeplink, accountDeeplink, moreDeeplink],
                assigningTo: Artist(),
                ifMatching: { url, artist in

                    XCTAssertTrue([url1, url2, url3].contains(url))

                    XCTAssertEqual(artist.id, "123")
                    XCTAssertEqual(artist.slug, "abc")

                    expectation1.fulfill()
                    return true
            })

            .register(
                deeplink: accountDeeplink,
                assigningTo: Artist(),
                ifMatching: { url, artist in

                    expectation2.fulfill()
                    return true
            })

        XCTAssertNoThrow(try repo
            .parse(url: url1))

        XCTAssertNoThrow(try repo
            .parse(url: url2))

        XCTAssertNoThrow(try repo
            .parse(url: url3))

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testNoMatchFound() {

        let artist = Artist()
        let location = Location()
        let event = Event()
        let eventType = EventType()

        let center = DeeplinksCenter()

        let artistURL: URL = "https://ticketswap.com/artist/metallica/123456"
        let locationURL: URL = "https://ticketswap.com/location/amsterdam/1234567/24-06-2019"
        let eventTypeURL: URL = "https://ticketswap.com/event/awakenings/regular/123/456"
        let eventURL: URL = "https://ticketswap.com/event/awakenings/123"

        let artistExpectation = expectation(description: "Do not receive an artist")
        artistExpectation.isInverted = true

        let locationExpectation = expectation(description: "Do not receive a location")
        locationExpectation.isInverted = true

        let eventExpectation = expectation(description: "Do not receive an event")
        eventExpectation.isInverted = true

        let eventTypeExpectation = expectation(description: "Do not receive an eventType")
        eventTypeExpectation.isInverted = true

        center
            .register(
                deeplink: artistDeeplink,
                assigningTo: artist,
                ifMatching: { url, newArtist in

                    XCTAssertEqual(artistURL, url)

                    XCTAssertEqual(
                        Artist(
                            id: "123456",
                            slug: "metallica"),
                        newArtist)

                    artistExpectation.fulfill()

                    return true
            })

            .register(
                deeplink: locationDeeplink,
                assigningTo: location,
                ifMatching: { url, newLocation in

                    XCTAssertEqual(locationURL, url)

                    XCTAssertEqual(
                        Location(
                            id: "1234567",
                            slug: "amsterdam",
                            period: "24-06-2019"),
                        newLocation)

                    locationExpectation.fulfill()

                    return true
            })

            .register(
                deeplink: eventTypeDeeplink,
                assigningTo: eventType,
                ifMatching: { url, newEventType in

                    XCTAssertEqual(eventTypeURL, url)

                    XCTAssertEqual(
                        EventType(
                            id: "456",
                            slug: "regular",
                            event: Event(
                                id: "123",
                                slug: "awakenings")),
                        newEventType)

                    eventTypeExpectation.fulfill()

                    return true
            })

            .register(
                deeplink: eventDeeplink,
                assigningTo: event,
                ifMatching: { url, newEvent in

                    XCTAssertEqual(eventURL, url)

                    XCTAssertEqual(
                        Event(
                            id: "123",
                            slug: "awakenings"),
                        newEvent)

                    eventExpectation.fulfill()

                    return true
            })

        XCTAssertThrowsError(
            try center.parse(url: "apple:///test?a=1&b=2"),
            "Expected error",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                    else { XCTFail("Error is of wrong type: \(error)"); return }

                print(error.localizedDescription)

                XCTAssertEqual(
                    .noMatchingDeeplinkFound(
                        forURL: "apple:///test?a=1&b=2",
                        errors: [
                        .pathDoesntMatchWithLiteralDeepLink(
                            path: "/test?a=1&b=2",
                            deepLink: "/artist/"),
                        .pathDoesntMatchWithLiteralDeepLink(
                            path: "/test?a=1&b=2",
                            deepLink: "/location/"),
                        .pathDoesntMatchWithLiteralDeepLink(
                            path: "/test?a=1&b=2",
                            deepLink: "/event/"),
                        .pathDoesntMatchWithLiteralDeepLink(
                            path: "/test?a=1&b=2",
                            deepLink: "/event/"),
                    ]),
                    deeplinkError)
        })

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testMatchingSuccessDoesNotRollToNextMatches() {

        let expectFirstMatch = expectation(description: "/test/me format should match")

        let expectSecondMatch = expectation(description: "/test/me/twice format should NOT match")
        expectSecondMatch.isInverted = true

        let testURL: URL = "https://ticketswap.com/test/me"

        let center = DeeplinksCenter()
            .register(
                deeplink: "/test/me",
                assigningTo: (),
                ifMatching: { url, _ in

                    expectFirstMatch.fulfill()

                    // Consider this URL matched only if it has exactly 3 `pathComponents`.
                    let didMatch = url.pathComponents.count == 3
                    XCTAssertTrue(didMatch)
                    return didMatch
            })

            // Normally this registration would never be triggered, because the format above matches the same strings.
            // When the `ifMatching` closure aboves returns `false`, the ``Deeplink/DeeplinksCenter`` attempts the next formats anyway.
            .register(
                deeplink: "/test/me/twice",
                assigningTo: (),
                ifMatching: { url, _ in

                    expectSecondMatch.fulfill()

                    XCTAssertEqual(url, testURL)

                    return true
            })

        XCTAssertNoThrow(try center.parse(url: testURL))

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testMatchingFailureRollsToNextMatches() {

        let expectFirstMatch = expectation(description: "/test/me format should match")
        let expectSecondMatch = expectation(description: "/test/me/twice format should match")

        let testURL: URL = "https://ticketswap.com/test/me/twice"

        let center = DeeplinksCenter()
            .register(
                deeplink: "/test/me",
                assigningTo: (),
                ifMatching: { url, _ in

                    expectFirstMatch.fulfill()

                    // Consider this URL matched only if it has exactly 3 `pathComponents`.
                    let didMatch = url.pathComponents.count == 3
                    XCTAssertFalse(didMatch)
                    return didMatch
            })

            // Normally this registration would never be triggered, because the format above matches the same strings.
            // When the `ifMatching` closure aboves returns `false`, the ``Deeplink/DeeplinksCenter`` attempts the next formats anyway.
            .register(
                deeplink: "/test/me/twice",
                assigningTo: (),
                ifMatching: { url, _ in

                    expectSecondMatch.fulfill()

                    XCTAssertEqual(url, testURL)

                    return true
            })

        XCTAssertNoThrow(try center.parse(url: testURL))

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testCustomDataParsing() {

        let expectFirstMatch = expectation(description: "/test/123 should match")
        let expectSecondMatch = expectation(description: "/test/abc should match")

        let goodURL: URL = "https://ticketswap.com/test/123"
        let badURL: URL = "https://ticketswap.com/test/abc"

        struct NoIntFoundError: Error {}

        let center = DeeplinksCenter()
            .register(
                deeplink: customDataDeeplink,
                assigningTo: .init(),
                ifMatching: { url, value in

                    if url == goodURL {
                        XCTAssertEqual(123, value.testData)
                        expectFirstMatch.fulfill()
                    } else if url == badURL {
                        XCTAssertNil(value.testData)
                        expectSecondMatch.fulfill()
                        throw NoIntFoundError()
                    }

                    return true
                })

        XCTAssertNoThrow(try center.parse(url: goodURL))
        XCTAssertThrowsError(
            try center.parse(url: badURL),
            "Should throw \"No matching deeplink\" because we're returning false in the registration closure.",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.noMatchingDeeplinkFound(
                        forURL: badURL,
                        errors: [
                            .registrationClosureThrownError(
                                underlying: NoIntFoundError())
                        ]),
                    deeplinkError)
            })

        waitForExpectations(timeout: 0.1, handler: nil)

    }
}
