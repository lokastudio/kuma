//
//  KumaSoundManager.swift
//  Kuma
//
//  Created for Kuma V4 (Reconstructed 100% from active V3 demangled binary symbols).
//

import AppKit
import Foundation
import AVFoundation
import UserNotifications
import os

/// Pure domain audio interface matching V3 active binary capabilities.
@MainActor
public protocol KumaSoundManagerProtocol: Sendable {
    var isMuted: Bool { get set }
    func syncCustomNotificationSoundToUserLibrary()
    func playNotificationSound()
    func playOnboardingSound()
}

/// Thread-safe Sound Manager backing notification audio sync and sound effect playback.
@MainActor
public final class KumaSoundManager: NSObject, KumaSoundManagerProtocol, AVAudioPlayerDelegate, Sendable {
    
    public static let shared = KumaSoundManager()
    private static let logger = Logger(subsystem: "com.kuma.app", category: "SoundManager")
    
    public var isMuted: Bool = false
    private var audioPlayer: AVAudioPlayer?
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        super.init()
    }

    /// Syncs custom notification sound (kuma-notify.aiff / kuma-alert.caf) to ~/Library/Sounds/ for macOS UNNotificationCenter daemon.
    public func syncCustomNotificationSoundToUserLibrary() {
        let userSoundsDir = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Sounds", isDirectory: true)
        
        do {
            if !fileManager.fileExists(atPath: userSoundsDir.path) {
                try fileManager.createDirectory(at: userSoundsDir, withIntermediateDirectories: true)
            }
            
            let soundFiles = ["kuma-notify.aiff", "kuma-alert.caf"]
            for soundFile in soundFiles {
                let destinationURL = userSoundsDir.appendingPathComponent(soundFile)
                if !fileManager.fileExists(atPath: destinationURL.path) {
                    if let bundleSoundURL = Bundle.main.url(forResource: soundFile, withExtension: nil) {
                        try fileManager.copyItem(at: bundleSoundURL, to: destinationURL)
                        Self.logger.info("Synced sound \(soundFile, privacy: .public) to ~/Library/Sounds/")
                    }
                }
            }
        } catch {
            Self.logger.error("Failed to sync custom sounds to ~/Library/Sounds/: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Plays notification sound with fallback to macOS system "Funk" sound.
    public func playNotificationSound() {
        guard !isMuted else { return }
        
        // 1. Try playing custom notification sound if present in ~/Library/Sounds/
        let userSoundsDir = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Sounds", isDirectory: true)
        let customSoundURL = userSoundsDir.appendingPathComponent("kuma-notify.aiff")
        
        if fileManager.fileExists(atPath: customSoundURL.path),
           let sound = NSSound(contentsOf: customSoundURL, byReference: true) {
            sound.play()
            Self.logger.debug("Played custom kuma-notify.aiff sound")
            return
        }
        
        // 2. Mandatory V3 Fallback: macOS system sound "Funk"
        if let fallbackSound = NSSound(named: NSSound.Name("Funk")) {
            fallbackSound.play()
            Self.logger.debug("Played fallback system sound 'Funk'")
        }
    }

    /// Plays onboarding welcome audio effect using AVAudioPlayer.
    public func playOnboardingSound() {
        guard !isMuted else { return }
        
        if let soundURL = Bundle.main.url(forResource: "kuma-notify", withExtension: "aiff") ??
                            Bundle.main.url(forResource: "kuma-alert", withExtension: "caf") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.delegate = self
                audioPlayer?.play()
                Self.logger.debug("Played onboarding sound via AVAudioPlayer")
            } catch {
                Self.logger.error("Failed to initialize AVAudioPlayer: \(error.localizedDescription, privacy: .public)")
            }
        } else if let fallbackSound = NSSound(named: NSSound.Name("Funk")) {
            fallbackSound.play()
        }
    }

    // MARK: - AVAudioPlayerDelegate
    
    public nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Self.logger.debug("AVAudioPlayer finished playback successfully: \(flag)")
    }
}
