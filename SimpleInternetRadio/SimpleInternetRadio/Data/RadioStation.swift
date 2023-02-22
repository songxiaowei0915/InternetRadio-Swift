//
//  RadioStation.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import Foundation

struct RadioStation: Codable, Equatable {
    let stationuuid:String
    let name: String
    let url: String
    let urlResolved: String
    let favicon: String
    let votes: Int
    let tags: String
    let language: String
    let languagecodes: String
    let country: String
    let countrycode: String
    let state: String
    let codec: String
    let sslError:Int
    let homepage:String
}

extension RadioStation {
    static func == (lhs: RadioStation, rhs: RadioStation) -> Bool {
        return lhs.stationuuid == rhs.stationuuid
    }
    
    static func != (lhs: RadioStation, rhs: RadioStation) -> Bool {
        return lhs.stationuuid != rhs.stationuuid
    }
}
