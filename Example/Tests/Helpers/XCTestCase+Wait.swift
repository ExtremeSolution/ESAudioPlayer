//
//  WaitForExpectation+Helper.swift
//  ESAudioPlayer_Tests
//
//  Created by Mario Mouris on 18/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest

extension XCTestCase {
    func wait(for time: TimeInterval) {
        let expectation = expectation(description: "Player Buffering")
        expectation.isInverted = true
        waitForExpectations(timeout: time, handler: nil)
    }
}
