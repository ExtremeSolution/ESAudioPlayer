#
# Be sure to run `pod lib lint ESAudioPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ESAudioPlayer'
  s.version          = '0.1.1'
  s.summary          = 'A reactive audio player for iOS using RxSwift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
ESAudioPlayer is a reactive audioplayer for iOS using RxSwift. It provides basic audio management features like playing an audio from a URL. And some more advanced features like queue management, MediaPlayer transport controls and now playing center info.
                       DESC

  s.homepage         = 'https://github.com/ExtremeSolution/ESAudioPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mario Mouris' => 'marioamgad9@gmail.com' }
  s.source           = { :git => 'https://github.com/ExtremeSolution/ESAudioPlayer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://extremesolution.com/'

  s.ios.deployment_target = '15.0'
  s.platform = :ios, "13.0"
  s.swift_version = '5.0'

  s.source_files = 'ESAudioPlayer/Classes/**/*'
  s.frameworks = 'AVFoundation'
  s.dependency 'RxSwift', '6.2.0'
  s.dependency 'RxCocoa', '6.2.0'
  
  # s.resource_bundles = {
  #   'ESAudioPlayer' => ['ESAudioPlayer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
