//
//  RadioStationModel.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/21.
//

import Foundation
import UIKit

class RadioStationModel: ObservableObject, Equatable, Hashable {
    @Published var radioStation: RadioStation {
        didSet {
            isPlaying = false
        }
    }
    @Published var isPlaying: Bool = false
    
    @Published var radioImage:UIImage = UIImage(named: "radio-default")!
    
    init(radioStation: RadioStation, isPlaying: Bool = false) {
        self.radioStation = radioStation
        self.isPlaying = isPlaying
    }
    
    func hash(into hasher: inout Hasher) {
        
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
