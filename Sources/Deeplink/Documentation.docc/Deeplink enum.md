# ``Deeplink/Deeplink``

An `enum` that represents a deeplink template.

## Overview

You can define one of these and use it to check if a URL matches the same pattern, and extract some information from it.

```swift
struct Product {
    var productId: String?
}

let productDeeplink: Deeplink<Product> = try! "/product/\(\.productId)"

var productInfo = Product()
productDeeplink.parse(url: someURL, into: &productInfo)

print(productInfo.productId ?? "nil")
```

A Deeplink can be or a literal deeplink with no parameters or an interpolated deeplink, where there are one or more parameters each represented by a `KeyPath`.

```swift
let productDeeplink: Deeplink<Product> = try! "/product/\(\.productId)"
let accountDeeplink: Deeplink<Void> = "/account"
```

The string interpolation initializer `throws` because there are a couple cases that cannot be handled via Deeplink templates yet:
* We cannot define a template with two consecutive parameters because we don't know when the first parameter needs to end and where the second one starts.
* We cannot define a template that uses the same keypath twice or more in the same template. No technical reason, I just thought that this would be result of a mistake in most cases, and I'd prefer to catch it early.

```swift
let badDeeplink1: Deeplink<Product> = try! "/product/\(\.productId)\(\.name)"
let badDeeplink2: Deeplink<Product> = try! "/product/\(\.productId)\(\.productId)"
```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
