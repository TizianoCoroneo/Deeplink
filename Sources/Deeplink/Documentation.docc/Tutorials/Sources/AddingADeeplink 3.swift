
// Example link: `https://example.com/product/123`

import Deeplink

struct Product {
    var productId: String?
}

// The type variable indicates which type do you want to use the keypaths of: using the `Product` type allows us to use the `\.productId` keypath.
let productDeeplink: Deeplink<Product> = try! "/product/\(\.productId)"

let center = DeeplinksCenter()

center.register(
    deeplink: productDeeplink,
    assigningTo: Product(), // When the template matches the input URL, the values extracted will be assigned to the object passed in this property.
    ifMatching: { url, value in

    // We can do what we need here with a ready `Product` value, parsed from the received deeplink URL if it is parsed successfully.
    print("ProductId: \(value.productId)")

    // We return `true` to indicate that we handled the deeplink successfully.
    return true
})
