//
//  PlayerViewControl.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/22.
//

import Foundation

class PlayerViewControl {
    class func playOrPauseClick() {
        NotificationCenter.default.post(name: Notification.Name(MessageDefine.STATION_PLAY_OR_PAUSE), object: nil)
    }
    
    class func favoriteClick() {
        let stationuuid = ModelManager.shared.crrentRadioProgress.radioStationModel?.radioStation.stationuuid;
        guard let uuid = stationuuid else {
            return
        }
        
        NotificationCenter.default.post(name: Notification.Name(MessageDefine.STATION_FAVORITE), object: uuid)
    }
    
    class var favoriteName: String {
        let stationuuid = ModelManager.shared.crrentRadioProgress.radioStationModel?.radioStation.stationuuid
        
        guard let uuid = stationuuid else {
            return "btn-favorite"
        }
        
        return ModelManager.shared.radioStationsModel.isFavorite(uuid) ? "btn-favoriteFill" : "btn-favorite"
    }
    
    class var playName:String {
        if ModelManager.shared.crrentRadioProgress.state == .playing {
            return "never-used"
        } else if ModelManager.shared.crrentRadioProgress.state == .pause {
            return "never-used-2"
        } else {
            return "but-play"
        }
    }
}
