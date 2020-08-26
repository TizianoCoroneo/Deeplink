//
//  DeeplinkError.swift
//  
//
//  Created by Tiziano Coroneo on 21/02/2020.
//

import Foundation

enum DeeplinkError: LocalizedError, Equatable, Hashable {
    case pathDoesntMatchWithLiteralDeepLink(
        path: String,
        deepLink: String)

    case argumentRepeated(
        argument: AnyKeyPath)

    case cannotSetTwoArgumentsConsecutively(
        argument1: AnyKeyPath,
        argument2: AnyKeyPath)

    case cannotExtractURLComponents(
        url: URL)

    case noMatchingDeeplinkFound(
        forURL: URL,
        errors: [DeeplinkError])

    // MARK: - Description

    var errorDescription: String? {
        switch self {
        case .pathDoesntMatchWithLiteralDeepLink(
            path: let path,
            deepLink: let link):
            return """
            Failed to parse path using literal deeplink.
            URL Path: \(path)
            Current deeplink: \(link)
            """

        case .argumentRepeated(argument: let keypath):
            return """
            Current deeplink declares same keypath more than once.
            Duplicated keypath: \(keypath)
            """

        case .cannotSetTwoArgumentsConsecutively(let arg1, let arg2):
            return """
            Current deeplink declares two arguments next to each other: we need at least one character in the middle to separate them, otherwise it is ambiguous to determine when the first one ends and the second one starts.
            First argument: \(arg1)
            Second argument: \(arg2)
            """

        case .cannotExtractURLComponents(let url):
            return """
            Initialization of URLComponents failed for url:
            \(url)
            """

        case .noMatchingDeeplinkFound(
            forURL: let url,
            errors: let errors):
            return """
            No matching deeplink found for this url.
            URL: \(url)

            List of matching errors:
            \(errors
            .map { $0.localizedDescription }
            .joined(separator: "\n"))
            """
        }
    }
}
