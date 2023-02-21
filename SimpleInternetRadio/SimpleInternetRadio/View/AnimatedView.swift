//
//  AnimatedView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import SwiftUI

struct AnimatedView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var imageNames:[String] = (0...3).map { String( "NowPlayingBars-\($0)") }
    @State var imageIndex: Int = 0
    @State var image:Image?
    @State var timer:Timer?
    @Binding var isPlaying:Bool
    var isReverseColor: Bool = false
    var frameWidth: CGFloat = 30
    var frameHeight: CGFloat = 30

    var body: some View {
        ZStack {
            image?
                .resizable()
                .frame(width: frameWidth, height: frameHeight)
                .colorMultiply(getColor())
        }.onAppear {
            if isPlaying {
                startAnimation()
            }
        }.onChange(of: isPlaying) { _ in
            if isPlaying {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }
  
    func startAnimation() {
        if timer != nil {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if imageIndex < imageNames.count {
                image = Image(imageNames[imageIndex])
                imageIndex += 1
            } else {
                imageIndex = 0
            }
        }
      
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stopAnimation() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            
            imageIndex = 0
            image = nil
        }
    }
    
    func getColor() -> Color {
        if isReverseColor {
            return colorScheme == .light ? .black : .white
        }
        
        return colorScheme == .light ? .white : .black
    }
}
