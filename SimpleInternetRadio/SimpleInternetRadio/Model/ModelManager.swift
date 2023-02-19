//
//  ModelManager.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import Foundation
import SwiftUI

class ModelManager {
    static let shared = ModelManager()
    
    var radioStationsModel: RadioStationsModel = RadioStationsModel()
    var crrentRadioProgress: RadioProgress = RadioProgress()
    
    private init() {
    }
    
    
}
