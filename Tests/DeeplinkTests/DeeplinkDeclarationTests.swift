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
    var argList1: [String]?
    var argList2: [String]?
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

    func testDoubleArgumentListError() {
        XCTAssertThrowsError(
            try "/\(\.argList1, separator: ",")#\(\.argList1, separator: ",")" as Deeplink<TestData>,
            "Cannot declare same keypath twice",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.argumentRepeated(
                        argument: \TestData.argList1),
                    deeplinkError)
            })
    }

    func testDoubleArgumentListError_withDifferentSeparator() {
        XCTAssertThrowsError(
            try "/\(\.argList1, separator: ",")#\(\.argList1, separator: "&")" as Deeplink<TestData>,
            "Cannot declare same keypath twice",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.argumentRepeated(
                        argument: \TestData.argList1),
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

    func testConsecutiveArgumentListError_arg_argList() {
        XCTAssertThrowsError(
            try "/\(\.arg1)\(\.argList1, separator: ",")" as Deeplink<TestData>,
            "Cannot declare two keypath consecutively",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.cannotSetTwoArgumentsConsecutively(
                        argument1: \TestData.arg1,
                        argument2: \TestData.argList1),
                    deeplinkError)
            })
    }

    func testConsecutiveArgumentListError_argList_arg() {
        XCTAssertThrowsError(
            try "/\(\.argList1, separator: ",")\(\.arg1)" as Deeplink<TestData>,
            "Cannot declare two keypath consecutively",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.cannotSetTwoArgumentsConsecutively(
                        argument1: \TestData.argList1,
                        argument2: \TestData.arg1),
                    deeplinkError)
            })
    }

    func testConsecutiveArgumentListError_argList_argList() {
        XCTAssertThrowsError(
            try "/\(\.argList1, separator: ",")\(\.argList2, separator: ",")" as Deeplink<TestData>,
            "Cannot declare two keypath consecutively",
            { error in
                guard let deeplinkError = error as? DeeplinkError
                else { XCTFail("Error is of wrong type: \(error)"); return }

                print(deeplinkError.localizedDescription)

                XCTAssertEqual(
                    DeeplinkError.cannotSetTwoArgumentsConsecutively(
                        argument1: \TestData.argList1,
                        argument2: \TestData.argList2),
                    deeplinkError)
            })
    }
}
