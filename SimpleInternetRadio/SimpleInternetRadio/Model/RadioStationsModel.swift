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
            getHistroyStations()
        }
    }
    @Published  var mainStations: [RadioStationModel] = []
    @Published  var searchMainStations: [RadioStationModel] = []
    
    @Published  var favoriteStations: [RadioStationModel] = []
    @Published  var searchFavoriteStations: [RadioStationModel] = []
    
    @Published  var histroyStations: [RadioStationModel] = []
    @Published  var searchHistroyStations: [RadioStationModel] = []
        
    func getMainStations() {
        let identifier = Locale.current.region!.identifier
        let tempes = stations.filter({$0.radioStation.countrycode == identifier}).sorted(by: { $0.radioStation.votes > $1.radioStation.votes })
        mainStations = getLimitArray(tempes)
    }
    
    func searchStationsForRangs(searchText: String, rangs:[RadioStationModel], completion: @escaping ([RadioStationModel]) -> Void ) {
        let searchText = searchText.trimmingCharacters(in: .whitespaces)
        DispatchQueue.main.async {
            let stations = rangs.filter({ $0.radioStation.name.contains(searchText) || $0.radioStation.country.contains(searchText) || $0.radioStation.language.contains(searchText) || $0.radioStation.tags.contains(searchText) || $0.radioStation.state.contains(searchText)
            }).sorted(by: { $0.radioStation.votes > $1.radioStation.votes })
            
            completion(stations)
        }
    }
    
    func getSearchStations(searchText: String) {
        searchStationsForRangs(searchText: searchText, rangs: stations) { [weak self] values in
            guard let self = self else {return}
            self.searchMainStations = self.getLimitArray(values)
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
    
    func getStationsForUUIDRangs(uuidRangs:[String]) -> [RadioStationModel] {
        let stationuuids = uuidRangs
        
        var results: [RadioStationModel] = []
        for uuid in stationuuids {
            guard let station = stations.filter({$0.radioStation.stationuuid == uuid}).first else {
                continue
            }
            results.append(station)
        }
        return results
    }
    
    func getFavoriteStations() {
        favoriteStations = getStationsForUUIDRangs(uuidRangs:FavoriteManager.shared.uuids)
        for favoriteStation in favoriteStations {
            favoriteStation.isFavorite = true
        }
    }
    
    func addFavoriteStation(uuid: String) {
        guard let station = stations.filter({$0.radioStation.stationuuid == uuid}).first else {
            return
        }
        
        if let _ = favoriteStations.firstIndex(of: station) {
            return
        }
        
        if favoriteStations.count >= STATION_COUNT_LIMIT {
            favoriteStations.removeLast()
        }
        
        station.isFavorite = true
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
        
        favoriteStations[index].isFavorite = false
        favoriteStations.remove(at: index)
        FavoriteManager.shared.remove(uuid)
    }
    
    func removeFavoriteStation(index: Int) {
        if index < favoriteStations.endIndex {
            let uuid = favoriteStations[index].radioStation.stationuuid
            favoriteStations[index].isFavorite = false
            favoriteStations.remove(at: index)
            FavoriteManager.shared.remove(uuid)
        }
    }
    
    func getSearchFavoriteStations(searchText: String) {
        searchStationsForRangs(searchText: searchText, rangs: favoriteStations) { [weak self] values in
            guard let self = self else {return}
            self.searchFavoriteStations = self.getLimitArray(values)
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
    
    func getHistroyStations() {
        histroyStations = getStationsForUUIDRangs(uuidRangs:HistroyManager.shared.uuids)
    }
    
    func addHistroyStation(_ uuid: String) {
        guard let station = stations.filter({$0.radioStation.stationuuid == uuid}).first else {
            return
        }
        
        if let index = histroyStations.firstIndex(of: station) {
            if index == 0 {
                return
            }
            
            histroyStations.remove(at: index)
            
        }
        
        if histroyStations.count >= STATION_COUNT_LIMIT {
            histroyStations.removeLast()
        }
        
        histroyStations.insert(station, at: 0)
        HistroyManager.shared.add(station.radioStation.stationuuid)
    }
    
    func removeHistroyStation(uuid: String) {
        guard let station = stations.filter({$0.radioStation.stationuuid == uuid}).first else {
            return
        }
        
        guard let index = favoriteStations.firstIndex(of: station) else {
            return
        }
        
        histroyStations.remove(at: index)
        HistroyManager.shared.remove(uuid)
    }
    
    func removeHistroyStation(index: Int) {
        if index < histroyStations.endIndex {
            let uuid = histroyStations[index].radioStation.stationuuid
            histroyStations.remove(at: index)
            HistroyManager.shared.remove(uuid)
        }
    }
    
    func getSearchHistroyStations(searchText: String) {
        searchStationsForRangs(searchText: searchText, rangs: histroyStations) { [weak self] values in
            guard let self = self else {return}
            self.searchHistroyStations = self.getLimitArray(values)
        }
    }
}
