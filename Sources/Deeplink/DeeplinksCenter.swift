//
//  DeeplinksCenter.swift
//  
//
//  Created by Tiziano Coroneo on 29/02/2020.
//

import Foundation

/// Object that manages a list of deeplinks, in order to find the first one that matches a specific `URL` and run an associated closure when a match is found.
public class DeeplinksCenter {

    // MARK: - Properties

    /// List of deeplinks to try when parsing a `URL`. Order matters!
    private var deeplinks: [AnyDeeplink]

    // MARK: - Initializer

    /// Public initializer that makes an empty center. Use the `register` functions to add your deeplinks.
    public convenience init() {
        self.init(deeplinks: [])
    }

    /**
     Initializer that takes a DeeplinkBuilder closure.

     Example:
     ```swift
     let link1 = "/test/1" as Deeplink<Void>
     let link2 = try "/test/\(\.arg1)/\(\.arg2)" as Deeplink<TestData>
     let link3 = try "/test2/\(\.arg1)/\(\.arg2)" as Deeplink<TestData2>

     let center = DeeplinksCenter {

     link1 { url in
     // Do something
     return true
     }

     link2 { url, value in
     // Do something
     return true
     }

     link3(
     assigningTo: .init(arg1: "default", arg2: "default")
     ) { (url, value) -> Bool in
     // Do something
     return true
     }
     }
     ```
     - Parameter builder: Closure that builds a list of deeplinks using `DeeplinkBuilder`.
     **/
    public convenience init(
        @DeeplinkBuilder _ builder: () -> [AnyDeeplink]
    ) {
        self.init(deeplinks: builder())
    }

    required init(deeplinks: [AnyDeeplink]) {
        self.deeplinks = deeplinks
    }
    // MARK: - Registration methods

    /// Function to use to add a deeplink to be recognized when parsing a `URL`.
    /// The order in which you add deeplinks to the center matters, since the first deeplink in the list to successfully match a URL will stop the pattern matching.
    /// This is the version for interpolated deeplinks: deeplinks that contain one or more arguments. The other version is `register(deeplink: ifMatching:)` for literal deeplinks.
    ///
    /// Example:
    /// ```swift
    /// let center = DeeplinksCenter()
    ///
    /// center
    ///
    /// // Registering this format will cover everything that matches "/sell/*" (excluding the reserved URL characters; see `URLPatternMatcher`).
    /// .register(
    ///     deeplink: try! "/sell/\(\.name)",
    ///     assigningTo: event,
    ///     ifMatching: { url, assignedTicket in
    ///          print("matched /sell")
    ///          return true
    /// })
    ///
    /// // This format will not match any URL, as the previous one overlaps its format and matches first. If you swap them, and register this pattern first, it will work just fine.
    /// // Another possibility is to return `false` in the `ifMatching` closure above: this will tell the `DeeplinkCenter` that the matching closure failed, and it will continue to try to parse the remaining registered deeplink templates where it left off.
    /// .register(
    ///     deeplink: try! "/sell/ticket/\(\.id)",
    ///     assigningTo: ticket,
    ///     ifMatching: { url, assignedTicket in
    ///          print("matched /sell/ticket")
    ///          return true
    /// })
    /// ```
    ///
    /// - Parameters:
    ///   - deeplink: The `Deeplink<Value>` that defines the format to match.
    ///   - assigningTo: An object that will receive the values extracted from the deeplink.
    ///   - ifMatching: A closure that will be executed when a `URL` matches the format defined by the `deeplink` argument. Return `true` to stop the URL matching and consider the `URL` successfully parsed. Return `false` to "fail" the match, and let the `DeeplinkCenter` try out the next registered `Deeplink` templates.
    @discardableResult
    public func register<Value>(
        deeplink: Deeplink<Value>,
        assigningTo: Value,
        ifMatching completion: @escaping (URL, Value) throws -> Bool
    ) -> DeeplinksCenter {
        let typeErasedDeeplink = AnyDeeplink(
            deeplink: deeplink,
            assigningTo: assigningTo,
            ifMatching: completion)

        self.deeplinks.append(typeErasedDeeplink)

        return self
    }

    /// Function to use to add multiple deeplink templates to be recognized when parsing a `URL`, executing the same closure afterwards.
    ///
    /// The order in which you add deeplinks in the array matches the order in which the deeplinks templates will be evaluated: the first deeplink in the list to successfully match a URL will stop the pattern matching.
    /// This is the version for interpolated deeplinks: deeplinks that contain one or more arguments. The other version is `register(deeplinks: ifMatching:)` for literal deeplinks.
    ///
    /// Example:
    /// ```swift
    /// let center = DeeplinksCenter()
    ///
    /// center
    ///
    /// // Registering this format will cover everything that matches both "/sell/ticket/*" and "/selling/ticket/*" (excluding the reserved URL characters; see `URLPatternMatcher`).
    /// .register(
    ///     deeplinks: [try! "/sell/ticket/\(\.id)", try! "/selling/ticket/\(\.id)"],
    ///     ifMatching: { url in
    ///          print("matched /sell/ticket")
    ///          return true
    /// })
    ///
    /// // This format will not match any URL, as the previous one overlaps its format and matches first. If you swap them, and register this pattern first, it will work just fine.
    /// // Another possibility is to return `false` in the `ifMatching` closure above: this will tell the `DeeplinkCenter` that the matching closure failed, and it will continue to try to parse the remaining registered deeplink templates where it left off.
    /// .register(
    ///     deeplink: [try! "/sell/ticket/test/\(\.id)", try! "/selling/ticket/test/\(\.id)"],
    ///     ifMatching: { url in
    ///          print("matched /sell/ticket/test")
    ///          return true
    /// })
    /// ```
    ///
    /// - Parameters:
    ///   - deeplinks: A list of `Deeplink<Void>`. The `DeeplinkCenter` will attempt to match a `URL` against each of this list's elements, in order. The same `ifMatching` closure will be called, if any of the templates successfully match the `URL`.
    ///   - ifMatching: A closure that will be executed when a `URL` matches one of the formats defined by the `deeplinks` argument. Return `true` to stop the URL matching and consider the `URL` successfully parsed. Return `false` to "fail" the match, and let the `DeeplinkCenter` try out the next template in the `deeplinks` array, or the next registered `Deeplink` templates on the center itself.
    @discardableResult
    public func register<Value>(
        deeplinks: [Deeplink<Value>],
        assigningTo: Value,
        ifMatching completion: @escaping (URL, Value) -> Bool
    ) -> DeeplinksCenter {

        self.deeplinks.append(contentsOf: deeplinks.map {
            AnyDeeplink(
                deeplink: $0,
                assigningTo: assigningTo,
                ifMatching: completion)
        })

        return self
    }

    /// Function to use to add a deeplink to be recognized when parsing a `URL`.
    ///
    /// The order in which you add deeplinks to the center matters, since the first deeplink in the list to successfully match a URL will stop the pattern matching.
    /// This is the version for literal deeplinks: deeplinks that contain no arguments. The other version is `register(deeplink: assigningTo: ifMatching:)` for interpolated deeplinks.
    ///
    /// Example:
    /// ```swift
    /// let center = DeeplinksCenter()
    ///
    /// center
    ///
    /// // Registering this format will cover everything that matches "/sell/ticket/*" (excluding the reserved URL characters; see `URLPatternMatcher`).
    /// .register(
    ///     deeplink: "/sell/ticket",
    ///     ifMatching: { url in
    ///          print("matched /sell/ticket")
    ///          return true
    /// })
    ///
    /// // This format will not match any URL, as the previous one overlaps its format and matches first. If you swap them, and register this pattern first, it will work just fine.
    /// // Another possibility is to return `false` in the `ifMatching` closure above: this will tell the `DeeplinkCenter` that the matching closure failed, and it will continue to try to parse the remaining registered deeplink templates where it left off.
    /// .register(
    ///     deeplink: "/sell/ticket/test",
    ///     ifMatching: { url in
    ///          print("matched /sell/ticket/test")
    ///          return true
    /// })
    /// ```
    ///
    /// - Parameters:
    ///   - deeplink: The `Deeplink<Void>` that defines the literal URL's relative path to match..
    ///   - ifMatching: A closure that will be executed when a `URL` matches the format defined by the `deeplink` argument. Return `true` to stop the URL matching and consider the `URL` successfully parsed. Return `false` to "fail" the match, and let the `DeeplinkCenter` try out the next registered `Deeplink` templates.
    @discardableResult
    public func register(
        deeplink: Deeplink<Void>,
        ifMatching completion: @escaping (URL) -> Bool
    ) -> DeeplinksCenter {
        self.register(
            deeplink: deeplink,
            assigningTo: (),
            ifMatching: { url, _ in completion(url) })
    }

    /// Function to use to add multiple deeplink templates to be recognized when parsing a `URL`, executing the same closure afterwards.
    ///
    /// The order in which you add deeplinks in the array matches the order in which the deeplinks templates will be evaluated: the first deeplink in the list to successfully match a URL will stop the pattern matching.
    /// This is the version for literal deeplinks: deeplinks that contain no arguments. The other version is `register(deeplinks: assigningTo: ifMatching:)` for interpolated deeplinks.
    ///
    /// Example:
    /// ```swift
    /// let center = DeeplinksCenter()
    ///
    /// center
    ///
    /// // Registering this format will cover everything that matches both "/sell/ticket/*" and "/selling/ticket/*" (excluding the reserved URL characters; see `URLPatternMatcher`).
    /// .register(
    ///     deeplinks: ["/sell/ticket", "/selling/ticket"],
    ///     ifMatching: { url in
    ///          print("matched /sell/ticket")
    ///          return true
    /// })
    ///
    /// // This format will not match any URL, as the previous one overlaps its format and matches first. If you swap them, and register this pattern first, it will work just fine.
    /// // Another possibility is to return `false` in the `ifMatching` closure above: this will tell the `DeeplinkCenter` that the matching closure failed, and it will continue to try to parse the remaining registered deeplink templates where it left off.
    /// .register(
    ///     deeplink: ["/sell/ticket/test", "/selling/ticket/test"],
    ///     ifMatching: { url in
    ///          print("matched /sell/ticket/test")
    ///          return true
    /// })
    /// ```
    ///
    /// - Parameters:
    ///   - deeplinks: A list of `Deeplink<Void>`. The `DeeplinkCenter` will attempt to match a `URL` against each of this list's elements, in order. The same `ifMatching` closure will be called, if any of the templates successfully match the `URL`.
    ///   - ifMatching: A closure that will be executed when a `URL` matches one of the formats defined by the `deeplinks` argument. Return `true` to stop the URL matching and consider the `URL` successfully parsed. Return `false` to "fail" the match, and let the `DeeplinkCenter` try out the next template in the `deeplinks` array, or the next registered `Deeplink` templates on the center itself.
    @discardableResult
    public func register(
        deeplinks: [Deeplink<Void>],
        ifMatching completion: @escaping (URL) -> Bool
    ) -> DeeplinksCenter {
        self.register(
            deeplinks: deeplinks,
            assigningTo: (),
            ifMatching: { url, _ in completion(url) })
    }

    // MARK: - Parse method

    /// Attempts to parse the `URL`, walking through the list of registered deeplinks.
    /// If a match is found, the corresponding argument segments will be assigned to the keypaths specified in the deeplink interpolation, and the `ifMatching` closure defined when calling `register:` will be executed.
    /// If no match is found, an error is thrown.
    /// - Parameter url: The `URL` to parse.
    public func parse(
        url: URL
    ) throws {

        var errors: [DeeplinkError] = []
        var successfullyParsed = false

        // Try one deeplink at the time
        for link in deeplinks {
            do {
                // If it matches, set a flag. The implementation of `AnyDeeplink` is executing the associated closure.
                successfullyParsed = try link.parse(url)
                if successfullyParsed { break }

            } catch let error as DeeplinkError {
                // If it doesn't match, keep the error to report it later in case nothing matches.
                errors.append(error)
                continue
            } catch {
                // If the registration closure throws an arbitrary error, pass it along.
                errors.append(.registrationClosureThrownError(underlying: error))
                continue
            }
        }

        // If no link matched the `URL`, throw an error reporting the url and all the reasons why it didn't match any link.
        if !successfullyParsed {
            throw DeeplinkError.noMatchingDeeplinkFound(
                forURL: url,
                errors: errors)
        }
    }
}
