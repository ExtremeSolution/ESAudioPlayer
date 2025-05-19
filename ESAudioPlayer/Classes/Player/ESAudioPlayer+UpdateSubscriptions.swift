//
//  ESAudioPlayer+UpdateSubscriptions.swift
//  Anaphora
//
//  Created by Mario Mouris on 24/06/2021.
//

import AVFoundation
import RxSwift
import RxCocoa

// MARK: - Player Update Subscriptions
extension ESAudioPlayer {
    func subscribeForTimeUpdatesAndSetDuration() {
        if let durationSeconds = currentPlayer?.currentItem?.asset.duration.seconds,
           durationSeconds.isFinite, !durationSeconds.isNaN {
            trackDuration.accept(durationSeconds.toMinutesAndSeconds())
        } else {
            trackDuration.accept((0, 0))
        }
        
        currentPlayerTimeObserverToken = currentPlayer?
            .addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 5), queue: .main, using: { [weak self] _ in
                guard let self = self else { return }
                
                if let currentSeconds = self.currentPlayer?.currentTime().seconds,
                   currentSeconds.isFinite, !currentSeconds.isNaN {
                    self.currentTime.accept(currentSeconds.toMinutesAndSeconds())
                }
                
                // update track duration if it changes
                let currentDuration = self.trackDuration.value
                if let durationSeconds = self.currentPlayer?.currentItem?.asset.duration.seconds,
                   durationSeconds.isFinite, !durationSeconds.isNaN {
                    let newDuration = durationSeconds.toMinutesAndSeconds()
                    if currentDuration != newDuration {
                        self.trackDuration.accept(newDuration)
                    }
                }
                
                // update Now Playing Info Center
                if let elapsedPlaybackTime = self.currentPlayer?.currentTime().seconds,
                   let trackDuration = self.currentPlayer?.currentItem?.asset.duration.seconds,
                   elapsedPlaybackTime.isFinite, !elapsedPlaybackTime.isNaN,
                   trackDuration.isFinite, !trackDuration.isNaN {
                    self.updateNowPlayingCenterTimes(elapsedPlaybackTime: Int(elapsedPlaybackTime),
                                                     trackDurationTime: Int(trackDuration))
                }
            })
    }
    
    func subscribeForPlayerStateUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime),
                                               name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInturruptionNotification),
                                               name: AVAudioSession.interruptionNotification, object: audioSession)
    }
    
    func subscribeForBufferingUpdates() {
        playBackBufferEmptyObserver = currentPlayer?.currentItem?
            .observe(\.isPlaybackBufferEmpty) { [unowned self] item, _ in
                guard item == self.currentPlayer?.currentItem,
                      self.state.value != .stopped else { return }
                if item.isPlaybackBufferEmpty {
                    self.state.accept(.buffering)
                }
            }
        
        playBackLikelyToKeepUpObserver = currentPlayer?.currentItem?
            .observe(\.isPlaybackLikelyToKeepUp) { [unowned self] item, _ in
                guard item == self.currentPlayer?.currentItem,
                      (self.state.value != .stopped && self.state.value != .paused) else { return }
                if item.isPlaybackLikelyToKeepUp {
                    self.state.accept(.playing)
                } else {
                    self.state.accept(.buffering)
                }
            }
        
        playBackBufferFullObserver = currentPlayer?.currentItem?
            .observe(\.isPlaybackBufferFull) { [unowned self] item, _ in
                guard item == self.currentPlayer?.currentItem,
                      self.state.value != .stopped else { return }
                self.state.accept(.playing)
            }
    }
    
    @objc private func playerItemDidPlayToEndTime() {
        if isRepeatOn.value {
            previous()
            currentPlayer?.playImmediately(atRate: currentSpeed.value.rawValue)
        } else {
            next()
        }
    }
    
    @objc private func handleInturruptionNotification(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // An interruption began. Update the UI as necessary.
            pause()
        case .ended:
            // An interruption ended. Resume playback, if appropriate.
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // An interruption ended. Resume playback.
                // Activate and configure the session before resuming to prevent deactivation from inactivity.
                configureAudioSession()
                resume()
            }
        default: ()
        }
    }
}
