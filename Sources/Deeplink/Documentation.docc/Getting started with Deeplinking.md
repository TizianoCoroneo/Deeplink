# Getting started with Deeplinking

From 0 to `/hero`.

## Overview

### What is deeplinking?

[Mobile apps' deep links](https://branch.io/what-is-deep-linking/) are URLs that point to the content inside an app. If you want to share a pair of shoes from Amazon with a friend, you can send a deep link that brings your friend directly to those shoes in the Amazon app.
Without a deep link, your friend would have to find the Amazon app on the App Store or Play Store, open the app to the homepage, locate the Search function, and then try to find the same pair of shoes you found.

This package provides the tools to define a specific deeplink template, pattern match a URL with a deeplink template, and parse the information contained in the URL into an object. 

It does the parsing so you don't have to!

### Using this library

Follow the shiny new DocC tutorial: <doc:Tutorial-Table-of-Contents>!

### Installing

The library only supports the Swift Package Manager. 
To install `Deeplink` for use in an app, command-line tool, or server-side application, add Deeplink as a dependency to your `Package.swift` file. For more information, please see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

```swift
.package(url: "https://github.com/TizianoCoroneo/Deeplink", from: "0.1.0")
```
