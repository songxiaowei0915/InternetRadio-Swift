//
//  SimpleInternetRadioApp.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/14.
//

import SwiftUI

@main
struct SimpleInternetRadioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().task {
                DataManager.shared.getStationList { stations in
                    DispatchQueue.main.async {
                        var stationModels:[RadioStationModel] = []
                        for station in stations {
                            stationModels.append(RadioStationModel(radioStation: station))
                        }
                        ModelManager.shared.radioStationsModel.stations = stationModels
                    }
                }
            }
        }
    }
}
