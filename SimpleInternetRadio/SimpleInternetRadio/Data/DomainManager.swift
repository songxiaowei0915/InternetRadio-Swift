//
//  DomainManager.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/24.
//

import Foundation

protocol DomainProtocol {
    var saveKey: String { get}
}

class DomainManager: DomainProtocol {
    var saveKey: String {
        return ""
    }
    
    var stationuuids:[String] = []
    
    var uuids: [String] {
        get {
            return stationuuids
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([String].self, from: data) {
                stationuuids = decoded
                return
            }
        }

        stationuuids = []
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(stationuuids) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func add(_ uuid: String) {
        if let _ = stationuuids.firstIndex(of: uuid) {
            return
        }
        stationuuids.insert(uuid, at: 0)
        save()
    }
    
    func remove(_ uuid: String) {
        if let index = stationuuids.firstIndex(of: uuid) {
            stationuuids.remove(at: index)
            save()
        }
    }
}
