//
//  RadioProgress.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import Foundation


class RadioProgress: ObservableObject {
    @Published var radioStationModel:RadioStationModel?
    
    @Published var isPlaying: Bool = false {
        didSet {
            radioStationModel?.isPlaying = isPlaying
        }
    }
    
    @Published var state: PlayerState = .none {
        didSet {
            switch state {
            case .playing:
                isPlaying = true
                break
            case .none,.pause,.stop,.buffering:
                isPlaying = false
                break
            }
        }
    }
}
