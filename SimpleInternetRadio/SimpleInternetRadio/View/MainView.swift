//
//  MainView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import SwiftUI

struct MainView: View {
    @State private var searchText = ""
    @State var topVotes: [RadioStation] = []
    @State var searchRadios: [RadioStation] = []
    @StateObject var crrentRadioProgress = ModelManager.shared.crrentRadioProgress
    @StateObject var radioStationsModel: RadioStationsModel = ModelManager.shared.radioStationsModel
    
    var body: some View {
        VStack {
            NavigationStack {
                List {
                    ForEach(searchResults) { radioStation in
                        RadioItemView(radioStationModel: radioStation, crrentRadioProgress: crrentRadioProgress)
                    }
                }
                .listStyle(.inset)
                
            }
            .overlay {
                ProgressView().isHidden(radioStationsModel.mainStations.count > 0)
            }
            .searchable(text: $searchText)
            .onSubmit(of:.search,runSearch)
            
            MiniPlayerView()
        }
    }
    
    var searchResults: [RadioStationModel] {
        if searchText.isEmpty  {
            return radioStationsModel.mainStations
        } else {
           
            return radioStationsModel.searchStations
        }
    }
    
    func runSearch() {
        if searchText.isEmpty {
           return
        }
        radioStationsModel.getSearchStations(searchText: searchText)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
