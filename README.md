# 🎣 Deeplink

A microlibrary to parse deeplinks and their arguments using String interpolation.

## [What is deeplinking?](https://branch.io/what-is-deep-linking/)

Mobile app deep links (also known simply as “deep links”) point to content inside an app. If you want to share a pair of shoes from the Jet with a friend, you can send a deep link that brings your friend directly to those shoes in the app. Without a deep link, your friend would have to find the Jet app on the App Store or Play Store, open the app to the homepage, locate the Search function, and then try to find the same pair of shoes you did.

This package provides the tools to define a specific deeplink template, pattern match a URL with a deeplink template, and to parse the informations contained in the URL into an object. It does the parsing so you don't have to!

## Using this library

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
    var id: String
    var text: String
}

let myTestDeeplink: Deeplink<TestData> = try! "/test/\(\.id)/\(.text)"
```

The interpolation part requires a `WritableKeyPath<Value, String>` where `Value` is your custom type. The property needs to be of type `String`, and needs to be a `var` to let the library write the new value into it. 

### Using deeplinks to match/parse URLs

This deeplink template is able to match URLs that look like this:
`https://ticketswap.com/test/123/abc`
`https://ticketswap.com/test/123/abc?some=else`
`https://ticketswap.com/test/123/abc#fragment`
`ticketswap:///test/123/abc#fragment`

And it is able to extract the path components `123` and `abc`, and assign them to the properties `id` and `text` on an instance of `TestData` like this:
```swift

// Define the deeplink
let myTestDeeplink: Deeplink<TestData> = try! "/test/\(\.id)/\(.text)"

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

### Pattern matching with multiple deeplinks

The typical use-case for a mobile app is to receive a URL through the `AppDelegate` with the method `application(_: open: options:)`, try to recognize which type of link it is (typically by using `URLComponents`), and matching piece by piece while extracting the needed data.

This library lets you take a more declarative approach: just define a list of deeplinks that you need to be able to match, and the corresponding action that you want to take when one is recognized. When a URL is received, every deeplink template will be tried one at the time until the correct one is found, the data is extracted and the corresponding action is triggered:

```swift

// This is the object that holds the list of deeplinks to try.
let center = DeeplinksCenter()

// Instances where to put the parsed data
var artist = Artist()
var location = Location()
var event = Event()

// URLs to parse
let artistURL = URL(string: "https://ticketswap.com/artist/metallica/123456")!
let locationURL = URL(string: "https://ticketswap.com/location/amsterdam/1234567/24-06-2019")!
let eventURL = URL(string: "https://ticketswap.com/event/awakenings/123")!

// Registering a deeplink template into the center, using the `artistDeeplink` to parse data into the `artist` var, and run the `ifMatching` closure if the template matches a URL.
center.register(
    deeplink: artistDeeplink,
    assigningTo: artist,
    ifMatching: { url, newArtist in

    // The parsed artist info is available here
    print("1")
})

// Same registration for the location deeplink
.register(
    deeplink: locationDeeplink,
    assigningTo: location,
    ifMatching: { url, newLocation in

    // The parsed location info is available here
    print("2")
})

// Same registration for the event deeplink
.register(
    deeplink: eventDeeplink,
    assigningTo: event,
    ifMatching: { url, newEvent in

    // The parsed event info is available here
    print("3")
})

// This will match the artist deeplink, extract the data and print "1".
try center.parse(url: artistURL)

// This will match the location deeplink, extract the data and print "2".
try center.parse(url: locationURL)

// This will match the event deeplink, extract the data and print "3".
try center.parse(url: eventURL)
```
