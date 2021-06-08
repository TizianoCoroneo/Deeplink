
// Example link: `https://example.com/product/123`

import Deeplink

struct Product {
    var productId: String?
}

let productDeeplink: Deeplink<Product> = try! "/product/\(\.productId)"

func isMagicOn() -> Bool { true }

let center = DeeplinksCenter()

center
    .register(
        deeplink: productDeeplink,
        assigningTo: Product(),
        ifMatching: { url, value in

        if isMagicOn() {
            // Present the magic product view.
        } else {
            // Present the normal product view.
        }

        return true
    })
