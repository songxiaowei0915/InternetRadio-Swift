//
//  RadioProgress.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import Foundation


class RadioProgress: ObservableObject {
    @Published var radioStationModel:RadioStationModel = RadioStationModel()
    @Published var state: PlayerState = .none {
        didSet {
            switch state {
            case .playing:
                radioStationModel.isPlaying = true
            default:
                radioStationModel.isPlaying = false
            }
        }
    }
}
