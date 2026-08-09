//
//  AppPhase.swift
//  Kuma
//

import Foundation

/// High-level lifecycle state machine for Kuma V4.
public enum AppPhase: Equatable, Sendable {
    case splash
    case onboarding(step: Int)
    case mainDeck
}
