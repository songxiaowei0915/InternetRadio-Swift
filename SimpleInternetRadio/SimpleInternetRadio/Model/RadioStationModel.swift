//
//  RadioStationModel.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/21.
//

import Foundation

class RadioStationModel: ObservableObject, Equatable {
    @Published var radioStation: RadioStation? {
        didSet {
            isPlaying = false
        }
    }
    @Published var isPlaying: Bool = false
    
    init(radioStation: RadioStation? = nil, isPlaying: Bool = false) {
        self.radioStation = radioStation
        self.isPlaying = isPlaying
    }
}

extension RadioStationModel {
    static func == (lhs: RadioStationModel, rhs: RadioStationModel) -> Bool {
        return lhs.radioStation == rhs.radioStation
    }

    static func != (lhs: RadioStationModel, rhs: RadioStationModel) -> Bool {
        return lhs.radioStation != rhs.radioStation
    }
}
