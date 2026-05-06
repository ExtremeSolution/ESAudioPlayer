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
    static let tracksList: [ESPlayerAudioTrack] = [
        ESPlayerAudioTrack(
            id: 1,
            name: "Believe",
            imageURL: "https://i.imgur.com/GrkPDIK.jpg",
            imageData: nil,
            fileURL: Bundle.main.url(
                forResource: "soundsample1",
                withExtension: "mp3"
            )!.absoluteString,
            artists: [
                ESPlayerArtist(
                    id: 1,
                    name: "John Mclain",
                    description: "",
                    imageURL: ""
                )
            ],
            subtitle: "",
            type: .track
        ),
        ESPlayerAudioTrack(
            id: 2,
            name: "Trust",
            imageURL: "https://i.redd.it/8atdz8vki3q11.png",
            imageData: nil,
            fileURL: Bundle.main.url(
                forResource: "soundsample2",
                withExtension: "mp3"
            )!.absoluteString,
            artists: [
                ESPlayerArtist(
                    id: 1,
                    name: "Smart Sandro",
                    description: "",
                    imageURL: ""
                )
            ],
            subtitle: "",
            type: .track
        )
    ]
}
