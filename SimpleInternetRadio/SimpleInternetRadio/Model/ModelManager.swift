//
//  ModelManager.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import Foundation
import SwiftUI

class ModelManager {
    static let shared = ModelManager()
    
    var radioStationsModel: RadioStationsModel = RadioStationsModel()
    var crrentRadioProgress: RadioProgress = RadioProgress()
    
    private init() {
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(radioStop), name:
                                                Notification.Name(MessageDefine.RADIOPLAYER_STOP), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(radioPause), name:
                                                Notification.Name(MessageDefine.RADIOPLAYER_PAUSE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(radioPlaying), name:
                                                Notification.Name(MessageDefine.RADIOPLAYER_PLAYING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(radioBuffering), name:
                                                Notification.Name(MessageDefine.RADIOPLAYER_BUFFERING), object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func radioPause() {
        crrentRadioProgress.isPlaying = false
        crrentRadioProgress.isBuffering = false
    }
    
    @objc private func radioStop() {
        crrentRadioProgress.isPlaying = false
        crrentRadioProgress.isBuffering = false
        crrentRadioProgress.radioStationModel = nil
    }
    
    @objc private func radioPlaying() {
        crrentRadioProgress.isPlaying = true
    }
    
    @objc private func radioBuffering() {
        crrentRadioProgress.isBuffering = true
    }
}
