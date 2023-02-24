//
//  HistroyManager.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/24.
//

import Foundation

class HistroyManager: DomainManager {
    static let shared = HistroyManager()
    
    override var saveKey: String {
        return "HistroyStationCache.SavedData"
    }
    
    override private init() {
        super.init()
    }
    
    override func add(_ uuid: String) {
        if let index = stationuuids.firstIndex(of: uuid) {
            stationuuids.remove(at: index)
        }
        stationuuids.insert(uuid, at: 0)
        save()
    }
}
