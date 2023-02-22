//
//  RadioStationModel.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/21.
//

import Foundation
import UIKit

class RadioStationModel: ObservableObject, Equatable, Identifiable {
    @Published var radioStation: RadioStation {
        didSet {
            isPlaying = false
            radioImage = nil
        }
    }
    @Published var isPlaying: Bool = false
    
    @Published var radioImage:UIImage?
    
    init(radioStation: RadioStation, isPlaying: Bool = false) {
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
