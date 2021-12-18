//
//  ESAudioPlayerInitializationTests.swift
//  ESAudioPlayer_Tests
//
//  Created by Mario Mouris on 16/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import ESAudioPlayer

class ESAudioPlayerInitializationTests: XCTestCase {

    // MARK: - Properties
    private var player: ESAudioPlayer!
    
    // MARK: - Setup methods
    override func setUp() {
        super.setUp()
        
        player = ESAudioPlayer()
    }
    
    // MARK: - Player initialziation tests
    func test_playerInitialization_shouldSetCorrectAudioSession() {
        XCTAssertEqual(player.audioSession.category, .playback)
        XCTAssertEqual(player.audioSession.mode, .spokenAudio)
    }
    
    func test_playerInitialization_shouldStartWithStoppedState() {
        XCTAssertEqual(player.state.value, .stopped)
    }
    
    func test_playerInitialization_shouldStartWithNoCurrentTrack() {
        XCTAssertNil(player.currentTrack.value)
    }
    
    func test_playerInitialization_shouldStartWithEmptyQueue() {
        XCTAssertEqual(player.queue.value, [])
    }
    
    func test_playerInitialization_shouldStartWithZeroCurrentTime() {
        XCTAssertEqual(player.currentTime.value.seconds, 0)
        XCTAssertEqual(player.currentTime.value.minutes, 0)
    }
    
    func test_playerInitialization_shouldStartWithZeroTrackDuration() {
        XCTAssertEqual(player.trackDuration.value.seconds, 0)
        XCTAssertEqual(player.trackDuration.value.minutes, 0)
    }
    
    func test_playerInitialization_shouldStartWithNormalPlaybackSpeed() {
        XCTAssertEqual(player.currentSpeed.value, .normal)
    }
    
    func test_playerInitialization_shouldStartWithRepeatOff() {
        XCTAssertEqual(player.isRepeatOn.value, false)
    }
    
    func test_playerInitialization_shouldStartWithShuffleOff() {
        XCTAssertEqual(player.isShuffleOn.value, false)
    }
}
