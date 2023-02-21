//
//  RadioItemView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/21.
//

import SwiftUI

struct RadioItemView: View {
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
                    .resizable()
                    .frame(width: 80, height: 80)
                    .scaledToFill()
                    .cornerRadius(20)
                
                VStack(alignment: .leading) {
                    Spacer()
                    Text(radioStationModel.radioStation.name)
                        .font(.headline)
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
        }
        .buttonStyle(.borderless)
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
            RadioPlayer.shared.play(name: radioStationModel.radioStation.name, streamUrl: radioStationModel.radioStation.urlResolved, showImage: radioImage)
        }
    }
    
    func cacheImage() {
        if isCacheImage {
            return
        }
        
        Task {
            let favicon = radioStationModel.radioStation.favicon
            if favicon != "" {
                DataManager.shared.fetchImage(url: favicon) { [self] image in
                    guard let image = image else { return }
                    DispatchQueue.main.async {
                        self.radioImage = image
                    }
                }
            }
        }
        
        self.isCacheImage = true
    }
    
}
