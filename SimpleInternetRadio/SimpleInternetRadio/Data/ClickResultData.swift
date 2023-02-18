//
//  ClickResult.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import Foundation

struct ClickResultData: Codable {
    let ok: Bool
    let message: String
    let stationuuid: String
    let name: String
    let url: String
}
