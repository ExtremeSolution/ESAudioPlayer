//
//  PlayerArtist.swift
//  Anaphora
//
//  Created by Mario Mouris on 21/06/2021.
//

import Foundation

/// The artist object used in player
public struct PlayerArtist: Equatable {
    
    // MARK: - Properties
    public let id: Int
    public let name: String
    public let description: String
    public let imageURL: String
    
    // MARK: - Initializer
    public init(
        id: Int,
        name: String,
        description: String,
        imageURL: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
    }
}
