
# 🎣 Deeplink

A microlibrary to parse deeplinks and their arguments using Swift's String interpolation.

<a href="https://github.com/TizianoCoroneo/Deeplink/actions?query=workflow%3ATest"><img alt="GitHub Actions status" src="https://github.com/TizianoCoroneo/Deeplink/workflows/Test/badge.svg?branch=main&event=push"></a> <img src="https://img.shields.io/badge/Swift-5.4-orange.svg" /> <a href="https://swift.org/package-manager"><img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" /></a> <a href="https://twitter.com/TizianoCoroneo"><img src="https://img.shields.io/badge/contact-@TizianoCoroneo-blue.svg?style=flat" alt="Twitter: @TizianoCoroneo" /></a>

### Why are the tests failing?

The main branch is using Swift 5.4 to fix a warning, which requires Xcode 12.5, which requires macOS 11 Big Sur. [GitHub actions do not support Big Sur and Xcode 12.5 yet](https://github.com/actions/virtual-environments/issues/2486).
Use version `0.1.0` if you want a Swift 5.3 version that passes the tests.

At this point I'm actually waiting to move onto Xcode Cloud. I already requested access.

## [What is deeplinking?](https://branch.io/what-is-deep-linking/)

Mobile app's deep links (also known simply as “deep links”) are URLs that point to content inside an app. If you want to share a pair of shoes from Amazon with a friend, you can send a deep link that brings your friend directly to those shoes in the Amazon app. Without a deep link, your friend would have to find the Amazon app on the App Store or Play Store, open the app to the homepage, locate the Search function, and then try to find the same pair of shoes you found.

This package provides the tools to define a specific deeplink template, pattern match a URL with a deeplink template, and to parse the informations contained in the URL into an object. It does the parsing so you don't have to!

## Installing using the Swift Package Manager

The library only supports the Swift Package Manager. 
To install `Deeplink` for use in an app, command line tool or server-side application, add Deeplink as a dependency to your `Package.swift` file. For more information, please see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

If you use Xcode 12, use version `.upToNextMinor(from: "0.1.0")`. 

```swift
.package(url: "https://github.com/TizianoCoroneo/Deeplink", .upToNextMinor(from: "0.1.0"))
```

If you use Xcode 13, you can use `.upToNextMinor(from: "0.2.0")`.
```swift
.package(url: "https://github.com/TizianoCoroneo/Deeplink", .upToNextMinor(from: "0.2.0"))
```

## Using this library

In addition to the examples below, there is a shiny new `.doccarchive` file in the repo that will let you see Deeplink's documentation and a couple cool tutorials directly in Xcode's documentation window. Just double click the `Deeplink.doccarchive` file to get started (if you have Xcode 13).

### Defining deeplinks

You can start using this library by defining the deeplinks that you expect to receive in your application. You do this by creating templates:

```swift
let mySellDeeplink: Deeplink<Void> = "/sell/ticket"
let myEventDeeplink = "/event/recommended" as Deeplink<Void>
```

Note that the `Deeplink` type has a generic type variable `Value`: if you need to extract data from the received URL, you can define the deeplink using string interpolation to specify which parts of the URL should be assigned to which property of an instance of `Value`.
This will attempt to pattern match the string components of the interpolation (throwing an error if the strings don't match), while assigning the extra parts of the URL to the property specified by keypaths from the argument components.

Example:

```swift
struct TestData {
    var id: String?
    var text: String?
}

let myTestDeeplink: Deeplink<TestData> = try! "/test/\(\.id)/\(\.text)"
```

The interpolation part requires a `WritableKeyPath<Value, String?>` where `Value` is your custom type. The property needs to be of type `String?`, and needs to be a `var` to let the library write the new value into it. 

### Using deeplinks to match/parse URLs

This deeplink template is able to match URLs that look like this:
`https://ticketswap.com/test/123/abc`
`https://ticketswap.com/test/123/abc?some=else`
`https://ticketswap.com/test/123/abc#fragment`
`ticketswap:///test/123/abc#fragment`

And it is able to extract the path components `123` and `abc`, and assign them to the properties `id` and `text` on an instance of `TestData` like this:
```swift

// Define the deeplink
let myTestDeeplink: Deeplink<TestData> = try! "/test/\(\.id)/\(\.text)"

// Example URL
let url = URL(string: "https://ticketswap.com/test/123/abc")!

// Object to write data into
var result = TestData(id: "", text: "")

// Use the deeplink to parse the URL, extracting its data into `result`
try myTestDeeplink.parse(url, into: &result)

// Check result's content
print(result.id) // Will print `123`
print(result.text) // Will print `abc`
```

In the first example we used a `Deeplink<Void>` to show that there is no argument in the deeplink template: these kinds of deeplink can be used if you only need to match a URL that has no variable data in it:
```swift
// Define the deeplink
let myTestDeeplink: Deeplink<TestData> = try! "/test/ticket"

// Example URL
let url = URL(string: "https://ticketswap.com/test/ticket")!

// Use the deeplink to parse the URL. Will throw if the URL relative part doesn't match the deeplink template. 
try myTestDeeplink.parse(url)
```

In case a property in `TestData` goes unused in a Deeplink template, that property will keep its initial value, which is `nil` unless you customized `TestData` init. Otherwise, if an argument is present in the template, but the URL contains no value for it, the property will assume a value of `""`.

### Pattern matching with multiple deeplinks

The typical use-case for a mobile app is to receive a URL through the `AppDelegate` with the method `application(_: open: options:)`, try to recognize which type of link it is (typically by using `URLComponents`), and matching piece by piece while extracting the needed data.

This library lets you take a more declarative approach: just define a list of deeplinks that you need to be able to match, and the corresponding action that you want to take when one is recognized. When a URL is received, every deeplink template will be tried one at the time until the correct one is found, the data is extracted and the corresponding action is triggered:

```swift

// This is the object that holds the list of deeplinks to try.
let center = DeeplinksCenter()

// Data types where to store parsed values
struct Artist: Equatable {
    var id: String?
    var slug: String?
}

struct Location: Equatable {
    var id: String?
    var slug: String?
    var period: String?
}

struct Event: Equatable {
    var id: String?
    var slug: String?
}

// Instances where to put the parsed data
var artist = Artist()
var location = Location()
var event = Event()

// URLs to parse
let artistURL = URL(string: "https://ticketswap.com/artist/metallica/123456")!
let locationURL = URL(string: "https://ticketswap.com/location/amsterdam/1234567/24-06-2019")!
let eventURL = URL(string: "https://ticketswap.com/event/awakenings/123")!

// Deeplink templates
let artistDeeplink = try! "/artist/\(\.slug)/\(\.id)"
    as Deeplink<Artist>

let locationDeeplink = try! "/location/\(\.slug)/\(\.id)/\(\.period)"
    as Deeplink<Location>

let eventDeeplink = try! "/event/\(\.slug)/\(\.id)"
    as Deeplink<Event>

// Registering a deeplink template into the center, using the `artistDeeplink` to parse data into the `artist` var, and run the `ifMatching` closure if the template matches a URL.
center.register(
    deeplink: artistDeeplink,
    assigningTo: artist,
    ifMatching: { url, newArtist in

    // The parsed artist info is available here
    if let id = newArtist.id {
        print(id)
    }
    
    // Indicates that we successfully handled the URL.
    // Returning `false` makes the center evaluate the rest of the list of registered deeplinks.
    return true
})

// Same registration for the location deeplink
.register(
    deeplink: locationDeeplink,
    assigningTo: location,
    ifMatching: { url, newLocation in

    // The parsed location info is available here
    if let id = newLocation.id {
        print(id)
    }
    
    return true
})

// Same registration for the event deeplink
.register(
    deeplink: eventDeeplink,
    assigningTo: event,
    ifMatching: { url, newEvent in

    // The parsed event info is available here
    if let id = newEvent.id {
        print(id)
    }
    
    return true
})

// This will match the artist deeplink, extract the data and print "123456".
try center.parse(url: artistURL)

// This will match the location deeplink, extract the data and print "1234567".
try center.parse(url: locationURL)

// This will match the event deeplink, extract the data and print "123".
try center.parse(url: eventURL)
```

### Result builder

You can take advantage of the shiny new result builders to register your deeplink templates: 
```swift
fileprivate struct TestData: DefaultInitializable {
    var arg1: String?
    var arg2: String?
}

fileprivate struct TestData2 {
    var arg1: String?
    var arg2: String?
}

let link1 = "/test/1" as Deeplink<Void>
let link2 = try "/test/\(\.arg1)/\(\.arg2)" as Deeplink<TestData>
let link3 = try "/test2/\(\.arg1)/\(\.arg2)" as Deeplink<TestData2>

let center = DeeplinksCenter {

    link1 { url in
        XCTAssertEqual(url.absoluteString, "https://apple.com/test/1")
        expectSimpleLink.fulfill()
        return true
    }

    link2 { url, value in
        XCTAssertEqual(url.absoluteString, "https://apple.com/test/a/b")
        XCTAssertEqual(value.arg1, "a")
        XCTAssertEqual(value.arg2, "b")
        expectInitializableDataLink.fulfill()
        return true
    }

    link3(
        assigningTo: .init(arg1: "default", arg2: "default")
    ) { (url, value) -> Bool in
        XCTAssertEqual(url.absoluteString, "https://apple.com/test2/a/b")
        XCTAssertEqual(value.arg1, "a")
        XCTAssertEqual(value.arg2, "b")
        expectDataLink.fulfill()
        return true
    }
}

try center.parse(url: URL(string: "https://apple.com/test/1")!)
try center.parse(url: URL(string: "https://apple.com/test/a/b")!)
try center.parse(url: URL(string: "https://apple.com/test2/a/b")!)
```
