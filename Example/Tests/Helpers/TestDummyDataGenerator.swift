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
    
    #if SWIFT_PACKAGE
    private static let bundle = Bundle.module
    #else
    private static let bundle = Bundle(for: TestDummyDataGenerator.self)
    #endif

    static let genericTrack = ESPlayerAudioTrack(
        id: 1,
        name: "TrackName",
        imageURL: "ImageURL",
        imageData: nil,
        fileURL: bundle.url(
            forResource: "soundsample1",
            withExtension: "mp3"
        )!.absoluteString,
        artists: [
            ESPlayerArtist(
                id: 1,
                name: "ArtistName",
                description: "ArtistDescription",
                imageURL: "ArtistImageURL"
            )
        ],
        subtitle: "",
        type: .track
    )
    
    static let genericTracksList: [ESPlayerAudioTrack] = [
        ESPlayerAudioTrack(
            id: 1,
            name: "TrackName1",
            imageURL: "ImageURL1",
            imageData: nil,
            fileURL: bundle.url(
                forResource: "soundsample1",
                withExtension: "mp3"
            )!.absoluteString,
            artists: [
                ESPlayerArtist(
                    id: 1,
                    name: "ArtistName1",
                    description: "ArtistDescription1",
                    imageURL: "ArtistImageURL1"
                )
            ],
            subtitle: "",
            type: .track
        ),
        ESPlayerAudioTrack(
            id: 2,
            name: "TrackName2",
            imageURL: "ImageURL2",
            imageData: nil,
            fileURL: bundle.url(
                forResource: "soundsample2",
                withExtension: "mp3"
            )!.absoluteString,
            artists: [
                ESPlayerArtist(
                    id: 2,
                    name: "ArtistName2",
                    description: "ArtistDescription2",
                    imageURL: "ArtistImageURL2"
                )
            ],
            subtitle: "",
            type: .track
        )
    ]
}
