//
//  ESAudioPlayer+Helpers.swift
//  Anaphora
//
//  Created by Mario Mouris on 24/06/2021.
//

import AVFoundation

// MARK: - Helpers
extension ESAudioPlayer {
    
    // MARK: - Calculated properties
    public var previousTrackInQueue: ESPlayerAudioTrack? {
        guard let currentItemIndex = queue.value.firstIndex(where: { $0.id == self.currentTrack.value?.id }),
              currentItemIndex - 1 >= 0 else { return nil }
        return queue.value[currentItemIndex - 1]
    }
    
    public var nextTrackInQueue: ESPlayerAudioTrack? {
        guard let currentItemIndex = queue.value.firstIndex(where: { $0.id == self.currentTrack.value?.id }),
              queue.value.count > currentItemIndex + 1 else { return nil }
        return queue.value[currentItemIndex + 1]
    }
    
    // MARK: - Methods
    func initializeAVPlayerAndStartPlaying(with track: ESPlayerAudioTrack?) {
        guard let track = track,
              let trackURL = URL(string: track.fileURL) else { return }
        
        // Clear time observer from player before releasing it
        if let currentObserver = currentPlayerTimeObserverToken {
            currentPlayer?.removeTimeObserver(currentObserver)
            currentPlayerTimeObserverToken = nil
        }
        
        // Pause anything that's currently playing and return to start
        currentPlayer?.replaceCurrentItem(with: nil)
        currentPlayer?.seek(to: CMTimeMake(value: 0, timescale: 1))
        currentPlayer?.pause()
        currentTime.accept((0, 0))
        trackDuration.accept((0, 0))
        state.accept(.buffering)
        
        // Initialize player
        loadAsset(withTrackURL: trackURL, track: track) { [unowned self] playerItem in
            guard let playerItem = playerItem else { return }
            if self.currentPlayer == nil {
                self.currentPlayer = AVPlayer(playerItem: playerItem)
                self.currentPlayer?.allowsExternalPlayback = true
                self.subscribeForPlayerStateUpdates()
            } else {
                self.currentPlayer?.replaceCurrentItem(with: playerItem)
            }
            
            // Start playing and configure player
            self.subscribeForTimeUpdatesAndSetDuration()
            self.subscribeForBufferingUpdates()
            self.currentPlayer?.playImmediately(atRate: self.currentSpeed.value.rawValue)
        }
        
        // Configure now playing center
        self.setupNowPlayingCenter(track: track)
    }
    
    private func loadAsset(withTrackURL trackURL: URL,
                           track: ESPlayerAudioTrack,
                           completion: @escaping (AVPlayerItem?) -> Void) {
        // Cancel already loading asset if it exists
        loadingAsset?.cancelLoading()
        
        // Initialize new asset and start loading it
        loadingAsset = AVAsset(url: trackURL)
        let keys: [String] = ["playable"]
        loadingAsset?.loadValuesAsynchronously(forKeys: keys) { [unowned self] in
            var error: NSError?
            let status = loadingAsset?.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                DispatchQueue.main.async {
                    guard let asset = loadingAsset else {
                        self.state.accept(.stopped)
                        completion(nil)
                        return
                    }
                    let item = AVPlayerItem(asset: asset)
                    completion(item)
                }
            case .loading, .cancelled:
                self.state.accept(.buffering)
            default:
                self.state.accept(.stopped)
                completion(nil)
            }
        }
    }
}
