//
//  FavoriteManager.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/21.
//

import Foundation

class FavoriteManager: DomainManager {
    static let shared = FavoriteManager()
    
    override var saveKey: String {
        return "FavoriteStationCache.SavedData"
    }
    
    override private init() {
        super.init()
    }
}
