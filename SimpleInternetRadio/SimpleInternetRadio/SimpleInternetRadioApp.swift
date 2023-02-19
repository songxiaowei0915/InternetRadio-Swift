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
            ContentView().onAppear {
                DataManager.shared.getStationList { stations in
                    DispatchQueue.main.async {
                        ModelManager.shared.radioStationsModel.stations = stations
                    }
                }
            }
        }
    }
}
