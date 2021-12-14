//
//  AudioPlayer.swift
//  Anaphora
//
//  Created by Mario Mouris on 21/06/2021.
//

import Foundation
import RxCocoa

public typealias Minutes = Int
public typealias Seconds = Int

public protocol AudioPlayer {
    
    // MARK: - Properties
    var currentTrack: BehaviorRelay<PlayerAudioTrack?> { get }
    var queue: BehaviorRelay<[PlayerAudioTrack]> { get }
    var state: BehaviorRelay<AudioPlayerState> { get }
    var currentTime: BehaviorRelay<(minutes: Minutes, seconds: Seconds)> { get }
    var trackDuration: BehaviorRelay<(minutes: Minutes, seconds: Seconds)> { get }
    var currentSpeed: BehaviorRelay<AudioPlayerSpeed> { get }
    var isRepeatOn: BehaviorRelay<Bool> { get }
    var isShuffleOn: BehaviorRelay<Bool> { get }
    var nextTrackInQueue: PlayerAudioTrack? { get }
    var previousTrackInQueue: PlayerAudioTrack? { get }
    
    // MARK: - Track Management Methods
    func play(track: PlayerAudioTrack)
    func play(list: [PlayerAudioTrack])
    func pause()
    func resume()
    func next()
    func previous()
    func seekForward()
    func seekBackward()
    func seek(to time: TimeInterval)
    func changeSpeed(to speed: AudioPlayerSpeed)
    
    // MARK: - Queue Management Methods
    func toggleRepeat()
    func toggleShuffle()
    func updateQueueOrder(queue: [PlayerAudioTrack])
    func removeTrackFromQueue(track: PlayerAudioTrack)
}
