//
//  RadioPlayAnimView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/20.
//

import SwiftUI

struct RadioPlayAnimView: View {
    var isReverseColor: Bool = true
    var frameWidth: CGFloat = 20
    var frameHeight: CGFloat = 20
    @Binding var isPlaying:Bool
    
    var body: some View {
        AnimatedView(imageNames: (0...3).map{"NowPlayingBars-\($0)"}, isPlaying: $isPlaying, isReverseColor: isReverseColor, frameWidth: frameWidth, frameHeight: frameHeight)
    }
}
