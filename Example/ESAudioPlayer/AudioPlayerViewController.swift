//
//  AudioPlayerViewController.swift
//  ESAudioPlayer
//
//  Created by Mario Mouris on 12/13/2021.
//  Copyright (c) 2021 Mario Mouris. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AudioPlayerViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistsNamesLabel: UILabel!
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var currentTrackTimeLabel: UILabel!
    @IBOutlet weak var trackDurationLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private let viewModel = AudioPlayerViewModel(
        list: DummyDataGenerator.tracksList,
        mode: .normal
    )
    private let disposeBag = DisposeBag()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToPlayerEvents()
        bindButtonActions()
        bindSliderActions()
    }
    
    private func bindSliderActions() {
        seekSlider.rx.controlEvent(.touchDown)
            .bind(to: viewModel.input.sliderBegin).disposed(by: disposeBag)
        seekSlider.rx.controlEvent(.touchUpInside)
            .compactMap { [unowned self] in self.seekSlider.value }
            .bind(to: viewModel.input.sliderEnd).disposed(by: disposeBag)
        seekSlider.rx.controlEvent(.touchUpOutside)
            .compactMap { [unowned self] in self.seekSlider.value }
            .bind(to: viewModel.input.sliderEnd).disposed(by: disposeBag)
    }
    
    private func bindButtonActions() {
        playPauseButton.rx.tap.bind(to: viewModel.input.playPauseButtonTapped).disposed(by: disposeBag)
        previousButton.rx.tap.bind(to: viewModel.input.previousButtonTapped).disposed(by: disposeBag)
        nextButton.rx.tap.bind(to: viewModel.input.nextButtonTapped).disposed(by: disposeBag)
    }
    
    private func subscribeToPlayerEvents() {
        viewModel.output.currentTrack.drive(onNext: { [unowned self] track in
            self.trackNameLabel.text = track.name
            self.artistsNamesLabel.text = track.combinedArtistsString
            if let url = URL(string: track.imageURL) {
                self.coverImageView.setImage(fromURL: url)
            }
        }).disposed(by: disposeBag)
        
        viewModel.output.state
            .map { $0 == .playing ? UIImage(named: "ic-pause") : UIImage(named: "ic-play") }
            .drive(playPauseButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.output.state
            .map { $0 == .buffering }
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.output.state
            .map { $0 == .buffering ? 0 : 1 }
            .drive(playPauseButton.rx.alpha)
            .disposed(by: disposeBag)

        viewModel.output.currentTimeFormatted.drive(currentTrackTimeLabel.rx.text).disposed(by: disposeBag)
        viewModel.output.trackDurationFormatted.drive(trackDurationLabel.rx.text).disposed(by: disposeBag)
        viewModel.output.trackSliderMaxValue.drive(seekSlider.rx.maximumValue).disposed(by: disposeBag)
        viewModel.output.trackSliderCurrentValue.drive(seekSlider.rx.value).disposed(by: disposeBag)
        viewModel.output.nextButtonEnabled.distinctUntilChanged()
            .drive(nextButton.rx.isEnabled).disposed(by: disposeBag)
    }
}

