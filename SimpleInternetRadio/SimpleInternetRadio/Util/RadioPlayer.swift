//
//  RadioPlayer.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import Foundation
import AVFoundation
import MediaPlayer

enum PlayerState {
    case none, playing, pause, stop, buffering
}

class RadioPlayer : NSObject {
    static let shared = RadioPlayer()
    
    var avPlayer: AVPlayer?
    var state:PlayerState = .none {
        didSet {
            postStateMessage()
        }
    }
    
    var volume : Float = 0.5 {
        didSet {
            avPlayer?.volume = volume
        }
    }
    
    private var periodicTimeObserver:Any?
    
    private var lastName:String = ""
    private var lastShowImage:UIImage?
    private var lastStreamUrl:String = ""
    private var interruptStatus:PlayerState? = nil
    
    private override init() {
        super.init()
        let audioSession = AVAudioSession.sharedInstance()
//        try? audioSession.setCategory(AVAudioSession.Category.playback, options: [.defaultToSpeaker])
//        try? audioSession.setMode(AVAudioSession.Mode.default)
//        try? audioSession.setActive(true)
        try? audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
//        avPlayer = AVPlayer()
//        avPlayer?.allowsExternalPlayback = false
//        avPlayer?.automaticallyWaitsToMinimizeStalling = true
        
//
//        let center = NotificationCenter.default
//        center.addObserver(self, selector:#selector(failedToPlayToEndTime), name: .AVPlayerItemFailedToPlayToEndTime, object: avPlayer?.currentItem)
//        center.addObserver(self, selector:#selector(playbackStalled), name: .AVPlayerItemPlaybackStalled, object: avPlayer?.currentItem)

        let center = NotificationCenter.default
        center.addObserver(
          forName: AVAudioSession.interruptionNotification,
          object: nil,
          queue: .main,
          using: handleAudioSessionInterruptionNotification)
        
        center.addObserver(self, selector: #selector(stationPlayOrPause), name:
                            Notification.Name(MessageDefine.STATION_PLAY_OR_PAUSE), object: nil)
        center.addObserver(self, selector: #selector(stationPlay), name:
                                                Notification.Name(MessageDefine.STATION_PLAY), object: nil)
        
        setupRemoteCommandCenter()
    }
    
    func play(name:String, streamUrl: String, showImage: UIImage? = nil) {
        guard let url = URL(string: streamUrl) else {
            return
        }
        
        stop()
        
        let avPlayerItem = AVPlayerItem.init(url: url)
        if avPlayer?.currentItem == nil {
            avPlayer = AVPlayer.init(playerItem: avPlayerItem)
            avPlayer?.allowsExternalPlayback = false
            avPlayer?.automaticallyWaitsToMinimizeStalling = true
        } else {
            avPlayer?.replaceCurrentItem(with: avPlayerItem)
        }
        
        state = .buffering
        avPlayer?.play()
        addPlayerTimeObserver()
        addPlayerStatusObserver()
        lastName = name
        lastStreamUrl = streamUrl
        lastShowImage = showImage

        print("buffering with url: \(streamUrl)")

        setupNowPlaying(name: name, showImage: showImage)
    }
    
    func stop() {
        if avPlayer != nil {
            removeTimeObserver()
            removePlayerStatusObserver()
            
            avPlayer?.pause()
            avPlayer?.replaceCurrentItem(with: nil)
            avPlayer?.rate = 0
            avPlayer = nil
            
            state = .stop
            print("stopped radio")
        }
    }
    
    func pause() {
        if avPlayer?.currentItem != nil {
            avPlayer?.pause()
            state = .pause
        }
    }
    
    func play() {
        play(name: lastName, streamUrl: lastStreamUrl, showImage: lastShowImage)
    }
    
    func interrupt() {
        if avPlayer?.currentItem == nil {
            return
        }
        
        interruptStatus = state
        avPlayer?.pause()
        state = .buffering
    }
    
    func resume() {
        if avPlayer?.currentItem == nil {
            return
        }
        
        switch interruptStatus {
        case .buffering, .playing:
            play()
            break
        case .pause:
            state = .pause
            break
        default:
            break
        }
        interruptStatus = nil
    }
    
    
    private func togglePlayPause() {
        switch state {
        case .playing:
            pause()
        case .pause:
            play()
        default: break
        }
    }
    
    private func addPlayerTimeObserver() {
        //        avPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
        //        avPlayer?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        periodicTimeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 10, timescale: 10), queue: DispatchQueue.main) {[weak self] time in
            guard let self = self else { return }
            
            let playbackLikelyToKeepUp = self.avPlayer?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false{
                print("Player.rate : \(String(describing: self.avPlayer?.rate))")
            } else {
                print("Buffering completed")
                self.removeTimeObserver()
            }
        }
    }
    
    private func addPlayerStatusObserver() {
        avPlayer?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new, .initial], context: nil)
    }
    
    private func removeTimeObserver() {
        if let periodicTimeObserverObserver = self.periodicTimeObserver {
            self.avPlayer?.removeTimeObserver(periodicTimeObserverObserver)
            self.periodicTimeObserver = nil
        }
    }
    
    private func removePlayerStatusObserver() {
        self.avPlayer?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status))
    }
    
    private func postStateMessage() {
        var message: String = ""
        switch state {
        case .playing:
            message = MessageDefine.RADIOPLAYER_PLAYING
        case .pause:
            message = MessageDefine.RADIOPLAYER_PAUSE
        case .stop:
            message = MessageDefine.RADIOPLAYER_STOP
        case .buffering:
            message = MessageDefine.RADIOPLAYER_BUFFERING
        case .none:
            break
        }
        NotificationCenter.default.post(name: Notification.Name(message), object: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        let newStatus = avPlayer?.currentItem?.status
        
        if newStatus == .readyToPlay {
            print("readyToPlay")
            self.state = .playing
        } else if newStatus == .failed {
            NSLog("Error: \(String(describing: self.avPlayer?.currentItem?.error?.localizedDescription)), error: \(String(describing: self.avPlayer?.currentItem?.error))")
            stop()
        }
    }

    @objc private func failedToPlayToEndTime(_ notification: Notification) {
        let error = notification.userInfo!["AVPlayerItemFailedToPlayToEndTimeErrorKey"]
        print("failedToPlayToEndTime Error: \(String(describing: error))")
        interrupt()
    }
    
    @objc private func playbackStalled(_ notification: Notification) {
        
    }
    
    @objc private func stationPlayOrPause() {
        if state == .playing {
            pause()
        } else if state == .pause ||  state == .stop {
            play()
        }
    }
    
    @objc private func stationPlay(_ notification: Notification) {
        guard let radioStationModel:RadioStationModel = notification.object as? RadioStationModel else {
            return
        }
    
        play(name: radioStationModel.radioStation.name, streamUrl: radioStationModel.radioStation.urlResolved, showImage: radioStationModel.radioImage)
    }
}

extension RadioPlayer {
    fileprivate func setupNowPlaying(name: String, showImage: UIImage? = nil) {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = name
        
        if let image = showImage {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { size -> UIImage in
                return image
            })
        }
        
        
        let playerItem = avPlayer?.currentItem
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem?.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = avPlayer?.rate

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

extension RadioPlayer {
    fileprivate func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
    
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
    
        commandCenter.playCommand.addTarget { [weak self] _ in
          self?.togglePlayPause()
          return .success
        }
    
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
    }
}

extension RadioPlayer {
    fileprivate func handleAudioSessionInterruptionNotification(note: Notification) {
        guard let typeNumber = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber else {return}
        guard let type = AVAudioSession.InterruptionType(rawValue: typeNumber.uintValue) else { return }
        
        switch type {
      
        case .began:
            pause()
      
        case .ended:
            let optionNumber = note.userInfo?[AVAudioSessionInterruptionOptionKey] as? NSNumber
            
            if let number = optionNumber {
                let options = AVAudioSession.InterruptionOptions(rawValue: number.uintValue)
                let shouldResume = options.contains(.shouldResume)
        
                if shouldResume {
                    play()
                }
            }
        @unknown default:
            print("No Implementation")
        }
    }
}
