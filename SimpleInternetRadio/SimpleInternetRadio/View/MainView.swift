//
//  MainView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import SwiftUI

struct RadioItem: View {
    @StateObject var radioStationModel: RadioStationModel
    @ObservedObject var crrentRadioProgress: RadioProgress
    @State var radioImage:UIImage = UIImage(named: "radio-default")!
    @State var isCacheImage = false
    
    @State var isPlaying = false
    
    var body: some View {
        Button {
            itemClick()
        } label: {
            HStack {
                Image(uiImage:radioImage)
//                AsyncImage(url: URL(string: radio.favicon)) { image in
//                    image.resizable()
//                } placeholder: {
//                    if radio.favicon.isEmpty {
//                        Image(systemName: "dot.radiowaves.left.and.right")
//                            .resizable()
//                            .scaledToFill()
//                    } else {
//                        ProgressView()
//                    }
//                }
                    .resizable()
                .frame(width: 80, height: 80)
                .scaledToFill()
                .cornerRadius(20)
                
                VStack(alignment: .leading) {
                    Text(radioStationModel.radioStation?.name ?? "")
                        .font(.headline)
                    HStack(alignment: .center)  {
                        RadioPlayAnimView(isPlaying: $radioStationModel.isPlaying)
                        Text("\(radioStationModel.radioStation?.tags ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                    }
                }
                .padding(10)
            }
        }
        .task {
            if !isCacheImage {
                cacheImage()
            }
        }
    }
    
    func itemClick() {
        if crrentRadioProgress.radioStationModel != radioStationModel {
            crrentRadioProgress.radioStationModel?.isPlaying = false
            crrentRadioProgress.radioStationModel = radioStationModel
            RadioPlayer.shared.play(name: radioStationModel.radioStation!.name, streamUrl: radioStationModel.radioStation!.urlResolved, showImage: radioImage)
        }
    }
    
    func cacheImage() {
        if isCacheImage {
            return
        }
        
        let favicon = radioStationModel.radioStation?.favicon ?? ""
        if favicon != "" {
            DataManager.shared.fetchImage(url: favicon) { [self] image in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    self.radioImage = image
                }
            }
        }
        
        self.isCacheImage = true
    }
    
}

struct MainView: View {
    @State private var searchText = ""
    @State var topVotes: [RadioStation] = []
    @State var searchRadios: [RadioStation] = []
    @StateObject var crerentRadioProgress = ModelManager.shared.crrentRadioProgress
    @StateObject var radioStationsModel: RadioStationsModel = ModelManager.shared.radioStationsModel
    
    var body: some View {
        VStack(alignment:.center) {
            
            ZStack {
                NavigationStack {
                    List {
                        ForEach(searchResults, id: \.self) { radioStation in
                            RadioItem(radioStationModel: RadioStationModel(radioStation: radioStation), crrentRadioProgress: crerentRadioProgress)
                        }
                    }
                    .listStyle(.inset)
                }
                .searchable(text: $searchText)
                .onSubmit(of:.search,runSearch) 
                
                ProgressView().isHidden(radioStationsModel.mainStations.count > 0)
            }.padding(0)

            MiniPlayerView(crerentRadioProgress: crerentRadioProgress)
        }
    }
    
    var searchResults: [RadioStation] {
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
