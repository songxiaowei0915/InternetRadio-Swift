//
//  RadioStationModel.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/21.
//

import Foundation
import UIKit
import SwiftUI

class RadioStationModel: ObservableObject, Equatable, Identifiable {
    @Published var radioStation: RadioStation {
        didSet {
            isPlaying = false
            isFavorite = false
            radioImage = nil
        }
    }
    @Published var isPlaying: Bool = false
    @Published var isFavorite: Bool =  false
    
    @Published var radioImage:UIImage? = nil
    
    init(radioStation: RadioStation, isPlaying: Bool = false, isFavorite:Bool = false, radioImage: UIImage? = nil) {
        self.radioStation = radioStation
        self.isPlaying = isPlaying
        self.isFavorite = isFavorite
        self.radioImage = radioImage
        
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
