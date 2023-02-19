//
//  VoiceWaveView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import SwiftUI

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
