//
//  DeeplinkError.swift
//  
//
//  Created by Tiziano Coroneo on 21/02/2020.
//

import Foundation

enum DeeplinkError: LocalizedError, Equatable {
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

    case registrationClosureThrownError(
        underlying: Error)

    // MARK: - Equatable

    static func ==(_ l: DeeplinkError, _ r: DeeplinkError) -> Bool {
        switch (l, r) {
        case let (
            .pathDoesntMatchWithLiteralDeepLink(path: lPath, deepLink: lLink),
            .pathDoesntMatchWithLiteralDeepLink(path: rPath, deepLink: rLink)
        ):
            return lPath == rPath && lLink == rLink

        case let (
            .argumentRepeated(argument: lKey),
            .argumentRepeated(argument: rKey)
        ):
            return lKey == rKey

        case let (
            .cannotSetTwoArgumentsConsecutively(argument1: lArg1, argument2: lArg2),
            .cannotSetTwoArgumentsConsecutively(argument1: rArg1, argument2: rArg2)
        ):
            return lArg1 == rArg1 && lArg2 == rArg2

        case let (
            .cannotExtractURLComponents(url: lURL),
            .cannotExtractURLComponents(url: rURL)
        ):
            return lURL == rURL

        case let (
            .noMatchingDeeplinkFound(forURL: lURL, errors: lErrors),
            .noMatchingDeeplinkFound(forURL: rURL, errors: rErrors)
        ):
            return lURL == rURL && lErrors == rErrors

        case let (
            .registrationClosureThrownError(underlying: lError),
            .registrationClosureThrownError(underlying: rError)
        ):
            return type(of: lError) == type(of: rError)

        default: return false
        }
    }

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

        case .registrationClosureThrownError(
            underlying: let error):
            return """
            A registration closure threw an error while evaluating a matched value.
            Thrown error: \(error.localizedDescription)
            """
        }
    }
}
