//
//  AnyDeeplink.swift
//  
//
//  Created by Tiziano Coroneo on 29/02/2020.
//

import Foundation

/// Type-erased version of `Deeplink`. Used to keep a list of `Deeplink`s in the `DeeplinkCenter` where every element of the list might have different type parameters.
struct AnyDeeplink {
    private let parseURLIntoInstance: (URL) throws -> Bool

    /// Designated initializer.
    ///
    /// - Parameters:
    ///   - deeplink: The `Deeplink` template to type-erase.
    ///   - assigningTo: The value to which the content of the `URL` arguments will be assigned to.
    ///   - completion: The completion handler to invoke if the `URL` passed to the `parse(_ url:)` function matches the deeplink template.
    init<Value>(
        deeplink: Deeplink<Value>,
        assigningTo instance: Value,
        ifMatching completion: @escaping (URL, Value) -> Bool
    ) {
        self.parseURLIntoInstance = { url in
            var newInstance = instance
            try deeplink.parse(url, into: &newInstance)
            return completion(url, newInstance)
        }
    }
}

extension AnyDeeplink {

    /// Attempts to parse the argument `url` using the `deeplink` previously passed to the initializer.
    /// If the pattern is recognized successfully, the arguments of the template will get assigned to the `assigningTo` parameter, which will be then forwarded to the `ifMatching` closure, together with the matching `url`.
    /// - Parameter url: The `URL` to match.
    func parse(
        _ url: URL
    ) throws -> Bool {
        try self.parseURLIntoInstance(url)
    }
}
