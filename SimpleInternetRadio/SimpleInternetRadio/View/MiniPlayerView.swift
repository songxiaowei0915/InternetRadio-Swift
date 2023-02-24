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
    @State var viewHieght:CGFloat = 80
    @State var showSheet:Bool = false
        
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack (alignment: .center,spacing: 20){
                    Image(PlayerViewControl.favoriteName)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .colorMultiply(colorScheme == .light ? .white : .black)
                        .onTapGesture {
                            PlayerViewControl.favoriteClick()
                        }.padding(10)
                    Spacer()
                    Image(PlayerViewControl.playName)
                        .resizable()
                        .frame(width:buttonFrame, height: buttonFrame)
                        .colorMultiply(colorScheme == .light ? .white : .black)
                        .onTapGesture {
                            PlayerViewControl.playOrPauseClick()
                        }.overlay {
                            BufferingView(isReverseColor: false)
                                .isHidden(crrentRadioProgress.state != .buffering)
                            
                        }.padding(buttonPadding)
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
    
    var buttonFrame: CGFloat {
        return crrentRadioProgress.state == .playing  || crrentRadioProgress.state == .pause ? 50 : 30
    }
    
    var buttonPadding: CGFloat {
        return crrentRadioProgress.state == .playing  || crrentRadioProgress.state == .pause ? 5 : 15
    }
}

struct MiniPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerView()
    }
}
