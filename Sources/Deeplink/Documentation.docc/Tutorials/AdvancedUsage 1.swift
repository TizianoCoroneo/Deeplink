
// Example link: `https://example.com/product/123`

import Deeplink

struct Product {
    var productId: String?
}

let productDeeplink: Deeplink<Product> = try! "/product/\(\.productId)"

func isMagicOn() -> Bool { true }
