//
//  URLPatternMatcher.swift
//  
//
//  Created by Tiziano Coroneo on 28/02/2020.
//

import Foundation

/// A utility structure to extract the relative part of a `URL`, and to contain the pattern matching logic.
struct URLPatternMatcher: Equatable, Hashable {

    // MARK: - Properties

    /// The relative part of the `URL`.
    ///
    /// Example: for the url `"https://apple.com/test?query=some#fragment"`, the relative path is `/test?query=some#fragment`, including query items (`?query=some`) and URL fragments (`#fragment`).
    let relativeString: String

    /// List of "reserved" characters in `URL`s: there are characters used to split different parts of a url as defined in `RFC 3986`.
    private let reservedURLCharacters: String = ":/?#[]@!$&'()*+,;="

    // MARK: - Initializer

    /// Initialize a `URLPatternMatcher` directly with the relative part of a `URL`. Used only in tests.
    /// - Parameter relativeString: The relative part of a `URL`, including query items and fragments. Basically everything except user, scheme and host `URL` components.
    init(
        relativeString: String
    ) {
        self.relativeString = relativeString
    }

    /// Initialize a `URLPatternMatcher` with a `URL`, stripping away user, scheme and host `URL` components to only get the relative part of it.
    init(
        url: URL
    ) throws {
        guard
            let relativeString = url.relativePathWithQueryItemsAndFragments
            else { throw DeeplinkError.cannotExtractURLComponents(url: url) }

        self.init(
            relativeString: relativeString)
    }

    // MARK: - Methods

    /// This function does the real heavy lifting: it breaks down the `relativeString` data in this instance of the pattern match to extract a single string for every `.argument` component in the deeplink's component list.
    ///
    /// Example:
    /// ```swift
    /// struct Event {
    ///    var name: String?
    ///    var id: String?
    /// }
    ///
    /// let deeplink: Deeplink<Event> = "/sell/\(\.name)/regular/\(\.id)"
    /// let url = URL(string: "https://ticketswap.com/sell/party/regular/123")!
    ///
    /// let patternMatcher = URLPatternMatcher(url: url) // Will extract the relative path: "/sell/party/regular/123"
    ///
    /// patternMatcher.findArgumentsSegments(forComponents: deeplink.components)
    /// // Will walk through the list of components, checking if the literal components match the relativeString, and extracting the keypaths.
    /// // First, it will split the relative path based on the literal components.
    /// // `deeplink` has two literals: "/sell/" and "/regular/".
    ///
    /// let argumentSegments = try splitRelativeStringWith(
    ///     literals: ["/sell/", "/regular/"],
    ///     relativeString: "/sell/party/regular/123")
    ///
    /// // `splitRelativeStringWith` will first split by "/sell/", resulting in this:
    /// [ "", "party/regular/123" ]
    /// // and then will split the last (remaining part of the) string by "/regular/", resulting in this:
    /// [ "", "party", "123" ]
    /// // Which kinda look like the arguments we want to extract from the URL.
    /// // This function contains extra logic to make sure we strip additional URL components from the last element of this array:
    /// [ "", "party", "123?query=some"] // The query item part will be removed.
    /// // And it also makes sure that the first element is empty. If not, we have some extra prefix before the patter we're looking for, and it will throw an error:
    /// "/some/sell/party/regular/123" // split by "/sell/" results in:
    /// [ "/some", "party/regular/123" ]
    ///
    /// // Once all the literals are split, the remaining segments are what should be assigned to the `argument` components' keypaths, in order.
    /// ```
    ///
    /// - Parameter components: List of deeplink components to match.
    func findArgumentsSegments<Value>(
        forComponents components: [DeeplinkInterpolation<Value>.Component]
    ) throws -> [String] {

        // Grab all the deeplink components that are literals.
        let literals = components
            .compactMap { $0.literalPath }

        // Split the relative part of the URL to parse using the list of literals, one at the time:
        // The string `1234567890` split with the literals `["2", "6"]` would return `["1", "345", "7890"]`.
        var segments: [String] = try splitRelativeStringWith(
            literals: literals,
            relativeString: relativeString)

        // If argument segments are found, perform extra checks.
        if !segments.isEmpty {

            // Remove from the last one all characters found after the first occurrence of one of the "reserved" characters.
            segments[segments.count - 1] = segments[segments.count - 1]
                .removeAfterAnyCharacterIn(string: reservedURLCharacters)

            // If the first segment is empty, it means that the first literal component was at the beginning of the URL to parse. Remove it.
            if segments[0].isEmpty {
                segments.removeFirst()

            } else {
                // Otherwise there is an extra prefix before the match with the first literal.
                // Throw non-matching paths error.
                throw DeeplinkError.pathDoesntMatchWithLiteralDeepLink(
                    path: segments[0],
                    deepLink: DeeplinkInterpolation(components: components).description)
            }
        }

        // If we found more segments than arguments, remove the extra segments.
        // This is needed in case we have an argument component that evaluates to an empty string, to avoid assigning an "out of bounds" value to it.
        // Just comment the next three lines and run the tests to see what I mean.
        let arguments = components.compactMap { $0.argumentPath }
        if segments.count > arguments.count {
            segments.removeLast(segments.count - arguments.count)
        }

        return segments
    }

    /// Use the relative path information in this `URLPatternMatcher` to extract the strings to be assigned to the interpolation keypaths.
    /// - Parameters:
    ///   - components: List of deeplink components to match.
    ///   - instance: Instance to assign extraceted values to.
    func match<Value>(
        components: [DeeplinkInterpolation<Value>.Component],
        into instance: inout Value
    ) throws {

        // Grab all the keypaths in the interpolation pattern
        let keypaths = components
            .compactMap { $0.argumentPath }

        // Grab all the argument segments from the `relativeString`.
        let segments = try findArgumentsSegments(forComponents: components)

        // For each keypath, assign its corresponding value to the `instance` object.
        zip(keypaths, segments).forEach {
            let (keyPath, segment) = $0
            instance[keyPath: keyPath] = segment
        }
    }

    // MARK: - Utilities

    /// Split the relative part of the URL to parse using the list of literals, one at the time:
    /// The string `1234567890` split with the literals `["2", "6"]` would return `["1", "345", "7890"]`.
    private func splitRelativeStringWith(
        literals: [String],
        relativeString: String
    ) throws -> [String] {
        try literals
            .reduce(into: [relativeString], { acc, x in
                let restOfTheString = acc.last!

                guard
                    !restOfTheString.isEmpty,
                    restOfTheString.contains(x)
                    else {
                        throw DeeplinkError.pathDoesntMatchWithLiteralDeepLink(
                            path: restOfTheString,
                            deepLink: x)
                }

                acc.removeLast()

                acc.append(contentsOf: restOfTheString.splitFirstOccurrence(of: x))
            })
    }
}
