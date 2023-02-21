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
    @ObservedObject var crerentRadioProgress: RadioProgress
        
    var body: some View {
        GeometryReader { geometry in
            HStack (alignment: .center,spacing: 30){
                Image("btn-favorite")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .colorMultiply(colorScheme == .light ? .white : .black)

                RadioPlayAnimView(isReverseColor: false, frameWidth: 30, frameHeight: 30, isPlaying: $crerentRadioProgress.isPlaying)

                VStack(alignment: .leading) {
                    Text( crerentRadioProgress.radioStationModel?.radioStation?.name ?? "Nothing to play")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(colorScheme == .light ? .white : .black)
                    Text(crerentRadioProgress.radioStationModel?.radioStation?.tags ?? "Nothing" )
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)

                }
                
                ZStack {
                    Image(buttonName)
                        .resizable()
                        .frame(width:buttonFrame, height: buttonFrame)
                        .colorMultiply(colorScheme == .light ? .white : .black)
                        .onTapGesture {
                            playClick()
                        }
                    
                    BufferingView().isHidden(!crerentRadioProgress.isBuffering)
                }
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
        }
        .frame(height: 80)
        .background(colorScheme == .light ? .black : .white)
    }
    
    func playClick() {
        if RadioPlayer.shared.state == .playing {
            RadioPlayer.shared.pause()
        } else if RadioPlayer.shared.state == .pause {
            RadioPlayer.shared.play()
        }
    }
    
    var buttonName:String {
        if (!crerentRadioProgress.isBuffering && !crerentRadioProgress.isPlaying) || crerentRadioProgress.isBuffering {
            return "but-play"
        } else {
            return crerentRadioProgress.isPlaying ? "never-used" : "never-used-2"
        }
    }
    
    var buttonFrame: CGFloat {
        return crerentRadioProgress.radioStationModel == nil || crerentRadioProgress.isBuffering ? 30 : 50
    }
}

struct MiniPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerView(crerentRadioProgress: RadioProgress())
    }
}
