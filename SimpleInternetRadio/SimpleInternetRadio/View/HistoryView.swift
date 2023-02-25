//
//  HistoryView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/23.
//

import SwiftUI

struct HistoryView: View {
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
            
            MiniPlayerView()
        }
    }
    
    var searchResults: [RadioStationModel] {
        if searchText.isEmpty  {
            return radioStationsModel.histroyStations
        } else {
            return radioStationsModel.searchHistroyStations
        }
    }
    
    func runSearch() {
        if searchText.isEmpty {
           return
        }
        
        radioStationsModel.getSearchHistroyStations(searchText: searchText)
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets{
            radioStationsModel.removeHistroyStation(index: index)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
