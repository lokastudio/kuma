//
//  KumaFormInputTests.swift
//  KumaTests
//

import XCTest
import SwiftUI
@testable import Kuma

@MainActor
final class KumaFormInputTests: XCTestCase {

    func testKumaTextFieldInitialization() {
        var text = "initial-value"
        let binding = Binding(get: { text }, set: { text = $0 })

        let field = KumaTextField(
            title: "Host",
            text: binding,
            placeholder: "e.g. 127.0.0.1",
            helpText: "Enter target IP",
            errorMessage: nil
        )

        XCTAssertEqual(field.title, "Host")
        XCTAssertEqual(field.placeholder, "e.g. 127.0.0.1")
        XCTAssertEqual(field.helpText, "Enter target IP")
        XCTAssertNil(field.errorMessage)
        XCTAssertFalse(field.isDisabled)
    }

    func testKumaSecureFieldInitialization() {
        var text = "secret-pass"
        let binding = Binding(get: { text }, set: { text = $0 })

        let field = KumaSecureField(
            title: "Vault Passphrase",
            text: binding,
            placeholder: "e.g. secret-token",
            errorMessage: "Passphrase required"
        )

        XCTAssertEqual(field.title, "Vault Passphrase")
        XCTAssertEqual(field.errorMessage, "Passphrase required")
    }

    func testKumaToggleFieldBinding() {
        var isOn = false
        let binding = Binding(get: { isOn }, set: { isOn = $0 })

        let toggle = KumaToggleField(
            title: "Auto Start",
            isOn: binding,
            description: "Starts services on boot"
        )

        XCTAssertEqual(toggle.title, "Auto Start")
        XCTAssertEqual(toggle.description, "Starts services on boot")
        
        binding.wrappedValue = true
        XCTAssertTrue(isOn)
    }

    func testKumaPickerFieldInitialization() {
        struct PickerOption: Hashable, Identifiable {
            let id: String
            let name: String
        }

        let options = [
            PickerOption(id: "1", name: "Engine 1"),
            PickerOption(id: "2", name: "Engine 2")
        ]
        var selected = options[0]
        let binding = Binding(get: { selected }, set: { selected = $0 })

        let picker = KumaPickerField(
            title: "Engine",
            selection: binding,
            options: options,
            labelProvider: { $0.name }
        )

        XCTAssertEqual(picker.title, "Engine")
        XCTAssertEqual(picker.options.count, 2)
    }
}
