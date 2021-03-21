//
//  DeeplinkDeclarationTests.swift
//  
//
//  Created by Tiziano Coroneo on 29/02/2020.
//

import Foundation
import XCTest
@testable import Deeplink

fileprivate struct TestData {
    var arg1: String?
    var arg2: String?
}

class DeeplinkDeclarationTests: XCTestCase {

    func testDoubleArgumentError() {
        XCTAssertThrowsError(
            try "/\(\.arg1)#\(\.arg1)" as Deeplink<TestData>,
            "Cannot declare same keypath twice",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                    else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.argumentRepeated(
                        argument: \TestData.arg1),
                    deeplinkError)
        })
    }

    func testConsecutiveArgumentError() {
        XCTAssertThrowsError(
            try "/\(\.arg1)\(\.arg2)" as Deeplink<TestData>,
            "Cannot declare two keypath consecutively",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                    else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.cannotSetTwoArgumentsConsecutively(
                        argument1: \TestData.arg1,
                        argument2: \TestData.arg2),
                    deeplinkError)
        })
    }
}
