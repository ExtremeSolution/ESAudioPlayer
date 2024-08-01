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
    public let imageURL: String?
    public let imageData: Data?
    public let fileURL: String
    public let artists: [ESPlayerArtist]?
    public let subtitle: String
    public let type: ESTrackType
    
    // MARK: - Calculated properties
    /// Reduces the list of artists into a single combined string
    public var combinedArtistsString: String {
        if let string = artists?.reduce("", { if $0 == "" { return $1.name } else { return $0 + ", " + ($1.name) } }),
           !string.isEmpty {
            return string
        } else {
            return subtitle
        }
    }
    
    // MARK: - Initializer
    public init(
        id: Int,
        name: String,
        imageURL: String?,
        imageData: Data?,
        fileURL: String,
        artists: [ESPlayerArtist]?,
        subtitle: String,
        type: ESTrackType
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.imageData = imageData
        self.fileURL = fileURL
        self.artists = artists
        self.subtitle = subtitle
        self.type = type
    }
}

public enum ESTrackType {
    case track
    case episode
}
