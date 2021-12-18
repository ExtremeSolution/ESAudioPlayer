//
//  ESAudioPlayerTrackManagementTests.swift
//  ESAudioPlayer_Tests
//
//  Created by Mario Mouris on 16/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import RxSwift
@testable import ESAudioPlayer

class ESAudioPlayerTrackManagementTests: XCTestCase {

    // MARK: - Properties
    private var player: ESAudioPlayer!
    
    // MARK: - Setup methods
    override func setUp() {
        super.setUp()
        
        player = ESAudioPlayer()
    }
    
    // MARK: - Player state tests
    func test_playTrack_shouldChangeStateToBuffering() {
        player.play(track: TestDummyDataGenerator.genericTrack)
        XCTAssertEqual(player.state.value, .buffering)
    }
    
    func test_playTrack_shouldChangeStateToPlaying() {
        let expectation = expectation(description: "Player Buffering")
        expectation.assertForOverFulfill = false
        let disposeBag = DisposeBag()
        
        player.play(track: TestDummyDataGenerator.genericTrack)
        player.state.subscribe(onNext: {
            if $0 == .playing { expectation.fulfill() }
        }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(player.state.value, .playing)
    }
    
    func test_changeSpeedThenPlayTrack_shouldChangeSpeedBackToNormal() {
        player.changeSpeed(to: .double)
        XCTAssertEqual(player.currentSpeed.value, .double)
        player.play(track: TestDummyDataGenerator.genericTrack)
        XCTAssertEqual(player.currentSpeed.value, .normal)
    }
    
    func test_playTrack_shouldUpdateQueueAndCurrentTrack() {
        let track = TestDummyDataGenerator.genericTrack
        player.play(track: track)
        XCTAssertEqual(player.currentTrack.value, track)
        XCTAssertEqual(player.queue.value, [track])
    }
    
    func test_playTrackThenPause_shouldUpdateStateToPaused() {
        player.play(track: TestDummyDataGenerator.genericTrack)
        player.pause()
        XCTAssertEqual(player.state.value, .paused)
    }
    
    func test_playTrackThenPauseThenResume_shouldUpdateStateToPlaying() {
        player.play(track: TestDummyDataGenerator.genericTrack)
        player.pause()
        player.resume()
        XCTAssertEqual(player.state.value, .playing)
    }
    
    func test_playTrackThenTriggerNextWithoutNextTrack_shouldStopPlayerAndUpdateStateToSopped() {
        player.play(track: TestDummyDataGenerator.genericTrack)
        player.next()
        XCTAssertEqual(player.state.value, .stopped)
    }
    
    func test_playTrackThenTriggerPreviousAfterSecond_shouldStartFromBeginning() {
        player.play(track: TestDummyDataGenerator.genericTrack)
        wait(for: 1.5)
        player.previous()
        wait(for: 0.2)
        
        XCTAssertEqual(player.currentTime.value.minutes, 0)
        XCTAssertEqual(player.currentTime.value.seconds, 0)
    }
    
    func test_playTrackThenSeekForward_shouldSkip15Seconds() {
        player.play(track: TestDummyDataGenerator.genericTrack)
        wait(for: 0.2)
        player.seekForward()
        wait(for: 0.2)
        XCTAssertEqual(player.currentTime.value.seconds, 15)
    }
    
    func test_playTrackThenSeekToTime_shouldSkipToSameTime() {
        player.play(track: TestDummyDataGenerator.genericTrack)
        wait(for: 0.2)
        player.seek(to: 20)
        wait(for: 0.2)
        XCTAssertEqual(player.currentTime.value.seconds, 20)
    }
}
