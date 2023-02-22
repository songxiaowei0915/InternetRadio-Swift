//
//  AnimatedView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import SwiftUI

struct AnimatedView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var images:[UIImage]
    @State var imageIndex: Int = 0
    @State var playImage:Image?
    @State var timer:Timer?
    @Binding var isPlaying:Bool
    @State var defaultIndex:Int = 0
    var isReverseColor: Bool = false
    var frameWidth: CGFloat = 30
    var frameHeight: CGFloat = 30

    var body: some View {
        ZStack {
            playImage?
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
            if imageIndex < images.count {
                playImage = Image(uiImage: images[imageIndex])
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
            
            imageIndex = defaultIndex
            playImage = nil
        }
    }
    
    func getColor() -> Color {
        if isReverseColor {
            return colorScheme == .light ? .black : .white
        }
        
        return colorScheme == .light ? .white : .black
    }
}
