//
//  Deeplink.swift
//
//
//  Created by Tiziano Coroneo on 21/02/2020.
//

import Foundation

// MARK: - Deeplink container

public enum Deeplink<Value>: Equatable, Hashable {
    public typealias StringLiteralType = String

    /// A "literal" deeplink is a simple string: you can have a deeplink with no arguments and still attempt pattern matching it with a URL.
    case literal(String)

    /// An "interpolated" deeplink is a string that also contains string interpolation arguments.
    ///
    /// In our case, the arguments are `WritableKeyPath<T, String>` that will be used to assign their corresponding string argument to that property on the `T` `assigningTo` instance (see ``DeeplinksCenter``).
    case interpolated(DeeplinkInterpolation<Value>)

    // MARK: - Utilities

    /// Returns all the components that makes up this deeplink: in case of a literal deeplink, there will be only one `literal` component corresponding to the whole string; in case of an interpolated deeplink, it will be a list of all the interpolation components (see `DeeplinkInterpolation<Value>` and `DeeplinkInterpolation<Value>.Component`).
    ///
    /// This is mainly used to unify the logic for handling a literal deeplink (matching the string) and the logic for handling an interpolated deeplink (matching string components, and assigning argument components).
    var components: [DeeplinkInterpolation<Value>.Component] {
        switch self {
        case let .literal(value):
            return [ .literal(value) ]
        case let .interpolated(interpolation):
            return interpolation.components
        }
    }

    /// Creates an interpolation pattern from the deeplink components.
    ///
    /// This is mainly used to unify the logic for handling a literal deeplink (matching the string) and the logic for handling an interpolated deeplink (matching string components, and assigning argument components).
    var interpolation: DeeplinkInterpolation<Value> {
        switch self {
        case .literal: return .init(components: self.components)
        case .interpolated(let interpolation): return interpolation
        }
    }
}

// MARK: - ExpressibleByStringLiteral

extension Deeplink: ExpressibleByStringLiteral {
    /// Initialize a deeplink template with a `String` literal. This will simply attempt to pattern match this string with the `URL` passed to the `parse(_:into:)` function.
    public init(
        stringLiteral value: StringLiteralType
    ) {
        self = .literal(value)
    }
}

// MARK: - ExpressibleByStringInterpolation

extension Deeplink: ExpressibleByStringInterpolation {
    /// Initialize a deeplink template with a string interpolation pattern. This will attempt to pattern match the string components of the interpolation, while assigning the extra parts of the URL to the property specified by keypaths from the argument components.
    ///
    /// Example:
    /// the deeplink `"/sell/\(\.ticketId)"` will match these URLs:
    /// `https://ticketswap.com/sell/123`
    /// `https://ticketswap.com/sell/123?some=else`
    /// `https://ticketswap.com/sell/123#fragment`
    /// `ticketswap:///sell/123#fragment`
    ///
    /// But it will not match these URLs:
    /// `https://ticketswap.com/sells/123`
    /// `https://ticketswap.com/some/sell/123`
    /// `https://ticketswap.com/sell?123`
    public init(
        stringInterpolation: DeeplinkInterpolation<Value>
    ) {
        self = .interpolated(stringInterpolation)
    }
}

// MARK: - Parse functions

public extension Deeplink {
    /// Attempt to parse a `URL` by using the current deeplink. In case of success, the argument found by the pattern matching will be assigned to their corresponding keypath to the `instance` object.
    ///
    /// - Parameters:
    ///   - url: the `URL` to parse.
    ///   - into: the `Value` instance we will assign the parameters values to if the URL matches this deeplink template.
    ///
    /// - Throws: a `DeeplinkError` if we cannot parse relative path, query items or fragments from the URL, or if there is no valid match.
    func parse(
        _ url: URL,
        into instance: inout Value
    ) throws {
        try interpolation.parse(url, into: &instance)
    }
}

public extension Deeplink where Value == Void {
    /// Attempt to parse a `URL` by using the current deeplink. This is a utility for literal deeplinks that do not contain any argument, as they don't need an instance to assign values to.
    ///
    /// - Throws: a `DeeplinkError` if we cannot parse relative path, query items or fragments from the URL, or if there is no valid match.
    func parse(
        _ url: URL
    ) throws {
        var void: Void = ()
        try interpolation.parse(url, into: &void)
    }
}

// MARK: - Converting to AnyDeeplink

public extension Deeplink {

    /// Embeds the action to take when matching this deeplink into the deeplink itself, producing a AnyDeeplink instance.
    /// - Parameters:
    ///   - value: Value to assign the content of the deeplink to.
    ///   - completion: Closure to run when the deeplink is matched.
    /// - Returns: A ``Deeplink/AnyDeeplink`` ready to be added to the ``DeeplinksCenter``
    func callAsFunction(
        assigningTo value: Value,
        _ completion: @escaping (URL, Value) throws -> Bool
    ) -> AnyDeeplink {
        AnyDeeplink(
            deeplink: self,
            assigningTo: value,
            ifMatching: completion)
    }
}

public extension Deeplink where Value: DefaultInitializable {
    /// Embeds the action to take when matching this deeplink into the deeplink itself, producing a AnyDeeplink instance.
    /// - Parameters:
    ///   - completion: Closure to run when the deeplink is matched.
    /// - Returns: A ``Deeplink/AnyDeeplink`` ready to be added to the ``Deeplink/DeeplinksCenter``
    func callAsFunction(
        _ completion: @escaping (URL, Value) throws -> Bool
    ) -> AnyDeeplink {
        AnyDeeplink(
            deeplink: self,
            ifMatching: completion)
    }
}

public extension Deeplink where Value == Void {
    /// Embeds the action to take when matching this deeplink into the deeplink itself, producing a AnyDeeplink instance.
    /// - Parameters:
    ///   - completion: Closure to run when the deeplink is matched.
    /// - Returns: A ``Deeplink/AnyDeeplink`` ready to be added to the ``Deeplink/DeeplinksCenter``
    func callAsFunction(
        _ completion: @escaping (URL) throws -> Bool
    ) -> AnyDeeplink {
        AnyDeeplink(
            deeplink: self,
            assigningTo: (),
            ifMatching: { url, _ in
                try completion(url)
            })
    }
}

// MARK: - CustomStringConvertible

extension Deeplink: CustomStringConvertible {
    public var description: String {
        switch self {
        case .literal(let value):
            return "Literal deeplink: \"\(value)\""
        case .interpolated(let interpolation):
            return "Interpolated deeplink: \"\(interpolation)\""
        }
    }
}
