//
//  RadioItemView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/21.
//

import SwiftUI

struct RadioItemView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var radioStationModel: RadioStationModel
    @ObservedObject var crrentRadioProgress: RadioProgress
    @State var isCacheImage = false
    @State var isPlaying = false
    @StateObject var radioStationsModel: RadioStationsModel = ModelManager.shared.radioStationsModel
    
    var body: some View {
        HStack {
            Button {
                itemClick()
            } label: {
                HStack {
                    Image(uiImage: radioImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .scaledToFill()
                        .cornerRadius(20)
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(radioStationModel.radioStation.name)
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(alignment: .center)  {
                            RadioPlayAnimView(isPlaying: $radioStationModel.isPlaying)
                            Text("\(radioStationModel.radioStation.tags)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(10)
                }
            }.buttonStyle(.borderless)
            
            Spacer()
            Image(favoriteName)
                .resizable()
                .frame(width: 30, height: 30)
                .colorMultiply(colorScheme == .light ? .black : .white)
                .onTapGesture {
                    favoriteClick()
                }
            
        }.task {
            if !isCacheImage {
                cacheImage()
            }
        }
    }
    
    var radioImage: UIImage {
        return radioStationModel.radioImage != nil ? radioStationModel.radioImage! : UIImage(named: "radio-default")!
    }
    
    var favoriteName: String {
        let uuid = radioStationModel.radioStation.stationuuid
        return radioStationsModel.isFavorite(uuid) ? "btn-favoriteFill" : "btn-favorite"
    }
    
    func favoriteClick() {
        let uuid = radioStationModel.radioStation.stationuuid
        if radioStationsModel.isFavorite(uuid) {
            radioStationsModel.removeFavoriteStation(uuid: uuid)
        } else {
            radioStationsModel.addFavoriteStation(uuid)
        }
    }
    
    func itemClick() {
        if crrentRadioProgress.radioStationModel != radioStationModel {
            crrentRadioProgress.radioStationModel?.isPlaying = false
            crrentRadioProgress.radioStationModel = radioStationModel
            RadioPlayer.shared.play(name: radioStationModel.radioStation.name, streamUrl: radioStationModel.radioStation.urlResolved, showImage: radioImage)
        }
    }
    
    func cacheImage() {
        if isCacheImage {
            return
        }
        
        if radioStationModel.radioImage != nil {
            isCacheImage = true
            return
        }
        
        Task {
            let favicon = radioStationModel.radioStation.favicon
            if favicon != "" {
                DataManager.shared.fetchImage(url: favicon) { [self] image in
                    guard let image = image else { return }
                    DispatchQueue.main.async {
                        radioStationModel.radioImage = image
                    }
                }
            }
        }
        
        self.isCacheImage = true
    }
    
}
