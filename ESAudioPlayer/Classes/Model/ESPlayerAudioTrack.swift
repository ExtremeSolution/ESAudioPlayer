//
//  ESPlayerAudioTrack.swift
//  Anaphora
//
//  Created by Mario Mouris on 21/06/2021.
//

import Foundation

/// The track object used in player
public struct ESPlayerAudioTrack: Equatable {
    
    // MARK: - Properties
    public let id: Int
    public let name: String
    public let imageURL: String
    public let fileURL: String
    public let artists: [ESPlayerArtist]
    
    // MARK: - Calculated properties
    /// Reduces the list of artists into a single combined string
    public var combinedArtistsString: String {
        artists.reduce("", { if $0 == "" { return $1.name } else { return $0 + ", " + ($1.name) } })
    }
    
    // MARK: - Initializer
    public init(
        id: Int,
        name: String,
        imageURL: String,
        fileURL: String,
        artists: [ESPlayerArtist]
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.fileURL = fileURL
        self.artists = artists
    }
}
