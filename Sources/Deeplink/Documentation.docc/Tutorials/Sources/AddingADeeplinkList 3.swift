
// Example link: `https://example.com/items?ids=1,2,3,4`

struct Items {
    var ids: [String]?
}

let itemsDeeplink: Deeplink<Items> = try! "/items?ids=\(\.ids, separator: ",")"

let center = DeeplinksCenter()

center.register(
    deeplink: itemsDeeplink,
    assigningTo: Items(), // When the template matches the input URL, the values extracted will be assigned to the object passed in this property.
    ifMatching: { url, value in

        // We can do what we need here with a ready `Items` value, parsed from the received deeplink URL if it is parsed successfully.
        print("Items: \(value.items!.joined(separator: "-"))")

        // We return `true` to indicate that we handled the deeplink successfully.
        return true
    })

let url = URL(string: "https://example.com/items?ids=1,2,3,4")!
try! center.parse(url: url)

// This will run the closure that we registered for the `itemsDeeplink` template since the format matches, and it will print `Items: 1-2-3-4`.
