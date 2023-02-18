//
//  NetworkManager.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/14.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://nl1.api.radio-browser.info/json/"
    
    typealias Completion = (Result<Data, NetworkError>) -> Void
    
    private init() {
    }
    
    func loadDataFromURL(api: String, completion: @escaping Completion, param:String? = nil) {
        guard let url = URL(string: baseURL+api) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                completion(.failure(.badRequest))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
    
    func getCountryList(completion: @escaping Completion, filter: String? = nil, param:String? = nil) {
        var api = "countries"
        if (filter != nil) {
            api += "/\(filter!)"
        }
        if (param != nil) {
            api += "?\(param!)"
        }
        loadDataFromURL(api: api, completion: completion, param: param);
    }
    
    func getStateList(completion: @escaping Completion, country: String? = nil, filter: String? = nil, param:String? = nil) {
        var api = "states"
        if (country != nil) {
            api += "/\(country!)"
        }
        if (filter != nil) {
            api += "/\(filter!)"
        }
        loadDataFromURL(api: api, completion: completion, param: param);
    }
    
    func getLanguageList(completion: @escaping Completion, filter: String? = nil, param:String? = nil) {
        var api = "languages"
        if (filter != nil) {
            api += "/\(filter!)"
        }
        loadDataFromURL(api: api, completion: completion, param: param);
    }
    
    func getTagList(completion: @escaping Completion, filter: String? = nil, param:String? = nil) {
        var api = "tags"
        if (filter != nil) {
            api += "/\(filter!)"
        }
        loadDataFromURL(api: api, completion: completion, param: param);
    }
    
    func getStationList(completion: @escaping Completion, filter: String? = nil, param:String? = nil) {
        var api = "stations"
        if (filter != nil) {
            api += "/\(filter!)"
        }
        loadDataFromURL(api: api, completion: completion, param: param);
    }
    
    func getStationListByUUID(uuid: String, completion: @escaping Completion, param:String? = nil) {
        let filter = "byuuid/\(uuid)"
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func getStationListByName(name: String, completion: @escaping Completion, param:String? = nil) {
        let filter = "byname/\(name)"
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func getStationListByCountryCodeExact(countryCode: String, completion: @escaping Completion, param:String? = nil) {
        let filter = "bycountrycodeexact/\(countryCode)"
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func getStationListByCountry(country: String, completion: @escaping Completion, param:String? = nil) {
        let filter = "bycountry/\(country)"
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func getStationListByState(state: String, completion: @escaping Completion, param:String? = nil) {
        let filter = "bystate/\(state)"
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func getStationListByLanguage(language: String, completion: @escaping Completion, param:String? = nil) {
        let filter = "bylanguage/\(language)"
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func getStationListByTag(tag: String, completion: @escaping Completion, param:String? = nil) {
        let filter = "bytag/\(tag)"
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func getClickList(completion: @escaping Completion, stationuuid: Int? = nil, param:String? = nil) {
        var api = "clicks"
        if (stationuuid != nil) {
            api += "/\(stationuuid!)"
        }
        loadDataFromURL(api: api, completion: completion, param: param);
    }
    
    func stationClick(stationuuid: String, completion: @escaping Completion, param:String? = nil) {
        let api = "url/\(stationuuid)"
        loadDataFromURL(api: api, completion: completion, param: param);
    }
    
    func stationsSearch(param:String, completion: @escaping Completion) {
        let filter = "search"
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func getStationsTopclick(completion: @escaping Completion, rowcount: Int?, param:String? = nil) {
        var filter = "topclick"
        if (rowcount != nil) {
            filter += "/\(rowcount!)"
        }
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func getStationsTopvote(completion: @escaping Completion, rowcount: Int?, param:String? = nil) {
        var filter = "topvote"
        if (rowcount != nil) {
            filter += "/\(rowcount!)"
        }
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func getStationsLastclick(completion: @escaping Completion, rowcount: Int?, param:String? = nil) {
        var filter = "lastclick"
        if (rowcount != nil) {
            filter += "/\(rowcount!)"
        }
        getStationList(completion: completion, filter: filter, param: param)
    }
    
    func stationVote(stationuuid: String, completion: @escaping Completion, param:String? = nil) {
        let api = "vote/\(stationuuid)"
        loadDataFromURL(api: api, completion: completion, param: param);
    }
    
    func getServiceStats(completion: @escaping Completion) {
        let api = "stats"
        loadDataFromURL(api: api, completion: completion);
    }
}
