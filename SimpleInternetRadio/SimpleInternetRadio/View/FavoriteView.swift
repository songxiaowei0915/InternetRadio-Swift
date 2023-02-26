//
//  Favorite.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/21.
//

import SwiftUI

struct FavoriteView: View {
    @State private var searchText = ""
    @StateObject var crrentRadioProgress: RadioProgress = ModelManager.shared.crrentRadioProgress
    @StateObject var radioStationsModel: RadioStationsModel = ModelManager.shared.radioStationsModel
    
    var body: some View {
        VStack {
            NavigationStack {
                List {
                    ForEach(searchResults) { radioStation in
                        RadioItemView(radioStationModel:radioStation, crrentRadioProgress: crrentRadioProgress)
                    }.onDelete(perform: delete)
                }
                .padding(10)
            }
            .listStyle(.inset)
            .overlay {
                ProgressView().isHidden(radioStationsModel.mainStations.count > 0)
            }
            .searchable(text: $searchText, prompt:"Search")
            .onSubmit(of:.search,runSearch)
            
            MiniPlayerView(crrentRadioProgress: crrentRadioProgress)
        }
    }
    
    var searchResults: [RadioStationModel] {
        if searchText.isEmpty  {
            return radioStationsModel.favoriteStations
        } else {
            return radioStationsModel.searchFavoriteStations
        }
    }
    
    func runSearch() {
        if searchText.isEmpty {
           return
        }
        
        radioStationsModel.getSearchFavoriteStations(searchText: searchText)
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets{
            radioStationsModel.removeFavoriteStation(index: index)
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView()
    }
}
