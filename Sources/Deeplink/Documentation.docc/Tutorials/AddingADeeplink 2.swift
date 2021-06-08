
// Example link: `https://example.com/product/123`

import Deeplink

struct Product {
    var productId: String?
}

// The type variable indicates which type do you want to use the keypaths of: using the `Product` type allows us to use the `\.productId` keypath.
let productDeeplink: Deeplink<Product> = try! "/product/\(\.productId)"
