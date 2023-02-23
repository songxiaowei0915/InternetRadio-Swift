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
    case initial, playing, pause, stop, buffering
}

class RadioPlayer : NSObject {
    static let shared = RadioPlayer()
    
    var avPlayer: AVPlayer
    var state:PlayerState {
        didSet {
            postStateMessage()
        }
    }
    
    var volume : Float = 0.5 {
        didSet {
            avPlayer.volume = volume
        }
    }
    
    private var observer:Any?
    private var lastName:String = ""
    private var lastShowImage:UIImage?
    private var lastStreamUrl:String = ""
    private var interrupt:Date?

    
    private override init() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSession.Category.playback, options: [.defaultToSpeaker])
        try? audioSession.setMode(AVAudioSession.Mode.default)
        try? audioSession.setActive(true)
        
        avPlayer = AVPlayer()
        avPlayer.allowsExternalPlayback = false
        avPlayer.automaticallyWaitsToMinimizeStalling = true
        state = .initial
        super.init()
        avPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
        avPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        avPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new, .initial], context: nil)

            // Watch notifications
        let center = NotificationCenter.default
        center.addObserver(self, selector:#selector(failedToPlayToEndTime), name: .AVPlayerItemFailedToPlayToEndTime, object: avPlayer.currentItem)
        
        center.addObserver(
          forName: AVAudioSession.interruptionNotification,
          object: nil,
          queue: .main,
          using: handleAudioSessionInterruptionNotification)
        
        setupRemoteCommandCenter()
    }
    

    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        let newStatus = avPlayer.currentItem?.status
        
        if newStatus == .failed {
            NSLog("Error: \(String(describing: self.avPlayer.currentItem?.error?.localizedDescription)), error: \(String(describing: self.avPlayer.currentItem?.error))")
        }
    }

    @objc func failedToPlayToEndTime(_ notification: Notification) {
        let error = notification.userInfo!["AVPlayerItemFailedToPlayToEndTimeErrorKey"]
        print("failedToPlayToEndTime Error: \(String(describing: error))")
        interruptRecord()
    }

    
    func play(name:String, streamUrl: String, showImage: UIImage? = nil) {
        let url = URL(string: streamUrl)
//        if let currentItem = avPlayer.currentItem {
//            if let currentURL = (currentItem.asset as? AVURLAsset)?.url ,
//                currentURL == url {
//                return
//            }
//
//            stop()
//        }
        
        let avPlayerItem = AVPlayerItem.init(url: url! as URL)
        if avPlayer.currentItem == nil {
            avPlayer = AVPlayer.init(playerItem: avPlayerItem)
        } else {
            avPlayer.replaceCurrentItem(with: avPlayerItem)
        }
        
        state = .buffering
        avPlayer.play()
        addPeriodicTimeObserver()
        
        lastName = name
        lastStreamUrl = streamUrl
        lastShowImage = showImage

        print("buffering with url: \(streamUrl)")

        setupNowPlaying(name: name, showImage: showImage)
    }
    
    func stop() {
        avPlayer.pause()
        avPlayer.replaceCurrentItem(with: nil)
        avPlayer.rate = 0
        removePeriodicTimeObserver()
        state = .stop
        
        print("stopped radio")
    }
    
    func pause() {
        if avPlayer.currentItem != nil {
            avPlayer.pause()
            state = .pause
        }
    }
    
    func play() {
        if avPlayer.currentItem != nil {
            avPlayer.play()
            state = .playing
        }
    }
    
    private func interruptRecord() {
        if state == .playing {
            interrupt = Date.now
            avPlayer.pause()
            state = .buffering
        }
    }
    
    public func resumeInterrupt() {
        if avPlayer.currentItem != nil {
            removePeriodicTimeObserver()
            play(name: lastName, streamUrl: lastStreamUrl, showImage: lastShowImage)
        }
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
    
    private func addPeriodicTimeObserver() {
        removePeriodicTimeObserver()
        observer = avPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 10, timescale: 10), queue: DispatchQueue.main) {[weak self] time in
            guard let self = self else { return }
            
            let playbackLikelyToKeepUp = self.avPlayer.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false{
                print("Player.rate : \(self.avPlayer.rate)")
            } else {
                
                
                print("Buffering completed")
                self.removePeriodicTimeObserver()
                self.state = .playing
            }
        }
    }
    
    private func removePeriodicTimeObserver() {
        if let observer = self.observer {
            self.avPlayer.removeTimeObserver(observer)
            self.observer = nil
        }
    }
    
    private func postStateMessage() {
        DispatchQueue.main.async { [self] in
            var message: String = ""
            switch state {
            case .initial:
                message = MessageDefine.RADIOPLAYER_INITIAL
            case .playing:
                message = MessageDefine.RADIOPLAYER_PLAYING
            case .pause:
                message = MessageDefine.RADIOPLAYER_PAUSE
            case .stop:
                message = MessageDefine.RADIOPLAYER_STOP
            case .buffering:
                message = MessageDefine.RADIOPLAYER_BUFFERING
            }
            NotificationCenter.default.post(name: Notification.Name(message), object: nil)
        }
    }
}

extension RadioPlayer {
    fileprivate func setupNowPlaying(name: String, showImage: UIImage? = nil) {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = name
        
        if let image = showImage  {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: CGSize(width: 80, height: 80)) { size in
                return image
            }
        }
        
        let playerItem = avPlayer.currentItem
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem?.currentTime().seconds
       // nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = avPlayer.rate

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
