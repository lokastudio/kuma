//
//  AppStoreTests.swift
//  KumaTests
//

import XCTest
@testable import Kuma

@MainActor
final class AppStoreTests: XCTestCase {

    func testInitialPhaseIsSplash() {
        let store = AppStore()
        XCTAssertEqual(store.appPhase, .splash)
        XCTAssertNil(store.activeToast)
        XCTAssertFalse(store.isInspectorPresented)
        XCTAssertNil(store.selectedServiceId)
    }

    func testPhaseTransitions() {
        let store = AppStore()

        store.transitionToPhase(.onboarding(step: 1))
        XCTAssertEqual(store.appPhase, .onboarding(step: 1))

        store.transitionToPhase(.mainDeck)
        XCTAssertEqual(store.appPhase, .mainDeck)
    }

    func testToastManagement() {
        let store = AppStore()
        let toast = KumaToastNotification(title: "Connected", style: .success)

        store.showToast(toast)
        XCTAssertEqual(store.activeToast?.title, "Connected")
        XCTAssertEqual(store.activeToast?.style, .success)

        store.dismissToast()
        XCTAssertNil(store.activeToast)
    }

    func testInspectorSelection() {
        let store = AppStore()
        let serviceId = UUID()

        store.selectServiceForInspector(serviceId)
        XCTAssertTrue(store.isInspectorPresented)
        XCTAssertEqual(store.selectedServiceId, serviceId)

        store.selectServiceForInspector(nil)
        XCTAssertFalse(store.isInspectorPresented)
        XCTAssertNil(store.selectedServiceId)
    }

    func testToggleInspector() {
        let store = AppStore()
        XCTAssertFalse(store.isInspectorPresented)

        store.toggleInspector()
        XCTAssertTrue(store.isInspectorPresented)

        store.toggleInspector()
        XCTAssertFalse(store.isInspectorPresented)
        XCTAssertNil(store.selectedServiceId)
    }
}
