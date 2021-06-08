
// Example link: `https://example.com/product/123`

import Deeplink
import SwiftUI

struct Product {
    var productId: String?
}

let productDeeplink: Deeplink<Product> = try! "/product/\(\.productId)"

let accountDeeplink: Deeplink<Void> = "/account"

let productDetailDeeplink: Deeplink<Product> = try! "/product/\(\.productId)/detail"

let center = DeeplinksCenter()

center
    .register(
        deeplink: productDetailDeeplink,
        assigningTo: Product(),
        ifMatching: { url, value in

        print(value.productId)

        return true
    })

    .register(
        deeplink: accountDeeplink,
        ifMatching: { url in

        return true
    })

    .register(
        deeplink: productDeeplink,
        assigningTo: Product(),
        ifMatching: { url, value in

        print(value.productId)

        return true
    })
