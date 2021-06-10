
// Example link: `https://example.com/product/123`

import Deeplink

struct Product {
    var productId: String?
}

let productDeeplink: Deeplink<Product> = try! "/product/\(\.productId)"

let center = DeeplinksCenter()

center
    .register(
        deeplink: productDeeplink,
        assigningTo: Product(),
        ifMatching: { url, value in

        // Present the product view.

        return true
    })
