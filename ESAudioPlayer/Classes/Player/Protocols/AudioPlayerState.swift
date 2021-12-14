//
//  AudioPlayerState.swift
//  Anaphora
//
//  Created by Mario Mouris on 21/06/2021.
//

import Foundation

public enum AudioPlayerState {
    case playing,
         buffering,
         paused,
         stopped,
         error
}
