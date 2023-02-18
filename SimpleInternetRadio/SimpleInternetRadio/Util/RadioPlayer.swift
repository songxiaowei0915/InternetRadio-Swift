//
//  RadioPlayer.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import Foundation
import AVFoundation

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
    
    func playRadio(streamUrl: String) {
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
    }
    
    func stopRadio() {
        avPlayer?.pause()
        avPlayer?.rate = 0
        
        isRadioPlaying = false
        
        print("stopped radio")
    }
}
