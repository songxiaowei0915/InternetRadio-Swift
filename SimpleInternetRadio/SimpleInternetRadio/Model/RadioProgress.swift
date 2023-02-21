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
            if isPlaying {
                isBuffering = false
            }
        }
    }
    @Published var isBuffering: Bool = false {
        didSet {
            if isBuffering {
                isPlaying = false
            }
        }
    }
}
