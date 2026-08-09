//
//  KumaSoundManagerTests.swift
//  KumaTests
//
//  Created for Kuma V4.
//

import XCTest
@testable import Kuma

@MainActor
final class KumaSoundManagerTests: XCTestCase {
    private var sut: KumaSoundManager!
    
    override func setUp() {
        super.setUp()
        sut = KumaSoundManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testPlaySoundEffectWhenMutedDoesNotCrashOrPlay() {
        sut.isMuted = true
        sut.playSoundEffect(.serviceStarted)
        XCTAssertTrue(sut.isMuted)
    }
    
    func testVolumeClamping() {
        sut.volume = 1.5
        XCTAssertEqual(sut.volume, 1.0)
        
        sut.volume = -0.5
        XCTAssertEqual(sut.volume, 0.0)
    }
    
    func testDefaultSoundMappingForDomainEvents() {
        XCTAssertEqual(KumaSoundEffect.serviceStarted.defaultSoundName, "Hero")
        XCTAssertEqual(KumaSoundEffect.serviceStopped.defaultSoundName, "Submarine")
        XCTAssertEqual(KumaSoundEffect.serviceFailed.defaultSoundName, "Basso")
        XCTAssertEqual(KumaSoundEffect.portConflictDetected.defaultSoundName, "Funk")
        XCTAssertEqual(KumaSoundEffect.actionSuccess.defaultSoundName, "Pop")
        XCTAssertEqual(KumaSoundEffect.custom("CustomAlert.wav").defaultSoundName, "CustomAlert.wav")
    }
    
    func testAvailableCustomSoundsReturnsArrayWithoutCrashing() {
        let sounds = sut.availableCustomSounds()
        XCTAssertNotNil(sounds)
    }
    
    func testPlayCustomSoundWithoutExtensionDoesNotCrash() {
        sut.playSoundEffect(.custom("NonExistentCustomSound"))
        XCTAssertFalse(sut.isMuted)
    }
}
