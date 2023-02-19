//
//  RadioProgress.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import Foundation

class RadioProgress: ObservableObject {
    @Published var radioStation: RadioStation? {
        didSet {
            if radioStation == nil {
                isPlaying = false
            } 
        }
    }
    @Published var isPlaying: Bool = false
}
