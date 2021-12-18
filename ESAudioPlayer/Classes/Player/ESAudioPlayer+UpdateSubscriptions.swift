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
        trackDuration.accept(currentPlayer?.currentItem?.asset.duration.seconds.toMinutesAndSeconds() ?? (0, 0))
        currentPlayerTimeObserverToken = currentPlayer?
            .addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 5), queue: .main, using: { _ in
                // Update current time
                self.currentTime.accept(self.currentPlayer?.currentTime().seconds.toMinutesAndSeconds() ?? (0, 0))
                
                // Update track duration if changed
                let currentDuration = self.trackDuration.value
                let trackDurationValue = self.currentPlayer?.currentItem?.asset
                    .duration.seconds.toMinutesAndSeconds() ?? (0, 0)
                if currentDuration != trackDurationValue {
                    self.trackDuration.accept(trackDurationValue)
                }
                
                // Update info center
                if let elapsedPlaybackTime = self.currentPlayer?.currentTime().seconds,
                   let trackDuration = self.currentPlayer?.currentItem?.asset.duration.seconds,
                   !trackDuration.isNaN,
                   elapsedPlaybackTime.isFinite, elapsedPlaybackTime.isNormal {
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
                self.state.accept(.buffering)
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
                resume()
            }
        default: ()
        }
    }
}
