//
//  AnyDeeplink.swift
//  
//
//  Created by Tiziano Coroneo on 29/02/2020.
//

import Foundation

/// Type-erased version of ``Deeplink/Deeplink``. Used to keep a list of Deeplinks in the ``Deeplink/DeeplinksCenter`` where every element of the list might have different type parameters.
public struct AnyDeeplink: CustomStringConvertible {
    var parseURLIntoInstance: (URL) throws -> Bool
    public let description: String

    /// Designated initializer.
    ///
    /// - Parameters:
    ///   - deeplink: The ``Deeplink/Deeplink`` template to type-erase.
    ///   - assigningTo: The value to which the content of the `URL` arguments will be assigned to.
    ///   - completion: The completion handler to invoke if the `URL` passed to the `parse(_ url:)` function matches the deeplink template.
    init<Value>(
        deeplink: Deeplink<Value>,
        assigningTo instance: Value,
        ifMatching completion: @escaping (URL, Value) throws -> Bool
    ) {
        self.parseURLIntoInstance = { url in
            var newInstance = instance
            try deeplink.parse(url, into: &newInstance)
            return try completion(url, newInstance)
        }

        self.description = deeplink.description
    }

    /// Initializer that assigns the deeplink values to a fresh new instance of `Value`.
    ///
    /// - Parameters:
    ///   - deeplink: The ``Deeplink/Deeplink`` template to type-erase.
    ///   - completion: The completion handler to invoke if the `URL` passed to the `parse(_ url:)` function matches the deeplink template.
    init<Value>(
        deeplink: Deeplink<Value>,
        ifMatching completion: @escaping (URL, Value) throws -> Bool
    )
    where Value: DefaultInitializable
    {
        self.init(
            deeplink: deeplink,
            assigningTo: .init(),
            ifMatching: completion)
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
