//
//  MiniPlayView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import SwiftUI

struct MiniPlayerView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var crrentRadioProgress: RadioProgress = ModelManager.shared.crrentRadioProgress
    @StateObject var radioStationsModel: RadioStationsModel = ModelManager.shared.radioStationsModel
    @State var viewHieght:CGFloat = 80
    @State var showSheet:Bool = false
        
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack (alignment: .center,spacing: 20){
                    Image(favoriteName)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .colorMultiply(colorScheme == .light ? .white : .black)
                        .onTapGesture {
                            PlayerViewControl.favoriteClick()
                        }.padding(10)
                    Spacer()
                    Image(buttonName)
                        .resizable()
                        .frame(width:buttonFrame, height: buttonFrame)
                        .colorMultiply(colorScheme == .light ? .white : .black)
                        .onTapGesture {
                            PlayerViewControl.playClick()
                        }.overlay {
                            BufferingView(isReverseColor: false)
                                .isHidden(!crrentRadioProgress.isBuffering)
                                .disabled(!crrentRadioProgress.isBuffering)
                            
                        }.padding(10)
                }
                
                
                HStack {
                    Spacer(minLength: 60)
                    RadioPlayAnimView(isReverseColor: false, frameWidth: 30, frameHeight: 30, isPlaying: $crrentRadioProgress.isPlaying)
                    
                    VStack(alignment: .leading) {
                        Text( crrentRadioProgress.radioStationModel?.radioStation.name ?? "Nothing to play")
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(colorScheme == .light ? .white : .black)
                            .lineLimit(2)
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
                    Spacer(minLength: 60)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
            .onTapGesture {
                showSheet = true
            }
        }
        .frame(height: viewHieght)
        .background(colorScheme == .light ? .black : .white)
        .sheet(isPresented: $showSheet) {
            RadioPlayerView()
        }
    }
    
    var buttonName:String {
        if (crrentRadioProgress.radioStationModel == nil && !crrentRadioProgress.isBuffering && !crrentRadioProgress.isPlaying) || crrentRadioProgress.isBuffering {
            return "but-play"
        } else {
            return crrentRadioProgress.isPlaying ? "never-used" : "never-used-2"
        }
    }
    
    var buttonFrame: CGFloat {
        return crrentRadioProgress.radioStationModel == nil || crrentRadioProgress.isBuffering ? 30 : 50
    }
    
    var favoriteName: String {
        let stationuuid = crrentRadioProgress.radioStationModel?.radioStation.stationuuid
        
        guard let uuid = stationuuid else {
            return "btn-favorite"
        }
        
        return radioStationsModel.isFavorite(uuid) ? "btn-favoriteFill" : "btn-favorite"
    }
}

struct MiniPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerView()
    }
}
