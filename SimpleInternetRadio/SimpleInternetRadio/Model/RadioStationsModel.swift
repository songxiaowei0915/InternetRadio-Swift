//
//  RadioStationsModel.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import Foundation
import UIKit

let STATION_COUNT_LIMIT = 10000

class RadioStationsModel : ObservableObject {
    @Published var stations:[RadioStationModel] = [] {
        didSet {
            getMainStations()
            getFavoriteStations()
        }
    }
    @Published var mainStations: [RadioStationModel] = []
    @Published var searchStations: [RadioStationModel] = []
    @Published var favoriteStations: [RadioStationModel] = []
    @Published var searchFavoriteStations: [RadioStationModel] = []
    
    func getMainStations() {
        let identifier = Locale.current.region!.identifier
        let tempes = stations.filter({$0.radioStation.countrycode == identifier}).sorted(by: { $0.radioStation.votes > $1.radioStation.votes })
        mainStations = getLimitArray(tempes)
    }
    
    func getSearchStations(searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespaces)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            let tempes = self.stations.filter({ $0.radioStation.name.contains(searchText) || $0.radioStation.country.contains(searchText) || $0.radioStation.language.contains(searchText) || $0.radioStation.tags.contains(searchText) || $0.radioStation.state.contains(searchText)
            }).sorted(by: { $0.radioStation.votes > $1.radioStation.votes })
            
            self.searchStations = self.getLimitArray(tempes)
        }
    }
    
    private func getLimitArray<T> (_ array: [T]) -> [T] {
        var count = array.count
        if count == 0 {
            return []
        }
        
        if count > STATION_COUNT_LIMIT {
            count = STATION_COUNT_LIMIT
        }
        
        return Array(array[0...count-1])
    }
    
    func getFavoriteStations() {
        let stationuuids = FavoriteManager.shared.stationuuids
        
        var stationsTemp:[RadioStationModel] = []
        for uuid in stationuuids {
            guard let station = stations.filter({$0.radioStation.stationuuid == uuid}).first else {
                continue
            }
            stationsTemp.append(station)
        }
        favoriteStations = stationsTemp
    }
    
    func addFavoriteStation(_ uuid: String) {
        guard let station = stations.filter({$0.radioStation.stationuuid == uuid}).first else {
            return
        }
        
        if let _ = favoriteStations.firstIndex(of: station) {
            return
        }
        
        if favoriteStations.count >= STATION_COUNT_LIMIT {
            favoriteStations.removeLast()
        }
        
        favoriteStations.insert(station, at: 0)
        FavoriteManager.shared.add(station.radioStation.stationuuid)
    }
    
    func removeFavoriteStation(uuid: String) {
        guard let station = stations.filter({$0.radioStation.stationuuid == uuid}).first else {
            return
        }
        
        guard let index = favoriteStations.firstIndex(of: station) else {
            return
        }
        
        favoriteStations.remove(at: index)
        FavoriteManager.shared.remove(uuid)
    }
    
    func removeFavoriteStation(index: Int) {
        if index < favoriteStations.endIndex {
            let uuid = favoriteStations[index].radioStation.stationuuid
            favoriteStations.remove(at: index)
            FavoriteManager.shared.remove(uuid)
        }
    }
    
    func getSearchFavoriteStations(searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespaces)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.searchFavoriteStations = self.favoriteStations.filter({ $0.radioStation.name.contains(searchText) || $0.radioStation.country.contains(searchText) || $0.radioStation.language.contains(searchText) || $0.radioStation.tags.contains(searchText) || $0.radioStation.state.contains(searchText)
            }).sorted(by: { $0.radioStation.votes > $1.radioStation.votes })
        }
    }
    
    func isFavorite(_ uuid: String) ->Bool {
        guard let station = stations.filter({$0.radioStation.stationuuid == uuid}).first else {
            return false
        }
        
        guard let _ = favoriteStations.firstIndex(of: station) else {
            return false
        }
        
        return true
    }
}
