//
//  DataManager.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import Foundation
import SwiftUI

class DataManager {
    static let shared = DataManager()
    
    private var stations:[RadioStation] = [] {
        didSet {
            var stationModels:[RadioStationModel] = []
            for station in stations {
                stationModels.append(RadioStationModel(radioStation: station))
            }
            
            DispatchQueue.main.async {
                ModelManager.shared.radioStationsModel.stations = stationModels
            }
        }
    }
    
    var isAlready: Bool {
        return stations.count > 0
    }
            
    private init() {
    }
    
    func loadAllStation() {
        if !stations.isEmpty {
            return
        }
        getStationList { stations in
            self.stations = stations
        }
    }
    
    func getConuntryList(completion: @escaping ([CountryData]) -> Void) {
        NetworkManager.shared.getCountryList(completion: { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let values = try decoder.decode([CountryData].self, from: data)
                    completion(values)
                } catch {
                   print("Get country list is fail!")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getLanguageList(completion: @escaping ([LanguageData]) -> Void) {
        NetworkManager.shared.getLanguageList(completion: { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let values = try decoder.decode([LanguageData].self, from: data)
                    completion(values)
                } catch {
                   print("Get language list is fail!")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getTagList(completion: @escaping ([TagData]) -> Void) {
        NetworkManager.shared.getTagList(completion: { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let values = try decoder.decode([TagData].self, from: data)
                    completion(values)
                } catch {
                   print("Get tag list is fail!")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getStateList(completion: @escaping ([StateData]) -> Void) {
        NetworkManager.shared.getStateList(completion: { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let values = try decoder.decode([StateData].self, from: data)
                    completion(values)
                } catch {
                   print("Get state list is fail!")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getTopVote(rowcount: Int, completion: @escaping ([RadioStation]) -> Void) {
        NetworkManager.shared.getStationsTopvote(completion: {result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let values = try decoder.decode([RadioStation].self, from: data)
                    completion(values)
                } catch {
                   print("Get top vote list is fail!")
                }
            case .failure(let error):
                print(error)
            }
        }, rowcount: rowcount)
    }
    
    func stationsSearch(name: String, completion: @escaping ([RadioStation]) -> Void) {
        let param = "name=\(name)&nameExact=false"
        NetworkManager.shared.stationsSearch(param: param, completion: { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let values = try decoder.decode([RadioStation].self, from: data)
                    completion(values)
                } catch {
                   print("Stations search is fail!")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getStationList(completion: @escaping ([RadioStation]) -> Void) {
        NetworkManager.shared.getStationList(completion: { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let values = try decoder.decode([RadioStation].self, from: data)
                    completion(values)
                } catch {
                   print("Get Station list is fail!")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getStationListByLanguage(language:String, completion: @escaping ([RadioStation]) -> Void) {
        NetworkManager.shared.getStationListByLanguage(language: language, completion: { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let values = try decoder.decode([RadioStation].self, from: data)
                    completion(values)
                } catch {
                   print("Get Station list by Language is fail!")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getStationListByCountryCodeExact(countryCode: String, completion: @escaping ([RadioStation]) -> Void) {
        NetworkManager.shared.getStationListByCountryCodeExact(countryCode: countryCode, completion: { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let values = try decoder.decode([RadioStation].self, from: data)
                    completion(values)
                } catch {
                   print("Get Station list by countrycodeexact is fail!")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func fetchImage(url: String, completion: @escaping (UIImage?) -> Void)  {
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }
        
        let getDataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }
        getDataTask.resume()
    }
}
