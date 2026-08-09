import XCTest
import SwiftUI
@testable import Kuma

final class KumaThemeTests: XCTestCase {

    func testSpacingTokens() {
        XCTAssertEqual(KumaTheme.Spacing.xs, 4)
        XCTAssertEqual(KumaTheme.Spacing.sm, 8)
        XCTAssertEqual(KumaTheme.Spacing.md, 12)
        XCTAssertEqual(KumaTheme.Spacing.lg, 16)
        XCTAssertEqual(KumaTheme.Spacing.xl, 24)
        XCTAssertEqual(KumaTheme.Spacing.xxl, 32)
    }

    func testRadiusTokens() {
        XCTAssertEqual(KumaTheme.Radius.xs, 4)
        XCTAssertEqual(KumaTheme.Radius.sm, 6)
        XCTAssertEqual(KumaTheme.Radius.md, 8)
        XCTAssertEqual(KumaTheme.Radius.lg, 12)
        XCTAssertEqual(KumaTheme.Radius.xl, 16)
        XCTAssertEqual(KumaTheme.Radius.full, 9999)
    }

    func testColorTokensExist() {
        XCTAssertNotNil(KumaTheme.Color.statusRunning)
        XCTAssertNotNil(KumaTheme.Color.statusStopped)
        XCTAssertNotNil(KumaTheme.Color.statusStarting)
        XCTAssertNotNil(KumaTheme.Color.statusStopping)
        XCTAssertNotNil(KumaTheme.Color.statusFailed)

        XCTAssertNotNil(KumaTheme.Color.providerKubernetes)
        XCTAssertNotNil(KumaTheme.Color.providerDocker)
        XCTAssertNotNil(KumaTheme.Color.providerPodman)
        XCTAssertNotNil(KumaTheme.Color.providerShell)
        XCTAssertNotNil(KumaTheme.Color.providerSSH)
        XCTAssertNotNil(KumaTheme.Color.providerHTTPCheck)
        XCTAssertNotNil(KumaTheme.Color.providerTunnel)
        XCTAssertNotNil(KumaTheme.Color.providerProcessMonitor)
    }

    func testDynamicColorResolution() {
        XCTAssertEqual(KumaTheme.Color.forState(.running), KumaTheme.Color.statusRunning)
        XCTAssertEqual(KumaTheme.Color.forState(.stopped), KumaTheme.Color.statusStopped)
        XCTAssertEqual(KumaTheme.Color.forState(.starting), KumaTheme.Color.statusStarting)
        XCTAssertEqual(KumaTheme.Color.forState(.stopping), KumaTheme.Color.statusStopping)
        XCTAssertEqual(KumaTheme.Color.forState(.failed), KumaTheme.Color.statusFailed)

        XCTAssertEqual(KumaTheme.Color.forProviderKey("k8s"), KumaTheme.Color.providerKubernetes)
        XCTAssertEqual(KumaTheme.Color.forProviderKey("docker"), KumaTheme.Color.providerDocker)
        XCTAssertEqual(KumaTheme.Color.forProviderKey("podman"), KumaTheme.Color.providerPodman)
        XCTAssertEqual(KumaTheme.Color.forProviderKey("shell"), KumaTheme.Color.providerShell)
        XCTAssertEqual(KumaTheme.Color.forProviderKey("ssh"), KumaTheme.Color.providerSSH)
        XCTAssertEqual(KumaTheme.Color.forProviderKey("http"), KumaTheme.Color.providerHTTPCheck)
        XCTAssertEqual(KumaTheme.Color.forProviderKey("tunnel"), KumaTheme.Color.providerTunnel)
        XCTAssertEqual(KumaTheme.Color.forProviderKey("monitor"), KumaTheme.Color.providerProcessMonitor)
        XCTAssertEqual(KumaTheme.Color.forProviderKey("unknown_provider"), KumaTheme.Color.textSecondary)
    }
}
