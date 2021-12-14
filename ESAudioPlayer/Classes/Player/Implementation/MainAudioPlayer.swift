//
//  MainAudioPlayer.swift
//  Anaphora
//
//  Created by Mario Mouris on 21/06/2021.
//

import AVFoundation
import RxSwift
import RxCocoa

class MainAudioPlayer: NSObject, AudioPlayer {
    
    // MARK: - Properties
    // Public properties
    let currentTrack = BehaviorRelay<PlayerAudioTrack?>(value: nil)
    let queue = BehaviorRelay<[PlayerAudioTrack]>(value: [])
    let state = BehaviorRelay<AudioPlayerState>(value: .stopped)
    let currentTime = BehaviorRelay<(minutes: Minutes, seconds: Seconds)>(value: (0, 0))
    let trackDuration = BehaviorRelay<(minutes: Minutes, seconds: Seconds)>(value: (0, 0))
    let currentSpeed = BehaviorRelay<AudioPlayerSpeed>(value: .normal)
    let isRepeatOn = BehaviorRelay<Bool>(value: false)
    let isShuffleOn = BehaviorRelay<Bool>(value: false)
    
    // Private properties
    var currentPlayer: AVPlayer?
    let audioSession = AVAudioSession.sharedInstance()
    var currentPlayerTimeObserverToken: Any?
    var unshuffledQueue: [PlayerAudioTrack]?
    var playBackBufferEmptyObserver: NSKeyValueObservation?
    var playBackLikelyToKeepUpObserver: NSKeyValueObservation?
    var playBackBufferFullObserver: NSKeyValueObservation?
    var imageDownloadDataTask: URLSessionDataTask?
    var loadingAsset: AVAsset?
    
    // MARK: - Initializer
    static let shared = MainAudioPlayer()
    private override init() {
        super.init()
        
        configureAudioSession()
        setupRemoteTransportControls()
    }
    
    private func configureAudioSession() {
        try? audioSession.setCategory(.playback)
        try? audioSession.setMode(.spokenAudio)
    }
}

// MARK: - Track Management Methods
extension MainAudioPlayer {
    func play(track: PlayerAudioTrack) {
        // Make sure the track is not already playing
        guard track != currentTrack.value else { return }
        
        // Reset playback speed
        currentSpeed.accept(.normal)
        
        // Skip to track if it's already in queue
        if queue.value.contains(track) {
            // Update public properties
            currentTrack.accept(track)
            
            // Initialize player
            initializeAVPlayerAndStartPlaying(with: track)
        } else {
            // Update public properties
            queue.accept([track])
            currentTrack.accept(track)
            
            // Initialize player with track
            initializeAVPlayerAndStartPlaying(with: track)
        }
    }
    
    func play(list: [PlayerAudioTrack]) {
        guard !list.isEmpty else { return }
        
        // Reset playback speed
        currentSpeed.accept(.normal)
        
        // Update public properties
        queue.accept(list)
        currentTrack.accept(list.first!)
        
        // Initialize player with first track
        initializeAVPlayerAndStartPlaying(with: list.first)
    }
    
    func pause() {
        currentPlayer?.pause()
        state.accept(.paused)
    }
    
    func resume() {
        guard state.value == . paused || state.value == .stopped else { return }
        currentPlayer?.playImmediately(atRate: currentSpeed.value.rawValue)
        state.accept(.playing)
    }
    
    func next() {
        // Get next track if available
        guard let nextTrack = nextTrackInQueue else {
            currentPlayer?.seek(to: CMTimeMake(value: 0, timescale: 1))
            currentPlayer?.pause()
            state.accept(.stopped)
            return
        }
        
        // Update public properties
        currentTrack.accept(nextTrack)
        
        // Initialize player
        initializeAVPlayerAndStartPlaying(with: nextTrack)
    }
    
    func previous() {
        // Play from start if it's more than 5 seconds in
        guard currentPlayer?.currentTime().seconds ?? 0 < 5 else {
            currentPlayer?.seek(to: CMTimeMake(value: 0, timescale: 1))
            return
        }
        
        // Get previous track if available
        guard let previousTrack = previousTrackInQueue else {
            // Play from start if there is no previous track
            currentPlayer?.seek(to: CMTimeMake(value: 0, timescale: 1))
            return
        }
        
        // Update public properties
        currentTrack.accept(previousTrack)
        
        // Initialize player
        initializeAVPlayerAndStartPlaying(with: previousTrack)
    }
    
    func seekForward() {
        let currentTime = convertMinutesAndSecondsToTotalSeconds(minutes: currentTime.value.minutes,
                                                                 seconds: currentTime.value.seconds)
        currentPlayer?.seek(to: CMTimeMake(value: Int64(currentTime + 15), timescale: 1))
    }
    
    func seekBackward() {
        let currentTime = convertMinutesAndSecondsToTotalSeconds(minutes: currentTime.value.minutes,
                                                                 seconds: currentTime.value.seconds)
        currentPlayer?.seek(to: CMTimeMake(value: Int64(currentTime - 15), timescale: 1))
    }
    
    func seek(to time: TimeInterval) {
        currentPlayer?.seek(to: CMTimeMake(value: Int64(time), timescale: 1))
    }
    
    func changeSpeed(to speed: AudioPlayerSpeed) {
        currentSpeed.accept(speed)
        if state.value == .playing {
            currentPlayer?.playImmediately(atRate: speed.rawValue)
        }
    }
}

// MARK: - Queue Management Methods
extension MainAudioPlayer {
    func toggleRepeat() {
        isRepeatOn.accept(!isRepeatOn.value)
    }
    
    func toggleShuffle() {
        isShuffleOn.accept(!isShuffleOn.value)
        if isShuffleOn.value {
            // Turn shuffle on
            self.unshuffledQueue = queue.value
            var shuffledQueue = queue.value.shuffled()
            guard let currentItemIndex = shuffledQueue.firstIndex(where: { $0.id == self.currentTrack.value?.id }),
                  let currentTrack = currentTrack.value else { return }
            shuffledQueue.remove(at: currentItemIndex)
            shuffledQueue = [currentTrack] + shuffledQueue
            queue.accept(shuffledQueue)
        } else {
            // Turn shuffle off
            guard let unshuffledQueue = unshuffledQueue else { return }
            queue.accept(unshuffledQueue)
            self.unshuffledQueue = nil
        }
    }
    
    func updateQueueOrder(queue: [PlayerAudioTrack]) {
        self.queue.accept(queue)
    }
    
    func removeTrackFromQueue(track: PlayerAudioTrack) {
        // Create updated instance of queue and remove track
        var updatedQueue = queue.value
        updatedQueue.removeAll { $0 == track }
        
        // Play next track if the removed track is the current one
        if track == currentTrack.value {
            next()
        }
        
        // Update current queue
        queue.accept(updatedQueue)
    }
}
