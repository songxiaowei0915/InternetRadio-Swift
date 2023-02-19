//
//  MainView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import SwiftUI

struct RadioPlayAnimView: View {
    @Environment(\.colorScheme) private var colorScheme
    var isReverseColor: Bool = true
    var frameWidth: CGFloat = 20
    var frameHeight: CGFloat = 20
    @Binding var isPlay:Bool
    
    var body: some View {
        VoiceWaveView(isPlay: $isPlay, isReverseColor: isReverseColor, frameWidth: frameWidth, frameHeight: frameHeight)
    }
    
    func getColor() -> Color {
        if isReverseColor {
            return colorScheme == .light ? .black : .white
        }
        
        return colorScheme == .light ? .white : .black
    }
}

struct RadioItem: View {
    @State var radio: RadioStation
    @ObservedObject var radioProgress: RadioProgress
    @State var isPlay: Bool = false
    @State var radioImage:UIImage = UIImage(named: "radio-default")!
    
    @State var isCacheImage = false
    
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
                    Text(radio.name)
                        .font(.headline)
                    HStack(alignment: .center)  {
                        RadioPlayAnimView(isPlay: $isPlay)
                        Text("\(radio.language) - \(radio.country)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                }
                .padding(10)
                .onChange(of: radioProgress.radioStation) { value in
                    if value == nil || value?.stationuuid != radio.stationuuid {
                        isPlay = false
                    }
                }
            }
        }
        .onAppear {
            cacheImage()
        }
    }
    
    func itemClick() {
        if radioProgress.radioStation?.stationuuid != radio.stationuuid {
            radioProgress.radioStation = radio
            radioProgress.isPlaying = true
            DispatchQueue.main.async {
                RadioPlayer.shared.play(name: radio.name, streamUrl: radio.urlResolved, showImage: radioImage)
            }
            isPlay = true
        }
    }
    
    func cacheImage() {
        if !isCacheImage {
            if !radio.favicon.isEmpty {
                DataManager.shared.fetchImage(url: radio.favicon) { [self] img in
                    DispatchQueue.main.async {
                        self.radioImage = img ?? UIImage(named: "radio-default")!
                    }
                    
                    self.isCacheImage = true
                }
            } else {
                self.isCacheImage = true
            }
        }
    }
    
}

struct RadioPlyaItem: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var radioProgress: RadioProgress
    
    var body: some View {
        GeometryReader { geometry in
            HStack (alignment: .center,spacing: 30){
                ZStack {}

                Image("btn-favorite")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .colorMultiply(colorScheme == .light ? .white : .black)

                RadioPlayAnimView(isReverseColor: false, frameWidth: 30, frameHeight: 30, isPlay: $radioProgress.isPlaying)

                VStack(alignment: .leading) {
                    Text( radioProgress.radioStation?.name ?? "")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(colorScheme == .light ? .white : .black)

                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
        }
        .frame(height: 80)
        .background(colorScheme == .light ? .black : .white)
    }
}

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}

struct MainView: View {
    @State private var searchText = ""
    @State var topVotes: [RadioStation] = []
    @State var searchRadios: [RadioStation] = []
    @StateObject var radioProgress = ModelManager.shared.crrentRadioProgress
    @StateObject var radioStationsModel: RadioStationsModel = ModelManager.shared.radioStationsModel
    
    @State var isShown = false
    
    var body: some View {
        VStack(alignment:.center) {
            
            ZStack {
                NavigationStack {
                    List {
                        ForEach(searchResults, id: \.self) { radio in
                            RadioItem(radio: radio, radioProgress: radioProgress)
                        }
                    }
                    .listStyle(.inset)
                }
                .searchable(text: $searchText)
                .onSubmit(of:.search,runSearch) 
                
                ProgressView().frame(width: 200,height: 200).isHidden(radioStationsModel.mainStations.count > 0)
            }.padding(0)

            RadioPlyaItem(radioProgress: radioProgress)
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
