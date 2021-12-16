//
//  TestDummyDataGenerator.swift
//  ESAudioPlayer_Example
//
//  Created by Mario Mouris on 16/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ESAudioPlayer

internal class TestDummyDataGenerator {
    static let genericTrack = ESPlayerAudioTrack(
        id: 1,
        name: "TrackName",
        imageURL: "ImageURL",
        fileURL: "https://www.bensound.com/bensound-music/bensound-buddy.mp3",
        artists: [
            ESPlayerArtist(
                id: 1,
                name: "ArtistName",
                description: "ArtistDescription",
                imageURL: "ArtistImageURL"
            )
        ]
    )
    
    static let genericTracksList: [ESPlayerAudioTrack] = [
        ESPlayerAudioTrack(
            id: 1,
            name: "TrackName1",
            imageURL: "ImageURL1",
            fileURL: "https://www.bensound.com/bensound-music/bensound-buddy.mp3",
            artists: [
                ESPlayerArtist(
                    id: 1,
                    name: "ArtistName1",
                    description: "ArtistDescription1",
                    imageURL: "ArtistImageURL1"
                )
            ]
        ),
        ESPlayerAudioTrack(
            id: 2,
            name: "TrackName2",
            imageURL: "ImageURL2",
            fileURL: "https://www.bensound.com/bensound-music/bensound-happyrock.mp3",
            artists: [
                ESPlayerArtist(
                    id: 2,
                    name: "ArtistName2",
                    description: "ArtistDescription2",
                    imageURL: "ArtistImageURL2"
                )
            ]
        )
    ]
}
