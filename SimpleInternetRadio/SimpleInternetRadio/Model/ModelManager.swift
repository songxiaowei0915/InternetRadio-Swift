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
        NotificationCenter.default.addObserver(self, selector: #selector(stationPlay), name:
                                                Notification.Name(MessageDefine.STATION_PLAY), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stationFavorite), name:
                                                Notification.Name(MessageDefine.STATION_FAVORITE), object: nil)
        
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func radioPause() {
        crrentRadioProgress.state = .pause
    }
    
    @objc private func radioStop() {
        crrentRadioProgress.state = .stop
    }
    
    @objc private func radioPlaying() {
        crrentRadioProgress.state = .playing
        radioStationsModel.addHistroyStation((crrentRadioProgress.radioStationModel?.radioStation.stationuuid)!)
    }
    
    @objc private func radioBuffering() {
        crrentRadioProgress.state = .buffering
    }
    
    @objc private func stationPlay(_ notification: NSNotification) {
        let radioStationModel:RadioStationModel = notification.object as! RadioStationModel
        if crrentRadioProgress.radioStationModel != radioStationModel {
            crrentRadioProgress.isPlaying = false
            crrentRadioProgress.radioStationModel = radioStationModel
        }
    }
    
    @objc private func stationFavorite(_ notification: NSNotification) {
        let stationuuid:String = notification.object as! String
        if radioStationsModel.isFavorite(stationuuid) {
            radioStationsModel.removeFavoriteStation(uuid: stationuuid)
        } else {
            radioStationsModel.addFavoriteStation(stationuuid)
        }
    }
}
