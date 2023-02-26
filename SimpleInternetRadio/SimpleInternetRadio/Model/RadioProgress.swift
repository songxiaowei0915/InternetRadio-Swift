//
//  RadioProgress.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import Foundation


class RadioProgress: ObservableObject {
    @Published var radioStationModel:RadioStationModel? {
        didSet {
            isPlaying = radioStationModel?.isPlaying ?? false
            isFavorite = radioStationModel?.isFavorite ?? false
        }
    }
    
    @Published var isPlaying: Bool = false {
        didSet {
            radioStationModel?.isPlaying = isPlaying
        }
    }
    @Published var isFavorite: Bool =  false {
        didSet {
            radioStationModel?.isFavorite = isFavorite
        }
    }
    
    @Published var state: PlayerState = .none {
        didSet {
            switch state {
            case .playing:
                isPlaying = true
            default:
                isPlaying = false
            }
        }
    }
}
