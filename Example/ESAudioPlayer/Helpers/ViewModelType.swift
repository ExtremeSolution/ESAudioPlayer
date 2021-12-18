//
//  ViewModelType.swift
//  ESAudioPlayer_Example
//
//  Created by Mario Mouris on 14/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

/// Defines how a view model should look like
public protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
}
