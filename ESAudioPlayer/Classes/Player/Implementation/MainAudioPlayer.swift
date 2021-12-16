//
//  MainAudioPlayer.swift
//  Anaphora
//
//  Created by Mario Mouris on 21/06/2021.
//

import AVFoundation
import RxSwift
import RxCocoa

public class MainAudioPlayer: NSObject, AudioPlayer {
    
    // MARK: - Properties
    // Public properties
    public let currentTrack = BehaviorRelay<ESPlayerAudioTrack?>(value: nil)
    public let queue = BehaviorRelay<[ESPlayerAudioTrack]>(value: [])
    public let state = BehaviorRelay<AudioPlayerState>(value: .stopped)
    public let currentTime = BehaviorRelay<(minutes: Minutes, seconds: Seconds)>(value: (0, 0))
    public let trackDuration = BehaviorRelay<(minutes: Minutes, seconds: Seconds)>(value: (0, 0))
    public let currentSpeed = BehaviorRelay<AudioPlayerSpeed>(value: .normal)
    public let isRepeatOn = BehaviorRelay<Bool>(value: false)
    public let isShuffleOn = BehaviorRelay<Bool>(value: false)
    
    // Private properties
    var currentPlayer: AVPlayer?
    let audioSession = AVAudioSession.sharedInstance()
    var currentPlayerTimeObserverToken: Any?
    var unshuffledQueue: [ESPlayerAudioTrack]?
    var playBackBufferEmptyObserver: NSKeyValueObservation?
    var playBackLikelyToKeepUpObserver: NSKeyValueObservation?
    var playBackBufferFullObserver: NSKeyValueObservation?
    var imageDownloadDataTask: URLSessionDataTask?
    var loadingAsset: AVAsset?
    
    // MARK: - Initializer
    public static let shared = MainAudioPlayer()
    override init() {
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
    public func play(track: ESPlayerAudioTrack) {
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
    
    public func play(list: [ESPlayerAudioTrack]) {
        guard !list.isEmpty else { return }
        
        // Reset playback speed
        currentSpeed.accept(.normal)
        
        // Update public properties
        queue.accept(list)
        currentTrack.accept(list.first!)
        
        // Initialize player with first track
        initializeAVPlayerAndStartPlaying(with: list.first)
    }
    
    public func pause() {
        currentPlayer?.pause()
        state.accept(.paused)
    }
    
    public func resume() {
        guard state.value == . paused || state.value == .stopped else { return }
        currentPlayer?.playImmediately(atRate: currentSpeed.value.rawValue)
        state.accept(.playing)
    }
    
    public func next() {
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
    
    public func previous() {
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
    
    public func seekForward() {
        let currentTime = convertMinutesAndSecondsToTotalSeconds(minutes: currentTime.value.minutes,
                                                                 seconds: currentTime.value.seconds)
        currentPlayer?.seek(to: CMTimeMake(value: Int64(currentTime + 15), timescale: 1))
    }
    
    public func seekBackward() {
        let currentTime = convertMinutesAndSecondsToTotalSeconds(minutes: currentTime.value.minutes,
                                                                 seconds: currentTime.value.seconds)
        currentPlayer?.seek(to: CMTimeMake(value: Int64(currentTime - 15), timescale: 1))
    }
    
    public func seek(to time: TimeInterval) {
        currentPlayer?.seek(to: CMTimeMake(value: Int64(time), timescale: 1))
    }
    
    public func changeSpeed(to speed: AudioPlayerSpeed) {
        currentSpeed.accept(speed)
        if state.value == .playing {
            currentPlayer?.playImmediately(atRate: speed.rawValue)
        }
    }
}

// MARK: - Queue Management Methods
extension MainAudioPlayer {
    public func toggleRepeat() {
        isRepeatOn.accept(!isRepeatOn.value)
    }
    
    public func toggleShuffle() {
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
    
    public func updateQueueOrder(queue: [ESPlayerAudioTrack]) {
        self.queue.accept(queue)
    }
    
    public func removeTrackFromQueue(track: ESPlayerAudioTrack) {
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
