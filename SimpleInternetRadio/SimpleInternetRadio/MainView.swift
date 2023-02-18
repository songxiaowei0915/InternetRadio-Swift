//
//  MainView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/16.
//

import SwiftUI

class RadioProgress: ObservableObject {
    @Published var radioStation: RadioStation?
    @Published var isPlaying: Bool = false {
        didSet {
            if radioStation != nil && isPlaying {
                RadioPlayer.shared.playRadio(streamUrl: radioStation!.urlResolved)
            } else {
                RadioPlayer.shared.stopRadio()
            }
        }
    }
    
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

class AnimationImage: ObservableObject {
    private var images:[UIImage] = []
    private var timer: Timer?
    @Published private var index = 0
    private var start = 0
    private var end = 0
    private var defaultIndex = 0
    
    public init(animName:String, start: Int, end: Int, defaultIndex: Int) {
        self.start = start
        self.end = end
        self.defaultIndex = defaultIndex
        images = (start...end).map { UIImage(named: "\(animName)\($0)")! }
        index = defaultIndex
    }
    
    public func currentUIImage() -> UIImage {
        return images[index]
    }
    
    func startAnim() {
        stopAnim()
        index = start
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.index += 1
            if self.index > self.end { self.index = 0 }
        }
    }
    
    func stopAnim() {
        index = defaultIndex
        timer?.invalidate()
    }
}

struct RadioPlayAnimView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State public var uuid: String?
    @ObservedObject var radioProgress: RadioProgress
    @StateObject var animImages = AnimationImage(animName: "NowPlayingBars-", start: 0, end: 3, defaultIndex: 2);
    @State var isReverseColor: Bool = true
    @State var frameWidth: CGFloat = 20
    @State var frameHeight: CGFloat = 20
    
    var body: some View {
        Image(uiImage: animImages.currentUIImage())
            .resizable()
            .frame(width: frameWidth, height: frameHeight)
            .onChange(of: radioProgress.radioStation) { _ in
                if (uuid != nil && radioProgress.radioStation?.stationuuid == uuid) || (uuid == nil && radioProgress.isPlaying) {
                    animImages.startAnim()
                } else {
                    animImages.stopAnim()
                }
            }
            .colorMultiply(getColor())
            .scaledToFill()
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
    @State var uiImage: UIImage = UIImage()
    
    var body: some View {
        Button {
            if radioProgress.radioStation?.stationuuid != radio.stationuuid {
                radioProgress.setValue(radioStation: radio, isPlaying: true)
            } else {
                radioProgress.setValue(radioStation: nil, isPlaying: false)
            }
        } label: {
            HStack {
                AsyncImage(url: URL(string: radio.favicon)) { image in
                    image.resizable()
                } placeholder: {
                    if radio.favicon.isEmpty {
                        Image(systemName: "radio")
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
                
                RadioPlayAnimView(uuid: nil, radioProgress: radioItemProgress, isReverseColor: false, frameWidth: 50, frameHeight: 50)
                
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
            //            .onChange(of: searchText) { _ in
            //                runSearch()
            //            }
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
