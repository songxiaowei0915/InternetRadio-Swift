//
//  MainView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import SwiftUI

class RadioProgress: ObservableObject {
    @Published var radioStation: RadioStation?
    @Published var isPlaying: Bool = false
    
    func setValue(radioStation: RadioStation?, isPlaying: Bool) {
        self.radioStation = radioStation
        self.isPlaying = isPlaying
    }
}

struct RadioPlayView: View {
    var body: some View {
        VStack {
            
        }
       // RadioPlayAnimView()
    }
}



struct VoiceWaveView: View {
    @Binding var isPlay:Bool
    var isReverseColor: Bool = false
    var frameWidth: CGFloat = 30
    var frameHeight: CGFloat = 30
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { timeline in
            subView(isPlaying:$isPlay, frameWidth: frameWidth, frameHeight: frameHeight, isReverseColor: isReverseColor, date: timeline.date)
        }
    }
    
    struct subView: View {
        @Environment(\.colorScheme) private var colorScheme
        @Binding var isPlaying: Bool
        @State private var images:[String] = (0...3).map { String( "NowPlayingBars-\($0)") }
        @State private var index:Int = 2
        var frameWidth: CGFloat
        var frameHeight: CGFloat
        var isReverseColor: Bool
        
        let date: Date
        
        var body: some View {
            Image(images[index])
                .resizable()
                .frame(width: frameWidth, height: frameHeight)
                .colorMultiply(getColor())
                .onChange(of: date) { _ in
                    if (isPlaying) {
                        accumulate()
                    } else {
                        index = 2
                    }
                }
                
        }
        
        func accumulate() -> Void {
            if index+1 > 3 {
                index = 0
            } else {
                index += 1
            }
        }
        
        func getColor() -> Color {
            if isReverseColor {
                return colorScheme == .light ? .black : .white
            }
            
            return colorScheme == .light ? .white : .black
        }
    }
}

struct RadioPlayAnimView: View {
    @Environment(\.colorScheme) private var colorScheme
    public var uuid: String?
    @ObservedObject var radioProgress: RadioProgress
    var isReverseColor: Bool = true
    var frameWidth: CGFloat = 20
    var frameHeight: CGFloat = 20
    @State var isPlay:Bool = false
    
    var body: some View {
        VoiceWaveView(isPlay: $isPlay, isReverseColor: isReverseColor, frameWidth: frameWidth, frameHeight: frameHeight)
            .onChange(of: radioProgress.radioStation) { _ in
                if (uuid != nil && radioProgress.radioStation?.stationuuid == uuid) || (uuid == nil && radioProgress.isPlaying) {
                    isPlay = true
                } else {
                    isPlay = false
                }
            }
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
    
    var body: some View {
        Button {
            if radioProgress.radioStation?.stationuuid != radio.stationuuid {
                radioProgress.setValue(radioStation: radio, isPlaying: true)
                RadioPlayer.shared.playRadio(name: radio.name, streamUrl: radio.urlResolved)
                
            } else {
                radioProgress.setValue(radioStation: nil, isPlaying: false)
                RadioPlayer.shared.stopRadio()
            }
        } label: {
            HStack {
                AsyncImage(url: URL(string: radio.favicon)) { image in
                    image.resizable()
                } placeholder: {
                    if radio.favicon.isEmpty {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .resizable()
                            .scaledToFill()
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 80, height: 80)
                .scaledToFill()
                .cornerRadius(20)
                VStack(alignment: .leading) {
                    Text(radio.name)
                        .font(.headline)
                    HStack(alignment: .center)  {
                        RadioPlayAnimView(uuid: radio.stationuuid, radioProgress: radioProgress)
                        Text("\(radio.language) - \(radio.country)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                }
                .padding(10)
            }
        }
    }
    
}

struct RadioPlyaItem: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var radioProgress: RadioProgress
    @StateObject var radioItemProgress = RadioProgress()
    
    var body: some View {
        GeometryReader { geometry in
            HStack (alignment: .center,spacing: 30){
                ZStack {}
                
                Image("btn-favorite")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .colorMultiply(colorScheme == .light ? .white : .black)
                //VoiceWaveView()
                RadioPlayAnimView(uuid: nil, radioProgress: radioItemProgress, isReverseColor: false, frameWidth: 30, frameHeight: 30)
                
                VStack(alignment: .leading) {
                    Text( radioItemProgress.radioStation?.name ?? "")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(colorScheme == .light ? .white : .black)
                    
                    Text("\(radioItemProgress.radioStation?.language ?? "")  \(radioItemProgress.radioStation?.country ?? "")")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .light ? .white : .black)

                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
        }
        .frame(height: 80)
        .background(colorScheme == .light ? .black : .white)
        .onChange(of: radioProgress.radioStation) { _ in
            radioItemProgress.setValue(radioStation: radioProgress.radioStation, isPlaying: radioProgress.isPlaying)
        }
    }
}

struct MainView: View {
    @State private var searchText = ""
    @State var topVotes: [RadioStation] = []
    @State var searchRadios: [RadioStation] = []
    @StateObject var radioProgress = RadioProgress()
    
    var body: some View {
        VStack(alignment:.center) {
            NavigationStack {
                List {
                    ForEach(searchResults, id: \.self) { radio in
                        RadioItem(radio: radio, radioProgress: radioProgress)
                    }
                }
                .listStyle(.inset)
            }
            .onAppear {
                initTopVotes()
            }
            .searchable(text: $searchText)
            .onSubmit(of:.search,runSearch)
            
            RadioPlyaItem(radioProgress:radioProgress)
        }
    }
    
    var searchResults: [RadioStation] {
        if searchText.isEmpty  {
            return topVotes
        } else {
            return searchRadios
        }
    }
    
    func initTopVotes() {
        if topVotes.isEmpty {
//            DataManager.shared.getTopVote(rowcount: 10) {values in
//                DispatchQueue.main.async {
//                    topVotes = values
//                }
//            }
            DataManager.shared.getStationListByCountryCodeExact(countryCode: Locale.current.region!.identifier, completion: { values in
                DispatchQueue.main.async {
                    topVotes = values
                        .filter{$0.sslError == 0}
                        .sorted(by: { $0.votes > $1.votes })
                    
                }
            })
        }
    }
    
    func runSearch() {
        if searchText.isEmpty {
           return
        }
        let searchText = searchText.trimmingCharacters(in: .whitespaces)
        if DataManager.shared.stations.isEmpty {
            DataManager.shared.stationsSearch(name: searchText, completion: { values in
                DispatchQueue.main.async {
                    searchRadios = values.filter{$0.sslError == 0}
                }
            })
        } else {
            DispatchQueue.main.async {
                searchRadios = DataManager.shared.stations.filter { $0.name.contains(searchText) || $0.country.contains(searchText) ||
                    $0.language.contains(searchText) ||
                    $0.tags.contains(searchText) ||
                    $0.state.contains(searchText)
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
