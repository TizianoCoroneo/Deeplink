
// Example link: `https://example.com/items?ids=1,2,3,4`

struct Items {
    var ids: [String]?
}

let itemsDeeplink: Deeplink<Items> = try! "/items?ids=\(\.ids, separator: ",")"
