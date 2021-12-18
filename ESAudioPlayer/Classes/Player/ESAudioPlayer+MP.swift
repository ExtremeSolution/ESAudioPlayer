//
//  ESAudioPlayer+MP.swift
//  Anaphora
//
//  Created by Mario Mouris on 24/06/2021.
//

import Foundation
import MediaPlayer

extension ESAudioPlayer {
    /// Configures the remote command handlers
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for play command
        commandCenter.playCommand.addTarget { [unowned self] _ in
            resume()
            return .commandFailed
        }
        
        // Add handler for pause command
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            pause()
            return .commandFailed
        }
        
        // Add handler for next command
        commandCenter.nextTrackCommand.addTarget { [unowned self] _ in
            if self.nextTrackInQueue != nil {
                self.next()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for previous command
        commandCenter.previousTrackCommand.addTarget { [unowned self] _ in
            self.previous()
            return .success
        }
        
        // Add handler for change playback position commant
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] command in
            guard let event = command as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.seek(to: event.positionTime)
            return .success
        }
    }
    
    /// Provides display metadata
    func setupNowPlayingCenter(track: ESPlayerAudioTrack) {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.combinedArtistsString
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = currentPlayer?.rate

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        // Download image & reset the meta data
        downloadTrackArtwork(stringURL: track.imageURL) { artwork in
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
        
        // Enable/disable next button
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = nextTrackInQueue != nil
    }
    
    /// Updates current time and track duration for
    func updateNowPlayingCenterTimes(elapsedPlaybackTime: Int, trackDurationTime: Int) {
        var nowPlayingInfo: [String : Any] = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedPlaybackTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = trackDurationTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func downloadTrackArtwork(stringURL: String?, completion: @escaping (MPMediaItemArtwork?) -> Void) {
        // Cancel existing image downlaod task if there
        imageDownloadDataTask?.cancel()
        
        guard let stringURL = stringURL else {
            completion(MPMediaItemArtwork(boundsSize: .zero, requestHandler: { _ in UIImage() }))
            return
        }
        
        // Create new task and start it
        guard let url = URL(string: stringURL) else { completion(nil); return }
        imageDownloadDataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data, let image = UIImage(data: data) else { completion(nil); return }
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
                return image
            })
            
            completion(artwork)
        }
        imageDownloadDataTask?.resume()
    }
}
