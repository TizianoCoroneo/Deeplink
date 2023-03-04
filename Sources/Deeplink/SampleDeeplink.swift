
import Foundation

public struct SampleDeeplink<Value> {
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
    func testSampleDeeplink<Value>(
        _ sample: SampleDeeplink<Value>
    ) throws {
        guard let anyDeeplinkIndex = self.deeplinks
                .firstIndex(where: { $0.description == sample.deeplinkTemplate.description })
        else { throw DeeplinkError.noMatchingDeeplinkFound(forURL: sample.urlToParse, errors: []) }

        self.deeplinks[anyDeeplinkIndex].injectSample(sample)

        try self.parse(url: sample.urlToParse)
    }
}
