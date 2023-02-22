//
//  RadioPlayView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import SwiftUI
import WebKit


struct WebView : UIViewRepresentable {
    
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    
}

struct RadioPlayerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) var openURL
    @ObservedObject var crrentRadioProgress: RadioProgress = ModelManager.shared.crrentRadioProgress
    @StateObject var radioStationsModel: RadioStationsModel = ModelManager.shared.radioStationsModel
    
    @State private var speed = RadioPlayer.shared.volume
    
    var body: some View {
        VStack(spacing: 20) {
            Button {
                dismiss()
            } label: {
                Image("btn-close")
            }.padding(20)
            
            Image(uiImage: radioImage)
                .resizable()
                .frame(width: 330, height: 330)
                .scaledToFill()
                .cornerRadius(20)
                .onTapGesture {
                    openHome()
                }
                
            VStack(alignment: .center,spacing: 5) {
                Text( crrentRadioProgress.radioStationModel?.radioStation.name ?? "Nothing to play")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
                    .onTapGesture {
                        openHome()
                    }
                
                Text(crrentRadioProgress.radioStationModel?.radioStation.tags ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                
            }
            
            HStack {
                Button {
                    speed = 0
                } label: {
                    Image("btn-low")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .colorMultiply(colorScheme == .light ? .black : .white)
                        
                }.padding(10)
                
                
                Slider(value: $speed,in: 0...1)
                    .onChange(of: speed ) {_ in
                        RadioPlayer.shared.volume = speed
                    }
                
                Button {
                    speed = 1
                } label: {
                    Image("btn-volume")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .colorMultiply(colorScheme == .light ? .black : .white)
                }.padding(10)
                
            }
            
            ZStack {
                HStack  {
                    Image(favoriteName)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .colorMultiply(colorScheme == .light ? .black : .white)
                        .onTapGesture {
                            PlayerViewControl.favoriteClick()
                        }.padding(10)
                    Spacer()
                    RadioPlayAnimView(frameWidth: 30, frameHeight: 30, isPlaying: $crrentRadioProgress.isPlaying).padding(10)
                }
                
                Image(buttonName)
                    .resizable()
                    .frame(width:buttonFrame, height: buttonFrame)
                    .colorMultiply(colorScheme == .light ? .black : .white)
                    .onTapGesture {
                        PlayerViewControl.playClick()
                    }.overlay {
                        BufferingView()
                            .isHidden(!crrentRadioProgress.isBuffering)
                            .disabled(!crrentRadioProgress.isBuffering)
                            
                    }
            }
            
            Spacer()
        }
    }
    
    var radioImage: UIImage {
        guard let radioStationModel = crrentRadioProgress.radioStationModel else {
            return UIImage(named: "radio-default")!
        }
        return radioStationModel.radioImage != nil ? radioStationModel.radioImage! : UIImage(named: "radio-default")!
    }
    
    var buttonFrame: CGFloat {
        return crrentRadioProgress.radioStationModel == nil || crrentRadioProgress.isBuffering ? 30 : 50
    }
    
    var buttonName:String {
        if (!crrentRadioProgress.isBuffering && !crrentRadioProgress.isPlaying) || crrentRadioProgress.isBuffering {
            return "but-play"
        } else {
            return crrentRadioProgress.isPlaying ? "never-used" : "never-used-2"
        }
    }
    
    var favoriteName: String {
        let stationuuid = crrentRadioProgress.radioStationModel?.radioStation.stationuuid
        
        guard let uuid = stationuuid else {
            return "btn-favorite"
        }
        
        return radioStationsModel.isFavorite(uuid) ? "btn-favoriteFill" : "btn-favorite"
    }
    
    func openHome() {
        guard let home = crrentRadioProgress.radioStationModel?.radioStation.homepage else {
            return
        }
        openURL.callAsFunction(URL(string:home)!)
    }
}

struct RadioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        RadioPlayerView(crrentRadioProgress: RadioProgress())
    }
}
