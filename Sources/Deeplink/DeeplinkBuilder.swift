//
//  DeeplinkBuilder.swift
//  
//
//  Created by Tiziano Coroneo on 22/01/2021.
//

import Foundation

/// A `@resultBuilder` that allows you to register deeplink templates using a DSL-like syntax.
///
/// See <doc:Using-a-ResultBuilder> for more information.
@resultBuilder
public struct DeeplinkBuilder {
    // https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md

    /// The type of a partial result, which will be carried through all of the
    /// build methods.
    public typealias Component = [AnyDeeplink]

    /// Required by every result builder to build combined results from
    /// statement blocks.
    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }

    /// If declared, provides contextual type information for statement
    /// expressions to translate them into partial results.
    public static func buildExpression(
        _ anyDeeplink: AnyDeeplink
    ) -> Component {
        [anyDeeplink]
    }

    public static func buildExpression(
        _ anyDeeplink: AnyDeeplink?
    ) -> Component {
        guard let component = anyDeeplink else { return [] }
        return buildExpression(component)
    }

    /// Enables support for `if` statements that do not have an `else`.
    public static func buildOptional(_ component: Component?) -> Component {
        guard let component = component else { return [] }
        return component
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch'
    /// statements by folding conditional results into a single result.
    public static func buildEither(first component: Component) -> Component {
        component
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch'
    /// statements by folding conditional results into a single result.
    public static func buildEither(second component: Component) -> Component {
        component
    }

    // Requires Swift 5.4
    /// Enables support for 'for..in' loops by combining the
    /// results of all iterations into a single result.
    public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap { $0 }
    }

    // Requires Swift 5.4
    /// If declared, this will be called on the partial result of an `if
    /// #available` block to allow the result builder to erase type
    /// information.
    public static func buildLimitedAvailability(_ component: Component) -> Component {
        component
    }
}
