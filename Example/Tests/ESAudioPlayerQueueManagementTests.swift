//
//  ESAudioPlayerQueueManagementTests.swift
//  ESAudioPlayer_Tests
//
//  Created by Mario Mouris on 18/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import ESAudioPlayer

class ESAudioPlayerQueueManagementTests: XCTestCase {

    // MARK: - Properties
    private var player: ESAudioPlayer!
    
    // MARK: - Setup methods
    override func setUp() {
        super.setUp()
        
        player = ESAudioPlayer()
    }
    
    // MARK: - Queue management tests
    func test_playList_shouldUpdateQueueWithList() {
        player.play(list: TestDummyDataGenerator.genericTracksList)
        XCTAssertEqual(player.queue.value, TestDummyDataGenerator.genericTracksList)
    }
    
    func test_playListThenToggleRepeatOnAndOff_shouldUpdateIsRepeatCorrectly() {
        player.play(list: TestDummyDataGenerator.genericTracksList)
        player.toggleRepeat()
        XCTAssertEqual(player.isRepeatOn.value, true)
        player.toggleRepeat()
        XCTAssertEqual(player.isRepeatOn.value, false)
    }
    
    func test_playListThenToggleShuffleOnAndOff_shouldUpdateIsShuffleCorrectly() {
        player.play(list: TestDummyDataGenerator.genericTracksList)
        player.toggleShuffle()
        XCTAssertEqual(player.isShuffleOn.value, true)
        player.toggleShuffle()
        XCTAssertEqual(player.isShuffleOn.value, false)
    }
    
    func test_playListThenUpdateQueueOrder_shouldUpdateQueueOrder() {
        player.play(list: TestDummyDataGenerator.genericTracksList)
        player.updateQueueOrder(queue: TestDummyDataGenerator.genericTracksList.reversed())
        XCTAssertEqual(player.queue.value, TestDummyDataGenerator.genericTracksList.reversed())
    }
    
    func test_playListThenRemoveTrackFromQueue_shouldUpdateQueue() {
        player.play(list: TestDummyDataGenerator.genericTracksList)
        player.removeTrackFromQueue(track: TestDummyDataGenerator.genericTracksList[1])
        XCTAssertEqual(player.queue.value, [TestDummyDataGenerator.genericTracksList[0]])
    }
}
