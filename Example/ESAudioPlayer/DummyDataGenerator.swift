//
//  DummyDataGenerator.swift
//  ESAudioPlayer_Example
//
//  Created by Mario Mouris on 14/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ESAudioPlayer

class DummyDataGenerator {
    static let tracksList: [PlayerAudioTrack] = [
        PlayerAudioTrack(
            id: 1,
            name: "Believe",
            imageURL: "https://i.imgur.com/GrkPDIK.jpg",
            fileURL: "https://www.bensound.com/bensound-music/bensound-buddy.mp3",
            artists: [
                PlayerArtist(
                    id: 1,
                    name: "John Mclain",
                    description: "",
                    imageURL: ""
                )
            ]
        ),
        PlayerAudioTrack(
            id: 2,
            name: "Trust",
            imageURL: "https://i.redd.it/8atdz8vki3q11.png",
            fileURL: "https://www.bensound.com/bensound-music/bensound-happyrock.mp3",
            artists: [
                PlayerArtist(
                    id: 1,
                    name: "Smart Sandro",
                    description: "",
                    imageURL: ""
                )
            ]
        )
    ]
}
