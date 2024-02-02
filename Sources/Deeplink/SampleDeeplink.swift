
import Foundation

/// You can use a ``SampleDeeplink`` to create unit tests that verify that the order of registrations of deeplinks in your ``DeeplinksCenter`` is sound, and no template stops another from being detected.
///
/// When you register deeplink templates in your ``DeeplinksCenter`` you need to check that no other template matches your new deeplink before it. This is because the registered deeplinks are evaluated in order of registration, and the first one that matches stops the process. Checking manually is very difficult once you have a substantial number of deeplink registrations.
/// An example is the following:
/// ```swift
/// let templateA = "/test/a" as Deeplink<Void>
/// let templateB = "/test/a/b" as Deeplink<Void>
/// ```
/// If these two links are registered in the order `A, B` in your `DeeplinkCenter`, then the pattern for `A` will always match links that more closely resemble `templateB`.
/// ``SampleDeeplink`` lets you write unit tests to verify that no one of your previous deeplinks are overridden by any new deeplink you're adding. You can write a unit test to verify a deeplink like this:
/// ```swift
/// func testMyDeeplink() throws {
///     let sample = SampleDeeplink(
///         deeplinkTemplate: "/my-deeplink/\(\.id)/hello" as Deeplink<MyData>,
///         urlToParse: "https://apple.com/my-deeplink/123/hello",
///         assigningToInstance: .init(),
///         expectation: { self.expectation(description: "Should call completion").fulfill() },
///         assertions: {
///             XCTAssertEqual($0.id, "123")
///         }
///     )
///
///     try deeplinkCenter.testSampleDeeplink(sample)
///
///     waitForExpectations(timeout: 0.1, handler: nil)
/// }
/// ```
///
/// This test will try to pass the provided `urlToParse` to your ``DeeplinksCenter`` instance, it will expect the registration corresponding to your template to be successfully executed, and it provides a closure where you can assert that the parameters were parsed correctly.
///
/// It is best to always write one unit test using ``SampleDeeplink`` for each of your registration.
public struct SampleDeeplink<Value> {

    /// Create a new ``SampleDeeplink`` to be tested within your ``DeeplinksCenter`` using the ``DeeplinksCenter/testSampleDeeplink(_:)`` method.
    /// - Parameters:
    ///   - deeplinkTemplate: The deeplink template that you want to test. It is recommended to pass the exact same template instance that you use in your `DeeplinkCenter` to avoid having to manually keep them in sync.
    ///   - urlToParse: The test URL that you want to use for testing.
    ///   - assigningToInstance: The instance of the object to which assign the values of the parsed parameters.
    ///   - expectation: A closure where you should declare an expectation to fulfill, using `XCTestCase.expectation(description:)`.
    ///   - assertions: A closure that you can use to verify the correctness of the parsed parameters.
    public init(
        deeplinkTemplate: Deeplink<Value>,
        urlToParse: URL,
        assigningToInstance: Value,
        expectation: @escaping () -> Void,
        assertions: @escaping (Value) -> Void
    ) {
        self.deeplinkTemplate = deeplinkTemplate
        self.urlToParse = urlToParse
        self.assigningToInstance = assigningToInstance
        self.expectation = expectation
        self.assertions = assertions
    }

    let deeplinkTemplate: Deeplink<Value>
    let urlToParse: URL
    let assigningToInstance: Value
    let expectation: () -> Void
    let assertions: (Value) -> Void
}

public extension SampleDeeplink where Value == Void {
    /// Create a new ``SampleDeeplink`` to be tested within your ``DeeplinksCenter`` using the ``DeeplinksCenter/testSampleDeeplink(_:)`` method.
    /// - Parameters:
    ///   - deeplinkTemplate: The deeplink template that you want to test. It is recommended to pass the exact same template instance that you use in your `DeeplinkCenter` to avoid having to manually keep them in sync.
    ///   - urlToParse: The test URL that you want to use for testing.
    ///   - expectation: A closure where you should declare an expectation to fulfill, using `XCTestCase.expectation(description:)`.
    init(
        deeplinkTemplate: Deeplink<Value>,
        urlToParse: URL,
        expectation: @escaping () -> Void
    ) {
        self.init(
            deeplinkTemplate: deeplinkTemplate,
            urlToParse: urlToParse,
            assigningToInstance: (),
            expectation: expectation,
            assertions: { _ in })
    }
}

fileprivate extension AnyDeeplink {
    mutating func injectSample<Value>(
        _ sample: SampleDeeplink<Value>
    ) {
        self.parseURLIntoInstance = { [] url in
            var newInstance = sample.assigningToInstance
            try sample.deeplinkTemplate.parse(url, into: &newInstance)
            sample.expectation()
            sample.assertions(newInstance)
            return true
        }
    }
}

public extension DeeplinksCenter {

    /// Pass a ``SampleDeeplink`` instance to this function to perform a deeplink registration unit test.
    ///
    /// See ``SampleDeeplink`` for more information.
    /// - Parameter sample: The ``SampleDeeplink`` to test.
    @MainActor func testSampleDeeplink<Value>(
        _ sample: SampleDeeplink<Value>
    ) throws {
        guard let anyDeeplinkIndex = self.deeplinks
                .firstIndex(where: { $0.description == sample.deeplinkTemplate.description })
        else { throw DeeplinkError.noMatchingDeeplinkFound(forURL: sample.urlToParse, errors: []) }

        self.deeplinks[anyDeeplinkIndex].injectSample(sample)

        try self.parse(url: sample.urlToParse)
    }
}
