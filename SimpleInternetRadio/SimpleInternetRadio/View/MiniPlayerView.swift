//
//  MiniPlayView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import SwiftUI

struct BufferingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var appear = false

    var body: some View {
        Circle()
            .trim(from: 0.2, to: 1)
            .stroke(lineWidth: 1)
            .foregroundColor(colorScheme == .light ? .white : .black)
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: appear ? 360 : 0))
            .animation(Animation.linear(duration:1).repeatForever(autoreverses: false), value: appear)
            .onAppear {
                appear = true
            }
    }
}

struct MiniPlayerView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var crrentRadioProgress: RadioProgress
    @StateObject var radioStationsModel: RadioStationsModel = ModelManager.shared.radioStationsModel
    @State var viewHieght:CGFloat = 80
        
    var body: some View {
        GeometryReader { geometry in
            HStack (alignment: .center,spacing: 20){
                Spacer()
                Image(favoriteName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .colorMultiply(colorScheme == .light ? .white : .black)
                    .onTapGesture {
                        favoriteClick()
                    }

                RadioPlayAnimView(isReverseColor: false, frameWidth: 30, frameHeight: 30, isPlaying: $crrentRadioProgress.isPlaying)

                VStack(alignment: .leading) {
                    Text( crrentRadioProgress.radioStationModel?.radioStation.name ?? "Nothing to play")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(colorScheme == .light ? .white : .black)
                    Text(crrentRadioProgress.radioStationModel?.radioStation.tags ?? "Nothing" )
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)

                }.readSize { size in
                    if size.height > 80 {
                        viewHieght = size.height+20
                    } else {
                        viewHieght = 80
                    }
                }
                
                Spacer()
                Image(buttonName)
                    .resizable()
                    .frame(width:buttonFrame, height: buttonFrame)
                    .colorMultiply(colorScheme == .light ? .white : .black)
                    .onTapGesture {
                        playClick()
                    }.overlay {
                        BufferingView()
                            .isHidden(!crrentRadioProgress.isBuffering)
                            .disabled(!crrentRadioProgress.isBuffering)
                            
                    }
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
        }
        .frame(height: viewHieght)
        .background(colorScheme == .light ? .black : .white)
    }
    
    func playClick() {
        if crrentRadioProgress.radioStationModel == nil {
            return
        }
        if RadioPlayer.shared.state == .playing {
            RadioPlayer.shared.pause()
        } else if RadioPlayer.shared.state == .pause {
            RadioPlayer.shared.play()
        }
    }
    
    func favoriteClick() {
        if crrentRadioProgress.radioStationModel == nil {
            return
        }
        
        let stationuuid = crrentRadioProgress.radioStationModel?.radioStation.stationuuid;
        
        guard let uuid = stationuuid else {
            return
        }
        
        if radioStationsModel.isFavorite(uuid) {
            radioStationsModel.removeFavoriteStation(uuid: uuid)
        } else {
            radioStationsModel.addFavoriteStation(uuid)
        }
    }
    
    var buttonName:String {
        if (!crrentRadioProgress.isBuffering && !crrentRadioProgress.isPlaying) || crrentRadioProgress.isBuffering {
            return "but-play"
        } else {
            return crrentRadioProgress.isPlaying ? "never-used" : "never-used-2"
        }
    }
    
    var buttonFrame: CGFloat {
        return crrentRadioProgress.radioStationModel == nil || crrentRadioProgress.isBuffering ? 30 : 50
    }
    
    var favoriteName: String {
        let stationuuid = crrentRadioProgress.radioStationModel?.radioStation.stationuuid;
        
        guard let uuid = stationuuid else {
            return "btn-favorite"
        }
        
        return radioStationsModel.isFavorite(uuid) ? "btn-favoriteFill" : "btn-favorite"
    }
}

struct MiniPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerView(crrentRadioProgress: RadioProgress())
    }
}
