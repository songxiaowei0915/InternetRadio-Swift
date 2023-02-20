//
//  RadioStationsModel.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import Foundation
import UIKit

class RadioStationsModel : ObservableObject {
    @Published var stations:[RadioStation] = [] {
        didSet {
            getMainStations()
        }
    }
    @Published var mainStations: [RadioStation] = []
    @Published var searchStations: [RadioStation] = []
    @Published var currentStation: RadioStation? = nil
    
    func getMainStations() {
        let identifier = Locale.current.region!.identifier
        mainStations = stations.filter({$0.countrycode == identifier}).sorted(by: { $0.votes > $1.votes })
    }
    
    func getSearchStations(searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespaces)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.searchStations = self.stations.filter({ $0.name.contains(searchText) || $0.country.contains(searchText) ||
                            $0.language.contains(searchText) ||
                            $0.tags.contains(searchText) ||
                            $0.state.contains(searchText)
            }).sorted(by: { $0.votes > $1.votes })
        }
    }
}
