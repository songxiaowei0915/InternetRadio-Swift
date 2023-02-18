//
//  RadioPlayer.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import Foundation
import AVFoundation
import MediaPlayer

class RadioPlayer {
    static let shared = RadioPlayer()
    
    var avPlayer: AVPlayer?
    var isRadioPlaying: Bool = false
    
    private init() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
            try session.setCategory(.playback)
        } catch {
            
        }
    }
    
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.avPlayer?.rate == 0.0 {
                self.avPlayer?.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.avPlayer?.rate == 1.0 {
                self.avPlayer?.pause()
                return .success
            }
            return .commandFailed
        }
    }

    func setupNowPlaying(name: String) {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = name

//        if let image = UIImage(named: "lockscreen") {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] =
//                MPMediaItemArtwork(boundsSize: image.size) { size in
//                    return image
//            }
//        }
        let playerItem = avPlayer?.currentItem
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem?.currentTime().seconds
       // nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = avPlayer?.rate

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    
    func playRadio(name:String, streamUrl: String) {
        let url = URL(string: streamUrl)
        avPlayer?.pause()
        let avPlayerItem = AVPlayerItem.init(url: url! as URL)
        if avPlayer?.currentItem == nil {
            avPlayer = AVPlayer.init(playerItem: avPlayerItem)
        } else {
            avPlayer?.replaceCurrentItem(with: avPlayerItem)
        }
        avPlayer?.allowsExternalPlayback = false
        avPlayer?.play()
        
        isRadioPlaying = true
        
        print("playing with url: \(streamUrl)")
        
        setupRemoteTransportControls()
        setupNowPlaying(name: name)
    }
    
    func stopRadio() {
        avPlayer?.pause()
        avPlayer?.rate = 0
        
        isRadioPlaying = false
        
        print("stopped radio")
    }
}
