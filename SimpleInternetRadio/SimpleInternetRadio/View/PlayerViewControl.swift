//
//  PlayerViewControl.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/22.
//

import Foundation

class PlayerViewControl {
    class func playClick() {
        if ModelManager.shared.crrentRadioProgress.radioStationModel == nil {
            return
        }
        if RadioPlayer.shared.state == .playing {
            RadioPlayer.shared.pause()
        } else if RadioPlayer.shared.state == .pause {
            RadioPlayer.shared.play()
        }
    }
    
    class func favoriteClick() {
        if ModelManager.shared.crrentRadioProgress.radioStationModel == nil {
            return
        }
        
        let stationuuid = ModelManager.shared.crrentRadioProgress.radioStationModel?.radioStation.stationuuid;
        
        guard let uuid = stationuuid else {
            return
        }
        
        if ModelManager.shared.radioStationsModel.isFavorite(uuid) {
            ModelManager.shared.radioStationsModel.removeFavoriteStation(uuid: uuid)
        } else {
            ModelManager.shared.radioStationsModel.addFavoriteStation(uuid)
        }
    }
}
