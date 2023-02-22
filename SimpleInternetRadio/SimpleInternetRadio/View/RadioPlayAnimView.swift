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
        AnimatedView(images: animFrames, isPlaying: $isPlaying, isReverseColor: isReverseColor, frameWidth: frameWidth, frameHeight: frameHeight)
    }
    
    var animFrames: [UIImage] {
        var animationFrames = [UIImage]()
        for index in 0...3 {
            if let image = UIImage(named: "NowPlayingBars-\(index)") {
                animationFrames.append(image)
            }
        }
      
        for index in stride(from: 2, to: 0, by: -1) {
            if let image = UIImage(named: "NowPlayingBars-\(index)") {
                animationFrames.append(image)
            }
        }
        return animationFrames
    }
}
