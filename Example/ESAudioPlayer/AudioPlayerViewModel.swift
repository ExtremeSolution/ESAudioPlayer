//
//  AudioPlayerViewModel.swift
//  ESAudioPlayer_Example
//
//  Created by Mario Mouris on 14/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ESAudioPlayer

public class AudioPlayerViewModel: ViewModelType {
    
    // MARK: - Input & Output
    public let input: AudioPlayerViewModel.Input
    public let output: AudioPlayerViewModel.Output
    
    public struct Input {
        let playPauseButtonTapped = PublishSubject<()>()
        let nextButtonTapped = PublishSubject<()>()
        let playTrackInIndex = PublishSubject<IndexPath>()
        let previousButtonTapped = PublishSubject<()>()
        let sliderBegin = PublishSubject<()>()
        let sliderEnd = PublishSubject<Float>()
    }
    
    public struct Output {
        let currentTrack: Driver<ESPlayerAudioTrack>
        let state: Driver<AudioPlayerState>
        let nextButtonEnabled: Driver<Bool>
        let currentTimeFormatted: Driver<String>
        let trackDurationFormatted: Driver<String>
        let trackSliderMaxValue: Driver<Float>
        let trackSliderCurrentValue: Driver<Float>
    }
    
    // MARK: - Subjects
    private let modeSubject = BehaviorSubject<ESPlayerMode>(value: .normal)
    private let selectedCoverImageIndexSubject = BehaviorSubject<IndexPath>(value: IndexPath(item: 0, section: 0))
    private let nextButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let currentTimeFormattedSubject = BehaviorSubject<String>(value: "")
    private let trackDurationFormattedSubject = BehaviorSubject<String>(value: "")
    private let trackSliderMaxValueSubject = BehaviorRelay<Float>(value: 0)
    private let trackSliderCurrentValueSubject = BehaviorRelay<Float>(value: 0)
    
    // MARK: - Properties
    private let player: AudioPlayer
    private let mode: ESPlayerMode
    private var isSeeking = false
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    public init(list: [ESPlayerAudioTrack]? = nil,
                track: ESPlayerAudioTrack? = nil,
                mode: ESPlayerMode = .normal) {
        self.mode = mode
        self.player = MainAudioPlayer.shared
        
        // Configure input & output
        input = Input()
        output = Output(currentTrack: player.currentTrack
                            .compactMap { $0 }
                            .asDriver(onErrorRecover: { _ in fatalError() }),
                        state: player.state.asDriver(onErrorRecover: { _ in fatalError() }),
                        nextButtonEnabled: nextButtonEnabledSubject.asDriver(onErrorJustReturn: false),
                        currentTimeFormatted: currentTimeFormattedSubject.asDriver(onErrorJustReturn: ""),
                        trackDurationFormatted: trackDurationFormattedSubject.asDriver(onErrorJustReturn: ""),
                        trackSliderMaxValue: trackSliderMaxValueSubject.asDriver(onErrorJustReturn: 0),
                        trackSliderCurrentValue: trackSliderCurrentValueSubject.asDriver(onErrorJustReturn: 0))
        
        // Subscribe to events
        subscribeToPlayPauseButtonTapped()
        subscribeToNextPreviousButtonTapped()
        subscribeToPlayTrackInIndex()
        subscribeToSliderActions()
        subscribeToNextPreviousButtonStates()
        subscribeToTrackTime()
        
        // Start playing list/track if any is passed
        play(list: list, track: track)
    }
    
    // Public Interface
    public func switchMode(to newMode: ESPlayerMode) {
        guard let oldMode = try? modeSubject.value(), oldMode != newMode else { return }
        modeSubject.onNext(newMode)
    }
    
    public func play(list: [ESPlayerAudioTrack]? = nil, track: ESPlayerAudioTrack? = nil) {
        if let list = list {
            player.play(list: list)
        } else if let track = track {
            player.play(track: track)
        }
    }
    
    // MARK: - Event subscription
    private func subscribeToPlayPauseButtonTapped() {
        input.playPauseButtonTapped.subscribe(onNext: { [unowned self] in
            switch self.player.state.value {
            case .playing:
                self.player.pause()
            default:
                self.player.resume()
            }
        }).disposed(by: disposeBag)
    }
    
    private func subscribeToPlayTrackInIndex() {
        input.playTrackInIndex.subscribe(onNext: { [unowned self] indexPath in
            guard self.player.queue.value.indices.contains(indexPath.item) else { return }
            let track = self.player.queue.value[indexPath.item]
            self.player.play(track: track)
        }).disposed(by: disposeBag)
    }
    
    private func subscribeToNextPreviousButtonTapped() {
        input.nextButtonTapped.subscribe(onNext: { [unowned self] in
            self.player.next()
        }).disposed(by: disposeBag)
        
        input.previousButtonTapped.subscribe(onNext: { [unowned self] in
            self.player.previous()
        }).disposed(by: disposeBag)
    }
    
    private func subscribeToSliderActions() {
        input.sliderBegin.subscribe(onNext: { [unowned self] in self.isSeeking = true }).disposed(by: disposeBag)
        input.sliderEnd.subscribe(onNext: { [unowned self] in
            self.player.seek(to: Double($0))
            self.isSeeking = false
        }).disposed(by: disposeBag)
    }
    
    private func subscribeToNextPreviousButtonStates() {
        Observable.combineLatest(player.currentTrack, player.queue)
            .subscribe(onNext: { [unowned self] track, queue in
                self.nextButtonEnabledSubject.onNext(self.player.nextTrackInQueue != nil)
                if let track = track, let indexForTrackInQueue = queue.firstIndex(of: track) {
                    self.selectedCoverImageIndexSubject.onNext(IndexPath(item: indexForTrackInQueue, section: 0))
                }
            }).disposed(by: disposeBag)
    }
    
    private func subscribeToTrackTime() {
        Observable.combineLatest(player.currentTime, player.trackDuration)
            .subscribe(onNext: { [unowned self] currentTime, trackDuration in
                self.currentTimeFormattedSubject.onNext("\(String(format: "%02d", currentTime.minutes))" +
                    ":" +
                    "\(String(format: "%02d", currentTime.seconds))")
                self.trackDurationFormattedSubject.onNext("\(String(format: "%02d", trackDuration.minutes))" +
                    ":" +
                    "\(String(format: "%02d", trackDuration.seconds))")

                if !self.isSeeking {
                    self.trackSliderMaxValueSubject.accept(Float(convertMinutesAndSecondsToTotalSeconds(
                                                                    minutes: trackDuration.minutes,
                                                                    seconds: trackDuration.seconds)))
                    self.trackSliderCurrentValueSubject.accept(Float(convertMinutesAndSecondsToTotalSeconds(
                                                                        minutes: currentTime.minutes,
                                                                        seconds: currentTime.seconds)))
                }
            }).disposed(by: disposeBag)
    }
}
